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

BOOL barmojiEnabled = NO;
BOOL barmojiHideGlobe = NO;
BOOL barmojiHideDictation = NO;

BOOL showingBarmoji = YES;

int barmojiEmojisPosition = 2;
int barmojiFeedbackType = 7;
int barmojiBottomLeading = 60;
int barmojiBottomTrailing = -60;
int barmojiBottomHeight = -20;
int barmojiEmojiPerRow = 6;

%group thirteenPlus

%hook TUIPredictionView

%property (retain, nonatomic) BarmojiCollectionView *barmoji;
- (instancetype)initWithFrame:(CGRect)frame {
    TUIPredictionView *predictionView = %orig;

    if (predictionView) {
        if (barmojiEmojisPosition == 1) {

            self.barmoji = [[BarmojiCollectionView alloc] initForPredictiveBar:YES];
            self.barmoji.feedbackType = barmojiFeedbackType;
            self.barmoji.translatesAutoresizingMaskIntoConstraints = NO;
            [predictionView addSubview:self.barmoji];

            [predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
            [predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
            [predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
            [predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(flipSubviewHiddenStatus:)];
            longPressGesture.minimumPressDuration = 0.25;
            [self addGestureRecognizer:longPressGesture];
        }
    }
    return predictionView;
}

- (void)addSubview:(UIView *)subview {
    if (barmojiEmojisPosition == 1) {
        if (![subview isKindOfClass:[BarmojiCollectionView class]]) {
            subview.hidden = YES;
        }
    }

    %orig;
}

- (void)layoutSubviews {
    %orig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TryReloadTest" object:nil];
}

- (void)_didRecognizeTapGesture:(id)arg1 {
    if (barmojiEmojisPosition == 1 && showingBarmoji) {
        return;
    }
    %orig;
}

%new
- (void)flipSubviewHiddenStatus:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self toggleBarmoji];
    }
}

%new
- (void)toggleBarmoji {
    showingBarmoji = !showingBarmoji;
    for (UIView *subview in self.subviews) {
        subview.hidden = !subview.hidden;
        subview.userInteractionEnabled = !subview.userInteractionEnabled;
    }
}

- (void)setAutocorrectionList:(TIAutocorrectionList *)list animated:(BOOL)animated {
    %orig;

    TIKeyboardCandidateSingle *correction = list.autocorrection;
    BOOL wantsCorrection = list.shouldAcceptTopCandidate || list.containsAutofillCandidates || list.containsProactiveTriggers;

    if (wantsCorrection && ![correction.input isEqualToString:correction.candidate]) {
        if (showingBarmoji) {
            [self toggleBarmoji];
        }
    } else if (!showingBarmoji) {
        [self toggleBarmoji];
    }
}

%end // TUIPredictionView

%end // thirteenPlus group

%group lessThirteen

%hook UIKeyboardPredictionView

%property (retain, nonatomic) BarmojiCollectionView *barmoji;

- (instancetype)initWithFrame:(CGRect)frame {
    UIKeyboardPredictionView *predictionView = %orig;

    if (predictionView) {
        if (barmojiEmojisPosition == 1) {

            self.barmoji = [[BarmojiCollectionView alloc] initForPredictiveBar:YES];
            self.barmoji.feedbackType = barmojiFeedbackType;
            self.barmoji.translatesAutoresizingMaskIntoConstraints = NO;
            [predictionView addSubview:self.barmoji];

            [predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
            [predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
            [predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
            [predictionView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:predictionView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

             UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(flipSubviewHiddenStatus:)];
             longPressGesture.minimumPressDuration = 0.25;
             [self addGestureRecognizer:longPressGesture];
        }
    }
    return predictionView;
}

- (void)addSubview:(UIView *)subview {
    if (barmojiEmojisPosition == 1) {
        if (![subview isKindOfClass:[BarmojiCollectionView class]]) {
            subview.hidden = YES;
        }
    }
    %orig;
}

- (void)activateCandidateAtPoint:(CGPoint)arg1  {
    if (barmojiEmojisPosition == 1 && showingBarmoji) {
        return;
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
    if (dockView) {
        if (barmojiEmojisPosition == 2) {

            UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
            BOOL deviceLandscape = UIDeviceOrientationIsLandscape(deviceOrientation);

            self.barmoji = [[BarmojiCollectionView alloc] initForPredictiveBar:NO];
            self.alpha = deviceLandscape ? 0.0 : 1.0;
            self.barmoji.feedbackType = barmojiFeedbackType;
            self.barmoji.translatesAutoresizingMaskIntoConstraints = NO;
            [dockView addSubview:self.barmoji];

            [dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:barmojiBottomLeading]];
            [dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:barmojiBottomTrailing]];
            [dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:60]];
            [dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:barmojiBottomHeight]];
        }
    }
    return dockView;
}

