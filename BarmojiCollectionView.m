//
//  BarmojiCollectionView.m
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 01/16/2018
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#import "Barmoji.h"
#import "BarmojiCollectionView.h"
#import "BarmojiHapticsManager.h"
#import "BarmojiEmojiCell.h"

@interface BarmojiCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (assign, nonatomic) UICollectionViewScrollDirection direction;
@property (assign, nonatomic) BOOL fullWidth;
@property (assign, nonatomic) BOOL replacingPredictiveBar;
@property (assign, nonatomic) BOOL useCustomEmojis;
@property (strong, nonatomic) NSArray *customEmojis;
@property (strong, nonatomic) NSArray *recentEmojis;
@property (assign, nonatomic) int emojiPerRow;
@property (strong, nonatomic) UIKeyboardEmojiKeyDisplayController *emojiManager;

@end

@implementation BarmojiCollectionView

- (instancetype)initForPredictiveBar:(BOOL)forPredictive; {
    
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.cpdigitaldarkroom.barmoji.plist"];

    int emojiSource = ([prefs objectForKey:@"EmojiSource"] ? [[prefs objectForKey:@"EmojiSource"] intValue] : 1);

    _direction = ([[prefs objectForKey:@"BarmojiScrollDirection"] ?: @(UICollectionViewScrollDirectionHorizontal) integerValue]);
    _emojiPerRow = 6;
    _fullWidth = ([prefs objectForKey:@"BarmojiFullWidthBottom"] ? [[prefs objectForKey:@"BarmojiFullWidthBottom"] boolValue] : NO);
    _replacingPredictiveBar = forPredictive;
    _useCustomEmojis = (emojiSource == 2);

    if (_useCustomEmojis) {
        NSString *emojiString = ([prefs objectForKey:@"CustomEmojis"] ? [prefs objectForKey:@"CustomEmojis"] : @"");

        NSMutableArray *emojis = [NSMutableArray new]; 
        
        [emojiString enumerateSubstringsInRange:NSMakeRange(0, emojiString.length)
        options:NSStringEnumerationByComposedCharacterSequences
        usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            [emojis addObject:substring];
        }];
        self.customEmojis = emojis;

    } else {
        self.emojiManager = [[NSClassFromString(@"UIKeyboardEmojiKeyDisplayController") alloc] init];
        self.recentEmojis = [self.emojiManager recents];
    }
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = self.replacingPredictiveBar ? self.direction : UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;

    self = [super initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.dataSource = self;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = YES;
        [self registerClass:NSClassFromString(@"BarmojiEmojiCell") forCellWithReuseIdentifier:@"kEmojiCellIdentifier"];
        
        [self rotationUpdate:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotationUpdate:) name:UIDeviceOrientationDidChangeNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLayout:) name:@"barmoji_reloadLayout" object:nil];

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)reloadLayout:(NSNotification *)note {
    [self reloadData];
}

- (void)rotationUpdate:(NSNotification *)notification {

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    // We don't want it to disappear in landscape if we're replacing the predictive bar
    self.alpha = landscape && !self.replacingPredictiveBar ? 0 : 1;
    // Landscape gets 12 emojis in the predictive bar,
    // Portrait gets 8 in the predictive bar or 6 on the bottom
    self.emojiPerRow = (landscape) ? 12 : ((self.replacingPredictiveBar || self.fullWidth ) ? 8 : 6);
    [self reloadData];
    
}

#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BarmojiEmojiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kEmojiCellIdentifier" forIndexPath:indexPath];
    if (_useCustomEmojis) {
        NSString *emojiString = self.customEmojis[indexPath.row];
        cell.emoji = [UIKeyboardEmoji emojiWithString:emojiString withVariantMask:0];
    } else {
        cell.emoji = _recentEmojis[indexPath.row];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _useCustomEmojis ? self.customEmojis.count : _recentEmojis.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat useableWidth = collectionView.frame.size.width / self.emojiPerRow;
    return CGSizeMake(useableWidth, 30);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.replacingPredictiveBar) {
        return UIEdgeInsetsZero;
    }

    return UIEdgeInsetsMake(22, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.feedbackType != 7) {
        [[BarmojiHapticsManager sharedManager] actuateHapticsForType:self.feedbackType];
    }
    
    UIKeyboardEmoji *pressedEmoji;
    if (_useCustomEmojis) {
        NSString *emojiString = self.customEmojis[indexPath.row];
        pressedEmoji = [UIKeyboardEmoji emojiWithString:emojiString withVariantMask:0];
    } else {
        pressedEmoji = [self.emojiManager recents][indexPath.row];
    }

    [[NSClassFromString(@"UIKeyboardImpl") activeInstance] insertText:pressedEmoji.emojiString];
}

@end
