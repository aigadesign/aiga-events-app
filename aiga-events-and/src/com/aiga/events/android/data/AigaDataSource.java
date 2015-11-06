package com.aiga.events.android.data;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;

import com.aiga.events.android.utils.Utils;

public class AigaDataSource {

	private SQLiteDatabase mDatabase;
	private final AigaSQLiteHelper mDbHelper;

	private final String[] mChapterColumns = { AigaSQLiteHelper.COLUMN_ID, AigaSQLiteHelper.COLUMN_CHAPTER_NAME,
			AigaSQLiteHelper.COLUMN_EVENT_BRITE_ID, AigaSQLiteHelper.COLUMN_IS_SELECTED,
			AigaSQLiteHelper.COLUMN_ETOUCHES_ID, AigaSQLiteHelper.COLUMN_EVENT_TIMESTAMP };

	private final String[] mEventColumns = { AigaSQLiteHelper.COLUMN_ID, AigaSQLiteHelper.COLUMN_CHAPTER_ID,
			AigaSQLiteHelper.COLUMN_DESCRIPTION, AigaSQLiteHelper.COLUMN_TITLE, AigaSQLiteHelper.COLUMN_START_DATE,
			AigaSQLiteHelper.COLUMN_END_DATE, AigaSQLiteHelper.COLUMN_TIMEZONE, AigaSQLiteHelper.COLUMN_THUMBNAIL_URL,
			AigaSQLiteHelper.COLUMN_LOGO_URL, AigaSQLiteHelper.COLUMN_CITY, AigaSQLiteHelper.COLUMN_REGION,
			AigaSQLiteHelper.COLUMN_POSTAL_CODE, AigaSQLiteHelper.COLUMN_ADDRESS, AigaSQLiteHelper.COLUMN_ADDRESS2,
			AigaSQLiteHelper.COLUMN_TICKET_URL, AigaSQLiteHelper.COLUMN_PRICE_RANGE,
			AigaSQLiteHelper.COLUMN_LOCATION_NAME, AigaSQLiteHelper.COLUMN_EMPTY };

	public AigaDataSource(Context context) {
		mDbHelper = new AigaSQLiteHelper(context);
	}

	public void open() throws SQLException {
		mDatabase = mDbHelper.getWritableDatabase();
	}

	public void close() {
		mDbHelper.close();
	}

	public void updateChapter(Chapter chapter) {
		ContentValues values = new ContentValues();

		values.put(AigaSQLiteHelper.COLUMN_CHAPTER_NAME, chapter.getChapterName());
		values.put(AigaSQLiteHelper.COLUMN_EVENT_BRITE_ID, chapter.getEventBriteId());
		values.put(AigaSQLiteHelper.COLUMN_IS_SELECTED, Integer.valueOf((chapter.isSelected() ? 1 : 0)));
		values.put(AigaSQLiteHelper.COLUMN_ETOUCHES_ID, chapter.getETouchesId());
		values.put(AigaSQLiteHelper.COLUMN_EVENT_TIMESTAMP, chapter.getEventTimestamp());

		mDatabase.insert(AigaSQLiteHelper.TABLE_CHAPTERS, null, values);
	}

	public void deleteEventsForChapter(Chapter chapter) {
		String whereClause = AigaSQLiteHelper.COLUMN_CHAPTER_ID + " = ?";
		String[] whereArgs = new String[1];
		whereArgs[0] = chapter.getChapterName();
		mDatabase.delete(AigaSQLiteHelper.TABLE_EVENTS, whereClause, whereArgs);
	}

	public void updateEvent(Chapter chapter, Event event) {
		ContentValues values = new ContentValues();

		EventDetails details = event.getEventDetails();
		Venue venue = details.getVenue();

		values.put(AigaSQLiteHelper.COLUMN_CHAPTER_ID, chapter.getChapterName());
		values.put(AigaSQLiteHelper.COLUMN_DESCRIPTION, details.getDescription());
		values.put(AigaSQLiteHelper.COLUMN_TITLE, details.getTitleHtmlFree());
		values.put(AigaSQLiteHelper.COLUMN_START_DATE, convertDateToTimestamp(details.getStartDateFormatDate()));
		values.put(AigaSQLiteHelper.COLUMN_END_DATE, convertDateToTimestamp(details.getEndDateFormatDate()));
		values.put(AigaSQLiteHelper.COLUMN_TIMEZONE, details.getTimeZone());
		values.put(AigaSQLiteHelper.COLUMN_THUMBNAIL_URL, details.getActualThumbnailUrl());
		values.put(AigaSQLiteHelper.COLUMN_LOGO_URL, details.getLogoUrl());
		values.put(AigaSQLiteHelper.COLUMN_CITY, venue.getCity());
		values.put(AigaSQLiteHelper.COLUMN_REGION, venue.getRegion());
		values.put(AigaSQLiteHelper.COLUMN_POSTAL_CODE, venue.getPostalCode());
		values.put(AigaSQLiteHelper.COLUMN_ADDRESS, venue.getAddress());
		values.put(AigaSQLiteHelper.COLUMN_ADDRESS2, venue.getAddress2());
		values.put(AigaSQLiteHelper.COLUMN_TICKET_URL, details.getOrganizer().getTicketUrl());
		values.put(AigaSQLiteHelper.COLUMN_PRICE_RANGE, details.getPriceRange());
		values.put(AigaSQLiteHelper.COLUMN_LOCATION_NAME, details.getVenue().getName());
		values.put(AigaSQLiteHelper.COLUMN_EMPTY, String.valueOf(venue.getEmpty()));
		
		mDatabase.insert(AigaSQLiteHelper.TABLE_EVENTS, null, values);
	}

