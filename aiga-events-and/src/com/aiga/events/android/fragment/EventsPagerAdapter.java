package com.aiga.events.android.fragment;

import java.util.ArrayList;
import java.util.List;

import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

import com.aiga.events.android.data.Chapter;
import com.aiga.events.android.utils.Logger;

public class EventsPagerAdapter extends FragmentStatePagerAdapter {

	private List<Chapter> mChapters = new ArrayList<Chapter>();
	private EventsFragment mCurrentFrag;
	
	public EventsPagerAdapter(FragmentManager fm, List<Chapter> chapters) {
		super(fm);
		mChapters = chapters;
	}

	@Override
	public EventsFragment getItem(int position) {
		Logger.d("EPF", "getItem " + position);
		EventsFragment fragment = EventsFragment.newInstance(mChapters.get(position));
		mCurrentFrag = fragment;
		return fragment;
	}

	@Override
	public int getCount() {
		return mChapters.size();
	}

	@Override
	public CharSequence getPageTitle(int position) {
		return mChapters.get(position).getChapterName();
	}
	
	public boolean getShouldAnimateItem() {
		Logger.d("EPF", "getShouldAnimateItem");
		return mCurrentFrag.getShouldAnimate();
	}
	
	public void setShouldAnimateItem(boolean shouldAnimate) {
		Logger.d("EPF", "setShouldAnimateItem to " + shouldAnimate);
		mCurrentFrag.setShouldAnimate(shouldAnimate);
	}

}