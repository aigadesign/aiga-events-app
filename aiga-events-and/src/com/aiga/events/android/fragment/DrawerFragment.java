package com.aiga.events.android.fragment;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import com.aiga.events.android.INavigationListener;
import com.aiga.events.android.R;
import com.aiga.events.android.utils.Logger;

public class DrawerFragment extends Fragment {

	private static final String TAG = "AIGADrawerFragment";

	public static final String FRAGMENT_MANAGER_TAG = "DrawerFragment";
	private final String[] mValues = new String[] { "EVENTS", "CHAPTERS", "CALENDAR", "ABOUT" };
	private final int[] mResourcesImages = new int[] { R.drawable.events, R.drawable.chapters, R.drawable.calendar,
			R.drawable.info };
	private INavigationListener mNavigationListener;

	public static DrawerFragment newInstance(Context context) {
		return new DrawerFragment();
	}

	@Override
	public void onAttach(Activity activity) {
		super.onAttach(activity);
		try {
			mNavigationListener = (INavigationListener) activity;
		} catch (Exception er) {
			Logger.d(TAG, "Activity must implement navigation interface");
		}
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		getActivity().getActionBar().setTitle(getString(R.string.action_bar_title_events));
		return inflater.inflate(R.layout.fragment_drawer_layout, container, false);
	}

	@Override
	public void onViewCreated(View view, Bundle savedInstanceState) {
		super.onViewCreated(view, savedInstanceState);
		ListView drawerListView = (ListView) view.findViewById(R.id.list_drawer_fragment);

		DrawerItemsCustomAdapter drawerAdapter = new DrawerItemsCustomAdapter(getActivity(), mValues, mResourcesImages);
		drawerListView.setAdapter(drawerAdapter);

		drawerListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View itemView, int position, long id) {

				getActivity().getSupportFragmentManager().popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);

				switch (position) {
				case 0:
					Fragment eventsPagerFrag = EventsPagerFragment.newInstance();
					getFragmentManager().beginTransaction()
							.replace(R.id.main_container, eventsPagerFrag, EventsPagerFragment.FRAGMENT_MANAGER_TAG)
							.addToBackStack(null).commit();
					mNavigationListener.closingDrawerTransaction();
					break;
				case 1:
					Fragment chapterFrag = ChapterFragment.newInstance();
					getFragmentManager().beginTransaction()
							.replace(R.id.main_container, chapterFrag, ChapterFragment.FRAGMENT_MANAGER_TAG)
							.addToBackStack(null).commit();
					mNavigationListener.closingDrawerTransaction();
					break;
				case 2:
					Fragment calendarPagerFrag = CalendarPagerFragment.newInstance();
					getFragmentManager()
							.beginTransaction()
							.replace(R.id.main_container, calendarPagerFrag, CalendarPagerFragment.FRAGMENT_MANAGER_TAG)
							.addToBackStack(null).commit();
					mNavigationListener.closingDrawerTransaction();
					break;
				case 3:
					AboutFragment aboutFrag = AboutFragment.newInstance();
					getFragmentManager()
							.beginTransaction()
							.replace(R.id.main_container, aboutFrag, AboutFragment.FRAGMENT_MANAGER_TAG)
							.addToBackStack(null).commit();
					mNavigationListener.closingDrawerTransaction();
				}
			}
		});
	}
}