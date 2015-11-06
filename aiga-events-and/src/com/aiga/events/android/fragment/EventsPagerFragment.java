package com.aiga.events.android.fragment;

import com.aiga.events.android.R;

public class EventsPagerFragment extends BasePagerFragment {

	public static final String FRAGMENT_MANAGER_TAG = "EventPagerFragment";
	public static final String TAG = "AIGAEventPagerFragment";
	
	public static EventsPagerFragment newInstance() {
		return new EventsPagerFragment();
	}
	
	@Override
	protected void setupAdapter() {
		mAdapter = new EventsPagerAdapter(getChildFragmentManager(), mChapters);
	}

	@Override
	protected String getTitle() {
		return getString(R.string.action_bar_title_events);
	}

	@Override
	protected void setupViewPager() {       
		// Prefetching additional pages to prevent card animation when paging
		// Not an ideal fix, but sufficient for release
		mViewPager.setOffscreenPageLimit(3);
	}
}