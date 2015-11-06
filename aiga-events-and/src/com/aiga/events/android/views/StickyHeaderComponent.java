package com.aiga.events.android.views;

import android.annotation.SuppressLint;
import android.view.View;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.ScrollView;

import com.aiga.events.android.R;
import com.aiga.events.android.views.EventDetailsScrollView.ScrollViewListener;

public class StickyHeaderComponent {
	private EventDetailsScrollView mScrollView;
	private OnGlobalLayoutListener mScrollViewGlobalLayoutListener;
	private OnGlobalLayoutListener mStickyHeaderGlobalLayoutListener;
	private View mStickyHeader;
	private View mPlaceHolderHeader;
	private View mStickyHeaderShadow;
	private View mStickyHeaderDivider;
	private int mStickyHeaderHeight = 0;

	public void init(View container, int observableScrollViewId, int headerId, int placeHolderHeaderId) {
		mScrollView = (EventDetailsScrollView) container.findViewById(observableScrollViewId);
		mStickyHeader = container.findViewById(headerId);
		mPlaceHolderHeader = container.findViewById(placeHolderHeaderId);
		mStickyHeaderShadow = mStickyHeader.findViewById(R.id.sticky_header_dropshadow);
		mStickyHeaderDivider = mStickyHeader.findViewById(R.id.sticky_header_divider);

		mScrollView.setScrollViewListener(new ScrollViewListener() {

			@Override
			public void onScrollChanged(ScrollView scrollView, int x, int y, int oldx, int oldy) {
				onScroll(scrollView);
			}
		});

		mScrollViewGlobalLayoutListener = new OnGlobalLayoutListener() {

			@Override
			public void onGlobalLayout() {
				onScroll(mScrollView);
			}
		};

		mScrollView.getViewTreeObserver().addOnGlobalLayoutListener(mScrollViewGlobalLayoutListener);

		mStickyHeaderGlobalLayoutListener = new OnGlobalLayoutListener() {

			@Override
			public void onGlobalLayout() {
				int height = mStickyHeader.getHeight();
				if (height > 0 && mStickyHeaderHeight != height) {
					mPlaceHolderHeader
							.setLayoutParams(new LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, height));
					mStickyHeaderHeight = height;
				}
			}
		};

		mStickyHeader.getViewTreeObserver().addOnGlobalLayoutListener(mStickyHeaderGlobalLayoutListener);
	}

	protected void onScroll(ScrollView scrollView) {
		int topPos = mPlaceHolderHeader.getTop() + ((View) mPlaceHolderHeader.getParent()).getTop();

		if (scrollView.getScrollY() < topPos) {
			int diff = (topPos - mStickyHeader.getTop()) - scrollView.getScrollY();
			mStickyHeaderDivider.setVisibility(View.VISIBLE);
			mStickyHeaderShadow.setVisibility(View.INVISIBLE);
			mStickyHeader.offsetTopAndBottom(diff);
		} else {
			setHeaderZoom(scrollView, topPos);
			mStickyHeaderDivider.setVisibility(View.INVISIBLE);
			mStickyHeaderShadow.setVisibility(View.VISIBLE);
			mStickyHeader.offsetTopAndBottom(-mStickyHeader.getTop());
		}
	}

	private void setHeaderZoom(ScrollView scrollView, int topPos) {
		int diff = (scrollView.getScrollY() - topPos);
		float zoom = (1.0f + (diff / (float) scrollView.getHeight()));
		if (zoom <= 1.03f) {
			mStickyHeader.setScaleX(zoom);
			mStickyHeader.setScaleY(zoom);
		}
	}
	
	public void destroy() {
		removeLayoutListeners();
		mScrollViewGlobalLayoutListener = null;
		mStickyHeaderGlobalLayoutListener = null;
		mScrollView.setScrollViewListener(null);
		mScrollView = null;
		mStickyHeader = null;
		mStickyHeaderShadow = null;
		mStickyHeaderDivider = null;
		mPlaceHolderHeader = null;
	}

	@SuppressLint("NewApi")
	@SuppressWarnings("deprecation")
	private void removeLayoutListeners() {
		if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN) {
			mScrollView.getViewTreeObserver().removeOnGlobalLayoutListener(mScrollViewGlobalLayoutListener);
			mStickyHeader.getViewTreeObserver().removeOnGlobalLayoutListener(mStickyHeaderGlobalLayoutListener);
		} else {
			mScrollView.getViewTreeObserver().removeGlobalOnLayoutListener(mScrollViewGlobalLayoutListener);
			mStickyHeader.getViewTreeObserver().removeGlobalOnLayoutListener(mStickyHeaderGlobalLayoutListener);
		}
	}
}
