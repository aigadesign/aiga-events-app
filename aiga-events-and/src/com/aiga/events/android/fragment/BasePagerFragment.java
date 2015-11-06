package com.aiga.events.android.fragment;

import java.util.ArrayList;
import java.util.List;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.aiga.events.android.R;
import com.aiga.events.android.data.Chapter;
import com.aiga.events.android.utils.Utils;
import com.aiga.events.android.utils.Utils.OnChaptersLoadedListener;

public abstract class BasePagerFragment extends Fragment implements OnChaptersLoadedListener {

	public static final String FRAGMENT_MANAGER_TAG = "CalendarPagerFragment";

	protected ViewPager mViewPager;
	protected View mEmptyText;
	protected PagerAdapter mAdapter;
	protected List<Chapter> mChapters = new ArrayList<Chapter>();

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		getActivity().getActionBar().setTitle(getTitle());
		View v = inflater.inflate(R.layout.pager, container, false);

		mViewPager = (ViewPager) v.findViewById(R.id.pager);
		mEmptyText = v.findViewById(R.id.message_first_launch);
		mEmptyText.setVisibility(View.GONE);

		Utils.getSelectedChapters(this);

		return v;
	}

	@Override
	public void onChaptersLoaded(List<Chapter> chapters) {
		if (mViewPager == null) {
			return;
		}

		mChapters = chapters;
		setupAdapter();
		setupViewPager();
		mViewPager.setAdapter(mAdapter);

		if (mChapters.size() > 0) {
			mEmptyText.setVisibility(View.GONE);
			mViewPager.setVisibility(View.VISIBLE);
		} else {
			mEmptyText.setVisibility(View.VISIBLE);
			mViewPager.setVisibility(View.GONE);
		}
	}

	protected abstract void setupAdapter();

	protected abstract void setupViewPager();

	protected abstract String getTitle();
}