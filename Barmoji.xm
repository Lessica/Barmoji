//
//  Barmoji.xm
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 01/16/2018
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#import "Barmoji.h"
#import "BarmojiCollectionView.h"
#import <version.h>

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

BOOL barmojiBottomEnabled = NO;
BOOL barmojiEnabled = NO;
BOOL barmojiBottomFullWidth = NO;
BOOL barmojiPredictiveEnabled = NO;

BOOL showingBarmoji = YES;


int barmojiFeedbackType = 7;

%group thirteenPlus

%hook TUIPredictionView

%property (retain, nonatomic) BarmojiCollectionView *barmoji;
- (instancetype)initWithFrame:(CGRect)frame {
	TUIPredictionView *predictionView = %orig;

	if(predictionView) {
		if(barmojiEnabled && barmojiPredictiveEnabled) {

			self.barmoji = [[BarmojiCollectionView alloc] initForPredictiveBar:YES];
			self.barmoji.feedbackType = barmojiFeedbackType;
			self.barmoji.translatesAutoresizingMaskIntoConstraints = NO;
			[predictionView addSubview:self.barmoji];

			[predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
			[predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
			[predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
			[predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

			UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(flipSubviewHiddenStatus:)];
			longPressGesture.minimumPressDuration = 1.0;
			[self addGestureRecognizer:longPressGesture];
		}
	}
	return predictionView;
}

- (void)addSubview:(UIView *)subview {
	if(barmojiEnabled && barmojiPredictiveEnabled) {
		if(![subview isKindOfClass:[BarmojiCollectionView class]]) {
			subview.hidden = YES;
		}
	}

	%orig;
}

- (void)layoutSubviews {
	%orig;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TryReloadTest" object:nil];
}

-(void)_didRecognizeTapGesture:(id)arg1 {
	if(barmojiEnabled) {
		if(barmojiPredictiveEnabled && showingBarmoji) {
			return;
		}
	}
	%orig;
}

%new
- (void)flipSubviewHiddenStatus:(UILongPressGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		showingBarmoji = !showingBarmoji;
		for (UIView *subview in self.subviews) {
			subview.hidden = !subview.hidden;
			subview.userInteractionEnabled = !subview.userInteractionEnabled;
		}
	}
}

%end // TUIPredictionView

%end // thirteenPlus group

%group lessThirteen

%hook UIKeyboardPredictionView

%property (retain, nonatomic) BarmojiCollectionView *barmoji;

- (instancetype)initWithFrame:(CGRect)frame {
	UIKeyboardPredictionView *predictionView = %orig;

	if(predictionView) {
		if(barmojiEnabled && barmojiPredictiveEnabled) {

			self.barmoji = [[BarmojiCollectionView alloc] initForPredictiveBar:YES];
			self.barmoji.feedbackType = barmojiFeedbackType;
			self.barmoji.translatesAutoresizingMaskIntoConstraints = NO;
			[predictionView addSubview:self.barmoji];

			[predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
			[predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
			[predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
			[predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

			 UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(flipSubviewHiddenStatus:)];
			 longPressGesture.minimumPressDuration = 1.0;
			 [self addGestureRecognizer:longPressGesture];
		}
	}
	return predictionView;
}

- (void)addSubview:(UIView *)subview {
	if(barmojiEnabled && barmojiPredictiveEnabled) {
		if(![subview isKindOfClass:[BarmojiCollectionView class]]) {
			subview.hidden = YES;
		}
	}
	%orig;
}

-(void)activateCandidateAtPoint:(CGPoint)arg1  {
	if(barmojiEnabled) {
		if(barmojiPredictiveEnabled && showingBarmoji) {
			return;
		}
	}
	%orig;
}

%new
- (void)flipSubviewHiddenStatus:(UILongPressGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		showingBarmoji = !showingBarmoji;
		for (UIView *subview in self.subviews) {
			subview.hidden = !subview.hidden;
			subview.userInteractionEnabled = !subview.userInteractionEnabled;
		}
	}
}

%end // UIKeyboardPredictionView

%end // lessThirteen group



%group common

%hook UIKeyboardDockView

%property (retain, nonatomic) BarmojiCollectionView *barmoji;

- (instancetype)initWithFrame:(CGRect)frame {
	UIKeyboardDockView *dockView = %orig;
	if(dockView) {

		if(barmojiEnabled && barmojiBottomEnabled) {
			self.barmoji = [[BarmojiCollectionView alloc] initForPredictiveBar:NO];
			self.barmoji.feedbackType = barmojiFeedbackType;
			self.barmoji.translatesAutoresizingMaskIntoConstraints = NO;
			[dockView addSubview:self.barmoji];

			[dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeLeading multiplier:1.0 constant: barmojiBottomFullWidth ? 0 : 60]];
			[dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:barmojiBottomFullWidth ? 0 : -50]];
			[dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:60]];
			[dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20]];
		}
	}
	return dockView;
}

