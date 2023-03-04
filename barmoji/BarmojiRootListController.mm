//
//  BarmojiPreferencesListController.mm
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 01/16/2018
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#import "BarmojiPreferences.h"
#import "NSConcreteNotification.h" // for converting return key to dismiss the keyboard
#import <spawn.h>

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface BarmojiRootListController : PSListController <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) NSMutableArray *dynamicSpecsEmojiSource;
@property (strong, nonatomic) NSMutableArray *dynamicSpecsPredictiveBar;
@property (strong, nonatomic) NSMutableArray *dynamicSpecsBottomBar;
@end

@implementation BarmojiRootListController

- (NSBundle *)bundle {
    return [NSBundle bundleForClass:[self class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createDynamicSpecsEmojiSource];
        [self createDynamicSpecsPredictiveBar];
        [self createDynamicSpecsBottomBar];
    }
    return self;
}

- (void)_returnKeyPressed:(NSConcreteNotification *)notification {
    [self.view endEditing:YES];
}

- (void)createDynamicSpecsEmojiSource {
    PSSpecifier *specifier;
    _dynamicSpecsEmojiSource = [NSMutableArray new];

    specifier = textEditCellWithName(NSLocalizedStringFromTableInBundle(@"Emojis", nil, self.bundle, nil));
    setClassForSpec(NSClassFromString(@"BarmojiEditableTextCell"));
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setDefaultForSpec(@"");
    setPlaceholderForSpec(@"Your Favorite Emojis");
    setKeyForSpec(@"CustomEmojis");
    [_dynamicSpecsEmojiSource addObject:specifier];
}

- (void)createDynamicSpecsPredictiveBar {
    PSSpecifier *specifier;
    _dynamicSpecsPredictiveBar = [NSMutableArray new];
    
    specifier = [PSSpecifier preferenceSpecifierNamed:NSLocalizedStringFromTableInBundle(@"Scroll Direction", nil, self.bundle, nil) target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"BarmojiListItemsController") cell:PSLinkListCell edit:nil];
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setKeyForSpec(@"BarmojiScrollDirection");
    [specifier setValues:[self scrollDirectionValues] titles:[self scrollDirectionTitles] shortTitles:[self scrollDirectionShortTitles]];
    [_dynamicSpecsPredictiveBar addObject:specifier];
}

- (void)createDynamicSpecsBottomBar {
    PSSpecifier *specifier;
    _dynamicSpecsBottomBar = [NSMutableArray new];

    specifier = textEditCellWithName(NSLocalizedStringFromTableInBundle(@"Left Offset", nil, self.bundle, nil));
    setClassForSpec(NSClassFromString(@"PSEditableTableCell"));
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setDefaultForSpec(@"60");
    setKeyForSpec(@"BarmojiBottomLeading");
    [_dynamicSpecsBottomBar addObject:specifier];
    
    specifier = textEditCellWithName(NSLocalizedStringFromTableInBundle(@"Right Offset", nil, self.bundle, nil));
    setClassForSpec(NSClassFromString(@"PSEditableTableCell"));
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setDefaultForSpec(@"-60");
    setKeyForSpec(@"BarmojiBottomTrailing");
    [_dynamicSpecsBottomBar addObject:specifier];

    specifier = textEditCellWithName(NSLocalizedStringFromTableInBundle(@"Emojis Height", nil, self.bundle, nil));
    setClassForSpec(NSClassFromString(@"PSEditableTableCell"));
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setDefaultForSpec(@"-20");
    setKeyForSpec(@"BarmojiBottomHeight");
    [_dynamicSpecsBottomBar addObject:specifier];
    
    specifier = subtitleSwitchCellWithName(NSLocalizedStringFromTableInBundle(@"Hide Globe Button", nil, self.bundle, nil));
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setKeyForSpec(@"BarmojiHideGlobe");
    [_dynamicSpecsBottomBar addObject:specifier];

    specifier = subtitleSwitchCellWithName(NSLocalizedStringFromTableInBundle(@"Hide Dictation Button", nil, self.bundle, nil));
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setKeyForSpec(@"BarmojiHideDictation");
    [_dynamicSpecsBottomBar addObject:specifier];
}


