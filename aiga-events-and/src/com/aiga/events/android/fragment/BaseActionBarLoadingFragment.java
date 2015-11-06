package com.aiga.events.android.fragment;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;

import com.aiga.events.android.R;
import com.aiga.events.android.data.Chapter;
import com.aiga.events.android.data.Event;
import com.aiga.events.android.loaders.KeyLoaderCallbacks.OnKeysDownloadedListener;
import com.aiga.events.android.utils.Logger;
import com.aiga.events.android.utils.Utils;

public abstract class BaseActionBarLoadingFragment extends Fragment implements OnKeysDownloadedListener {

	public static final String TAG = "AIGABaseActionBarLoadingFragment";

	protected boolean mIsLoading;
	private Menu mOptionsMenu;

	private final BroadcastReceiver mBroadcastReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			@SuppressWarnings("unchecked")
			Map<Chapter, List<Event>> eventMap = (HashMap<Chapter, List<Event>>) intent.getExtras().get(
					Utils.EVENTS_KEY);

			@SuppressWarnings("unchecked")
			List<Chapter> chapters = (List<Chapter>) intent.getExtras().get(Utils.CHAPTERS_KEY);

			String error = intent.getExtras().getString(Utils.EVENTS_ERROR_KEY);

			if (getView() == null) {
				Logger.d(TAG, "dead fragment receiving broadcast: " + this);
				return;
			}

			if (eventMap != null) {
				handleEventsBroadcast(eventMap);
			}

			if (chapters != null) {
				Logger.d(TAG, "Selected chapters broadcast received");
				handleChapterBroadcast(chapters);
			}

			if (error != null) {
				Logger.d(TAG, "Error received: " + error);
				Chapter chapter = (Chapter) intent.getExtras().getParcelable(Utils.EVENTS_ERROR_CHAPTER_KEY);
				handleErrorBroadcast(chapter, error);
			}
		}
	};

	protected abstract void handleChapterBroadcast(List<Chapter> chapters);

	protected abstract void handleEventsBroadcast(Map<Chapter, List<Event>> eventMap);

	protected void handleErrorBroadcast(Chapter chapter, String error) {
		if (chapter != null) {
			chapter.resetEventTimestamp();
		}
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setHasOptionsMenu(true);
	}

	@Override
	public void onDestroyView() {
		if (mOptionsMenu != null) {
			mOptionsMenu.clear();
		}

		mOptionsMenu = null;
		super.onDestroyView();
	}

	@Override
	public void onResume() {
		super.onResume();
		LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mBroadcastReceiver,
				new IntentFilter(Utils.EVENTS_UPDATED_FLAG));
	}

	@Override
	public void onPause() {
		LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mBroadcastReceiver);
		super.onPause();
	}

	@Override
	public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
		if (getFragmentManager().findFragmentByTag(AboutFragment.FRAGMENT_MANAGER_TAG) == null) {
			mOptionsMenu = menu;
			inflater.inflate(R.menu.refresh, menu);

			if (mIsLoading) {
				setRefreshActionButtonState(true);
			}
		}
		super.onCreateOptionsMenu(menu, inflater);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == R.id.action_refresh) {
			handleRefreshRequested();
			return true;
		}

		return super.onOptionsItemSelected(item);
	}

	protected void handleRefreshRequested() {
		showProgress(true);
	}

	protected void showProgress(boolean show) {
		setRefreshActionButtonState(show);
		mIsLoading = show;
	}

	protected void setRefreshActionButtonState(final boolean refreshing) {
		if (mOptionsMenu != null) {
			final MenuItem refreshItem = mOptionsMenu.findItem(R.id.action_refresh);

			if (refreshItem != null) {
				if (refreshing) {
					refreshItem.setActionView(R.layout.actionbar_progress);
				} else {
					refreshItem.setActionView(null);
				}
			}
		}
	}

	@Override
	public void onKeysDownloaded() {
		handleRefreshRequested();
	}

	@Override
	public void onError() {
		handleErrorBroadcast(null, "Unknown error");
	}
}