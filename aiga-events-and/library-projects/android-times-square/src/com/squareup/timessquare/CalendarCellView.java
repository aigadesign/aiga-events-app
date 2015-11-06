// Copyright 2013 Square, Inc.

package com.squareup.timessquare;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.widget.TextView;

import com.squareup.timessquare.MonthCellDescriptor.RangeState;

public class CalendarCellView extends TextView {

	private static final int[] STATE_SELECTABLE = { R.attr.state_selectable };
	private static final int[] STATE_CURRENT_MONTH = { R.attr.state_current_month };
	private static final int[] STATE_TODAY = { R.attr.state_today };
	private static final int[] STATE_RANGE_FIRST = { R.attr.state_range_first };
	private static final int[] STATE_RANGE_MIDDLE = { R.attr.state_range_middle };
	private static final int[] STATE_RANGE_LAST = { R.attr.state_range_last };

	private static final int DAY_INDICATOR_WIDTH = 6;
	private static final int DAY_INDICATOR_OFFSET = 4;

	private final Paint currentDayIndicator = new Paint();

	private boolean isSelectable = false;
	private boolean isCurrentMonth = false;
	private boolean isToday = false;
	private boolean hasEvent = false;
	private RangeState rangeState = RangeState.NONE;

	public CalendarCellView(Context context) {
		super(context);
	}

	public CalendarCellView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public CalendarCellView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	public void setSelectable(boolean isSelectable) {
		this.isSelectable = isSelectable;
		refreshDrawableState();
	}

	public void setCurrentMonth(boolean isCurrentMonth) {
		this.isCurrentMonth = isCurrentMonth;
		refreshDrawableState();
	}

	public void setToday(boolean isToday) {
		this.isToday = isToday;
		refreshDrawableState();
	}

	public void setHasEvent(boolean hasEvent) {
		this.hasEvent = hasEvent;
		refreshDrawableState();
	}

	public void setRangeState(MonthCellDescriptor.RangeState rangeState) {
		this.rangeState = rangeState;
		refreshDrawableState();
	}

	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);

		if (isToday) {
			currentDayIndicator.setColor(getResources().getColor(R.color.calendar_current_day_selector));
			currentDayIndicator.setStyle(Paint.Style.STROKE);
			currentDayIndicator.setStrokeWidth(DAY_INDICATOR_WIDTH);
			canvas.drawLine(0, getHeight() - DAY_INDICATOR_OFFSET, getWidth(), getHeight() - DAY_INDICATOR_OFFSET,
					currentDayIndicator);
		}

		if (hasEvent) {
			setTextColor(getResources().getColor(R.color.calendar_text_has_event));
		}
	}

	@Override
	protected int[] onCreateDrawableState(int extraSpace) {
		final int[] drawableState = super.onCreateDrawableState(extraSpace + 4);

		if (isSelectable) {
			mergeDrawableStates(drawableState, STATE_SELECTABLE);
		}

		if (isCurrentMonth) {
			mergeDrawableStates(drawableState, STATE_CURRENT_MONTH);
		}

		if (isToday) {
			mergeDrawableStates(drawableState, STATE_TODAY);
		}

		if (rangeState == MonthCellDescriptor.RangeState.FIRST) {
			mergeDrawableStates(drawableState, STATE_RANGE_FIRST);
		} else if (rangeState == MonthCellDescriptor.RangeState.MIDDLE) {
			mergeDrawableStates(drawableState, STATE_RANGE_MIDDLE);
		} else if (rangeState == RangeState.LAST) {
			mergeDrawableStates(drawableState, STATE_RANGE_LAST);
		}

		return drawableState;
	}
}
