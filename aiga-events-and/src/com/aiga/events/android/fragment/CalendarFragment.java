package com.aiga.events.android.fragment;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.SparseIntArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.aiga.events.android.R;
import com.aiga.events.android.data.Chapter;
import com.aiga.events.android.data.Event;
import com.aiga.events.android.loaders.KeyLoaderCallbacks;
import com.aiga.events.android.utils.Logger;
import com.aiga.events.android.utils.Utils;
import com.aiga.events.android.utils.Utils.OnEventsLoadedForChaptersListener;
import com.aiga.events.android.views.NoScrollSwipeRefreshLayout.OnRefreshListener;
import com.aiga.events.android.views.ScrollSpeedAnimationListener;
import com.squareup.timessquare.CalendarPickerView;
import com.squareup.timessquare.CalendarPickerView.OnDateSelectedListener;

public class CalendarFragment extends BaseActionBarLoadingFragment implements OnEventsLoadedForChaptersListener,
		OnDateSelectedListener, OnItemClickListener, OnRefreshListener {

	public static final String TAG = "AIGACalendarFragment";
	public static final String FRAGMENT_MANAGER_TAG = "CalendarFragment";
	private static final String MONTH_ARG = "month";
	private static final String YEAR_ARG = "year";
	private static final String DATE_ARG = "date";
	private static final String CHAPTERS_ARG = "chaptersArg";

	private ListView mList;
	private View mNoEventsView;
	private CalendarListAdapter mListAdapter;
	private Map<Chapter, List<Event>> mEventMap;
	private List<Date> mMonthDateRange;
	private SparseIntArray mEventDates;
	private boolean mAdapterInitialized = false;
	private CalendarPickerView mCalendarView;
	private int mLoadCount;
	private int mErrorCount;

	private static enum CalendarFilterType {
		DAILY, MONTHLY
	}

	public static CalendarFragment newInstance(Date date, List<Chapter> chapters) {
		CalendarFragment calFrag = new CalendarFragment();
		Bundle args = getBundleForDate(date);
		ArrayList<Chapter> chaptersArray = new ArrayList<Chapter>(chapters);
		args.putParcelableArrayList(CHAPTERS_ARG, chaptersArray);
		calFrag.setArguments(args);
		return calFrag;
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		View view = inflater.inflate(R.layout.fragment_calendar_layout, container, false);
		View calendarListHeader = inflater.inflate(R.layout.list_header_calendar, null, false);

		// Initialize the base view: the calendar and events list
		mList = (ListView) view.findViewById(R.id.calendar_fragment_list);
		mCalendarView = (CalendarPickerView) calendarListHeader.findViewById(R.id.calendar_view);
		mNoEventsView = view.findViewById(R.id.calendar_no_events_found);
		mNoEventsView.setVisibility(View.GONE);
		mList.addHeaderView(calendarListHeader, null, false);
		mList.setOnItemClickListener(this);
		mList.setDivider(null);

		mEventDates = new SparseIntArray();
		mEventMap = new HashMap<Chapter, List<Event>>();

		return view;
	}

	@Override
	public void onDestroyView() {
		mList = null;
		mListAdapter = null;
		mEventMap = null;
		mEventDates = null;
		mCalendarView = null;
		mNoEventsView = null;
		mAdapterInitialized = false;
		mLoadCount = 0;
		super.onDestroyView();
	}

	@Override
	public void onViewCreated(View view, Bundle savedInstanceState) {
		super.onViewCreated(view, savedInstanceState);
		List<Chapter> chapters = getArguments().getParcelableArrayList(CHAPTERS_ARG);
		getEvents(chapters, false);
		initCalendarView();
	}

	private void initCalendarView() {
		int selectedMonth = getArguments().getInt(MONTH_ARG);
		int selectedYear = getArguments().getInt(YEAR_ARG);
		int selectedDate = getArguments().getInt(DATE_ARG);
		Logger.d(TAG, "args year: " + selectedYear + " month: " + selectedMonth + " date: " + selectedDate);

		Calendar calendar = Calendar.getInstance();
		calendar.set(Calendar.MONTH, selectedMonth);
		calendar.set(Calendar.YEAR, selectedYear);

		int firstDayOfMonth = calendar.getActualMinimum(Calendar.DAY_OF_MONTH);
		calendar.set(Calendar.DAY_OF_MONTH, firstDayOfMonth);
		Utils.setMidnight(calendar);
		Date firstDateOfMonth = calendar.getTime();

		Utils.incrementMonth(calendar);
		Date lastDateOfMonth = calendar.getTime();

		mMonthDateRange = new ArrayList<Date>();
		mMonthDateRange.add(firstDateOfMonth);
		mMonthDateRange.add(lastDateOfMonth);

		mCalendarView.init(firstDateOfMonth, lastDateOfMonth);
		mCalendarView.setEventDates(mEventDates);
		mCalendarView.setOnDateSelectedListener(this);
	}

	@Override
	public void onEventsLoaded(Map<Chapter, List<Event>> eventMap) {
		onEventsUpdated(eventMap);
	}

	private void onEventsUpdated(Map<Chapter, List<Event>> eventMap) {

		if (mEventMap == null) {
			return;
		}

		mLoadCount--;
		addEventsForMonth(eventMap);
		mEventDates = getEventDatesForEventMap(mEventMap, mMonthDateRange);
		List<Event> allEvents = getEventsFromEventMap(mEventMap);

		if (mLoadCount <= 0) {
			showProgress(false);
			if (mCalendarView.getSelectedDate() != null) {
				((TextView) mNoEventsView.findViewById(R.id.no_events_message)).setText(R.string.no_events_cal_date);
			} else {
				((TextView) mNoEventsView.findViewById(R.id.no_events_message)).setText(R.string.no_events_cal_month);
			}
			mNoEventsView.setVisibility(allEvents.size() == 0 ? View.VISIBLE : View.GONE);
		}

		mCalendarView.setEventDates(mEventDates);
		mCalendarView.invalidateViews();

		Collections.sort(allEvents, new Utils.EventDateComparator());

		if (mAdapterInitialized) {
			mListAdapter.setEvents(allEvents);
			mListAdapter.notifyDataSetChanged();
		} else {
			mListAdapter = new CalendarListAdapter(getActivity(), new ScrollSpeedAnimationListener(), allEvents);
			mList.setAdapter(mListAdapter);
			mAdapterInitialized = true;
		}
	}

	private void addEventsForMonth(Map<Chapter, List<Event>> eventMap) {
		for (Chapter chapter : eventMap.keySet()) {
			List<Event> events = eventMap.get(chapter);
			List<Event> eventsForMonth = new ArrayList<Event>();

			if (events != null) {
				for (Event event : events) {
					Date startDate = event.getEventDetails().getStartDateFormatDate();
					Date endDate = event.getEventDetails().getEndDateFormatDate();
					Date firstDateOfMonth = mMonthDateRange.get(0);
					Date lastDateOfMonth = mMonthDateRange.get(1);

					if (startDate.after(firstDateOfMonth) && startDate.before(lastDateOfMonth)) {
						eventsForMonth.add(event);
					} else if (endDate.after(firstDateOfMonth) && endDate.before(lastDateOfMonth)) {
						eventsForMonth.add(event);
					} else if (startDate.before(firstDateOfMonth) && endDate.after(lastDateOfMonth)) {
						eventsForMonth.add(event);
					}
				}

				mEventMap.put(chapter, eventsForMonth);
			}
		}
	}

	private static SparseIntArray getEventDatesForEventMap(Map<Chapter, List<Event>> eventMap, List<Date> monthDates) {
		SparseIntArray eventDates = new SparseIntArray();

		for (List<Event> events : eventMap.values()) {
			for (Event event : events) {

				int firstDateToHighlight;
				int lastDateToHighlight;
				long eventStartDate = event.getEventDetails().getStartDateFormatDate().getTime();
				long eventEndDate = event.getEventDetails().getEndDateFormatDate().getTime();
				long firstDateOfMonth = monthDates.get(0).getTime();
				long lastDateOfMonth = monthDates.get(1).getTime();

				if (eventStartDate <= firstDateOfMonth) {
					// event starts before beginning of month
					firstDateToHighlight = 1;
				} else {
					firstDateToHighlight = getDayOfMonth(event.getEventDetails().getStartDateFormatDate());
				}

				if (eventEndDate >= lastDateOfMonth) {
					// event ends after end of month
					lastDateToHighlight = 31;
				} else {
					lastDateToHighlight = getDayOfMonth(event.getEventDetails().getEndDateFormatDate());
				}

				for (int i = firstDateToHighlight; i <= lastDateToHighlight; ++i) {
					int numEvents = (eventDates.get(i) + 1);
					eventDates.put(i, numEvents);
				}
			}
		}

		return eventDates;
	}

	private static int getDayOfMonth(Date date) {
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		return calendar.get(Calendar.DATE);
	}

	private List<Event> getEventsFromEventMap(Map<Chapter, List<Event>> eventMap) {
		List<Event> allEvents = new ArrayList<Event>();

		if (eventMap != null) {
			for (List<Event> eventsForChapter : eventMap.values()) {
				allEvents.addAll(eventsForChapter);
			}
		}

		return allEvents;
	}

	private void getEvents(List<Chapter> chapters, boolean forceRefresh) {

		if (mErrorCount > 0) {
			mErrorCount = 0;
			KeyLoaderCallbacks.restartLoader(getLoaderManager(), this);
			showProgress(true);
			return;
		}

		List<Chapter> chaptersWithEvents = new ArrayList<Chapter>();

		for (Chapter chapter : chapters) {
			if (chapter.shouldDownloadEvents() || forceRefresh) {
				showProgress(true);
				mLoadCount++;
				Utils.downloadEventsForChapter(getActivity(), chapter);
			} else {
				chaptersWithEvents.add(chapter);
			}
		}

		if (chaptersWithEvents.size() > 0) {
			mLoadCount++;
			List<Date> dates = getDatesForFiltering(CalendarFilterType.MONTHLY, 1);
			Utils.getEventsForChapters(chaptersWithEvents, dates.get(0), dates.get(1), this);
		}
	}

	public List<Date> getDatesForFiltering(CalendarFilterType type, int date) {

		ArrayList<Date> dates = new ArrayList<Date>();

		Calendar calendar = Calendar.getInstance();
		calendar.set(Calendar.YEAR, getArguments().getInt(YEAR_ARG));
		calendar.set(Calendar.MONTH, getArguments().getInt(MONTH_ARG));
		calendar.set(Calendar.DATE, date);

		Utils.setMidnight(calendar);

		dates.add(calendar.getTime());
		if (type == CalendarFilterType.DAILY) {
			Utils.incrementDay(calendar);
		} else if (type == CalendarFilterType.MONTHLY) {
			Utils.incrementMonth(calendar);
		}
		dates.add(calendar.getTime());

		return dates;
	}

	@Override
	public void onDateSelected(Date date) {
		List<Date> dates = getDatesForFiltering(CalendarFilterType.DAILY, getDayOfMonth(date));
		List<Chapter> chapters = new ArrayList<Chapter>(mEventMap.keySet());
		Utils.getEventsForChapters(chapters, dates.get(0), dates.get(1), this);
	}

	@Override
	public void onDateUnselected(Date date) {
		List<Date> dates = getDatesForFiltering(CalendarFilterType.MONTHLY, 1);
		List<Chapter> chapters = new ArrayList<Chapter>(mEventMap.keySet());
		Utils.getEventsForChapters(chapters, dates.get(0), dates.get(1), this);
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View v, int position, long id) {
		if (mListAdapter == null) {
			return;
		}

		// position offset by -1 because the calendar view/header fills in as
		// the first element
		Event event = mListAdapter.getEvent(position - 1);
		Fragment detailsFrag = DetailsFragment.newInstance(event);
		getActivity().getSupportFragmentManager().beginTransaction()
				.replace(R.id.main_container, detailsFrag, DetailsFragment.FRAGMENT_MANAGER_TAG).addToBackStack(null)
				.commit();
	}

	private static Bundle getBundleForDate(Date date) {
		Bundle args = new Bundle();
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		args.putInt(MONTH_ARG, calendar.get(Calendar.MONTH));
		args.putInt(YEAR_ARG, calendar.get(Calendar.YEAR));
		args.putInt(DATE_ARG, calendar.get(Calendar.DATE));
		return args;
	}

	@Override
	protected void handleRefreshRequested() {
		super.handleRefreshRequested();
		mLoadCount = 0;
		List<Chapter> chapters = getArguments().getParcelableArrayList(CHAPTERS_ARG);
		getEvents(chapters, true);
	}

	@Override
	protected void handleChapterBroadcast(List<Chapter> chapters) {
		ArrayList<Chapter> chaptersArray = new ArrayList<Chapter>(chapters);
		getArguments().putParcelableArrayList(CHAPTERS_ARG, chaptersArray);
		getEvents(chapters, false);
	}

	@Override
	protected void handleEventsBroadcast(Map<Chapter, List<Event>> eventMap) {
		onEventsUpdated(eventMap);
	}

	@Override
	protected void handleErrorBroadcast(Chapter chapter, String error) {
		super.handleErrorBroadcast(chapter, error);

		mLoadCount--;
		mErrorCount++;

		Logger.d(TAG, "Error received with error count: " + mErrorCount);

		if (mErrorCount == 1) {
			Toast.makeText(getActivity(), getResources().getString(R.string.calendar_error_message), Toast.LENGTH_SHORT)
					.show();
		}

		if (mLoadCount <= 0) {
			showProgress(false);
		}
	}

	@Override
	public void onRefresh() {
		handleRefreshRequested();
	}
}