- (void)setLeftDockItem:(UIKeyboardDockItem *)arg1 {
    if (barmojiHideGlobe) { return;}
    %orig;
}
- (void)setRightDockItem:(UIKeyboardDockItem *)arg1 {
    if (barmojiHideDictation) { return;}
    %orig;
}

- (void)layoutSubviews {
    %orig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"barmoji_reloadLayout" object:nil];
}

%end // UIKeyboardDockView

//Fix for barmoji view overlapping when dicatation is running
%hook UISystemKeyboardDockController
- (void)updateDockItemsVisibility {
    %orig;
    self.dockView.barmoji.hidden = self.dockView.centerDockItem ? !self.dockView.centerDockItem.view.hidden : NO;
}
%end

%end // common group

static void updateSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.cpdigitaldarkroom.barmoji.plist"];
    [prefs addEntriesFromDictionary:(__bridge NSDictionary *)userInfo];
    
    barmojiEnabled = ([prefs objectForKey:@"BarmojiEnabled"] ? [[prefs objectForKey:@"BarmojiEnabled"] boolValue] : NO);
    barmojiFeedbackType = ([prefs objectForKey:@"BarmojiFeedbackType"] ? [[prefs objectForKey:@"BarmojiFeedbackType"] intValue] : 7);
    barmojiBottomLeading = ([prefs objectForKey:@"BarmojiBottomLeading"] ? [[prefs objectForKey:@"BarmojiBottomLeading"] intValue] : 60);
    barmojiBottomTrailing = ([prefs objectForKey:@"BarmojiBottomTrailing"] ? [[prefs objectForKey:@"BarmojiBottomTrailing"] intValue] : -60);
    barmojiBottomHeight = ([prefs objectForKey:@"BarmojiBottomHeight"] ? [[prefs objectForKey:@"BarmojiBottomHeight"] intValue] : -20);
    barmojiEmojiPerRow = ([prefs objectForKey:@"BarmojiEmojiPerRow"] ? [[prefs objectForKey:@"BarmojiEmojiPerRow"] intValue] : 6);
    barmojiHideGlobe = ([prefs objectForKey:@"BarmojiHideGlobe"] ? [[prefs objectForKey:@"BarmojiHideGlobe"] boolValue] : NO);
    barmojiHideDictation = ([prefs objectForKey:@"BarmojiHideDictation"] ? [[prefs objectForKey:@"BarmojiHideDictation"] boolValue] : NO);
    barmojiEmojisPosition = ([prefs objectForKey:@"EmojisPosition"] ? [[prefs objectForKey:@"EmojisPosition"] intValue] : 1);
    barmojiEmojisPosition = 2;
}

static void loadPrefs() {
    updateSettings(NULL, NULL, NULL, NULL, NULL);
}

%ctor
{
    @autoreleasepool
    {
        // check if process is springboard or an application
        // this prevents our tweak from running in non-application (with UI)
        // processes and also prevents bad behaving tweaks to invoke our tweak
        loadPrefs();
        if (barmojiEnabled) {
            NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
            
            if (args.count != 0) {
                NSString *executablePath = args[0];
                
                if (executablePath) {
                    NSString *processName = [executablePath lastPathComponent];
                    
                    BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
                    BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
                    
                    if (isSpringBoard || isApplication) {
                        if (@available(iOS 13, *)) {
                            NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/TextInputUI.framework"];
                            if (!bundle.loaded) [bundle load];
                                if (barmojiEmojisPosition == 1) {
                                    %init(thirteenPlus)
                                }
                        } else {
                            if (barmojiEmojisPosition == 1) {
                                %init(lessThirteen)
                            }
                        }
                        
                        CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, updateSettings, CFSTR("com.cpdigitaldarkroom.barmoji.settings"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                        if (barmojiEmojisPosition == 2) {
                            %init(common);
                        }
                    }
                }
            }
        }
    }
}
