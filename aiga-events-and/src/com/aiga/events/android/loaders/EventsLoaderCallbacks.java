package com.aiga.events.android.loaders;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.v4.app.LoaderManager;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.Loader;

import com.aiga.events.android.AIGAApplication;
import com.aiga.events.android.data.Chapter;
import com.aiga.events.android.data.Event;
import com.aiga.events.android.utils.JSONUtils;
import com.aiga.events.android.utils.Logger;
import com.aiga.events.android.utils.URLUtils;
import com.aiga.events.android.utils.Utils;
import com.ubermind.http.converter.BitmapConverter;
import com.ubermind.http.converter.JSONObjectConverter;
import com.ubermind.http.converter.TextConverter;
import com.ubermind.http.loader.HttpTaskLoader;
import com.ubermind.http.request.HttpGetRequest;
import com.ubermind.http.request.HttpGetRequestBuilder;
import com.ubermind.http.task.HttpGetTask;

public class EventsLoaderCallbacks implements LoaderCallbacks<Map<Chapter, List<Event>>> {

	private static final String TAG = "AIGAEventsLoaderCallbacks";
	private static final String CHAPTER_ARG = "chapterArg";
	private static final String ETOUCHES_PARSE_NAME = "etouches";
	private static final String ETOUCHES_AUTH_URL = "https://www.eiseverywhere.com/api/v2/global/authorize.json?accountid=2824&key=";

	private static void startLoader(LoaderManager manager, Chapter chapter, int loaderId) {
		EventsLoaderCallbacks callback = new EventsLoaderCallbacks();
		Bundle args = new Bundle();
		args.putParcelable(CHAPTER_ARG, chapter);
		manager.initLoader(loaderId, args, callback);
	}

	public static void restartLoader(LoaderManager manager, Chapter chapter) {
		int loaderId = chapter.getEventLoaderId();
		Logger.d(TAG, "Restarting loader with id: " + loaderId);
		manager.destroyLoader(loaderId);
		startLoader(manager, chapter, loaderId);
	}

	@Override
	public Loader<Map<Chapter, List<Event>>> onCreateLoader(int id, Bundle args) {
		Chapter chapter = args.getParcelable(CHAPTER_ARG);
		return new EventsLoader(AIGAApplication.getInstance(), chapter);
	}

	@Override
	public void onLoadFinished(Loader<Map<Chapter, List<Event>>> loader, Map<Chapter, List<Event>> eventMap) {
		Chapter chapter = new Chapter();
		List<Event> events = new ArrayList<Event>();

		if (eventMap != null && eventMap.keySet().iterator().hasNext()) {
			chapter = eventMap.keySet().iterator().next();
			events = eventMap.values().iterator().next();
			Utils.saveEvents(chapter, events);

			if (events != null) {
				for (Event event : events) {
					prefetchDetailsImage(event);
				}
			}
		} else {
			Utils.notifyEventsError("Event map is empty");
		}
	}

	private static void prefetchDetailsImage(Event event) {
		if (event != null && event.getEventDetails() != null) {
			String url = event.getEventDetails().getLogoUrl();
			Logger.d(TAG, "Prefetching image at url: " + url);

			HttpGetTask<Void, Bitmap> task = new HttpGetTask<Void, Bitmap>(AIGAApplication.getInstance(), url,
					BitmapConverter.instance);
			task.execute();
		}
	}

	@Override
	public void onLoaderReset(Loader<Map<Chapter, List<Event>>> arg0) {
		// intentionally left blank
	}

