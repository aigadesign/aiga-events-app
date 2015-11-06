package com.aiga.events.android.loaders;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.LoaderManager;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.Loader;

import com.aiga.events.android.AIGAApplication;
import com.aiga.events.android.data.Chapter;
import com.aiga.events.android.utils.Logger;
import com.aiga.events.android.utils.Utils;
import com.aiga.events.android.utils.Utils.OnChaptersLoadedListener;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.ubermind.http.loader.HttpTaskLoader;

public class ChapterLoaderCallbacks implements LoaderCallbacks<List<Chapter>> {

	private static final String TAG = "AIGAChapterLoaderCallbacks";

	public interface OnChaptersDownloadedListener {
		public void onChaptersDownloaded(List<Chapter> chapters);
		public void onError(ParseException e);
	}

	private final WeakReference<OnChaptersDownloadedListener> mListenerRef;

	protected ChapterLoaderCallbacks(OnChaptersDownloadedListener listener) {
		mListenerRef = new WeakReference<OnChaptersDownloadedListener>(listener);
	}

	private static void startLoader(LoaderManager manager, OnChaptersDownloadedListener listener) {
		ChapterLoaderCallbacks callback = new ChapterLoaderCallbacks(listener);
		Bundle args = new Bundle();
		manager.initLoader(LoaderIds.CHAPTER_LOADER, args, callback);
	}

	public static void restartLoader(LoaderManager manager, OnChaptersDownloadedListener listener) {
		manager.destroyLoader(LoaderIds.CHAPTER_LOADER);
		startLoader(manager, listener);
	}

	@Override
	public Loader<List<Chapter>> onCreateLoader(int id, Bundle args) {
		return new ChapterLoader(AIGAApplication.getInstance());
	}

	@Override
	public void onLoadFinished(Loader<List<Chapter>> loader, List<Chapter> chapters) {
		Logger.d(TAG, "onLoadFinished");
		OnChaptersDownloadedListener listener = mListenerRef.get();

		if (listener != null) {
			listener.onChaptersDownloaded(chapters);
		}
	}

	@Override
	public void onLoaderReset(Loader<List<Chapter>> arg0) {
		// intentionally left blank
	}

	/* package */static class ChapterLoader extends HttpTaskLoader<List<Chapter>> {

		private List<Chapter> mStoredChapters = new ArrayList<Chapter>();

		protected ChapterLoader(Context context) {
			super(context);
			loadSelectedChapters();
		}

		@Override
		protected List<Chapter> loadDataInBackground() throws Exception {
			Logger.d(TAG, "Downloading chapter list");
			final List<Chapter> chapters = new ArrayList<Chapter>();

			ParseQuery<ParseObject> query = ParseQuery.getQuery("AIGAChapter");
			query.whereExists("City");


			final List<ParseObject> parseObjects = query.find();

			for (ParseObject response : parseObjects) {
				String city = response.getString("City");
				String eventBriteId = response.getString("eventBritesID");
				String eTouchesId = response.getNumber("eTouchesID").toString();
				Chapter chapter = new Chapter(city, eventBriteId, eTouchesId);

				// Do not update state properties in db for
				// chapters that already exist
				if (mStoredChapters.contains(chapter)) {
					Chapter storedChapter = mStoredChapters.get(mStoredChapters.indexOf(chapter));
					chapter.setSelected(storedChapter.isSelected());
					chapter.setEventTimestamp(storedChapter.getEventTimestamp());
				}

				if (chapter.getEventId() != null) {
					chapters.add(chapter);
				}
			}

			if (chapters.size() > 0) {
				Utils.saveChapters(chapters);
			}

			return chapters;
		}

		@Override
		protected List<Chapter> buildEmptyResult() {
			return null;
		}

		private void loadSelectedChapters() {
			Utils.getSelectedChapters(new OnChaptersLoadedListener() {

				@Override
				public void onChaptersLoaded(List<Chapter> storedChapters) {
					Logger.d(TAG, "onChaptersLoaded");
					mStoredChapters = storedChapters;
				}
			});
		}
	}
}