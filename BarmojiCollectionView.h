//
//  BarmojiCollectionView.h
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 01/16/2018
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarmojiCollectionView : UICollectionView

@property (assign, nonatomic) int feedbackType;

- (instancetype)initForPredictiveBar:(BOOL)forPredictive;

@end
