package com.aiga.events.android.fragment;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.media.ThumbnailUtils;
import android.util.SparseBooleanArray;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewPropertyAnimator;
import android.view.WindowManager;
import android.view.animation.DecelerateInterpolator;
import android.view.animation.Interpolator;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ProgressBar;

import com.aiga.events.android.AIGAApplication;
import com.aiga.events.android.R;
import com.aiga.events.android.data.Event;
import com.aiga.events.android.data.EventDetails;
import com.aiga.events.android.utils.Utils;
import com.aiga.events.android.views.ScrollSpeedAnimationListener;
import com.ubermind.http.cache.BitmapCache;
import com.ubermind.http.task.HttpBitmapLoadTask;

public abstract class BaseAnimatedListAdapter extends BaseAdapter {

	// Default values; some can be modified through the use of parameterized
	// constructor.
	protected static long ANIMATION_DEFAULT_SPEED = 500L; // milliseconds
	protected static final int SPEED_MULTIPLIER = 15000;
	protected static float ROTATE_X_START = 45.0f; // degrees
	protected static final float ROTATE_X_END = 0.0f; // ^
	protected static final float TRANS_X_START = 0.0f; // percentage
	protected static final float TRANS_X_END = 0.0f; // ^
	protected static final float TRANS_Y_END = 0.0f; // ^
	protected static final float SCALE_X_START = 0.7f; // ^
	protected static final float SCALE_Y_START = 0.55f; // ^
	protected static final float SCALE_X_END = 1.0f; // ^
	protected static final float SCALE_Y_END = 1.0f; // ^

	protected List<Event> mEvents;

	protected LayoutInflater mInflater = null;
	protected Interpolator mInterpolator;

	protected boolean mShouldAnimate = true;	// this value is set true by default
	
	protected SparseBooleanArray mViewedPositionMapper;
	protected int mHeight;
	protected int mWidth;
	protected int mPreviousPosition;
	protected ScrollSpeedAnimationListener mScrollListener;
	
	protected BaseAnimatedListAdapter(Context context, ScrollSpeedAnimationListener scrollListener, List<Event> mEvents) {
		initialize(context, scrollListener, mEvents);
	}

	protected BaseAnimatedListAdapter(Context context, ScrollSpeedAnimationListener scrollListener,
			List<Event> mEvents, long animationSpeed, float startAngle) {

		initialize(context, scrollListener, mEvents);
		ANIMATION_DEFAULT_SPEED = animationSpeed;
		ROTATE_X_START = startAngle;
	}

	@Override
	public int getCount() {
		if (mEvents != null) {
			return mEvents.size();
		}

		return 0;
	}

