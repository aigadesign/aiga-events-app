package com.aiga.events.android.data;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.annotations.SerializedName;

public class Venue implements Parcelable {
	@SerializedName("city")
	private String mCity;

	@SerializedName("region")
	private String mRegion;

	@SerializedName("postal_code")
	private String mPostalCode;

	@SerializedName("address")
	private String mAddress;

	@SerializedName("address_2")
	private String mAddress2;

	@SerializedName("name")
	private String mName;

	private boolean mEmpty = false;
	
	public Venue(String city, String state, String postalCode, String address, String address2, String name, boolean empty) {
		mCity = city;
		mRegion = state;
		mPostalCode = postalCode;
		mAddress = address;
		mAddress2 = address2;
		mName = name;
		mEmpty = empty;
	}

	public String getCity() {
		return mCity;
	}

	public String getRegion() {
		return mRegion;
	}

	public String getPostalCode() {
		return mPostalCode;
	}

	public String getAddress() {
		return mAddress;
	}

	public String getAddress2() {
		return mAddress2;
	}

	public String getName() {
		return mName;
	}

	public boolean getEmpty() {
		return mEmpty;
	}
	
	public Venue(Parcel in) {
		readFromParcel(in);
	}

	@Override
	public int describeContents() {
		return 0;
	}

	private void readFromParcel(Parcel in) {
		mCity = in.readString();
		mRegion = in.readString();
		mPostalCode = in.readString();
		mAddress = in.readString();
		mAddress2 = in.readString();
		mName = in.readString();
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(mCity);
		dest.writeString(mRegion);
		dest.writeString(mPostalCode);
		dest.writeString(mAddress);
		dest.writeString(mAddress2);
		dest.writeString(mName);
	}

	public static final Parcelable.Creator<Venue> CREATOR = new Parcelable.Creator<Venue>() {

		@Override
		public Venue createFromParcel(Parcel in) {
			return new Venue(in);
		}

		@Override
		public Venue[] newArray(int size) {
			return new Venue[size];
		}
	};
}
