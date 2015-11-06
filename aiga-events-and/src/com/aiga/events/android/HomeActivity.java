package com.aiga.events.android;


import android.content.SharedPreferences;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.Configuration;
import android.os.Bundle;
import android.support.v4.app.ActionBarDrawerToggle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarActivity;
import android.util.TypedValue;
import android.view.MenuItem;
import android.view.View;
import android.widget.FrameLayout;

import com.aiga.events.android.fragment.ChapterFragment;
import com.aiga.events.android.fragment.DrawerFragment;
import com.aiga.events.android.fragment.EventsPagerFragment;
import com.aiga.events.android.fragment.LaunchFragment;
import com.aiga.events.android.utils.Logger;
import com.aiga.events.android.utils.Utils;
import com.parse.Parse;
import com.parse.ParseAnalytics;

public class HomeActivity extends ActionBarActivity implements INavigationListener {

	private static final String TAG = "AIGAHomeActivity";
	public static final String EVENTS_DOWNLOADED_FLAG = "eventsDownloaded";
	private static final String PARSE_CLIENT_KEY = "xuAVpQYkuTnjLoNx1VUe0O1G25oK5OPpnqh4SJWX";
	private static final String PARSE_APPLICATION_ID = "4Utrt6Ok4pkIsiAJT95ih0sFtZjtXz1HKEcoS2ug";

	private DrawerLayout mDrawerLayout = null;
	private ActionBarDrawerToggle mDrawerToggle = null;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		initParse();
		setContentView(R.layout.activity_home);

		mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);

		mDrawerToggle = new ActionBarDrawerToggle(
				this,                  /* host Activity */
				mDrawerLayout,         /* DrawerLayout object */
				R.drawable.ic_drawer,  /* nav drawer image to replace 'Up' caret */
				R.string.drawer_open,  /* "open drawer" description for accessibility */
				R.string.drawer_close  /* "close drawer" description for accessibility */
				) {	// empty block
		};

		Fragment drawerFragment = DrawerFragment.newInstance(this);
		getSupportFragmentManager().beginTransaction().add(R.id.drawer_container, drawerFragment, DrawerFragment.FRAGMENT_MANAGER_TAG).commit();

		mDrawerLayout.setDrawerListener(mDrawerToggle);

		if (Utils.isFirstLaunch()) {
			showLaunchFragment();
		} else if (Utils.isUpgrade(this)) {
			SharedPreferences.Editor editor = AIGAApplication.getSharedPreferences().edit();
			editor.putBoolean(Utils.FIRST_LAUNCH_TAG, true);
			editor.commit();
			showLaunchFragment();
		} else {
			enableDrawerOnActionBar();
			showEventPagerFragment();
		}
	}

	private void initParse() {
		Logger.d(TAG, "Initializing Parse");
		Parse.initialize(this, PARSE_APPLICATION_ID, PARSE_CLIENT_KEY);
		ParseAnalytics.trackAppOpened(getIntent());
	}

	private void enableDrawerOnActionBar() {
		mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED);
		getSupportActionBar().setDisplayHomeAsUpEnabled(true);
		getSupportActionBar().setDisplayShowHomeEnabled(true);
		getSupportActionBar().setIcon(android.R.color.transparent);
		getSupportActionBar().setDisplayShowTitleEnabled(true);
	}

	private void showLaunchFragment() {
		getSupportActionBar().hide();
		mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
		getSupportActionBar().setDisplayShowTitleEnabled(true);
		getSupportActionBar().setTitle(getString(R.string.action_bar_title_chapters));
		getSupportFragmentManager().beginTransaction().replace(R.id.main_container, new LaunchFragment(), null)
				.addToBackStack(null).commit();
	}

	@Override
	public void exitLaunchFragment() {
		getSupportActionBar().show();

		FragmentManager fm = getSupportFragmentManager();
		fm.popBackStack();

		FragmentTransaction ft = fm.beginTransaction();
		ft.replace(R.id.main_container, ChapterFragment.newInstance(), ChapterFragment.FRAGMENT_MANAGER_TAG);
		ft.addToBackStack(null);
		ft.commit();
	}

	@Override
	public void onChaptersDoneClicked() {
		SharedPreferences.Editor editor = AIGAApplication.getSharedPreferences().edit();
		int currentVersion = -1; // Default (non-existent) version code
		try {
			currentVersion = getPackageManager().getPackageInfo(getPackageName(), 0).versionCode;
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}
		editor.putInt(Utils.VERSION_TAG, currentVersion);
		editor.putBoolean(Utils.FIRST_LAUNCH_TAG, false);
		editor.commit();

		enableDrawerOnActionBar();

		getSupportFragmentManager().popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);
		Fragment eventsPagerFrag = EventsPagerFragment.newInstance();
		getSupportFragmentManager().beginTransaction()
				.replace(R.id.main_container, eventsPagerFrag, EventsPagerFragment.FRAGMENT_MANAGER_TAG)
				.addToBackStack(null).commit();
	}

	private void showEventPagerFragment() {
		if (getSupportFragmentManager().findFragmentByTag(EventsPagerFragment.FRAGMENT_MANAGER_TAG) == null) {
			getSupportFragmentManager()
					.beginTransaction()
					.replace(R.id.main_container, new EventsPagerFragment(), EventsPagerFragment.FRAGMENT_MANAGER_TAG)
					.addToBackStack(null).commit();
		}
	}

	@Override
	public void closingDrawerTransaction() {
		mDrawerLayout.closeDrawers();
	}

	@Override
	protected void onPostCreate(Bundle savedInstanceState) {
		super.onPostCreate(savedInstanceState);
		mDrawerToggle.syncState();
		setWindowContentOverlayCompat();
	}

	// http://stackoverflow.com/questions/17945785/what-happened-to-windowcontentoverlay-in-android-api-18/18093909#18093909
	private void setWindowContentOverlayCompat() {
	    if (android.os.Build.VERSION.SDK_INT == android.os.Build.VERSION_CODES.JELLY_BEAN_MR2) {
	        // Get the content view
	        View contentView = findViewById(android.R.id.content);

	        // Make sure it's a valid instance of a FrameLayout
	        if (contentView instanceof FrameLayout) {
	            TypedValue tv = new TypedValue();

	            // Get the windowContentOverlay value of the current theme
	            if (getTheme().resolveAttribute(
	                    android.R.attr.windowContentOverlay, tv, true)) {

	                // If it's a valid resource, set it as the foreground drawable
	                // for the content view
	                if (tv.resourceId != 0) {
	                    ((FrameLayout) contentView).setForeground(getResources().getDrawable(tv.resourceId));
	                }
	            }
	        }
	    }
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		mDrawerToggle.onConfigurationChanged(newConfig);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		if (mDrawerToggle.onOptionsItemSelected(item)) {
			return true;
		}
		switch (item.getItemId()) {
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	@Override
	public void onBackPressed() {
		if (getSupportFragmentManager().getBackStackEntryCount() == 1) {
			this.finish();
		} else {
			getSupportFragmentManager().popBackStack();
		}
	}
}