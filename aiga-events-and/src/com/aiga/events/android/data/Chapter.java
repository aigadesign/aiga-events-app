package com.aiga.events.android.data;

import java.util.Date;

import android.os.Parcel;
import android.os.Parcelable;

import com.aiga.events.android.utils.Logger;

public class Chapter implements Parcelable, Comparable<Chapter> {

	private static final String TAG = "AIGAChapter";
	private static final long EVENT_REFRESH_INTERVAL = 86400000; // 24 hours

	private long mId;
	private boolean mIsSelected;
	private String mChapterName;
	private String mEventBriteId;
	private String mETouchesId;
	private long mEventTimestamp;

	public Chapter() {
		// intentionally left blank
	}

	public Chapter(String chapterName, String eventBriteId, String eTouchesId) {
		mChapterName = chapterName;
		mEventBriteId = eventBriteId;
		mETouchesId = eTouchesId;
	}

	public long getId() {
		return mId;
	}

	void setId(long id) {
		mId = id;
	}

	public boolean isSelected() {
		return mIsSelected;
	}

	public void setSelected(boolean isSelected) {
		mIsSelected = isSelected;
	}

	public boolean shouldDownloadEvents() {
		Date now = new Date();
		long timeSinceUpdate = now.getTime() - mEventTimestamp;
		boolean shouldDownload = (timeSinceUpdate > EVENT_REFRESH_INTERVAL);

		if (shouldDownload) {
			Logger.d(TAG, "Reloading expired events for chapter: " + mChapterName);
		}

		return shouldDownload;
	}

	public void setEventTimestampToCurrentTime() {
		Date now = new Date();
		mEventTimestamp = now.getTime();
	}

	public long getEventTimestamp() {
		return mEventTimestamp;
	}

	public void setEventTimestamp(long timeStamp) {
		mEventTimestamp = timeStamp;
	}

	public void resetEventTimestamp() {
		mEventTimestamp = 0;
	}

	public String getChapterName() {
		return mChapterName;
	}

	void setChapterName(String chapterName) {
		mChapterName = chapterName;
	}

	public String getEventId() {
		if (mEventBriteId != null) {
			return mEventBriteId;
		}

		return mETouchesId;
	}

	public String getEventBriteId() {
		return mEventBriteId;
	}

	void setEventBriteId(String eventBriteId) {
		mEventBriteId = eventBriteId;
	}

	public String getETouchesId() {
		return mETouchesId;
	}

	void setETouchesId(String eTouchesId) {
		mETouchesId = eTouchesId;
	}

	public boolean isEventBriteChapter() {
		return (mEventBriteId != null);
	}

	public boolean isETouchesChapter() {
		return (mETouchesId != null);
	}
	
	public int getEventLoaderId() {
		return this.hashCode();
	}

	public Chapter(Parcel in) {
		readFromParcel(in);
	}

	@Override
	public int describeContents() {
		return 0;
	}

	private void readFromParcel(Parcel in) {
		mId = in.readLong();
		mChapterName = in.readString();
		mIsSelected = in.readByte() == 1 ? true : false;
		mEventBriteId = in.readString();
		mETouchesId = in.readString();
		mEventTimestamp = in.readLong();
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeLong(mId);
		dest.writeString(mChapterName);
		dest.writeByte((byte) (mIsSelected ? 1 : 0));
		dest.writeString(mEventBriteId);
		dest.writeString(mETouchesId);
		dest.writeLong(mEventTimestamp);
	}

	public static final Parcelable.Creator<Chapter> CREATOR = new Parcelable.Creator<Chapter>() {

		@Override
		public Chapter createFromParcel(Parcel in) {
			return new Chapter(in);
		}

		@Override
		public Chapter[] newArray(int size) {
			return new Chapter[size];
		}
	};

	@Override
	public int compareTo(Chapter another) {
		return this.getChapterName().compareTo(another.getChapterName());
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((mChapterName == null) ? 0 : mChapterName.hashCode());
		result = prime * result + ((getEventId() == null) ? 0 : getEventId().hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Chapter other = (Chapter) obj;
		if (mChapterName == null) {
			if (other.mChapterName != null)
				return false;
		} else if (!mChapterName.equals(other.mChapterName))
			return false;
		if (getEventId() == null) {
			if (other.getEventId() != null)
				return false;
		} else if (!getEventId().equals(other.getEventId()))
			return false;
		return true;
	}
}
