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

- (instancetype)init {
    if(self = [super init]) {
    }
    return self;
}

- (void)actuateHapticsForType:(int)feedbackType {

    if(feedbackType == 1) {
        [self handleHapticFeedbackForSelection];
    } else if(feedbackType == 2) {
        [self handleHapticFeedbackForImpactStyle:UIImpactFeedbackStyleLight];
    } else if(feedbackType == 3) {
        [self handleHapticFeedbackForImpactStyle:UIImpactFeedbackStyleMedium];
    } else if(feedbackType == 4) {
        [self handleHapticFeedbackForImpactStyle:UIImpactFeedbackStyleHeavy];
    } else if(feedbackType == 5) {
        [self handleHapticFeedbackForSuccess];
    } else if(feedbackType == 6) {
        [self handleHapticFeedbackForWarning];
    }
}

- (void)handleHapticFeedbackForImpactStyle:(UIImpactFeedbackStyle)style {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 10.0, *)) {
            _hapticFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:style];
            [_hapticFeedbackGenerator prepare];
            [_hapticFeedbackGenerator impactOccurred];
            _hapticFeedbackGenerator = nil;
        }
    });
}

- (void)handleHapticFeedbackForError {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 10.0, *)) {
            _hapticFeedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
            [_hapticFeedbackGenerator prepare];
            [_hapticFeedbackGenerator notificationOccurred:UINotificationFeedbackTypeError];
            _hapticFeedbackGenerator = nil;
        }
    });
}

- (void)handleHapticFeedbackForSelection {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 10.0, *)) {
            _hapticFeedbackGenerator = [[UISelectionFeedbackGenerator alloc] init];
            [_hapticFeedbackGenerator prepare];
            [_hapticFeedbackGenerator selectionChanged];
            _hapticFeedbackGenerator = nil;
        }
    });
}

- (void)handleHapticFeedbackForSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 10.0, *)) {
            _hapticFeedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
            [_hapticFeedbackGenerator prepare];
            [_hapticFeedbackGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
            _hapticFeedbackGenerator = nil;
        }
    });
}

- (void)handleHapticFeedbackForWarning {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 10.0, *)) {
            _hapticFeedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
            [_hapticFeedbackGenerator prepare];
            [_hapticFeedbackGenerator notificationOccurred:UINotificationFeedbackTypeWarning];
            _hapticFeedbackGenerator = nil;
        }
    });
}

@end
