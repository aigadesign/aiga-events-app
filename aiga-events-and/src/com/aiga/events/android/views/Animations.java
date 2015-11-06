package com.aiga.events.android.views;

import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;

import com.aiga.events.android.AIGAApplication;

public class Animations {
	
	public static void animateFadeIn(final View v) {
		animateFadeIn(v, 0.0f, 800);
	}

	public static void animateFadeIn(final View v, float start, int duration) {
		if (AIGAApplication.getDeviceAPIVersion() >= android.os.Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
			AlphaAnimation anim = new AlphaAnimation(start, 1.0f);
			anim.setDuration(duration);
			anim.setAnimationListener(new AnimationListener() {

				@Override
				public void onAnimationEnd(Animation animation) {
					// not implemented
				}

				@Override
				public void onAnimationRepeat(Animation animation) {
					// not implemented
				}

				@Override
				public void onAnimationStart(Animation animation) {
					v.setVisibility(View.VISIBLE);
				}
				
			});
			v.setAnimation(anim);
			v.startAnimation(anim);
		}
	}
	
	public static void animateFadeOut(final View v) {

		if (AIGAApplication.getDeviceAPIVersion() >= android.os.Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
			AlphaAnimation anim = new AlphaAnimation(1.0f, 0.0f);
			anim.setDuration(250);
			anim.setAnimationListener(new AnimationListener() {

				@Override
				public void onAnimationEnd(Animation animation) {
					v.setVisibility(View.GONE);
				}

				@Override
				public void onAnimationRepeat(Animation animation) {
					// not implemented
				}

				@Override
				public void onAnimationStart(Animation animation) {
					// not implemented
				}
				
			});
			v.setAnimation(anim);
			v.startAnimation(anim);
		}
	}
}
