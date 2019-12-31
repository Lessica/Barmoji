//
//  BarmojiHapticsManager.h
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 01/16/2018
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#import "BarmojiHapticsManager.h"

@interface BarmojiHapticsManager ()

@property (strong, nonatomic) id hapticFeedbackGenerator;

@end

@implementation BarmojiHapticsManager

+ (instancetype)sharedManager {
    static BarmojiHapticsManager *sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)actuateHapticsForType:(int)feedbackType {
    switch (feedbackType) {
        case 1:
            [self handleHapticFeedbackForSelection]; break;
        case 2:
            [self handleHapticFeedbackForImpactStyle:UIImpactFeedbackStyleLight]; break;
        case 3:
            [self handleHapticFeedbackForImpactStyle:UIImpactFeedbackStyleMedium]; break;
        case 4:
            [self handleHapticFeedbackForImpactStyle:UIImpactFeedbackStyleHeavy]; break;
        case 5:
            [self handleHapticFeedbackForSuccess]; break;
        case 6:
            [self handleHapticFeedbackForWarning]; break;
    }
}

- (void)handleHapticFeedbackForImpactStyle:(UIImpactFeedbackStyle)style {
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hapticFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:style];
            [_hapticFeedbackGenerator prepare];
            [_hapticFeedbackGenerator impactOccurred];
            _hapticFeedbackGenerator = nil;
        });
    }
}

- (void)handleHapticFeedbackForError {
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hapticFeedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
            [_hapticFeedbackGenerator prepare];
            [_hapticFeedbackGenerator notificationOccurred:UINotificationFeedbackTypeError];
            _hapticFeedbackGenerator = nil;
        });
    }
}

- (void)handleHapticFeedbackForSelection {
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hapticFeedbackGenerator = [[UISelectionFeedbackGenerator alloc] init];
            [_hapticFeedbackGenerator prepare];
            [_hapticFeedbackGenerator selectionChanged];
            _hapticFeedbackGenerator = nil;
        });
    }
}

- (void)handleHapticFeedbackForSuccess {
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hapticFeedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
            [_hapticFeedbackGenerator prepare];
            [_hapticFeedbackGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
            _hapticFeedbackGenerator = nil;
        });
    }
}

- (void)handleHapticFeedbackForWarning {
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hapticFeedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
            [_hapticFeedbackGenerator prepare];
            [_hapticFeedbackGenerator notificationOccurred:UINotificationFeedbackTypeWarning];
            _hapticFeedbackGenerator = nil;
        });
    }
}

@end
