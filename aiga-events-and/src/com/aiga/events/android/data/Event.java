package com.aiga.events.android.data;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.SerializedName;

public class Event implements Parcelable {
	@SerializedName("summary")
	private Summary mSummary;

	@SerializedName("event")
	private EventDetails mEventDetails;

	public Event(EventDetails eventDetails) {
		mEventDetails = eventDetails;
	}

	public Summary getSummary() {
		return mSummary;
	}

	public EventDetails getEventDetails() {
		return mEventDetails;
	}

	public Event(Parcel in) {
		readFromParcel(in);
	}

	@Override
	public int describeContents() {
		return 0;
	}

	private void readFromParcel(Parcel in) {
		mSummary = in.readParcelable(this.getClass().getClassLoader());
		mEventDetails = in.readParcelable(this.getClass().getClassLoader());
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeParcelable(mSummary, flags);
		dest.writeParcelable(mEventDetails, flags);
	}

	public static final Parcelable.Creator<Event> CREATOR = new Parcelable.Creator<Event>() {

		public Event createFromParcel(Parcel in) {
			return new Event(in);
		}

		public Event[] newArray(int size) {
			return new Event[size];
		}
	};
}
