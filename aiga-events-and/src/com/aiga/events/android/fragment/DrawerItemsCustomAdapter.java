package com.aiga.events.android.fragment;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.aiga.events.android.R;

public class DrawerItemsCustomAdapter extends BaseAdapter {

	private String[] mDrawerItems;
	private int[] mDrawerImages;
	private LayoutInflater mInflater = null;

	public DrawerItemsCustomAdapter(Context context, String[] items,
			int[] images) {
		mDrawerItems = items;
		mDrawerImages = images;
		mInflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
	}

	@Override
	public int getCount() {
		return mDrawerItems.length;
	}

	@Override
	public Object getItem(int position) {
		return position;
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View v = convertView;
		if (convertView == null)
			v = mInflater.inflate(R.layout.list_item_drawer, null);

		ImageView drawerImage = (ImageView) v.findViewById(R.id.drawer_listimage);
		TextView drawerText = (TextView) v.findViewById(R.id.drawer_listText);

		drawerText.setText(mDrawerItems[position]);
		drawerImage.setBackgroundResource(mDrawerImages[position]);
		return v;
	}
}