- (id)specifiers {
    if (_specifiers == nil) {

        NSMutableArray *mutableSpecifiers = [NSMutableArray new];
        PSSpecifier *specifier;

        specifier = groupSpecifier(@"");
        [mutableSpecifiers addObject:specifier];

        specifier = subtitleSwitchCellWithName(NSLocalizedStringFromTableInBundle(@"Enabled", nil, self.bundle, nil));
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        setKeyForSpec(@"BarmojiEnabled");
        [mutableSpecifiers addObject:specifier];

        specifier = groupSpecifier(NSLocalizedStringFromTableInBundle(@"Shown Emojis", nil, self.bundle, nil));
        [mutableSpecifiers addObject:specifier];

        specifier = segmentCellWithName(NSLocalizedStringFromTableInBundle(@"Shown Emojis", nil, self.bundle, nil));
        [specifier setProperty:@YES forKey:@"enabled"];
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        [specifier setValues:@[@(1), @(2)] titles:@[NSLocalizedStringFromTableInBundle(@"Recent", nil, self.bundle, nil), NSLocalizedStringFromTableInBundle(@"Custom", nil, self.bundle, nil)]];
        setDefaultForSpec(@1);
        setKeyForSpec(@"EmojiSource");
        [mutableSpecifiers addObject:specifier];

        int sourceType = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("EmojiSource"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
        if (sourceType == 2) {
            for(PSSpecifier *sp in _dynamicSpecsEmojiSource) {
                [mutableSpecifiers addObject:sp];
            }
        }
        
        specifier = groupSpecifier(NSLocalizedStringFromTableInBundle(@"Emojis Per Row", nil, self.bundle, nil));
        setFooterForSpec(NSLocalizedStringFromTableInBundle(@"Choose how many emojis showing per row.\nDefault Font Size = 24", nil, self.bundle, nil));
        [mutableSpecifiers addObject:specifier];
        
        specifier = segmentCellWithName(NSLocalizedStringFromTableInBundle(@"Emoji Per Row", nil, self.bundle, nil));
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        [specifier setValues:@[@(4), @(5), @(6), @(7), @(8), @(9)] titles:@[@"4", @"5", @"6", @"7", @"8", @"9"]];
        setDefaultForSpec(@6);
        setKeyForSpec(@"BarmojiEmojiPerRow");
        [mutableSpecifiers addObject:specifier];
        
        specifier = textEditCellWithName(NSLocalizedStringFromTableInBundle(@"Font Size", nil, self.bundle, nil));
        setClassForSpec(NSClassFromString(@"PSEditableTableCell"));
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        setDefaultForSpec(@"24");
        setKeyForSpec(@"EmojiFontSize");
        [mutableSpecifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:NSLocalizedStringFromTableInBundle(@"Haptic Feedback Type", nil, self.bundle, nil) target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"BarmojiListItemsController") cell:PSLinkListCell edit:nil];
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        setKeyForSpec(@"BarmojiFeedbackType");
        [specifier setValues:[self activationTypeValues] titles:[self activationTypeTitles] shortTitles:[self activationTypeShortTitles]];
        [mutableSpecifiers addObject:specifier];
        
        specifier = groupSpecifier(NSLocalizedStringFromTableInBundle(@"Emojis Position", nil, self.bundle, nil));
        setFooterForSpec(NSLocalizedStringFromTableInBundle(@"Default Values:\nLeft Offset = 60\nRight Offset = -60\nEmojis Height = -20\nFor full width set Left Offset = 0 and Right Offset = 0.", nil, self.bundle, nil));
        [mutableSpecifiers addObject:specifier];

        specifier = segmentCellWithName(NSLocalizedStringFromTableInBundle(@"Emojis Position", nil, self.bundle, nil));
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        [specifier setValues:@[@(2)] titles:@[NSLocalizedStringFromTableInBundle(@"Bottom Bar", nil, self.bundle, nil)]];
        setDefaultForSpec(@2);
        setKeyForSpec(@"EmojisPosition");
        [mutableSpecifiers addObject:specifier];

        int emojisPositionType = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("EmojisPosition"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
        emojisPositionType = 2;
        
        if (emojisPositionType == 2) {
            for (PSSpecifier *sp in _dynamicSpecsBottomBar) {
                [mutableSpecifiers addObject:sp];
            }
        } else {
            for (PSSpecifier *sp in _dynamicSpecsPredictiveBar) {
                [mutableSpecifiers addObject:sp];
            }
        }

        specifier = groupSpecifier(@"");
        setFooterForSpec(NSLocalizedStringFromTableInBundle(@"A respring is required to fully apply setting changes.", nil, self.bundle, nil));
        [mutableSpecifiers addObject:specifier];

        specifier = buttonCellWithName(NSLocalizedStringFromTableInBundle(@"Respring", nil, self.bundle, nil));
        specifier->action = @selector(respring);
        [mutableSpecifiers addObject:specifier];

		specifier = groupSpecifier(@"");
		[specifier setProperty:@(1) forKey:@"footerAlignment"];
		setFooterForSpec(NSLocalizedStringFromTableInBundle(@"Barmoji v2023.3\nCopyright © 2020-2023 CP Digital Darkroom", nil, self.bundle, nil));
		[mutableSpecifiers addObject:specifier];

        specifier = groupSpecifier(@"");
		[specifier setProperty:@(1) forKey:@"footerAlignment"];
		setFooterForSpec(NSLocalizedStringFromTableInBundle(@"\nSpecial thanks to MiRO92, NSExceptional, p2kdev for their contributions in making Barmoji better.", nil, self.bundle, nil));
		[mutableSpecifiers addObject:specifier];

        _specifiers = [mutableSpecifiers copy];
    }

    return _specifiers;
}

- (NSArray *)activationTypeShortTitles {
    return @[
        NSLocalizedStringFromTableInBundle(@"None", nil, self.bundle, nil),
        NSLocalizedStringFromTableInBundle(@"Extra Light", nil, self.bundle, nil),
        NSLocalizedStringFromTableInBundle(@"Light", nil, self.bundle, nil),
        NSLocalizedStringFromTableInBundle(@"Medium", nil, self.bundle, nil),
        NSLocalizedStringFromTableInBundle(@"Strong", nil, self.bundle, nil),
        NSLocalizedStringFromTableInBundle(@"Strong 2", nil, self.bundle, nil),
        NSLocalizedStringFromTableInBundle(@"Strong 3", nil, self.bundle, nil)
    ];
}

- (NSArray *)activationTypeTitles {
    return @[
        NSLocalizedStringFromTableInBundle(@"None", nil, self.bundle, nil),
        NSLocalizedStringFromTableInBundle(@"Extra Light", nil, self.bundle, nil),
        NSLocalizedStringFromTableInBundle(@"Light", nil, self.bundle, nil),
        NSLocalizedStringFromTableInBundle(@"Medium", nil, self.bundle, nil),
        NSLocalizedStringFromTableInBundle(@"Strong", nil, self.bundle, nil),
        NSLocalizedStringFromTableInBundle(@"Strong 2", nil, self.bundle, nil),
        NSLocalizedStringFromTableInBundle(@"Strong 3", nil, self.bundle, nil)
    ];
}

- (NSArray *)activationTypeValues {
    return @[
        @7, @1, @2, @3, @4, @5, @6
    ];
}

- (NSArray *)scrollDirectionShortTitles {
    return [self scrollDirectionTitles];
}

- (NSArray *)scrollDirectionTitles {
    return @[
        NSLocalizedStringFromTableInBundle(@"Horizontal", nil, self.bundle, nil),
        NSLocalizedStringFromTableInBundle(@"Vertical", nil, self.bundle, nil)
    ];
}

- (NSArray *)scrollDirectionValues {
    return @[
        @(UICollectionViewScrollDirectionHorizontal), @(UICollectionViewScrollDirectionVertical)
    ];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    
    [super setPreferenceValue:value specifier:specifier];

    NSDictionary *properties = specifier.properties;
    NSString *key = properties[@"key"];

    if ([key isEqualToString:@"EmojiSource"]) {
        BOOL shouldShow = [value intValue] == 2;
        [self shouldShowCustomEmojiSpecifiers:shouldShow];
    }
    
    if ([key isEqualToString:@"EmojisPosition"]) {
        BOOL shouldShowPredictiveBar = [value intValue] == 1;
        [self shouldShowEmojiPositionSpecifiers:shouldShowPredictiveBar];
    }

    int feedbackType = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiFeedbackType"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
    BOOL enabled = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiEnabled"), CFSTR("com.cpdigitaldarkroom.barmoji"))) boolValue];
    int barmojiBottomLeading = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiBottomLeading"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
    int barmojiBottomTrailing = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiBottomTrailing"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
    int barmojiBottomHeight = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiBottomHeight"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
    int barmojiEmojiPerRow = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiEmojiPerRow"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
    int barmojiEmojiFontSize = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("EmojiFontSize"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
    BOOL barmojiHideGlobe = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiHideGlobe"), CFSTR("com.cpdigitaldarkroom.barmoji"))) boolValue];
    BOOL barmojiHideDictation = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiHideDictation"), CFSTR("com.cpdigitaldarkroom.barmoji"))) boolValue];
    int barmojiEmojisPosition = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("EmojisPosition"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
    barmojiEmojisPosition = 2;

    NSDictionary *dictionary = @{
        @"feedbackType": @(feedbackType),
        @"enabled": @(enabled),
        @"BarmojiBottomLeading": @(barmojiBottomLeading),
        @"BarmojiBottomTrailing": @(barmojiBottomTrailing),
        @"BarmojiBottomHeight": @(barmojiBottomHeight),
        @"BarmojiEmojiPerRow": @(barmojiEmojiPerRow),
        @"EmojiFontSize": @(barmojiEmojiFontSize),
        @"BarmojiHideGlobe": @(barmojiHideGlobe),
        @"BarmojiHideDictation": @(barmojiHideDictation),
        @"EmojisPosition": @(barmojiEmojisPosition)
    };
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDistributedCenter(),
        CFSTR("com.cpdigitaldarkroom.barmoji.settings"),
        nil, (__bridge CFDictionaryRef)dictionary, true);
}

- (void)shouldShowCustomEmojiSpecifiers:(BOOL)show {
    if (show) {
        [self insertContiguousSpecifiers:_dynamicSpecsEmojiSource afterSpecifierID:@"EmojiSource" animated:YES];
    } else {
        [self removeContiguousSpecifiers:_dynamicSpecsEmojiSource animated:YES];
    }
}

- (void)shouldShowEmojiPositionSpecifiers:(BOOL)show {
    if (show) {
        [self insertContiguousSpecifiers:_dynamicSpecsPredictiveBar afterSpecifierID:@"EmojisPosition" animated:YES];
        [self removeContiguousSpecifiers:_dynamicSpecsBottomBar animated:YES];
    } else {
        [self insertContiguousSpecifiers:_dynamicSpecsBottomBar afterSpecifierID:@"EmojisPosition" animated:YES];
        [self removeContiguousSpecifiers:_dynamicSpecsPredictiveBar animated:YES];
    }
}

- (void)respring {
    pid_t pid;
    int status;
    const char *args[] = {"killall", "-9", "backboardd", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char * const *)args, NULL);
    waitpid(pid, &status, WEXITED);
}

@end
