package com.aiga.events.android.data;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.SerializedName;

public class Ticket implements Parcelable {

	@SerializedName("ticket")
	private TicketDetails mTicketDetails;

	public TicketDetails getTicketDetails() {
		return mTicketDetails;
	}

	public Ticket(Parcel in) {
		readFromParcel(in);
	}

	@Override
	public int describeContents() {
		return 0;
	}

	private void readFromParcel(Parcel in) {
		mTicketDetails = in.readParcelable(this.getClass().getClassLoader());
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeParcelable(mTicketDetails, flags);
	}

	public static final Parcelable.Creator<Ticket> CREATOR = new Parcelable.Creator<Ticket>() {

		public Ticket createFromParcel(Parcel in) {
			return new Ticket(in);
		}

		public Ticket[] newArray(int size) {
			return new Ticket[size];
		}
	};
}
