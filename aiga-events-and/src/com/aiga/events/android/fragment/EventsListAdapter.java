package com.aiga.events.android.fragment;

import java.util.List;

import android.content.Context;
import android.support.v4.app.FragmentActivity;
import android.text.Html;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.aiga.events.android.R;
import com.aiga.events.android.data.Event;
import com.aiga.events.android.data.EventDetails;
import com.aiga.events.android.views.ScrollSpeedAnimationListener;

public class EventsListAdapter extends BaseAnimatedListAdapter {

	public EventsListAdapter(FragmentActivity activity, ScrollSpeedAnimationListener listener, List<Event> events) {
		super(activity, listener, events);
	}

	public EventsListAdapter(Context context, ScrollSpeedAnimationListener scrollListener, List<Event> mEvents,
			long animationSpeed, float startAngle) {
		super(context, scrollListener, mEvents, animationSpeed, startAngle);
	}                                        

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		return getAnimatedView(position, convertView, parent);
	}

	@Override
	protected View getUnanimatedView(int position, View convertView, ViewGroup parent) {
		View v = convertView;
		ViewHolder holder;

		if (v == null) {
			v = mInflater.inflate(R.layout.list_item_events, null);
			holder = new ViewHolder(v);
			v.setTag(holder);
		} else {
			holder = (ViewHolder) v.getTag();
			holder.mThumbnail.setImageDrawable(null);
		}

		Event event = getEvent(position);
		EventDetails details = event.getEventDetails();

		if (details != null) {
			getThumbnailForView(holder.mThumbnail, holder.mImageProgressBar, details.getUrlForThumbnail(),
					!details.hasThumbnailUrl());
			
			int truncatedLength = 100;
			int fullLength = details.getDescriptionHtmlFree().length();
			// Stripping out double new line chars to condense the string into an appropriate space
			String description = details.getDescriptionHtmlFree().replace("\n\n", " ");
			if (fullLength > truncatedLength) {
				description = description.substring(0, truncatedLength).concat("...");
			}
			holder.mDescription.setText(description);
			holder.mTitle.setText(details.getTitleHtmlFree());
			
			String date = getDateTimeDetailsText(event);
			if (date != null) {
				holder.mDate.setText(date);	
			} else {
				holder.mDate.setVisibility(View.GONE);
			}

			if (details.getVenue() != null) {
				if (!details.getVenue().getEmpty()) {
					holder.mLocation.setText(Html.fromHtml(details.getVenue().getName()));	
				} else {
					holder.mLocation.setText(parent.getResources().getString(R.string.no_venue));
				}
			}
		}

		return v;
	}

	private static class ViewHolder {
		ImageView mThumbnail;
		ProgressBar mImageProgressBar;
		TextView mDescription;
		TextView mTitle;
		TextView mDate;
		TextView mLocation;

		ViewHolder(View v) {
			mThumbnail = (ImageView) v.findViewById(R.id.thumbnail);
			mImageProgressBar = (ProgressBar) v.findViewById(R.id.progress_bar);
			mDescription = (TextView) v.findViewById(R.id.location_description_text);
			mTitle = (TextView) v.findViewById(R.id.title);
			mDate = (TextView) v.findViewById(R.id.calendar_date);
			mLocation = (TextView) v.findViewById(R.id.location_text);
		}
	}
}
