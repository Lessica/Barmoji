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

@property (assign, nonatomic) BOOL useCustomEmojis;

@property (strong, nonatomic) NSArray *customEmojis;

@property (strong, nonatomic) UIKeyboardEmojiKeyDisplayController *emojiManager;

@end

@implementation BarmojiCollectionView

- (instancetype)init {
    
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.cpdigitaldarkroom.barmoji.plist"];
    int emojiSource = ([prefs objectForKey:@"EmojiSource"] ? [[prefs objectForKey:@"EmojiSource"] intValue] : 1);

    _useCustomEmojis = (emojiSource == 2);

    if(_useCustomEmojis) {
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
    }

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

    if(_useCustomEmojis) {
        NSString *emojiString = self.customEmojis[indexPath.row];
        cell.emoji = [UIKeyboardEmoji emojiWithString:emojiString withVariantMask:0];
    } else {
        cell.emoji = [self.emojiManager recents][indexPath.row];
    }
    
    cell.emojiFontSize = 26;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int count =  _useCustomEmojis ? self.customEmojis.count : [self.emojiManager recents].count;
    return count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(44, 30);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if(self.feedbackType != 7) {
        [[BarmojiHapticsManager sharedManager] actuateHapticsForType:self.feedbackType];
    }
    
    UIKeyboardEmoji *pressedEmoji;
    if(_useCustomEmojis) {
        NSString *emojiString = self.customEmojis[indexPath.row];
        pressedEmoji = [UIKeyboardEmoji emojiWithString:emojiString withVariantMask:0];
    } else {
        pressedEmoji = [self.emojiManager recents][indexPath.row];
    }

    [[NSClassFromString(@"UIKeyboardImpl") activeInstance] insertText:pressedEmoji.emojiString];
}

@end


