//
//  Barmoji.h
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 01/16/2018
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#define kPrefDomain "com.cpdigitaldarkroom.barmoji"

@interface EMFEmojiToken : NSObject
@property (nonatomic, copy) NSString *string;
@end

@interface EMFEmojiPreferences : NSObject
- (NSArray *)allRecents;
- (NSArray *)recentEmojis;
@end

@class BarmojiCollectionView;

@interface TUIPredictionView : UIView // iOS 13 +
@property (nonatomic, retain) BarmojiCollectionView *barmoji;
- (void)toggleBarmoji;
@end

@interface UIKBInputDelegateManager : NSObject  // iOS 15
- (void)insertText:(id)arg1;
- (void)insertText:(id)arg1 updateInputSource:(BOOL)arg2;
- (void)clearForwardingInputDelegateAndResign:(BOOL)arg1;
@end

@interface UIKeyboardImpl : UIView
+ (id)activeInstance;
- (void)insertText:(id)arg1;
- (void)addInputString:(NSString *)arg1 withFlags:(unsigned long long)arg2 executionContext:(id)arg3;
- (void)completeAddInputString:(NSString *)arg1;
- (void)completeAddInputString:(NSString *)arg1 generateCandidates:(BOOL)arg2;
- (void)clearForwardingInputDelegateAndResign:(BOOL)arg1;
- (void)updateReturnKey;
- (UIKBInputDelegateManager *)inputDelegateManager;
@end

@interface UIKeyboardEmoji
@property (nonatomic, retain) NSString *emojiString;
+ (id)emojiWithString:(id)arg1 withVariantMask:(NSUInteger)arg2;
@end

@interface UIKeyboardEmojiCollectionViewCell : UICollectionViewCell
@property (nonatomic, copy) UIKeyboardEmoji *emoji;
@property (assign, nonatomic) NSInteger emojiFontSize;
@end

@interface UIKeyboardEmojiKeyDisplayController : NSObject
- (NSArray *)recents;
@end

@interface UIKeyboardPredictionView : UIView
@property (nonatomic, retain) BarmojiCollectionView *barmoji;
@end

@interface UIKeyboardDockItemButton: UIButton
@end

@interface UIKeyboardDockItem : NSObject
@property (nonatomic, retain) UIKeyboardDockItemButton *button; 
@property (nonatomic,readonly) UIKeyboardDockItemButton * view; 
@end

@interface UIKeyboardDockView : UIView
@property (nonatomic, retain) BarmojiCollectionView *barmoji;
 @property (nonatomic,retain) UIKeyboardDockItem * centerDockItem;
- (id)_keyboardLayoutView;
@end

@interface UISystemKeyboardDockController : UIViewController
@property (nonatomic, retain) UIKeyboardDockView *dockView;
@end

@interface TIKeyboardCandidateSingle : NSObject
@property (readonly) NSString *candidate;
@property (readonly) NSString *input;
@end

@interface TIAutocorrectionList : NSObject
@property (readonly) NSArray *candidates;
@property (readonly) TIKeyboardCandidateSingle *autocorrection;
@property (readonly) BOOL containsProactiveTriggers;
@property (readonly) BOOL containsAutofillCandidates;
@property (readonly) BOOL shouldAcceptTopCandidate;
@end
