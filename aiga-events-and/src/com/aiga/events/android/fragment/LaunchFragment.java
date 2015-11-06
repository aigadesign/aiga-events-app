package com.aiga.events.android.fragment;

import java.util.List;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.aiga.events.android.INavigationListener;
import com.aiga.events.android.R;
import com.aiga.events.android.data.Chapter;
import com.aiga.events.android.loaders.ChapterLoaderCallbacks;
import com.aiga.events.android.loaders.ChapterLoaderCallbacks.OnChaptersDownloadedListener;
import com.aiga.events.android.loaders.KeyLoaderCallbacks;
import com.aiga.events.android.loaders.KeyLoaderCallbacks.OnKeysDownloadedListener;
import com.aiga.events.android.utils.Logger;
import com.parse.ParseException;

public class LaunchFragment extends Fragment implements OnChaptersDownloadedListener, OnKeysDownloadedListener {

	private static final String TAG = "AIGALaunchFragment";

	private int mLoadCount;
	private LinearLayout mLoadingView;
	private ProgressBar mProgressBar;
	private TextView mGetStarted;
	private boolean mHasErrors;
	private INavigationListener mNavListener;

	@Override
	public void onAttach(Activity activity) {
		super.onAttach(activity);
		mNavListener = (INavigationListener) activity;
	}

	@Override
	public void onDetach() {
		mNavListener = null;
		super.onDetach();
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		View v = inflater.inflate(R.layout.message_first_launch_layout, null);
		mLoadingView = (LinearLayout) v.findViewById(R.id.first_launch_loading);
		mProgressBar = (ProgressBar) v.findViewById(R.id.first_launch_progress);
		mGetStarted = (TextView) v.findViewById(R.id.message_first_launch_button);

		mGetStarted.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				if (mHasErrors) {
					mHasErrors = false;
					startLoaders();
				} else {
					mNavListener.exitLaunchFragment();
				}
			}
		});

		return v;
	}

	@Override
	public void onDestroyView() {
		mLoadingView = null;
		mProgressBar = null;
		mGetStarted = null;
		super.onDestroyView();
	}

	@Override
	public void onViewCreated(View view, Bundle savedInstanceState) {
		super.onViewCreated(view, savedInstanceState);
		startLoaders();
	}

	private void showProgress(boolean show) {
		mLoadingView.setVisibility(show ? View.VISIBLE : View.GONE);
		mProgressBar.setVisibility(show ? View.VISIBLE : View.GONE);
		mGetStarted.setVisibility(show ? View.GONE : View.VISIBLE);

		String getStarted = getResources().getString(R.string.get_started);
		String retry = getResources().getString(R.string.retry);

		if (mHasErrors) {
			mGetStarted.setText(retry);
		} else {
			mGetStarted.setText(getStarted);
		}
	}

	private void startLoaders() {
		showProgress(true);
		Logger.d(TAG, "Starting loaders");
		mLoadCount = 2;
		KeyLoaderCallbacks.restartLoader(getLoaderManager(), LaunchFragment.this);
		ChapterLoaderCallbacks.restartLoader(getLoaderManager(), LaunchFragment.this);
	}

	private void onLoadFinished() {
		if (mLoadCount <= 0) {
			showProgress(false);
		}
	}

	// Chapters loader
	@Override
	public void onChaptersDownloaded(List<Chapter> chapters) {
		Logger.d(TAG, "Chapters downloaded");

		if (chapters == null || chapters.size() == 0) {
			mHasErrors = true;
		}

		mLoadCount--;
		onLoadFinished();
	}

	@Override
	public void onError(ParseException e) {
		Logger.d(TAG, "Error downloading chapters: " + e);
		mLoadCount--;
		mHasErrors = true;
		onLoadFinished();
	}

	// API Key loader
	@Override
	public void onKeysDownloaded() {
		Logger.d(TAG, "Keys downloaded");
		mLoadCount--;
		onLoadFinished();
	}

	@Override
	public void onError() {
		Logger.d(TAG, "Error downloading keys");
		mLoadCount--;
		mHasErrors = true;
		onLoadFinished();
	}
}
