package com.aiga.events.android.utils;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import com.aiga.events.android.data.Chapter;
import com.aiga.events.android.data.Event;
import com.aiga.events.android.data.EventDetails;
import com.aiga.events.android.data.Organizer;
import com.aiga.events.android.data.Venue;
import com.google.gson.Gson;

public class JSONUtils {

	private static final String TAG = "AIGAJSONUtils";

	public static String parseAuthResult(JSONObject result) {
		return result.optString("accesstoken", null);
	}

	public static List<Event> parseEventBriteEvents(Chapter chapter, String result) {
		Gson gson = new Gson();
		List<Event> events = new ArrayList<Event>();

		try {
			JSONObject resultJson = new JSONObject(new JSONTokener(result));
			JSONArray eventsJson = resultJson.optJSONArray("events");

			for (int i = 0; i < eventsJson.length(); i++) {
				try {
					Event event = gson.fromJson(eventsJson.getString(i), Event.class);
					if (event.getEventDetails() != null) {
						event.getEventDetails().convertTicketsToPriceRange();
						events.add(event);
					}
				} catch (JSONException e) {
					Logger.d(TAG, "Error parsing event brite event: " + e);
				}
			}
		} catch (JSONException e) {
			Logger.d(TAG, "Error parsing event brite event list: " + e);
			Utils.notifyEventsError(chapter, e.toString());
		}

		return events;
	}

	public static Event parseETouchesEvent(JSONObject json) {
		String title = json.optString("name");
		String description = json.optString("description");
		String logoUrl = json.optString("clientcontact");
		String thumbnailUrl = json.optString("programmanager");

		String startDate = json.optString("startdate");
		String startTime = json.optString("starttime");
		String endDate = json.optString("enddate");
		String endTime = json.optString("endtime");
		String startDateTime = startDate + " " + startTime;
		String endDateTime = endDate + " " + endTime;
		String status = json.optString("status");

		JSONObject location = json.optJSONObject("location");
		Venue venue = null;

		if (location != null) {
			String city = location.optString("city");
			String state = location.optString("state");
			String postalCode = location.optString("postcode");
			String address = location.optString("address1");
			String address2 = location.optString("address2");
			String name = location.optString("name");
			venue = new Venue(city, state, postalCode, address, address2, name, false);
		}

		String ticketUrl = json.optString("url");
		Organizer organizer = new Organizer(ticketUrl);
		String timeZone = null;

		try {
			String rawTimeZone = json.optString("timezone");
			Pattern brackets = Pattern.compile("\\[(.*?)\\]");
			Matcher matcher = brackets.matcher(rawTimeZone);
			matcher.find();
			timeZone = matcher.group(1);
		} catch (Exception e) {
			Logger.d(TAG, "Error parsing time zone: " + e);
		}

		EventDetails details = new EventDetails(description, title, startDateTime, endDateTime, logoUrl, thumbnailUrl,
				timeZone, venue, organizer, null);

		// Events with other statuses should be ignored
		if (!status.equalsIgnoreCase("live")) {
			return null;
		}

		Event event = new Event(details);
		return event;
	}

	public static List<String> getEventIds(String result) throws JSONException {
		JSONArray resultJsonArray = new JSONArray(new JSONTokener(result));
		List<String> eventIds = new ArrayList<String>();

		for (int i = 0; i < resultJsonArray.length(); i++) {
			JSONObject eventJson = resultJsonArray.getJSONObject(i);

			if (eventJson.has("eventid")) {
				eventIds.add(eventJson.getString("eventid"));
			}
		}

		return eventIds;
	}

	public static boolean hasAuthError(String result) throws JSONException {
		JSONObject resultsJson = new JSONObject(new JSONTokener(result));
		JSONObject error = resultsJson.optJSONObject("error");
		return (error != null && error.has("authorized"));
	}
}