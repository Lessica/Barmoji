//
//  BarmojiHapticsManager.h
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 01/16/2018
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BarmojiHapticsManager : NSObject

+ (instancetype)sharedManager;

- (void)actuateHapticsForType:(int)feedbackType;

@end
