package com.aiga.events.android.data;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.SerializedName;

public class Organizer implements Parcelable {
	@SerializedName("url")
	private String mTicketUrl;

	public Organizer(String ticketUrl) {
		mTicketUrl = ticketUrl;
	}

	public String getTicketUrl() {
		return mTicketUrl;
	}

	public Organizer(Parcel in) {
		readFromParcel(in);
	}

	@Override
	public int describeContents() {
		return 0;
	}

	private void readFromParcel(Parcel in) {
		mTicketUrl = in.readString();
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(mTicketUrl);
	}

	public static final Parcelable.Creator<Organizer> CREATOR = new Parcelable.Creator<Organizer>() {

		public Organizer createFromParcel(Parcel in) {
			return new Organizer(in);
		}

		public Organizer[] newArray(int size) {
			return new Organizer[size];
		}
	};
}