-(void)setLeftDockItem:(UIKeyboardDockItem *)arg1 {
	if(barmojiBottomFullWidth) { return ;}
	%orig;
}
-(void)setRightDockItem:(UIKeyboardDockItem *)arg1 {
	if(barmojiBottomFullWidth) { return ;}
	%orig;
}

- (void)layoutSubviews {
	%orig;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"barmoji_reloadLayout" object:nil];
}

%end // UIKeyboardDockView

%end // common group

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.cpdigitaldarkroom.barmoji.plist"];
	barmojiBottomEnabled = ([prefs objectForKey:@"BarmojiBottomEnabled"] ? [[prefs objectForKey:@"BarmojiBottomEnabled"] boolValue] : NO);
	barmojiBottomFullWidth = ([prefs objectForKey:@"BarmojiFullWidthBottom"] ? [[prefs objectForKey:@"BarmojiFullWidthBottom"] boolValue] : NO);
	barmojiEnabled = ([prefs objectForKey:@"BarmojiEnabled"] ? [[prefs objectForKey:@"BarmojiEnabled"] boolValue] : NO);
	barmojiFeedbackType = ([prefs objectForKey:@"BarmojiFeedbackType"] ? [[prefs objectForKey:@"BarmojiFeedbackType"] intValue] : 7);
	barmojiPredictiveEnabled = ([prefs objectForKey:@"BarmojiPredictiveEnabled"] ? [[prefs objectForKey:@"BarmojiPredictiveEnabled"] boolValue] : NO);
}

static void updateSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {

	NSDictionary *info = (__bridge NSDictionary*)userInfo;

	barmojiBottomEnabled = [info[@"bottom"] boolValue];
	barmojiBottomFullWidth = [info[@"fullwidth"] boolValue];
	barmojiEnabled = [info[@"enabled"] boolValue];
	barmojiFeedbackType = [info[@"feedbackType"] intValue];
	barmojiPredictiveEnabled = [info[@"predictive"] boolValue];

}

%ctor {
	
	@autoreleasepool {
		
		// check if process is springboard or an application
		// this prevents our tweak from running in non-application (with UI)
		// processes and also prevents bad behaving tweaks to invoke our tweak
		
		NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
		
		if (args.count != 0) {
			NSString *executablePath = args[0];
			
			if (executablePath) {
				NSString *processName = [executablePath lastPathComponent];
				
				BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
				BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
				
				if (isSpringBoard || isApplication) {

					loadPrefs();

					if(IS_IOS_OR_NEWER(iOS_13_0)) {
						
						NSBundle* bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/TextInputUI.framework"];
						if (!bundle.loaded) [bundle load];

						%init(thirteenPlus)
					} else {
						%init(lessThirteen)
					}
					
					CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, updateSettings, CFSTR("com.cpdigitaldarkroom.barmoji.settings"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
					
					%init(common);
				}
			}
		}
	}
}
