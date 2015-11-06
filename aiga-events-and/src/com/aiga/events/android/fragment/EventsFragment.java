package com.aiga.events.android.fragment;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import com.aiga.events.android.R;
import com.aiga.events.android.data.Chapter;
import com.aiga.events.android.data.Event;
import com.aiga.events.android.loaders.KeyLoaderCallbacks;
import com.aiga.events.android.utils.Logger;
import com.aiga.events.android.utils.Utils;
import com.aiga.events.android.utils.Utils.OnEventsLoadedForChapterListener;
import com.aiga.events.android.views.Animations;
import com.aiga.events.android.views.NoScrollSwipeRefreshLayout;
import com.aiga.events.android.views.NoScrollSwipeRefreshLayout.OnRefreshListener;
import com.aiga.events.android.views.ScrollSpeedAnimationListener;

public class EventsFragment extends BaseActionBarLoadingFragment implements OnEventsLoadedForChapterListener,
		OnRefreshListener {

	private static final String EVENT_CHAPTER = "chapter";
	private static final String TAG = "AIGAEventsFragment";

	private NoScrollSwipeRefreshLayout mSwipeContainer;
	private EventsListAdapter mAdapter;
	private ListView mListView;
	private NoScrollSwipeRefreshLayout mEmptyView;
	private NoScrollSwipeRefreshLayout mErrorView;
	private boolean mShouldAnimate = true;
	private boolean mHasErrors;

	public static EventsFragment newInstance(Chapter chapter) {
		EventsFragment frag = new EventsFragment();
		Bundle args = new Bundle();
		args.putParcelable(EVENT_CHAPTER, chapter);
		frag.setArguments(args);
		Logger.d(TAG, "frag " + frag.toString());
		return frag;
	}

	@Override
	public void onCreate(Bundle saved) {
		super.onCreate(saved);
	}

	@Override
	public void onResume() {
		super.onResume();
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		
		View v = inflater.inflate(R.layout.fragment_events_layout, null);
		
		mSwipeContainer = (NoScrollSwipeRefreshLayout) v.findViewById(R.id.swipable_container);
		mListView = (ListView) v.findViewById(R.id.list_viewpager_events);
		mEmptyView = (NoScrollSwipeRefreshLayout) v.findViewById(R.id.empty_view_container);
		mErrorView = (NoScrollSwipeRefreshLayout) v.findViewById(R.id.error_view_container);
		
		mSwipeContainer.setOnRefreshListener(this);
		mSwipeContainer.setColorScheme(R.color.aiga_blue, R.color.swipe_refresh_dark, R.color.swipe_refresh_medium,
				R.color.swipe_refresh_light);
		mEmptyView.setOnRefreshListener(this);
		mEmptyView.setColorScheme(R.color.aiga_blue, R.color.swipe_refresh_dark, R.color.swipe_refresh_medium,
				R.color.swipe_refresh_light);
		mErrorView.setOnRefreshListener(this);
		mErrorView.setColorScheme(R.color.aiga_blue, R.color.swipe_refresh_dark, R.color.swipe_refresh_medium,
				R.color.swipe_refresh_light);

		mListView.setDivider(null);
		mListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View v, int position, long id) {

				if (mAdapter != null) {
					Event event = mAdapter.getEvent(position);
					Fragment detailsFrag = DetailsFragment.newInstance(event);
					getActivity().getSupportFragmentManager().beginTransaction()
							.replace(R.id.main_container, detailsFrag, DetailsFragment.FRAGMENT_MANAGER_TAG)
							.addToBackStack(null).commit();
				}
			}
		});
		
		return v;
	}

	@Override
	public void onDestroyView() {
		mSwipeContainer = null;
		mListView = null;
		mEmptyView = null;
		mErrorView = null;
		mAdapter = null;
		super.onDestroyView();
	}

	@Override
	public void onViewCreated(View view, Bundle savedInstanceState) {
		super.onViewCreated(view, savedInstanceState);
		getActivity().invalidateOptionsMenu();
		updateEvents(false);
	}

	private void updateListAdapter(List<Event> events) {
		if (mListView != null) {
			mAdapter = new EventsListAdapter(getActivity(), new ScrollSpeedAnimationListener(), events);
			mListView.setAdapter(mAdapter);
			mAdapter.setShouldAnimate(mShouldAnimate);
		}
	}

	@Override
	protected void showProgress(boolean show) {
		super.showProgress(show);

		if (mListView == null || mEmptyView == null || mErrorView == null) {
			return;
		}

		if (show) {
			if (mListView.getVisibility() == View.VISIBLE) {
				if (mShouldAnimate)
					Animations.animateFadeOut(mListView);
			}
			if (mEmptyView.getVisibility() == View.VISIBLE) {
				if (mShouldAnimate)
					Animations.animateFadeOut(mEmptyView);
			}
			if (mErrorView.getVisibility() == View.VISIBLE) {
				if (mShouldAnimate)
					Animations.animateFadeOut(mErrorView);
			}

		} else {
			if (mAdapter != null && mAdapter.getCount() > 0) {
				if (mShouldAnimate)
					// overriding default fade-in values with "fake" values 
					// (no actual alpha change and a duration of 0)
					// as a fix for flickering on 4.3 and 4.4 devices
					Animations.animateFadeIn(mListView, 1.0f, 0);
			} else {
				if (mShouldAnimate)
					Animations.animateFadeIn(mEmptyView);
			}
		}
	}

	protected void showError() {
		super.showProgress(false);

		if (mListView == null || mEmptyView == null || mErrorView == null || mSwipeContainer == null) {
			return;
		}

		mSwipeContainer.setRefreshing(false);
		mEmptyView.setRefreshing(false);
		mErrorView.setRefreshing(false);
		mListView.setVisibility(View.GONE);
		mEmptyView.setVisibility(View.GONE);
		Animations.animateFadeIn(mErrorView);
	}

	private void onEventError(String error) {
		Logger.d(TAG, "onEventError");
		mHasErrors = true;
		showError();
	}

	private void onEventsUpdated(List<Event> events) {
		if (mSwipeContainer != null) {
			mSwipeContainer.setRefreshing(false);	
		}
		if (mEmptyView != null) {
			mEmptyView.setRefreshing(false);	
		}
		if (mErrorView != null) {
			mErrorView.setRefreshing(false);	
		}
		Chapter chapter = getArguments().getParcelable(EVENT_CHAPTER);
		int size = (events == null ? 0 : events.size());
		Logger.d(TAG, "onEventsUpdated for chapter: " + chapter.getChapterName() + " with events: " + size);

		if (getActivity() == null) {
			return;
		}

		if (events != null) {
			Collections.sort(events, new Utils.EventDateComparator());
		}

		updateListAdapter(events);
		showProgress(false);
	}

	public void updateEventsForNewChapter(Chapter chapter) {
		getArguments().putParcelable(EVENT_CHAPTER, chapter);
		updateEvents(false);
	}

	private void updateEvents(boolean forceRefresh) {
		Chapter chapter = getArguments().getParcelable(EVENT_CHAPTER);
		showProgress(true);

		if (forceRefresh || chapter.shouldDownloadEvents()) {
			if (mHasErrors) {
				mHasErrors = false;
				KeyLoaderCallbacks.restartLoader(getLoaderManager(), this);
			} else {
				Utils.downloadEventsForChapter(getActivity(), chapter);
			}
		} else {
			Utils.getEventsForChapter(chapter, this);
		}
	}

	@Override
	public void onEventsLoaded(List<Event> events) {
		onEventsUpdated(events);
	}

	@Override
	protected void handleRefreshRequested() {
		Logger.d(TAG, "handleRefreshRequested");
		super.handleRefreshRequested();
		mSwipeContainer.setRefreshing(true);
		mEmptyView.setRefreshing(true);
		mErrorView.setRefreshing(true);
		updateEvents(true);
	}

	@Override
	protected void handleChapterBroadcast(List<Chapter> chapters) {
		// do nothing
	}

	@Override
	protected void handleEventsBroadcast(Map<Chapter, List<Event>> eventMap) {
		for (Map.Entry<Chapter, List<Event>> entry : eventMap.entrySet()) {
			Chapter chapter = entry.getKey();

			if (chapter.equals(getArguments().getParcelable(EVENT_CHAPTER))) {
				Logger.d(TAG, "Events broadcast received for chapter: " + chapter.getChapterName());
				onEventsUpdated(entry.getValue());
			}
		}
	}

	@Override
	protected void handleErrorBroadcast(Chapter chapter, String error) {
		super.handleErrorBroadcast(chapter, error);

		if (chapter != null) {
			if (chapter.equals(getArguments().getParcelable(EVENT_CHAPTER))) {
				Logger.d(TAG, "Received error for chapter: " + chapter.getChapterName());
				onEventError(error);
			} else {
				Logger.d(TAG, "Received error for another chapter, ignoring");
			}
		} else {
			onEventError(error);
		}
	}

	@Override
	public void onRefresh() {
		Logger.d(TAG, "onRefresh");
		handleRefreshRequested();
	}

	public void setShouldAnimate(boolean shouldAnimate) {
		mShouldAnimate = shouldAnimate;
	}

	public boolean getShouldAnimate() {
		return mShouldAnimate;
	}
}