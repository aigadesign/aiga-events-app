package com.aiga.events.android.data;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.SerializedName;

public class Summary implements Parcelable {
	@SerializedName("total_items")
	public String mTotalItems;

	public Summary(Parcel in) {
		readFromParcel(in);
	}

	@Override
	public int describeContents() {
		return 0;
	}

	private void readFromParcel(Parcel in) {
		mTotalItems = in.readString();
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(mTotalItems);
	}

	public static final Parcelable.Creator<Summary> CREATOR = new Parcelable.Creator<Summary>() {

		public Summary createFromParcel(Parcel in) {
			return new Summary(in);
		}

		public Summary[] newArray(int size) {
			return new Summary[size];
		}
	};
}
