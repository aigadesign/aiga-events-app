package com.aiga.events.android.data;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.SerializedName;

public class TicketDetails implements Parcelable {

	@SerializedName("currency")
	private String mCurrency;

	@SerializedName("display_price")
	private String mDisplayPrice = "-1";

	public String getCurrency() {
		return mCurrency;
	}

	public String getDisplayPrice() {
		return mDisplayPrice;
	}

	public TicketDetails(Parcel in) {
		readFromParcel(in);
	}

	@Override
	public int describeContents() {
		return 0;
	}

	private void readFromParcel(Parcel in) {
		mCurrency = in.readString();
		mDisplayPrice = in.readString();
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(mCurrency);
		dest.writeString(mDisplayPrice);
	}

	public static final Parcelable.Creator<TicketDetails> CREATOR = new Parcelable.Creator<TicketDetails>() {

		@Override
		public TicketDetails createFromParcel(Parcel in) {
			return new TicketDetails(in);
		}

		@Override
		public TicketDetails[] newArray(int size) {
			return new TicketDetails[size];
		}
	};
}
