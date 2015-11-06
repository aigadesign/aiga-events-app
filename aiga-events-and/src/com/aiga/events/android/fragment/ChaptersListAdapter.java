package com.aiga.events.android.fragment;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.SectionIndexer;
import android.widget.TextView;

import com.aiga.events.android.R;
import com.aiga.events.android.data.Chapter;

public class ChaptersListAdapter extends ArrayAdapter<Chapter> implements SectionIndexer {

	private final List<String> mSections = new ArrayList<String>();
	private final Map<String, Integer> mSectionCount = new TreeMap<String, Integer>();

	public ChaptersListAdapter(Context context) {
		super(context, 0);
	}

	public List<Chapter> getAllChildren() {
		List<Chapter> chapters = new ArrayList<Chapter>();

		for (int i = 0; i < getCount(); i++) {
			chapters.add(getItem(i));
		}

		return chapters;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View v = convertView;
		Chapter chapter = getItem(position);

		if (v == null) {
			LayoutInflater inflater = (LayoutInflater) getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			v = inflater.inflate(R.layout.list_item_chapter, null);
		}

		ImageView image = (ImageView) v.findViewById(R.id.image);
		image.setVisibility(chapter.isSelected() ? View.VISIBLE : View.GONE);

		TextView text = (TextView) v.findViewById(R.id.text);
		text.setText(chapter.getChapterName());

		TextView subheaderText = (TextView) v.findViewById(R.id.subheader_text);

		if (position > 0) {
			Chapter previousChapter = getItem(position - 1);
			if (!chapter.getChapterName().substring(0, 1).equals(previousChapter.getChapterName().substring(0, 1))) {
				showSubheaderView(subheaderText, chapter);
			} else {
				subheaderText.setVisibility(View.GONE);
			}
		} else {
			showSubheaderView(subheaderText, chapter);
		}

		return v;
	}

	private static void showSubheaderView(TextView subheaderText, Chapter chapter) {
		subheaderText.setVisibility(View.VISIBLE);
		String firstLetter = chapter.getChapterName().substring(0, 1);
		subheaderText.setText(firstLetter);
	}

	@Override
	public void addAll(Collection<? extends Chapter> chapters) {
		addSections(chapters);
		super.addAll(chapters);
	}

	private void addSections(Collection<? extends Chapter> chapters) {
		mSections.clear();
		mSectionCount.clear();

		for (Chapter chapter : chapters) {
			addSection(chapter);
		}
	}

	private void addSection(Chapter chapter) {
		String firstLetter = chapter.getChapterName().substring(0, 1);

		if (!mSections.contains(firstLetter)) {
			mSections.add(firstLetter);
			mSectionCount.put(firstLetter, 0);
		}

		mSectionCount.put(firstLetter, mSectionCount.get(firstLetter) + 1);
	}

	@Override
	public void add(Chapter chapter) {
		addSection(chapter);
		super.add(chapter);
	}

	@Override
	public int getPositionForSection(int sectionIndex) {
		int position = 0;
		int sectionPosition = 0;

		for (String s : mSectionCount.keySet()) {

			if (sectionPosition < sectionIndex) {
				position += mSectionCount.get(s);
			}

			sectionPosition++;
		}

		return position;
	}

	@Override
	public int getSectionForPosition(int position) {
		Chapter chapter = getItem(position);
		int index = mSections.indexOf(chapter.getChapterName().substring(0, 1));
		return index;
	}

	@Override
	public Object[] getSections() {
		String[] sections;

		if (mSections != null) {
			sections = mSections.toArray(new String[mSections.size()]);
		} else {
			sections = new String[0];
		}

		return sections;
	}
}