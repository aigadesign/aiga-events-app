package com.aiga.events.android.fragment;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.net.Uri;
import android.os.Bundle;
import android.provider.CalendarContract;
import android.provider.CalendarContract.Events;
import android.support.v4.app.Fragment;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.aiga.events.android.AIGAApplication;
import com.aiga.events.android.R;
import com.aiga.events.android.data.Event;
import com.aiga.events.android.data.EventDetails;
import com.aiga.events.android.data.Venue;
import com.aiga.events.android.utils.Logger;
import com.aiga.events.android.utils.Utils;
import com.aiga.events.android.views.Animations;
import com.aiga.events.android.views.StickyHeaderComponent;
import com.ubermind.http.converter.IDataConverter;
import com.ubermind.http.request.BaseHttpRequest;
import com.ubermind.http.task.HttpBitmapLoadTask;

public class DetailsFragment extends Fragment {

	private static final String EVENT_TAG = "event";
	private static final String TAG = "AIGADetailsFragment";
	public static final String FRAGMENT_MANAGER_TAG = "DetailsFragment";

	private ProgressBar mImageProgressBar;
	private FrameLayout mImageLayout;
	private StickyHeaderComponent mStickyHeaderComponent;

	public static DetailsFragment newInstance(Event event) {
		DetailsFragment fragment = new DetailsFragment();
		Bundle args = new Bundle();
		args.putParcelable(EVENT_TAG, event);
		fragment.setArguments(args);
		return fragment;
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		getActivity().getActionBar().setTitle(getString(R.string.action_bar_title_details));
		View rootView = inflater.inflate(R.layout.fragment_event_details_layout, container, false);
		mImageProgressBar = (ProgressBar) rootView.findViewById(R.id.progress_bar);
		mImageLayout = (FrameLayout) rootView.findViewById(R.id.image_layout);

		final Event event = getArguments().getParcelable(EVENT_TAG);
		final EventDetails details = event.getEventDetails();

		if (details != null) {
			TextView price = (TextView) rootView.findViewById(R.id.details_price);
			price.setText(details.getPriceRange());

			TextView title = (TextView) rootView.findViewById(R.id.title);
			title.setText(details.getTitleHtmlFree());

			setupEventDetails(rootView, details.getDescription());

			// We'll handle improperly formatted or missing dates by discarding
			// the broken string and
			// displaying a message to the user
			// These events will not be visible in the calendar for obvious
			// reasons
			TextView dateLong = (TextView) rootView.findViewById(R.id.details_datetime_description);
			String date = getDateTimeDetailsText(event);
			if (date != null) {
				dateLong.setText(getDateTimeDetailsText(event));
			} else {
				dateLong.setText(getResources().getString(R.string.not_available));
			}

			setupMapDetails(rootView, details.getVenue());
			setupAddButton(rootView, details);
			setupTicketsButton(rootView, details);

			mStickyHeaderComponent = new StickyHeaderComponent();
			mStickyHeaderComponent.init(rootView, R.id.scrollview, R.id.header, R.id.placeholder_header);
		}

		ImageView image = (ImageView) rootView.findViewById(R.id.details_image);

		BitmapLoadTask task = new BitmapLoadTask(event.getEventDetails().getLogoUrl(), image,
				HttpBitmapLoadTask.NO_DISPLAY_RESOURCE_ID, R.drawable.event_details_placeholder);
		task.executeOnThreadPool();

		return rootView;
	}

	@Override
	public void onDestroyView() {
		mImageProgressBar = null;
		mStickyHeaderComponent.destroy();
		super.onDestroyView();
	}

	private void setupEventDetails(View rootView, String description) {
		WebView detail = (WebView) rootView.findViewById(R.id.detail_description);
		detail.setBackgroundColor(getResources().getColor(R.color.aiga_grey_1));

		StringBuilder formattedTextBuilder = new StringBuilder();
		formattedTextBuilder.append("<html>");
		formattedTextBuilder.append("<head>");
		formattedTextBuilder.append("<style type=\"text/css\">");
		formattedTextBuilder.append("body {");
		formattedTextBuilder.append("font-size: medium;");
		formattedTextBuilder.append("font-style: italic;");
		formattedTextBuilder.append("}");
		formattedTextBuilder.append("</style>");
		formattedTextBuilder.append("</head>");
		formattedTextBuilder.append("<body>");
		formattedTextBuilder.append(description);
		formattedTextBuilder.append("</body>");
		formattedTextBuilder.append("</html>");

		String formattedText = formattedTextBuilder.toString();
		detail.loadData(formattedText, "text/html; charset=UTF-8", null);
	}

