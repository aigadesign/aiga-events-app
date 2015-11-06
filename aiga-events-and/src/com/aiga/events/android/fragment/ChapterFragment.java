package com.aiga.events.android.fragment;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import com.aiga.events.android.INavigationListener;
import com.aiga.events.android.R;
import com.aiga.events.android.data.Chapter;
import com.aiga.events.android.data.Event;
import com.aiga.events.android.loaders.ChapterLoaderCallbacks;
import com.aiga.events.android.loaders.ChapterLoaderCallbacks.OnChaptersDownloadedListener;
import com.aiga.events.android.utils.Utils;
import com.aiga.events.android.utils.Utils.OnChaptersLoadedListener;
import com.aiga.events.android.views.NoScrollSwipeRefreshLayout;
import com.aiga.events.android.views.NoScrollSwipeRefreshLayout.OnRefreshListener;
import com.parse.ParseException;

public class ChapterFragment extends BaseActionBarLoadingFragment implements OnChaptersLoadedListener,
		OnChaptersDownloadedListener, OnRefreshListener {

	public static final String FRAGMENT_MANAGER_TAG = "ChapterFragment";

	private NoScrollSwipeRefreshLayout mSwipeContainer;
	private ChaptersListAdapter mListAdapter;
	private ListView mListView;
	private List<Chapter> mSelectedChapters;
	private MenuItem mDoneMenuItem;
	private INavigationListener mNavListener;

	public static ChapterFragment newInstance() {
		return new ChapterFragment();
	}

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
		getActivity().getActionBar().setTitle(getString(R.string.action_bar_title_chapters));
		View rootView = inflater.inflate(R.layout.fragment_chapters_layout, container, false);
		mSwipeContainer = (NoScrollSwipeRefreshLayout) rootView.findViewById(R.id.swipable_container);
		mListView = (ListView) rootView.findViewById(R.id.chapter_list);

		mSwipeContainer.setOnRefreshListener(this);
		mSwipeContainer.setColorScheme(R.color.aiga_blue, R.color.swipe_refresh_dark, R.color.swipe_refresh_medium,
				R.color.swipe_refresh_light);

		mListAdapter = new ChaptersListAdapter(getActivity());
		mListView.setAdapter(mListAdapter);
		mSelectedChapters = new ArrayList<Chapter>();

		setListViewOnClickListener();
		showProgress(true);
		Utils.getAllChapters(this);

		return rootView;
	}

	@Override
	public void onDestroyView() {
		Utils.notifySelectedChaptersChanged(mSelectedChapters);
		mSwipeContainer = null;
		mSelectedChapters = null;
		mListView = null;
		mListAdapter = null;
		mDoneMenuItem = null;
		super.onDestroyView();
	}

	private void setListViewOnClickListener() {
		mListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				Chapter chapter = mListAdapter.getItem(position);
				chapter.setSelected(!chapter.isSelected());
				Utils.saveChapter(chapter);
				mListAdapter.notifyDataSetChanged();

				if (chapter.isSelected()) {
					mSelectedChapters.add(chapter);
				} else {
					mSelectedChapters.remove(chapter);
				}

				if (mDoneMenuItem != null) {
					mDoneMenuItem.setEnabled(mSelectedChapters.size() > 0);
				}
			}
		});
	}

	@Override
	public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
		super.onCreateOptionsMenu(menu, inflater);

		if (Utils.isFirstLaunch()) {
			mDoneMenuItem = menu.findItem(R.id.action_done);
			mDoneMenuItem.setVisible(!mIsLoading);
			mDoneMenuItem.setEnabled(false);
		}
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == R.id.action_done) {
			mNavListener.onChaptersDoneClicked();
			return true;
		}

		return super.onOptionsItemSelected(item);
	}

	@Override
	protected void showProgress(boolean show) {
		super.showProgress(show);

		if (mListView != null) {
			mListView.setVisibility(show ? View.GONE : View.VISIBLE);
		}

		if (mDoneMenuItem != null) {
			mDoneMenuItem.setVisible(!show);
		}
	}

	private void updateChapters(List<Chapter> chapters) {
		showProgress(false);
		if (mListAdapter != null) {
			mListAdapter.clear();
			mListAdapter.addAll(chapters);
			mListAdapter.notifyDataSetChanged();
		}
	}

	@Override
	public void onChaptersLoaded(List<Chapter> chapters) {
		if (mSelectedChapters == null) {
			return;
		}

		for (Chapter chapter : chapters) {
			if (chapter.isSelected()) {
				mSelectedChapters.add(chapter);
			}
		}

		if (chapters.size() > 0) {
			updateChapters(chapters);
		}

		showProgress(false);
	}

	@Override
	public void onChaptersDownloaded(List<Chapter> chapters) {
		mSwipeContainer.setRefreshing(false);
		Collections.sort(chapters);
		updateChapters(chapters);
	}

	@Override
	protected void handleRefreshRequested() {
		super.handleRefreshRequested();
		mSwipeContainer.setRefreshing(true);
		ChapterLoaderCallbacks.restartLoader(getLoaderManager(), this);
	}

	@Override
	public void onError(ParseException e) {
		showProgress(false);
	}

	@Override
	public void onRefresh() {
		handleRefreshRequested();
	}

	// Leaving these unimplemented for future use
	@Override
	protected void handleChapterBroadcast(List<Chapter> chapters) {
		// do nothing
	}

	@Override
	protected void handleEventsBroadcast(Map<Chapter, List<Event>> eventMap) {
		// do nothing
	}

}