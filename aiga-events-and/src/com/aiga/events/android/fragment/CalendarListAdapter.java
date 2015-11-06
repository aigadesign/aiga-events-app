package com.aiga.events.android.fragment;

import java.util.List;
import java.util.Locale;

import android.support.v4.app.FragmentActivity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.aiga.events.android.R;
import com.aiga.events.android.data.Event;
import com.aiga.events.android.data.EventDetails;
import com.aiga.events.android.utils.Logger;
import com.aiga.events.android.views.ScrollSpeedAnimationListener;

public class CalendarListAdapter extends BaseAnimatedListAdapter {

	private static final String TAG = "AIGAEventsCalendarListAdapter";

	public CalendarListAdapter(FragmentActivity activity, ScrollSpeedAnimationListener listener, List<Event> events) {
		super(activity, listener, events);
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		return getAnimatedView(position, convertView, parent);
	}

	@Override
	protected View getUnanimatedView(int position, View convertView, ViewGroup parent) {
		View v = convertView;
		ViewHolder holder;
		Event event;
		EventDetails details;

		if (v == null) {
			v = mInflater.inflate(R.layout.list_item_calendar, null);
			holder = new ViewHolder(v);
			v.setTag(holder);
		} else {
			holder = (ViewHolder) v.getTag();
			holder.mThumbnail.setImageDrawable(null);
		}

		event = getEvent(position);
		details = event.getEventDetails();

		if (details != null) {
			getThumbnailForView(holder.mThumbnail, holder.mImageProgressBar, details.getUrlForThumbnail(),
					!details.hasThumbnailUrl());
			holder.mTitle.setText(details.getTitleHtmlFree().toUpperCase(Locale.US));
			StringBuilder subtitle = new StringBuilder();
			String dateTime = getDateTimeDetailsText(event);
			if (dateTime != null) {
				subtitle.append(dateTime).append("  ");	
			}

			if (details.getVenue() != null) {
				if (!details.getVenue().getEmpty()) {
					subtitle.append(details.getVenueNameHtmlFree().toUpperCase(Locale.US));
				} else {
					subtitle.append(parent.getResources().getString(R.string.no_venue));	
				}
			}

			holder.mSubtitle.setText(subtitle.toString());
		}

		return v;
	}

	@Override
	public int getCount() {
		return mEvents.size();
	}

	private static class ViewHolder {
		ImageView mThumbnail;
		ProgressBar mImageProgressBar;
		TextView mTitle;
		TextView mSubtitle;

		ViewHolder(View v) {
			mThumbnail = (ImageView) v.findViewById(R.id.calendar_event_image);
			mImageProgressBar = (ProgressBar) v.findViewById(R.id.progress_bar);
			mTitle = (TextView) v.findViewById(R.id.calendar_event_title);
			mSubtitle = (TextView) v.findViewById(R.id.calendar_event_subtitle);

			if (mThumbnail == null) {
				Logger.d(TAG, "thumbnail view is null");
			}
		}
	}
}
