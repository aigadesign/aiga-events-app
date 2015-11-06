// Copyright 2012 Square, Inc.
package com.squareup.timessquare;

import java.text.DateFormat;
import java.util.Calendar;
import java.util.List;

import android.content.Context;
import android.util.AttributeSet;
import android.util.SparseIntArray;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

public class MonthView extends LinearLayout {
	TextView title;
	CalendarGridView grid;
	private Listener listener;

	public static MonthView create(ViewGroup parent, LayoutInflater inflater, DateFormat weekdayNameFormat,
			Listener listener, Calendar today) {
		final MonthView view = (MonthView) inflater.inflate(R.layout.month, parent, false);

		final int originalDayOfWeek = today.get(Calendar.DAY_OF_WEEK);

		int firstDayOfWeek = today.getFirstDayOfWeek();
		final CalendarRowView headerRow = (CalendarRowView) view.grid.getChildAt(0);
		for (int offset = 0; offset < 7; offset++) {
			today.set(Calendar.DAY_OF_WEEK, firstDayOfWeek + offset);
			final TextView textView = (TextView) headerRow.getChildAt(offset);
			final String weekdayName = weekdayNameFormat.format(today.getTime()).substring(0, 1);
			textView.setText(weekdayName);
		}
		today.set(Calendar.DAY_OF_WEEK, originalDayOfWeek);
		view.listener = listener;
		return view;
	}

	public MonthView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	@Override
	protected void onFinishInflate() {
		super.onFinishInflate();
		title = (TextView) findViewById(R.id.title);
		grid = (CalendarGridView) findViewById(R.id.calendar_grid);
	}

	public void init(MonthDescriptor month, List<List<MonthCellDescriptor>> cells, SparseIntArray eventDates) {
		Logr.d("Initializing MonthView (%d) for %s", System.identityHashCode(this), month);
		long start = System.currentTimeMillis();
		title.setText(month.getLabel().toUpperCase());

		final int numRows = cells.size();
		grid.setNumRows(numRows);
		for (int i = 0; i < 6; i++) {
			CalendarRowView weekRow = (CalendarRowView) grid.getChildAt(i + 1);
			weekRow.setListener(listener);
			if (i < numRows) {
				weekRow.setVisibility(VISIBLE);
				List<MonthCellDescriptor> week = cells.get(i);
				for (int c = 0; c < week.size(); c++) {
					MonthCellDescriptor cell = week.get(c);
					CalendarCellView cellView = (CalendarCellView) weekRow.getChildAt(c);

					cellView.setText(Integer.toString(cell.getValue()));

					// currently only checks for non-zero result because the event date design only has two
					// view states (events and no events). If need be, can easily be configured for additional 
					// view states via the following logic:
					// if eventDates.get() == 0 :: no events
					// else if eventDates.get() == (n > 0) :: n events
					if (eventDates.get(cell.getValue()) != 0 && cell.isCurrentMonth()) {
						cellView.setHasEvent(true);
					}
					cellView.setEnabled(cell.isCurrentMonth());

					cellView.setSelectable(cell.isSelectable());
					cellView.setSelected(cell.isSelected());
					cellView.setCurrentMonth(cell.isCurrentMonth());
					cellView.setToday(cell.isToday());
					cellView.setRangeState(cell.getRangeState());
					cellView.setTag(cell);
				}
			} else {
				weekRow.setVisibility(GONE);
			}
		}
		Logr.d("MonthView.init took %d ms", System.currentTimeMillis() - start);
	}

	public interface Listener {
		void handleClick(MonthCellDescriptor cell);
	}
}