	@Override
	public Object getItem(int position) {
		if (mEvents != null && position < getCount()) {
			return mEvents.get(position);
		}
		return null;
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	protected Event getEvent(int position) {
		return mEvents.get(position);
	}

	protected void setEvents(List<Event> events) {
		mEvents = events;
	}

	@Override
	public abstract View getView(int position, View convertView, ViewGroup parent);

	protected void getThumbnailForView(ImageView view, ProgressBar progressBar, String urlString,
			boolean needsProcessing) {

		if (urlString == null || urlString.length() == 0) {
			view.setImageDrawable(AIGAApplication.getInstance().getResources().getDrawable(R.drawable.logo));
			return;
		}

		BitmapLoadTask task = new BitmapLoadTask(urlString, view, progressBar,
				HttpBitmapLoadTask.NO_DISPLAY_RESOURCE_ID, R.drawable.logo, needsProcessing);
		task.executeOnThreadPool();
	}

	class BitmapLoadTask extends HttpBitmapLoadTask {

		private static final int CACHE_EXPIRATION_OVERRIDE = 432000000;
		// 5 days; This is arbitrary

		private final boolean mNeedsProcessing;
		private final ProgressBar mProgressBar;

		public BitmapLoadTask(String url, ImageView imageView, ProgressBar progressBar, int waitingDrawable,
				int errorDrawable, boolean needsProcessing) {
			super(url, imageView, waitingDrawable, errorDrawable);
			mNeedsProcessing = needsProcessing;
			mProgressBar = progressBar;
		}

		@Override
		protected void onPreExecute() {
			mProgressBar.setVisibility(View.VISIBLE);
			super.onPreExecute();
		}

		@Override
		protected void onError() {
			mProgressBar.setVisibility(View.GONE);
			super.onError();
		}

		@Override
		protected void onCancelled() {
			mProgressBar.setVisibility(View.GONE);
			super.onCancelled();
		}

		@Override
		protected void onPostBitmapCached(Bitmap bitmap) {
			showThumbnailImage(bitmap);
		}

		@Override
		protected void onPostExecute(Bitmap result) {
			// Overriding the server cache directive which is often set to 0
			BitmapCache.getSingleton().putBitmap(getUrl(), result, CACHE_EXPIRATION_OVERRIDE);
			showThumbnailImage(result);
		}

		private void showThumbnailImage(Bitmap bitmap) {
			mProgressBar.setVisibility(View.GONE);
			ImageView view = getView();

			if (view == null) {
				return;
			}

			view.setTag(R.id.HttpBitmapLoadId, null);

			if (bitmap == null) {
				view.setImageResource(R.drawable.logo);
				return;
			}

			if (mNeedsProcessing) {
				Bitmap thumbnail = ThumbnailUtils.extractThumbnail(bitmap, 50, 50);
				view.setImageBitmap(thumbnail);
			} else {
				view.setImageBitmap(bitmap);
			}

		}
	}

	protected String getDateTimeDetailsText(Event event) {
		EventDetails details = event.getEventDetails();

		if (details.getStartDate() == null || details.getEndDate() == null) {
			return null;
		}

		StringBuilder dateTime = new StringBuilder();
		SimpleDateFormat input = new SimpleDateFormat(Utils.DATE_FORMAT, Locale.US);
		SimpleDateFormat dateFormat = new SimpleDateFormat("M/dd", Locale.US);

		try {
			Date startDate = input.parse(details.getStartDate());
			String formattedStartDate = dateFormat.format(startDate);
			dateTime.append(formattedStartDate);

			Date endDate = input.parse(details.getEndDate());
			String formattedEndDate = dateFormat.format(endDate);

			// Bad date handling: will set timestamp to 0 in case of parsing
			// errors further up the execution chain
			// in this case, we'll simply return null so that the view does not
			// display a date at all
			if (startDate.getTime() == 0 || endDate.getTime() == 0) {
				return null;
			}

			if (!formattedEndDate.equals(formattedStartDate)) {
				dateTime.append(" - ");
				dateTime.append(formattedEndDate);
			}

		} catch (ParseException e) {
			// throw out the entire date rather than make assumptions
			return null;
		}

		return dateTime.toString();
	}

	protected View getAnimatedView(int position, View convertView, ViewGroup parent) {

		final View view = getUnanimatedView(position, convertView, parent);

		if (AIGAApplication.getDeviceAPIVersion() >= android.os.Build.VERSION_CODES.ICE_CREAM_SANDWICH
				&& mShouldAnimate) {
			// the animation assignments only execute if the item has not yet
			// been displayed/animated
			if (view != null && !mViewedPositionMapper.get(position) && position > mPreviousPosition) {
				double speed = mScrollListener.getSpeed();
				long animationDuration;

				// determine animation speeds with respect to scroll speed
				if ((int) speed == 0) {
					animationDuration = ANIMATION_DEFAULT_SPEED;
				} else {
					animationDuration = (long) (1 / speed * SPEED_MULTIPLIER);
				}

				// limit animation speed to default values as needed
				if (animationDuration > ANIMATION_DEFAULT_SPEED) {
					animationDuration = ANIMATION_DEFAULT_SPEED;
				}

				mPreviousPosition = position;

				// define start positions for animated views
				view.setTranslationX(TRANS_X_START);
				view.setTranslationY(mHeight);
				view.setRotationX(ROTATE_X_START);
				view.setScaleX(SCALE_X_START);
				view.setScaleY(SCALE_Y_START);
				
				// define end positions for animated views
				ViewPropertyAnimator localViewPropertyAnimator = view.animate().rotationX(ROTATE_X_END)
						.translationX(TRANS_X_END).translationY(TRANS_Y_END).setDuration(animationDuration)
						.scaleX(SCALE_X_END).scaleY(SCALE_Y_END).setInterpolator(mInterpolator);

				// Execute the animation and mark the animated views to avoid repetition
				localViewPropertyAnimator.setStartDelay(0).start();
				mViewedPositionMapper.put(position, true);
			}
		}
		
		return view;
	}

	private void initialize(Context context, ScrollSpeedAnimationListener scrollListener, List<Event> mEvents) {
		mInflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

		this.mScrollListener = scrollListener;
		this.mEvents = mEvents;

		mPreviousPosition = -1;
		mViewedPositionMapper = new SparseBooleanArray(getCount());
		Point size = new Point();
		WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
		Display display = windowManager.getDefaultDisplay();
		display.getSize(size);
		mWidth = size.x;
		mHeight = size.y;
		mInterpolator = new DecelerateInterpolator();
	}

	public void setShouldAnimate(boolean shouldAnimate) {
		mShouldAnimate = shouldAnimate;
	}
	
	protected abstract View getUnanimatedView(int position, View convertView, ViewGroup parent);
}