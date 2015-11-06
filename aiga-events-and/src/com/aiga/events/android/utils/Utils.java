package com.aiga.events.android.utils;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.AsyncTask;
import android.support.v4.app.FragmentActivity;
import android.support.v4.content.LocalBroadcastManager;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;

import com.aiga.events.android.AIGAApplication;
import com.aiga.events.android.R;
import com.aiga.events.android.data.AigaDataSource;
import com.aiga.events.android.data.Chapter;
import com.aiga.events.android.data.Event;
import com.aiga.events.android.data.EventDetails;
import com.aiga.events.android.loaders.EventsLoaderCallbacks;

public class Utils {

	private static final String TAG = "AIGAUtils";

	public static final String FIRST_LAUNCH_TAG = "firstLaunch";
	public static final String DATE_FORMAT = "yyyy-MM-dd HH:mm:ss";
	public static final String EVENTS_KEY = "events broadcast key";
	public static final String EVENTS_ERROR_KEY = "events broadcast error key";
	public static final String EVENTS_ERROR_CHAPTER_KEY = "events broadcast error chapter key";
	public static final String CHAPTERS_KEY = "chapters broadcast key";
	public static final String API_KEY_APPEND = "_key";
	public static final String EVENTS_UPDATED_FLAG = "eventsUpdated";
	public static final String VERSION_TAG = "appVersion";
	
	public interface OnChaptersLoadedListener {
		public void onChaptersLoaded(List<Chapter> chapters);
	}

	public interface OnEventsLoadedForChaptersListener {
		public void onEventsLoaded(Map<Chapter, List<Event>> eventMap);
	}

	public interface OnEventsLoadedForChapterListener {
		public void onEventsLoaded(List<Event> events);
	}

	public static void getChapters(final boolean selectedOnly, final OnChaptersLoadedListener listener) {
		final WeakReference<OnChaptersLoadedListener> mListenerRef = new WeakReference<OnChaptersLoadedListener>(
				listener);

		new AsyncTask<Void, Void, List<Chapter>>() {
			@Override
			protected List<Chapter> doInBackground(Void... params) {
				AigaDataSource datasource = new AigaDataSource(AIGAApplication.getInstance());
				datasource.open();
				List<Chapter> chapters = datasource.getChapters(selectedOnly);
				datasource.close();
				return chapters;
			}

			@Override
			protected void onPostExecute(List<Chapter> chapters) {
				OnChaptersLoadedListener listener = mListenerRef.get();

				if (listener != null) {
					listener.onChaptersLoaded(chapters);
				}
			}
		}.execute();
	}

	public static void getAllChapters(OnChaptersLoadedListener listener) {
		getChapters(false, listener);
	}

	public static void getSelectedChapters(OnChaptersLoadedListener listener) {
		getChapters(true, listener);
	}

	public static void saveChapters(final List<Chapter> chapters) {
		Logger.d(TAG, "saving chapters to db");

		new AsyncTask<Void, Void, Void>() {
			@Override
			protected Void doInBackground(Void... params) {
				AigaDataSource datasource = new AigaDataSource(AIGAApplication.getInstance());
				datasource.open();

				for (Chapter chapter : chapters) {
					datasource.updateChapter(chapter);
				}

				datasource.close();
				return null;
			}
		}.execute();

	}

	public static void saveChapter(Chapter chapter) {
		Logger.d(TAG, "saving chapter: " + chapter.getChapterName());
		List<Chapter> chapters = new ArrayList<Chapter>();
		chapters.add(chapter);
		saveChapters(chapters);
	}

	public static void saveEvents(final Chapter chapter, final List<Event> events) {
		Logger.d(TAG, "Saving events for chapter: " + chapter.getChapterName());

		new AsyncTask<Void, Void, Void>() {
			@Override
			protected Void doInBackground(Void... params) {

				AigaDataSource datasource = new AigaDataSource(AIGAApplication.getInstance());
				datasource.open();

				datasource.deleteEventsForChapter(chapter);

				if (events != null) {
					for (Event event : events) {
						datasource.updateEvent(chapter, event);
					}
				}

				datasource.close();
				return null;
			}

			@Override
			protected void onPostExecute(Void result) {
				Map<Chapter, List<Event>> eventMap = new HashMap<Chapter, List<Event>>();
				eventMap.put(chapter, events);
				notifyEventsChanged(eventMap);
				chapter.setEventTimestampToCurrentTime();
				saveChapter(chapter);
			}
		}.execute();
	}

	public static void notifyEventsChanged(Map<Chapter, List<Event>> eventMap) {
		if (eventMap != null) {
			Logger.d(TAG, "Broadcast events changed");
		} else {
			Logger.d(TAG, "Something went wrong; event map is empty");
		}

		Intent intent = new Intent(EVENTS_UPDATED_FLAG);
		HashMap<Chapter, List<Event>> eventHashMap = new HashMap<Chapter, List<Event>>(eventMap);
		intent.putExtra(EVENTS_KEY, eventHashMap);
		LocalBroadcastManager.getInstance(AIGAApplication.getInstance()).sendBroadcast(intent);
	}

	public static void notifyEventsError(String error) {
		notifyEventsError(null, error);
	}