	private static long convertDateToTimestamp(Date date) {
		// Some special handling is needed here for bad date values
		if (date == null) {
			return 0;
		}
		return date.getTime();
	}

	private static String convertTimestampToDateString(long timestamp) {
		Calendar calendar = Calendar.getInstance();
		calendar.setTimeInMillis(timestamp);
		SimpleDateFormat format = new SimpleDateFormat(Utils.DATE_FORMAT, Locale.US);
		String dateString = format.format(calendar.getTime());
		return dateString;
	}

	public List<Chapter> getChapters(boolean selectedOnly) {
		List<Chapter> chapters = new ArrayList<Chapter>();

		Cursor cursor;

		if (selectedOnly) {
			String whereClause = AigaSQLiteHelper.COLUMN_IS_SELECTED + " = ?";
			String[] whereArgs = new String[] { "1" };
			cursor = mDatabase.query(AigaSQLiteHelper.TABLE_CHAPTERS, mChapterColumns, whereClause, whereArgs, null,
					null, null);
		} else {
			cursor = mDatabase.query(AigaSQLiteHelper.TABLE_CHAPTERS, mChapterColumns, null, null, null, null, null);
		}

		cursor.moveToFirst();

		while (!cursor.isAfterLast()) {
			Chapter chapter = cursorToChapter(cursor);
			chapters.add(chapter);
			cursor.moveToNext();
		}

		cursor.close();

		Collections.sort(chapters);
		return chapters;
	}

	public Map<Chapter, List<Event>> getEventsForChapters(List<Chapter> chapters, Date startDate, Date endDate) {
		Map<Chapter, List<Event>> eventMap = new HashMap<Chapter, List<Event>>();

		// TODO this could be done with an SQL IN comparison; see if there's a
		// significant performance impact
		for (Chapter chapter : chapters) {
			List<Event> events = new ArrayList<Event>();
			Cursor cursor;
			List<String> whereArgs = new LinkedList<String>();
			String whereClause;

			if (startDate != null && endDate != null) {
				long startTimestamp = convertDateToTimestamp(startDate);
				long endTimestamp = convertDateToTimestamp(endDate);
				whereArgs.add(chapter.getChapterName());
				whereArgs.add(String.valueOf(startTimestamp));
				whereArgs.add(String.valueOf(endTimestamp));
				whereArgs.add(String.valueOf(startTimestamp));
				whereArgs.add(String.valueOf(endTimestamp));
				whereArgs.add(String.valueOf(startTimestamp));
				whereArgs.add(String.valueOf(endTimestamp));
				whereClause = AigaSQLiteHelper.COLUMN_CHAPTER_ID + " = ? AND ((" + AigaSQLiteHelper.COLUMN_START_DATE
						+ " BETWEEN ? AND ? OR " + AigaSQLiteHelper.COLUMN_END_DATE + " BETWEEN ? AND ?) OR ("
						+ AigaSQLiteHelper.COLUMN_START_DATE + " <= ? AND " + AigaSQLiteHelper.COLUMN_END_DATE
						+ " >= ?))";
			} else {
				whereArgs.add(chapter.getChapterName());
				whereClause = AigaSQLiteHelper.COLUMN_CHAPTER_ID + " = ?";
			}

			cursor = mDatabase.query(AigaSQLiteHelper.TABLE_EVENTS, mEventColumns, whereClause,
					whereArgs.toArray(new String[whereArgs.size()]), null, null,
					null);

			cursor.moveToFirst();

			while (!cursor.isAfterLast()) {
				Event event = cursorToEvent(cursor);
				events.add(event);
				cursor.moveToNext();
			}

			cursor.close();
			eventMap.put(chapter, events);
		}

		return eventMap;
	}

	public List<Event> getEventsForChapter(Chapter chapter) {
		List<Chapter> chapters = new ArrayList<Chapter>();
		chapters.add(chapter);
		Map<Chapter, List<Event>> eventMap = getEventsForChapters(chapters, null, null);
		return eventMap.get(chapter);
	}

	private static Chapter cursorToChapter(Cursor cursor) {
		Chapter chapter = new Chapter();
		chapter.setId(cursor.getLong(0));
		chapter.setChapterName(cursor.getString(1));
		chapter.setEventBriteId(cursor.getString(2));
		chapter.setSelected((cursor.getInt(3) == 1) ? true : false);
		chapter.setETouchesId(cursor.getString(4));
		chapter.setEventTimestamp(cursor.getLong(5));
		return chapter;
	}

	private Event cursorToEvent(Cursor cursor) {
		// id and chapterName currently unused
		// long id = cursor.getLong(0);
		// String chapterName = cursor.getString(1);

		String description = cursor.getString(2);
		String title = cursor.getString(3);
		String startDate = convertTimestampToDateString(cursor.getLong(4));
		String endDate = convertTimestampToDateString(cursor.getLong(5));
		String timezone = cursor.getString(6);
		String thumbnailUrl = cursor.getString(7);
		String logoUrl = cursor.getString(8);
		String city = cursor.getString(9);
		String region = cursor.getString(10);
		String postalCode = cursor.getString(11);
		String address = cursor.getString(12);
		String address2 = cursor.getString(13);
		String ticketUrl = cursor.getString(14);
		String priceRange = cursor.getString(15);
		String locationName = cursor.getString(16);
		boolean empty = Boolean.parseBoolean(cursor.getString(17));
		
		Organizer organizer = new Organizer(ticketUrl);
		Venue venue = new Venue(city, region, postalCode, address, address2, locationName, empty);
		EventDetails eventDetails = new EventDetails(description, title, startDate, endDate, logoUrl, thumbnailUrl,
				timezone, venue, organizer, priceRange);
		Event event = new Event(eventDetails);

		return event;
	}
}