	/* package */static class EventsLoader extends HttpTaskLoader<Map<Chapter, List<Event>>> {

		private static final int MAX_AUTH_RETRIES = 3;
		private int mRetryCount = 0;
		private final Chapter mChapter;

		protected EventsLoader(Context context, Chapter chapter) {
			super(context);
			this.mChapter = chapter;
		}

		@Override
		protected Map<Chapter, List<Event>> loadDataInBackground() throws Exception {
			// eventId must be a numeric for eTouches chapters
			// and chapter name for eventbrite chapters
			String eventBriteId = mChapter.getEventBriteId();
			String etouchesId = mChapter.getETouchesId();
			List<Event> events = new ArrayList<Event>();

			if (mChapter.isEventBriteChapter()) {
				List<Event> eventBriteEvents = getEventBriteEvents(eventBriteId);

				if (eventBriteEvents != null) {
					events.addAll(eventBriteEvents);
				}
			}

			if (mChapter.isETouchesChapter()) {
				List<Event> etouchesEvents = getETouchesEvents(etouchesId);

				if (etouchesEvents != null) {
					events.addAll(etouchesEvents);
				}
			}

			Map<Chapter, List<Event>> eventMap = new HashMap<Chapter, List<Event>>();
			eventMap.put(mChapter, events);
			return eventMap;
		}

		private List<Event> getEventBriteEvents(String id) throws Exception {
			String urlString = URLUtils.buildEventBriteUrlString(id);
			Logger.d(TAG, "Loading eventbrite events at url: " + urlString);

			HttpGetRequest<String> request = HttpGetRequestBuilder.getRequestBuilder().buildRequest(getContext(),
					urlString, TextConverter.instance);
			String result = request.fetchResult();

			return JSONUtils.parseEventBriteEvents(mChapter, result);
		}

		private List<Event> getETouchesEvents(String id) throws Exception {
			String urlString = URLUtils.buildETouchesUrlString(id, getAuthToken(false));

			Logger.d(TAG, "Loading etouches events at url: " + urlString);

			HttpGetRequest<String> request = HttpGetRequestBuilder.getRequestBuilder().buildRequest(getContext(),
					urlString, TextConverter.instance);
			String result = request.fetchResult();

			return parseETouchesResult(mChapter, result);
		}

		private List<Event> parseETouchesResult(Chapter chapter, String result) {
			try {
				List<Event> eventList = new ArrayList<Event>();
				List<String> eventIds = JSONUtils.getEventIds(result);

				for (String eventId : eventIds) {
					Event event = getETouchesEvent(eventId);

					if (event != null) {
						eventList.add(event);
					}
				}

				return eventList;
			} catch (JSONException e) {
				try {
					if (JSONUtils.hasAuthError(result)) {
						mRetryCount++;
						if (mRetryCount < MAX_AUTH_RETRIES) {
							Logger.d(TAG, "Auth token expired, requesting new auth token attempt: " + mRetryCount);
							getAuthToken(true);
							loadDataInBackground();
						} else {
							Logger.d(TAG, "Failed to get auth token after: " + mRetryCount + " attempts.");
							throw new Exception();
						}
					}

				} catch (Exception e2) {
					Utils.notifyEventsError(chapter, e2.toString());
					Logger.d(TAG, "Error retrieving events: " + e2);
				}
			}

			return null;
		}

		private Event getETouchesEvent(String eventId) {
			String authToken = getAuthToken(false);

			String urlString = URLUtils.buildETouchesEventUrlString(authToken, eventId);
			Logger.d(TAG, "Loading event at url: " + urlString);

			HttpGetRequest<JSONObject> request = HttpGetRequestBuilder.getRequestBuilder().buildRequest(getContext(),
					urlString, JSONObjectConverter.instance);

			JSONObject result = request.fetchResult();
			return JSONUtils.parseETouchesEvent(result);
		}

		private String getAuthToken(boolean forceRefresh) {
			String authToken = AIGAApplication.getETouchesAccessToken();

			if (authToken == null || forceRefresh) {
				authToken = refreshAuthToken();
				AIGAApplication.setETouchesAccessToken(authToken);
			}

			return authToken;
		}

		private String refreshAuthToken() {
			StringBuilder url = new StringBuilder();
			url.append(ETOUCHES_AUTH_URL);
			url.append(URLUtils.getApiKey(ETOUCHES_PARSE_NAME));
			String urlString = url.toString();

			Logger.d(TAG, "Requesting auth token at url: " + urlString);

			HttpGetRequest<JSONObject> request = HttpGetRequestBuilder.getRequestBuilder().buildRequest(getContext(),
					urlString, JSONObjectConverter.instance);

			String response = JSONUtils.parseAuthResult(request.fetchResult());

			if (response == null) {
				Utils.notifyEventsError(mChapter, "auth loader failed");
			}

			return response;
		}

		@Override
		protected Map<Chapter, List<Event>> buildEmptyResult() {
			return null;
		}
	}
}