	private void setupMapDetails(View rootView, Venue venue) {
		TextView mapLink = (TextView) rootView.findViewById(R.id.details_location_mapit);
		View mapLayout = rootView.findViewById(R.id.details_location_layout);
		TextView locationDescription = (TextView) rootView.findViewById(R.id.details_location_description);

		if (venue == null || venue.getEmpty()) {
			mapLink.setVisibility(View.INVISIBLE);
			locationDescription.setText(getResources().getString(R.string.not_available));
			return;
		}

		mapLink.setVisibility(View.VISIBLE);
		locationDescription.setText(getLocationDetailsText(venue));

		StringBuilder address = new StringBuilder();
		appendIfValid(address, venue.getAddress());
		appendIfValid(address, venue.getAddress2());
		appendIfValid(address, venue.getCity());
		appendIfValid(address, venue.getRegion());
		appendIfValid(address, venue.getPostalCode());
		final String addressString = address.toString();

		mapLayout.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent geoIntent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse("geo:0,0?q="
						+ addressString));
				startActivity(geoIntent);
			}
		});
	}

	private void setupAddButton(View rootView, final EventDetails details) {
		TextView add = (TextView) rootView.findViewById(R.id.details_description_add);
		View dateLayout = rootView.findViewById(R.id.details_datetime_layout);

		try {
			SimpleDateFormat input = new SimpleDateFormat(Utils.DATE_FORMAT, Locale.US);
			Date startDate = input.parse(details.getStartDate());
			Date endDate = input.parse(details.getEndDate());

			if (startDate.getTime() == 0 || endDate.getTime() == 0) {
				throw new Exception();
			}

			dateLayout.setOnClickListener(new View.OnClickListener() {

				@Override
				public void onClick(View v) {
					addToLocalCalendar(details);
				}
			});

			add.setVisibility(View.VISIBLE);
		} catch (Exception e) {
			Logger.d(TAG, "Error parsing event dates: " + e);
			add.setVisibility(View.GONE);
		}
	}

	private void setupTicketsButton(View rootView, final EventDetails details) {
		TextView tickets = (TextView) rootView.findViewById(R.id.details_get_tickets_view);

		if (details.getOrganizer() != null && details.getOrganizer().getTicketUrl() != null) {

			tickets.setOnClickListener(new View.OnClickListener() {

				@Override
				public void onClick(View v) {
					Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(details.getOrganizer()
							.getTicketUrl()));
					startActivity(browserIntent);
				}
			});

		} else {
			tickets.setVisibility(View.GONE);
		}
	}

	class BitmapLoadTask extends HttpBitmapLoadTask {

		// 5 days; This is arbitrary
		private static final int CACHE_EXPIRATION_OVERRIDE = 432000000;

		public BitmapLoadTask(String url, ImageView imageView, int waitingDrawable, int errorDrawable) {
			super(url, imageView, waitingDrawable, errorDrawable);
		}

		@Override
		protected void onPreExecute() {
			mImageProgressBar.setVisibility(View.VISIBLE);
			super.onPreExecute();
		}

		@Override
		protected BaseHttpRequest<Bitmap> buildHttpRequest(Context context, String url, IDataConverter<Bitmap> converter) {
			BaseHttpRequest<Bitmap> request = super.buildHttpRequest(context, url, converter);

			// Overriding the server cache directive which is often set to 0
			request.setExpirationInterval(CACHE_EXPIRATION_OVERRIDE);
			request.setIgnoringCacheDirectives(true);
			return request;
		}

		@Override
		protected void onPostBitmapCached(Bitmap bitmap) {
			setVisibilityGone(mImageProgressBar);
			resizeImageView(bitmap);
			Animations.animateFadeIn(mImageLayout);
			super.onPostBitmapCached(bitmap);
		}

		@Override
		protected void onError() {
			setVisibilityGone(mImageProgressBar);
			super.onError();
		}

		@Override
		protected void onPostExecute(Bitmap result) {
			setVisibilityGone(mImageProgressBar);
			resizeImageView(result);
			Animations.animateFadeIn(mImageLayout);
			super.onPostExecute(result);
		}

		private void resizeImageView(final Bitmap result) {
			Logger.d(TAG, "resizeImageView");
			if (AIGAApplication.getDeviceAPIVersion() < android.os.Build.VERSION_CODES.JELLY_BEAN_MR2) {
				// Multitude of null checks for monkey issues when attempting to resize display
				if (getActivity() != null && getActivity().getWindowManager() != null
						&& getActivity().getWindowManager().getDefaultDisplay() != null) {
					Display display = getActivity().getWindowManager().getDefaultDisplay();
					Point size = new Point();
					display.getSize(size);
					int scrWidth = size.x;
					float ratio = (scrWidth / (float) result.getWidth());
					mImageLayout.getLayoutParams().height = (int) (result.getHeight() * ratio);
				}
			}
		}

	}

	private static void setVisibilityGone(View view) {
		if (view != null) {
			view.setVisibility(View.GONE);
		}
	}

	private static void appendIfValid(StringBuilder builder, String text) {
		if (text != null && text.length() > 0) {
			builder.append(text);
			builder.append(" ");
		}
	}

	private void addToLocalCalendar(EventDetails details) {
		SimpleDateFormat input = new SimpleDateFormat(Utils.DATE_FORMAT, Locale.US);

		try {
			Date startDate = input.parse(details.getStartDate());
			Calendar startDateCalendar = Calendar.getInstance();
			startDateCalendar.setTime(startDate);

			Date endDate = input.parse(details.getEndDate());
			Calendar endDateCalendar = Calendar.getInstance();
			endDateCalendar.setTime(endDate);

			String rawTimeZone = details.getTimeZone();

			Intent intent = new Intent(Intent.ACTION_INSERT);
			intent.setData(Events.CONTENT_URI);
			intent.putExtra(Events.TITLE, details.getTitleHtmlFree());
			intent.putExtra(Events.DESCRIPTION, details.getDescriptionHtmlFree());
			StringBuilder address = new StringBuilder(details.getVenue().getAddress());
			address.append(" ").append(details.getVenue().getCity()).append(" ").append(details.getVenue().getRegion())
					.append(" ").append(details.getVenue().getPostalCode());
			intent.putExtra(Events.EVENT_LOCATION, address.toString());

			long startTimeInMillis = startDateCalendar.getTimeInMillis();
			long endTimeInMillis = endDateCalendar.getTimeInMillis();

			if (rawTimeZone != null) {
				// offset time zone manually because calendar intents don't
				// support setting a time zone
				TimeZone timeZone = TimeZone.getTimeZone(rawTimeZone);
				int eventOffset = timeZone.getRawOffset();

				TimeZone localTimeZone = TimeZone.getDefault();
				int localOffset = localTimeZone.getRawOffset();

				startTimeInMillis += (localOffset - eventOffset);
				endTimeInMillis += (localOffset - eventOffset);
			}

			intent.putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, startTimeInMillis);
			intent.putExtra(CalendarContract.EXTRA_EVENT_END_TIME, endTimeInMillis);

			startActivity(intent);
		} catch (ParseException e) {
			Logger.d(TAG, "Error parsing date: " + e);
			Toast.makeText(getActivity(), getResources().getString(R.string.error_adding_to_calendar),
					Toast.LENGTH_SHORT).show();
		}
	}

	private static String getLocationDetailsText(Venue venue) {
		StringBuilder location = new StringBuilder();

		if (venue != null) {
			location.append(venue.getAddress());
			location.append("\n");
			String address2 = venue.getAddress2();

			if (address2 != null && address2.length() > 0) {
				location.append(address2);
				location.append("\n");
			}

			location.append(venue.getCity());
			location.append(", ");
			location.append(venue.getRegion());
			location.append("  ");
			location.append(venue.getPostalCode());
		}

		return location.toString();
	}

	private static String getDateTimeDetailsText(Event event) {
		EventDetails details = event.getEventDetails();

		if (details.getStartDate() == null || details.getEndDate() == null) {
			return null;
		}

		StringBuilder dateTime = new StringBuilder();
		SimpleDateFormat input = new SimpleDateFormat(Utils.DATE_FORMAT, Locale.US);
		SimpleDateFormat outputDate = new SimpleDateFormat("MMMM d, yyyy", Locale.US);
		SimpleDateFormat outputTime = new SimpleDateFormat("h:mm a", Locale.US);

		try {
			Date startDate = input.parse(details.getStartDate());
			String formattedStartDate = outputDate.format(startDate);
			dateTime.append(formattedStartDate);

			Date endDate = input.parse(details.getEndDate());
			String formattedEndDate = outputDate.format(endDate);

			if (startDate.getTime() == 0 || endDate.getTime() == 0) {
				return null;
			}

			if (!formattedEndDate.equals(formattedStartDate)) {
				dateTime.append(" - \n");
				dateTime.append(formattedEndDate);
				dateTime.append("\n");
			} else {
				String formattedStartTime = outputTime.format(startDate);
				dateTime.append("\n");
				dateTime.append(formattedStartTime);
				dateTime.append(" - ");
				String formattedEndTime = outputTime.format(endDate);
				dateTime.append(formattedEndTime);
			}

		} catch (ParseException e) {
			// return null if the parsing fails
			return null;
		}

		return dateTime.toString();
	}
}
