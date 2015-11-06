package com.aiga.events.android.data;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class AigaSQLiteHelper extends SQLiteOpenHelper {

	private static final String DB_NAME = "aiga.db";
	private static final int DB_VERSION = 2;

	public static final String TABLE_CHAPTERS = "tableChapters";
	public static final String COLUMN_ID = "_id";
	public static final String COLUMN_CHAPTER_NAME = "chapterName";
	public static final String COLUMN_EVENT_BRITE_ID = "eventBriteId";
	public static final String COLUMN_IS_SELECTED = "isSelected";
	public static final String COLUMN_ETOUCHES_ID = "eTouchesId";
	public static final String COLUMN_EVENT_TIMESTAMP = "eventTimestamp";

	public static final String TABLE_EVENTS = "tableEvents";
	public static final String COLUMN_CHAPTER_ID = "chapterId";
	public static final String COLUMN_DESCRIPTION = "eventDescription";
	public static final String COLUMN_TITLE = "eventTitle";
	public static final String COLUMN_START_DATE = "eventStartDate";
	public static final String COLUMN_END_DATE = "eventEndDate";
	public static final String COLUMN_TIMEZONE = "eventTimezone";
	public static final String COLUMN_THUMBNAIL_URL = "eventThumbnailUrl";
	public static final String COLUMN_LOGO_URL = "eventLogoUrl";
	public static final String COLUMN_CITY = "venueCity";
	public static final String COLUMN_REGION = "venueRegion";
	public static final String COLUMN_POSTAL_CODE = "venuePostalCode";
	public static final String COLUMN_ADDRESS = "venueAddress";
	public static final String COLUMN_ADDRESS2 = "venueAddress2";
	public static final String COLUMN_TICKET_URL = "ticketUrl";
	public static final String COLUMN_PRICE_RANGE = "priceRange";
	public static final String COLUMN_LOCATION_NAME = "locationName";
	public static final String COLUMN_EMPTY = "emptyVenue";
	
	// Note: the chapter name is treated as a unique id here, but in the data object
	// equals compares name and event id
	private static final String CHAPTER_TABLE_CREATE = "create table " + TABLE_CHAPTERS + "(" + COLUMN_ID
			+ " integer primary key autoincrement, " + COLUMN_CHAPTER_NAME + " text not null, " + COLUMN_EVENT_BRITE_ID
			+ ", " + COLUMN_IS_SELECTED + " integer not null, " + COLUMN_ETOUCHES_ID + ", " + COLUMN_EVENT_TIMESTAMP
			+ " integer, unique(" + COLUMN_CHAPTER_NAME + ") on conflict replace);";

	// Note: there's some confusion regarding an appropriate unique ID. Currently checking the
	// event title, start date, and end date for uniqueness
	private static final String EVENT_TABLE_CREATE = "create table " + TABLE_EVENTS + "(" + COLUMN_ID
			+ " integer primary key autoincrement, " + COLUMN_CHAPTER_ID + ", " + COLUMN_DESCRIPTION + ", "
			+ COLUMN_TITLE + ", " + COLUMN_START_DATE + " integer, " + COLUMN_END_DATE + " integer, " + COLUMN_TIMEZONE
			+ ", " + COLUMN_THUMBNAIL_URL + ", " + COLUMN_LOGO_URL + ", " + COLUMN_CITY + ", " + COLUMN_REGION + ", "
			+ COLUMN_POSTAL_CODE + ", " + COLUMN_ADDRESS + ", " + COLUMN_ADDRESS2 + ", " + COLUMN_TICKET_URL + ", "
			+ COLUMN_PRICE_RANGE + ", " + COLUMN_LOCATION_NAME + ", " + COLUMN_EMPTY + ", unique(" + COLUMN_TITLE + ", " + COLUMN_START_DATE
			+ ", " + COLUMN_END_DATE + ") on conflict replace );";

	public AigaSQLiteHelper(Context context) {
		super(context, DB_NAME, null, DB_VERSION);
	}

	@Override
	public void onCreate(SQLiteDatabase db) {
		db.execSQL(CHAPTER_TABLE_CREATE);
		db.execSQL(EVENT_TABLE_CREATE);
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		db.execSQL("DROP TABLE IF EXISTS " + TABLE_CHAPTERS);
		db.execSQL("DROP TABLE IF EXISTS " + TABLE_EVENTS);
		onCreate(db);
	}
}