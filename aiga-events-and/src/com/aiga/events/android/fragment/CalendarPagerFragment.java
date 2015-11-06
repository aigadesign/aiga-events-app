package com.aiga.events.android.fragment;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import android.support.v4.view.ViewPager.OnPageChangeListener;

import com.aiga.events.android.R;
import com.aiga.events.android.utils.Utils;

public class CalendarPagerFragment extends BasePagerFragment {

	public static final String FRAGMENT_MANAGER_TAG = "CalendarPagerFragment";

	public static CalendarPagerFragment newInstance() {
		return new CalendarPagerFragment();
	}

	@Override
	protected String getTitle() {
		return getString(R.string.action_bar_title_calendar);
	}

	@Override
	protected void setupAdapter() {
		List<Date> dates = new ArrayList<Date>();
		Calendar calendar = Calendar.getInstance();

		for (int i = 0; i < 12; i++) {
			dates.add(calendar.getTime());
			Utils.incrementMonth(calendar);
		}

		mAdapter = new CalendarPagerAdapter(getChildFragmentManager(), dates, mChapters);
	}

	@Override
	protected void setupViewPager() {
		mViewPager.setOnPageChangeListener((OnPageChangeListener) mAdapter);
	}
	
}
