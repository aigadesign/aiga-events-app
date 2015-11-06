package com.aiga.events.android.views;

import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;

public class ScrollSpeedAnimationListener implements OnScrollListener {

	private int previousFirstVisibleItem = 0;
	private long previousEventTime = 0;
	private long currentTime;
	private long timeToScrollOneElement;
	private double speed = 0;
	
	@Override
	public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
		if (previousFirstVisibleItem != firstVisibleItem) {
			currentTime = System.currentTimeMillis();
			timeToScrollOneElement = currentTime - previousEventTime;
			speed = ((double) 1 / timeToScrollOneElement) * 1000;
			
			previousFirstVisibleItem = firstVisibleItem;
			previousEventTime = currentTime;
		}
	}

	@Override
	public void onScrollStateChanged(AbsListView view, int scrollState) {
		// not implemented
	}

	public double getSpeed() {
		return speed;
	}
}
