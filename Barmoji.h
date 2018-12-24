//
//  Barmoji.h
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 01/16/2018
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#define kPrefDomain "com.cpdigitaldarkroom.barmoji"

@interface EMFEmojiToken : NSObject
@property (nonatomic,copy) NSString * string;
@end

@interface EMFEmojiPreferences : NSObject
-(NSArray *)allRecents;
-(NSArray *)recentEmojis;
@end

@interface UIKeyboardImpl : UIView

+(id)activeInstance;
-(void)insertText:(id)arg1 ;
@end

@interface UIKeyboardEmoji
@property (nonatomic,retain) NSString* emojiString;
+(id)emojiWithString:(id)arg1 withVariantMask:(unsigned long long)arg2 ;
@end

@interface UIKeyboardEmojiCollectionViewCell : UICollectionViewCell
@property (nonatomic,copy) UIKeyboardEmoji* emoji;
@property (assign, nonatomic) long long emojiFontSize;
@end

@interface UIKeyboardEmojiKeyDisplayController : NSObject
- (NSArray *)recents;
@end

@class BarmojiCollectionView;
@interface UIKeyboardPredictionView : UIView
@property (nonatomic,retain) BarmojiCollectionView* barmoji;
@end

@interface UIKeyboardDockView : UIView
@property (nonatomic,retain) BarmojiCollectionView* barmoji;
@end

@interface UISystemKeyboardDockController : UIViewController
@property (nonatomic,retain) UIKeyboardDockView* dockView;
@end
