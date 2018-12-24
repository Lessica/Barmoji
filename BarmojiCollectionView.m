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

@interface BarmojiCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UIKeyboardEmojiKeyDisplayController *emojiManager;
@property (strong, nonatomic) NSArray *recentEmojis;

@end


@implementation BarmojiCollectionView

- (instancetype)init {

    EMFEmojiPreferences *emojiPrefs = [[NSClassFromString(@"EMFEmojiPreferences") alloc] init];
    self.recentEmojis = [emojiPrefs recentEmojis];

	//self.emojiManager = [[NSClassFromString(@"UIKeyboardEmojiKeyDisplayController") alloc] init];

	UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 20;
    flowLayout.minimumLineSpacing = 0;

    if(self = [super initWithFrame:CGRectZero collectionViewLayout:flowLayout]) {

        self.delegate = self;
        self.dataSource = self;
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = YES;
        [self registerClass:NSClassFromString(@"UIKeyboardEmojiCollectionViewCell") forCellWithReuseIdentifier:@"EmojiKey"];
        self.backgroundColor = [UIColor clearColor];

    }
    return self;
}

#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIKeyboardEmojiCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmojiKey" forIndexPath:indexPath];

    EMFEmojiToken *emojiToken = self.recentEmojis[indexPath.row];
    cell.emoji = [UIKeyboardEmoji emojiWithString:emojiToken.string withVariantMask:0];
    cell.emojiFontSize = 26;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recentEmojis.count;//[self.emojiManager recents].count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(44, 30);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if(self.feedbackType != 7) {
        [[BarmojiHapticsManager sharedManager] actuateHapticsForType:self.feedbackType];
    }
    EMFEmojiToken *emojiToken = self.recentEmojis[indexPath.row];
    UIKeyboardEmoji *pressedEmoji = [UIKeyboardEmoji emojiWithString:emojiToken.string withVariantMask:0];
    [[NSClassFromString(@"UIKeyboardImpl") activeInstance] insertText:pressedEmoji.emojiString];
}

@end


