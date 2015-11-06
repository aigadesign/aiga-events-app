package com.aiga.events.android.utils;

import android.util.Log;

import com.aiga.events.android.BuildConfig;

public class Logger {

	public static void d(String tag, String message) {
		if (BuildConfig.DEBUG) {
			Log.d(tag, message);
		}
	}
}
