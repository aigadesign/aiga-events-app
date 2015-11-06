package com.aiga.events.android.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.webkit.WebView;
import android.widget.ScrollView;

public class EventDetailsScrollView extends ScrollView {

	private ScrollViewListener mScrollListener;

	public interface ScrollViewListener {
		void onScrollChanged(ScrollView scrollView, int x, int y, int oldx, int oldy);
	}

	public EventDetailsScrollView(Context context) {
		super(context);
	}

	public EventDetailsScrollView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public EventDetailsScrollView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	public void setScrollViewListener(ScrollViewListener scrollViewListener) {
		mScrollListener = scrollViewListener;
	}

	@Override
	protected void onScrollChanged(int x, int y, int oldx, int oldy) {
		super.onScrollChanged(x, y, oldx, oldy);
		if (mScrollListener != null) {
			mScrollListener.onScrollChanged(this, x, y, oldx, oldy);
		}
	}

	@Override
	public void requestChildFocus(View child, View focused) {

		if (focused instanceof WebView) {
			return;
		}

		super.requestChildFocus(child, focused);
	}
}
