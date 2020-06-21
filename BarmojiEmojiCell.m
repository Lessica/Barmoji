//
//  BarmojiEmojiCell.m
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 11/21/2019
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#import "Barmoji.h"
#import "BarmojiEmojiCell.h"

@interface BarmojiEmojiCell ()

@property (strong, nonatomic) UILabel *emojiLabel;

@end

@implementation BarmojiEmojiCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.cpdigitaldarkroom.barmoji.plist"];
        int emojiFontSize = ([prefs objectForKey:@"EmojiFontSize"] ? [[prefs objectForKey:@"EmojiFontSize"] intValue] : 24);

        _emojiLabel = [[UILabel alloc] initWithFrame: CGRectZero];
        _emojiLabel.font = [UIFont systemFontOfSize: emojiFontSize];
        _emojiLabel.textAlignment = NSTextAlignmentCenter;
        _emojiLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview: _emojiLabel];

        [NSLayoutConstraint activateConstraints: @[
            [_emojiLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
            [_emojiLabel.bottomAnchor constraintEqualToAnchor: self.contentView.bottomAnchor],
            [_emojiLabel.leadingAnchor constraintEqualToAnchor: self.contentView.leadingAnchor],
            [_emojiLabel.trailingAnchor constraintEqualToAnchor: self.contentView.trailingAnchor]
        ]];

    }
    return self;
}

- (void)setEmoji:(UIKeyboardEmoji *)emoji {
    _emoji = emoji;
    _emojiLabel.text = emoji.emojiString;
}

@end
