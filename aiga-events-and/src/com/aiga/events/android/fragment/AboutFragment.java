package com.aiga.events.android.fragment;

import java.util.List;
import java.util.Map;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.TextView;

import com.aiga.events.android.R;
import com.aiga.events.android.data.Chapter;
import com.aiga.events.android.data.Event;

public class AboutFragment extends BaseActionBarLoadingFragment implements OnClickListener {

	public static final String FRAGMENT_MANAGER_TAG = "AboutFragment";

	public static AboutFragment newInstance() {
		return new AboutFragment();
	}     

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		getActivity().getActionBar().setTitle(R.string.action_bar_title_about);
		View rootView = inflater.inflate(R.layout.fragment_about_layout, container, false);

		rootView.findViewById(R.id.dd_url).setOnClickListener(this);
		rootView.findViewById(R.id.square_url).setOnClickListener(this);
		rootView.findViewById(R.id.apache_url).setOnClickListener(this);

		return rootView;
	}

	@Override
	protected void handleChapterBroadcast(List<Chapter> chapters) {
		// not used here
	}

	@Override
	protected void handleEventsBroadcast(Map<Chapter, List<Event>> eventMap) {
		// not used here
	}

	@Override
	public void onClick(View v) {
		TextView tv = (TextView) v;
		Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(tv.getText().toString()));
		startActivity(intent);
	}
}
