package com.aiga.events.android;

import android.app.Application;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import com.ubermind.http.cache.BitmapCache;

public class AIGAApplication extends Application {

    private static AIGAApplication sInstance;
    private static String sAuthToken;

    public AIGAApplication() {
        sInstance = this;
    }

	@Override
	public void onCreate() {
		super.onCreate();

		// The default cache size for UberHttp is much lower than needed for
		// modern devices. This sets the cache size based on the memory class of
		// the device
		BitmapCache.setCacheSizeBasedMemoryClass(getApplicationContext());
	}

	public static int getDeviceAPIVersion() {
		return android.os.Build.VERSION.SDK_INT;
	}

    public static AIGAApplication getInstance() {
        return sInstance;
    }

    public static SharedPreferences getSharedPreferences() {
        return PreferenceManager.getDefaultSharedPreferences(sInstance);
    }

    public static String getETouchesAccessToken() {
        return sAuthToken;
    }

    public static void setETouchesAccessToken(String authToken) {
        sAuthToken = authToken;
    }
}