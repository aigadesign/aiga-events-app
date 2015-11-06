package com.aiga.events.android.loaders;

import java.lang.ref.WeakReference;
import java.util.List;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.LoaderManager;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.Loader;

import com.aiga.events.android.AIGAApplication;
import com.aiga.events.android.utils.Logger;
import com.aiga.events.android.utils.Utils;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.ubermind.http.cache.Data;
import com.ubermind.http.loader.HttpTaskLoader;

public class KeyLoaderCallbacks implements LoaderCallbacks<Data> {

	private static final String TAG = "AIGAKeyLoaderCallbacks";

	public interface OnKeysDownloadedListener {
		public void onKeysDownloaded();
		public void onError();
	}

	private final WeakReference<OnKeysDownloadedListener> mListenerRef;

	protected KeyLoaderCallbacks(OnKeysDownloadedListener listener) {
		mListenerRef = new WeakReference<OnKeysDownloadedListener>(listener);
	}

	private static void startLoader(LoaderManager manager, OnKeysDownloadedListener listener) {
		KeyLoaderCallbacks callback = new KeyLoaderCallbacks(listener);
		Bundle args = new Bundle();
		manager.initLoader(LoaderIds.KEY_LOADER, args, callback);
	}

	public static void restartLoader(LoaderManager manager, OnKeysDownloadedListener listener) {
		AIGAApplication.setETouchesAccessToken(null);
		manager.destroyLoader(LoaderIds.KEY_LOADER);
		startLoader(manager, listener);
	}

	@Override
	public Loader<Data> onCreateLoader(int id, Bundle args) {
		return new KeyLoader(AIGAApplication.getInstance());
	}

	@Override
	public void onLoadFinished(Loader<Data> loader, Data data) {
		OnKeysDownloadedListener listener = mListenerRef.get();

		if (listener != null) {
			listener.onKeysDownloaded();
		}
	}

	@Override
	public void onLoaderReset(Loader<Data> arg0) {
		// intentionally left blank
	}

	/* package */static class KeyLoader extends HttpTaskLoader<Data> {

		protected KeyLoader(Context context) {
			super(context);
		}

		@Override
		protected Data loadDataInBackground() throws Exception {
			Logger.d(TAG, "Loading API keys");
			ParseQuery<ParseObject> query = ParseQuery.getQuery("Keys");
			query.whereExists("Key");
			final SharedPreferences.Editor editor = AIGAApplication.getSharedPreferences().edit();

			List<ParseObject> parseObjects = query.find();

			for (ParseObject response : parseObjects) {
				String name = response.getString("Name");
				String key = response.getString("Key");
				editor.putString(name + Utils.API_KEY_APPEND, key);
			}

			editor.apply();
			return null;
		}

		@Override
		protected Data buildEmptyResult() {
			return null;
		}
	}
}
