package com.aiga.events.android.utils;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;

import android.content.SharedPreferences;

import com.aiga.events.android.AIGAApplication;

public class URLUtils {

	private static final String ETOUCHES_EVENT_URL = "https://www.eiseverywhere.com/api/v2/ereg/getEvent.json?";
	private static final String EVENT_BRITE_URL = "https://www.eventbrite.com/json/event_search?app_key=";
	private static final String EVENT_BRITE_PARSE_NAME = "eventbrite";
	private static final String ETOUCHES_URL = "https://www.eiseverywhere.com/api/v2/global/searchEvents.json?accesstoken=";

	public static String buildEventBriteUrlString(String eventId) throws UnsupportedEncodingException {
		StringBuilder url = new StringBuilder();
		url.append(EVENT_BRITE_URL);
		url.append(getApiKey(EVENT_BRITE_PARSE_NAME));
		url.append("&organizer=");
		url.append(URLEncoder.encode(eventId, "ISO-8859-1"));
		return url.toString();
	}

	public static String buildETouchesUrlString(String eventId, String authToken) throws UnsupportedEncodingException {
		StringBuilder urlStringBuilder = new StringBuilder();
		urlStringBuilder.append(ETOUCHES_URL);
		urlStringBuilder.append(URLEncoder.encode(authToken, "ISO-8859-1"));

		// This is an arbitrary date in the future
		urlStringBuilder.append("&enddate=");
		urlStringBuilder.append("4000-12-31");

		urlStringBuilder.append("&folderid=");
		urlStringBuilder.append(eventId);

		// Use yesterday for start date
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd", Locale.US);
		Calendar cal = Calendar.getInstance();
		cal.add(Calendar.DATE, -1);
		String yesterdayString = format.format(cal.getTime());
		urlStringBuilder.append("&startdate=");
		urlStringBuilder.append(yesterdayString);

		return urlStringBuilder.toString();
	}


	public static String buildETouchesEventUrlString(String authToken, String eventId) {
		StringBuilder urlStringBuilder = new StringBuilder();

		urlStringBuilder.append(ETOUCHES_EVENT_URL);
		urlStringBuilder.append("accesstoken=");
		urlStringBuilder.append(authToken);
		urlStringBuilder.append("&eventid=");
		urlStringBuilder.append(eventId);

		return urlStringBuilder.toString();
	}

	public static String getApiKey(String eventType) {
		SharedPreferences prefs = AIGAApplication.getSharedPreferences();
		String eventTypeKey = eventType + Utils.API_KEY_APPEND;
		return prefs.getString(eventTypeKey, "");
	}
}
