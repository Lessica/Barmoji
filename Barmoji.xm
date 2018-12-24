//
//  Barmoji.xm
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 01/16/2018
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#import "Barmoji.h"
#import "BarmojiCollectionView.h"

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

BOOL barmojiBottomEnabled = NO;
BOOL barmojiEnabled = NO;
BOOL barmojiPredictiveEnabled = NO;
BOOL barmojiPreventsHomeGesture = NO;

BOOL preventHomeGesture = NO;

int barmojiFeedbackType = 7;

%hook UISystemKeyboardDockController

- (void)viewDidDisappear:(BOOL)animated {
	%orig;
	NSLog(@"Did Disappear");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

	if(barmojiPreventsHomeGesture) {
		NSLog(@"Disable prevents gesture");
		preventHomeGesture = NO;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	%orig;
	NSLog(@"Did appear");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(barmojiRotationUpdate:) name:UIDeviceOrientationDidChangeNotification object:nil];

	if(barmojiPreventsHomeGesture) {
		NSLog(@"Set prevents gesture");
		preventHomeGesture = YES;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	%orig;
	self.dockView.barmoji.alpha = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? 0 : 1;
}

%new
- (void)barmojiRotationUpdate:(NSNotification *)notification {
	self.dockView.barmoji.alpha = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? 0 : 1;
}

%end

%hook UIKeyboardPredictionView
%property (retain, nonatomic) BarmojiCollectionView *barmoji;
- (instancetype)initWithFrame:(CGRect)frame {

	UIKeyboardPredictionView *predictionView = %orig;
	if(predictionView) {

		if(barmojiEnabled && barmojiPredictiveEnabled) {
			self.barmoji = [[BarmojiCollectionView alloc] init];
			self.barmoji.feedbackType = barmojiFeedbackType;
			self.barmoji.translatesAutoresizingMaskIntoConstraints = NO;
			[predictionView addSubview:self.barmoji];

			[predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
			[predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
			[predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40]];
			[predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
		}

	}
	return predictionView;
}

- (void)addSubview:(UIView *)subview {

	if(barmojiEnabled && barmojiPredictiveEnabled) {
		if(subview != self.barmoji) {
			return;
		}
	}

	%orig;
}

-(void)_setPredictions:(id)arg1 autocorrection:(id)arg2 emojiList:(id)arg3 {
	if(barmojiEnabled && barmojiPredictiveEnabled) {
		return;
	}
	%orig;
}
%end

%hook UIKeyboardDockView
%property (retain, nonatomic) BarmojiCollectionView *barmoji;

- (instancetype)initWithFrame:(CGRect)frame {

	UIKeyboardDockView *dockView = %orig;
	if(dockView) {

		if(barmojiEnabled && barmojiBottomEnabled) {

			self.barmoji = [[BarmojiCollectionView alloc] init];
			self.barmoji.feedbackType = barmojiFeedbackType;
			self.barmoji.translatesAutoresizingMaskIntoConstraints = NO;
			[dockView addSubview:self.barmoji];

			[dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:60]];
			[dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-50]];
			[dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40]];
			[dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-22]];
		}
	}
	return dockView;
}

%end

%hook SBHomeGestureSettings

-(BOOL)isHomeGestureEnabled {
	NSLog(@"Reading From Here");
	if(barmojiPreventsHomeGesture) {
		NSLog(@"Prevents Gesture: %@", preventHomeGesture ? @"YES" : @"NO");
		return preventHomeGesture;
	}
	return %orig;
}

%end

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.cpdigitaldarkroom.barmoji.plist"];
	barmojiBottomEnabled = ([prefs objectForKey:@"BarmojiBottomEnabled"] ? [[prefs objectForKey:@"BarmojiBottomEnabled"] boolValue] : NO);
	barmojiEnabled = ([prefs objectForKey:@"BarmojiEnabled"] ? [[prefs objectForKey:@"BarmojiEnabled"] boolValue] : NO);
	barmojiFeedbackType = ([prefs objectForKey:@"BarmojiFeedbackType"] ? [[prefs objectForKey:@"BarmojiFeedbackType"] intValue] : 7);
	barmojiPredictiveEnabled = ([prefs objectForKey:@"BarmojiPredictiveEnabled"] ? [[prefs objectForKey:@"BarmojiPredictiveEnabled"] boolValue] : NO);
	barmojiPreventsHomeGesture = ([prefs objectForKey:@"BarmojiDisablesGesture"] ? [[prefs objectForKey:@"BarmojiDisablesGesture"] boolValue] : NO);
    [prefs release];
}

static void updateSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {

	NSDictionary *info = (__bridge NSDictionary*)userInfo;

	barmojiBottomEnabled = [info[@"bottom"] boolValue];
	barmojiEnabled = [info[@"enabled"] boolValue];
	barmojiFeedbackType = [info[@"feedbackType"] intValue];
	barmojiPredictiveEnabled = [info[@"predictive"] boolValue];

}

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, updateSettings, CFSTR("com.cpdigitaldarkroom.barmoji.settings"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