	public static void notifyEventsError(Chapter chapter, String error) {
		Logger.d(TAG, "Error downloading events, notifying\nerror = " + error);
		Intent intent = new Intent(EVENTS_UPDATED_FLAG);
		intent.putExtra(EVENTS_ERROR_KEY, error);

		if (chapter != null) {
			intent.putExtra(EVENTS_ERROR_CHAPTER_KEY, chapter);
		}

		LocalBroadcastManager.getInstance(AIGAApplication.getInstance()).sendBroadcast(intent);
	}

	public static void notifySelectedChaptersChanged(List<Chapter> chapters) {
		if (chapters != null) {
			Logger.d(TAG, "Broadcast chapters changed");
		} else {
			Logger.d(TAG, "Chapters updated but something went wrong");
		}

		Intent intent = new Intent(EVENTS_UPDATED_FLAG);
		ArrayList<Chapter> chaptersArray = new ArrayList<Chapter>(chapters);
		intent.putExtra(CHAPTERS_KEY, chaptersArray);
		LocalBroadcastManager.getInstance(AIGAApplication.getInstance()).sendBroadcast(intent);
	}

	public static void getEventsForChapter(final Chapter chapter, OnEventsLoadedForChapterListener listener) {
		final WeakReference<OnEventsLoadedForChapterListener> mListenerRef = new WeakReference<OnEventsLoadedForChapterListener>(
				listener);

		new AsyncTask<Void, Void, List<Event>>() {
			@Override
			protected List<Event> doInBackground(Void... params) {
				AigaDataSource datasource = new AigaDataSource(AIGAApplication.getInstance());
				datasource.open();
				List<Event> events = datasource.getEventsForChapter(chapter);
				datasource.close();
				return events;
			}

			@Override
			protected void onPostExecute(List<Event> events) {
				OnEventsLoadedForChapterListener listener = mListenerRef.get();

				if (listener != null) {
					listener.onEventsLoaded(events);
				}
			}
		}.execute();
	}

	public static void getEventsForChapters(final List<Chapter> chapters, final Date startDate, final Date endDate,
			OnEventsLoadedForChaptersListener listener) {

		final WeakReference<OnEventsLoadedForChaptersListener> mListenerRef = new WeakReference<OnEventsLoadedForChaptersListener>(
				listener);

		new AsyncTask<Void, Void, Map<Chapter, List<Event>>>() {
			@Override
			protected Map<Chapter, List<Event>> doInBackground(Void... params) {
				AigaDataSource datasource = new AigaDataSource(AIGAApplication.getInstance());
				datasource.open();
				Map<Chapter, List<Event>> eventMap = datasource.getEventsForChapters(chapters, startDate, endDate);
				datasource.close();
				return eventMap;
			}

			@Override
			protected void onPostExecute(Map<Chapter, List<Event>> eventMap) {
				OnEventsLoadedForChaptersListener listener = mListenerRef.get();

				if (listener != null) {
					listener.onEventsLoaded(eventMap);
				}
			}
		}.execute();
	}

	public static void downloadEventsForChapter(FragmentActivity activity, Chapter chapter) {
		Logger.d(TAG, "Downloading events for chapter: " + chapter.getChapterName());
		EventsLoaderCallbacks.restartLoader(activity.getSupportLoaderManager(), chapter);
	}

	public static void crossfade(final View fadeView, View showView) {
		showView.setVisibility(View.VISIBLE);
		Context context = AIGAApplication.getInstance();
		Animation fadeIn = AnimationUtils.loadAnimation(context, R.anim.fade_in);
		Animation fadeOut = AnimationUtils.loadAnimation(context, R.anim.fade_out);
		fadeView.startAnimation(fadeOut);
		showView.startAnimation(fadeIn);
		fadeView.setVisibility(View.GONE);
	}

	// Copied from the timessquare library to mirror their implementation of
	// date ranges
	public static void setMidnight(Calendar cal) {
		cal.set(Calendar.HOUR_OF_DAY, 0);
		cal.set(Calendar.MINUTE, 0);
		cal.set(Calendar.SECOND, 0);
		cal.set(Calendar.MILLISECOND, 0);
	}

	// Creating this as a convenience method because the Calendar implementation
	// is not as expected
	public static void incrementMonth(Calendar cal) {
		cal.roll(Calendar.MONTH, true);

		if (cal.get(Calendar.MONTH) == 0) {
			cal.roll(Calendar.YEAR, true);
		}
	}

	public static void incrementDay(Calendar cal) {
		cal.roll(Calendar.DATE, true);

		if (cal.get(Calendar.DATE) == 1) {
			cal.roll(Calendar.MONTH, true);
			if (cal.get(Calendar.MONTH) == 0) {
				cal.roll(Calendar.YEAR, true);
			}
		}
	}

	public static boolean isFirstLaunch() {
		SharedPreferences prefs = AIGAApplication.getSharedPreferences();
		return prefs.getBoolean(FIRST_LAUNCH_TAG, true);
	}

	public static boolean isUpgrade(Activity activity) {
		SharedPreferences prefs = AIGAApplication.getSharedPreferences();
		int savedVersion = prefs.getInt(VERSION_TAG, -1);
		int currentVersion = 0;
		try {
			currentVersion = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0).versionCode;
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}
		return (savedVersion != currentVersion);
	}
	
	public static class EventDateComparator implements Comparator<Event> {
		@Override
		public int compare(Event event1, Event event2) {
			EventDetails details1 = event1.getEventDetails();
			EventDetails details2 = event2.getEventDetails();
			return details1.getStartDate().compareTo(details2.getStartDate());
		}
	}
}