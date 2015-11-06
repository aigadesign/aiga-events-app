package com.aiga.events.android.data;

import java.text.NumberFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import android.os.Parcel;
import android.os.Parcelable;
import android.text.Html;

import com.aiga.events.android.AIGAApplication;
import com.aiga.events.android.R;
import com.aiga.events.android.utils.Utils;
import com.google.gson.annotations.SerializedName;

public class EventDetails implements Parcelable {

	@SerializedName("logo")
	private String mLogoUrl;

	@SerializedName("description")
	private String mDescription;

	@SerializedName("title")
	private String mTitle;

	@SerializedName("start_date")
	private String mStartDate;

	@SerializedName("end_date")
	private String mEndDate;

	@SerializedName("venue")
	private Venue mVenue;

	@SerializedName("organizer")
	private Organizer mOrganizer;

	@SerializedName("timezone_offset")
	private String mTimeZone;

	@SerializedName("tickets")
	private List<Ticket> mTickets;

	private String mPriceRange;
	private String mThumbnailUrl;

	public EventDetails(String description, String title, String startDate, String endDate, String logoUrl,
			String thumbnailUrl, String timeZone, Venue venue, Organizer organizer, String priceRange) {
		mLogoUrl = logoUrl;
		mDescription = description;
		mTitle = title;
		mStartDate = startDate;
		mEndDate = endDate;
		mVenue = venue;
		mOrganizer = organizer;
		mTimeZone = timeZone;
		mThumbnailUrl = thumbnailUrl;
		mPriceRange = priceRange;
	}

	public String getLogoUrl() {
		if (mLogoUrl == null || mLogoUrl.length() == 0) {
			return mThumbnailUrl;
		}

		return mLogoUrl;
	}

	public String getUrlForThumbnail() {
		return (hasThumbnailUrl() ? mThumbnailUrl : mLogoUrl);
	}

	public String getActualThumbnailUrl() {
		return mThumbnailUrl;
	}

	public boolean hasThumbnailUrl() {
		return mThumbnailUrl != null && mThumbnailUrl.length() > 0;
	}

	public String getDescriptionHtmlFree() {
		return Html.fromHtml(mDescription).toString();
	}

	public String getDescription() {
		return mDescription;
	}

	public String getTitleHtmlFree() {
		return Html.fromHtml(mTitle).toString();
	}

	public String getStartDate() {
		return mStartDate;
	}

	public Date getStartDateFormatDate() {
		SimpleDateFormat input = new SimpleDateFormat(Utils.DATE_FORMAT, Locale.US);
		Date date;
		try {
			date = input.parse(getStartDate());
			return date;
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return null;
	}

	public String getEndDate() {
		return mEndDate;
	}

	public Date getEndDateFormatDate() {
		SimpleDateFormat input = new SimpleDateFormat(Utils.DATE_FORMAT, Locale.US);
		Date date;
		try {
			date = input.parse(getEndDate());
			return date;
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return null;
	}

	public Venue getVenue() {
		// Initialize a blank venue in case of bad data:
		// Null/missing venue, null/missing venue name and address, or leading
		// character in venue address field is not a number
		if (mVenue == null) {
			mVenue = new Venue("", "", "", "", "", "", true);
			return mVenue;
		}
		
		String addr = mVenue.getAddress();
		if ((addr.equals("") && mVenue.getName().equals(""))
				|| (addr.length() > 0 && (addr.charAt(0) < '1' || addr.charAt(0) > '9'))) {
			String addr2 = mVenue.getAddress2();
			if ((addr2.equals("") && mVenue.getName().equals(""))
					|| (addr2.length() > 0 && (addr2.charAt(0) < '1' || addr2.charAt(0) > '9'))) {
				mVenue = new Venue("", "", "", "", "", "", true);
			}
		}

		return mVenue;
	}

	public String getVenueNameHtmlFree() {
		return Html.fromHtml(mVenue.getName()).toString();
	}

	public Organizer getOrganizer() {
		return mOrganizer;
	}

	public String getTimeZone() {
		return mTimeZone;
	}

	public String getPriceRange() {
		if (mPriceRange != null) {
			return mPriceRange;
		}

		return AIGAApplication.getInstance().getString(R.string.pricing_not_available);
	}

	public void convertTicketsToPriceRange() {
		float minPrice = 0;
		float maxPrice = 0;
		boolean pricesInitialized = false;

		for (Ticket ticket : mTickets) {

			String currency = ticket.getTicketDetails().getCurrency();

			if (currency != null && currency.equalsIgnoreCase("usd")) {
				String displayPriceString = ticket.getTicketDetails().getDisplayPrice();
				float displayPrice = 0.0f;

				// This is needed to handle cases where prices are badly
				// formatted or missing:
				try {
					displayPrice = Float.parseFloat(displayPriceString);
				} catch (NumberFormatException e) {
					displayPriceString = displayPriceString.replace(",", "").replace("$", "");
					displayPrice = Float.parseFloat(displayPriceString);
				} catch (NullPointerException e) {
					displayPrice = 0.0f;
				}

				if (displayPrice < minPrice || !pricesInitialized) {
					minPrice = displayPrice;
				}

				if (displayPrice > maxPrice || !pricesInitialized) {
					maxPrice = displayPrice;
				}

				pricesInitialized = true;
			}
		}

		NumberFormat format = NumberFormat.getCurrencyInstance();
		StringBuilder priceRange = new StringBuilder();

		if (minPrice <= 0) {
			priceRange.append("FREE");
		} else {
			priceRange.append(format.format(minPrice));
		}

		if (minPrice != maxPrice) {
			priceRange.append(" - ");
			priceRange.append(format.format(maxPrice));
		}

		mPriceRange = priceRange.toString();
	}

	public EventDetails(Parcel in) {
		readFromParcel(in);
	}

	@Override
	public int describeContents() {
		return 0;
	}

	private void readFromParcel(Parcel in) {
		mLogoUrl = in.readString();
		mDescription = in.readString();
		mTitle = in.readString();
		mStartDate = in.readString();
		mEndDate = in.readString();
		mVenue = in.readParcelable(this.getClass().getClassLoader());
		mOrganizer = in.readParcelable(this.getClass().getClassLoader());
		mThumbnailUrl = in.readString();
		mTimeZone = in.readString();
		mPriceRange = in.readString();
		mTickets = new ArrayList<Ticket>();
		in.readList(mTickets, this.getClass().getClassLoader());
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(mLogoUrl);
		dest.writeString(mDescription);
		dest.writeString(mTitle);
		dest.writeString(mStartDate);
		dest.writeString(mEndDate);
		dest.writeParcelable(mVenue, flags);
		dest.writeParcelable(mOrganizer, flags);
		dest.writeString(mThumbnailUrl);
		dest.writeString(mTimeZone);
		dest.writeString(mPriceRange);
		dest.writeList(mTickets);
	}

	public static final Parcelable.Creator<EventDetails> CREATOR = new Parcelable.Creator<EventDetails>() {

		@Override
		public EventDetails createFromParcel(Parcel in) {
			return new EventDetails(in);
		}

		@Override
		public EventDetails[] newArray(int size) {
			return new EventDetails[size];
		}
	};
}
