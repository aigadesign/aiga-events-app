package com.aiga.events.android.fragment;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager.OnPageChangeListener;

import com.aiga.events.android.data.Chapter;

public class CalendarPagerAdapter extends FragmentPagerAdapter implements OnPageChangeListener {

	private final List<Date> mDates;
	private List<Chapter> mChapters = new ArrayList<Chapter>();
	private int mCurrentItem;

	public CalendarPagerAdapter(FragmentManager fm, List<Date> dates, List<Chapter> chapters) {
		super(fm);
		mDates = dates;
		mChapters = chapters;
		mCurrentItem = 0;
	}

	@Override
	public CalendarFragment getItem(int position) {
		CalendarFragment fragment = CalendarFragment.newInstance(mDates.get(position), mChapters);
		return fragment;
	}

	@Override
	public int getCount() {
		return mDates.size();
	}

	@Override
	public CharSequence getPageTitle(int position) {
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(mDates.get(position));
		String month = calendar.getDisplayName(Calendar.MONTH, Calendar.LONG, Locale.US).toUpperCase(Locale.US);
		int currentYear = Calendar.getInstance().get(Calendar.YEAR);
		int calendarYear = calendar.get(Calendar.YEAR);

		StringBuilder title = new StringBuilder();
		if (position == mCurrentItem) {
			title.append(month);
			if (calendarYear > currentYear) {
				title.append(" ").append(calendarYear);
			}
		} else if (position < mCurrentItem) {
			String shortMonth = calendar.getDisplayName(Calendar.MONTH, Calendar.SHORT, Locale.US).toUpperCase(
					Locale.US);
			title.append(" ").append(shortMonth);
		} else {
			String shortMonth = calendar.getDisplayName(Calendar.MONTH, Calendar.SHORT, Locale.US).toUpperCase(
					Locale.US);
			title.append(shortMonth).append(" ");
		}

		return title.toString();
	}

	public void setCurrentItem(int item) {
		mCurrentItem = item;
	}

	@Override
	public void onPageScrollStateChanged(int arg0) {
		// not implemented
	}

	@Override
	public void onPageScrolled(int arg0, float arg1, int arg2) {
		// not implemented
	}

	@Override
	public void onPageSelected(int position) {
		mCurrentItem = position;
	}
}
