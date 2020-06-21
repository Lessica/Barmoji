//
//  BarmojiPreferencesListController.mm
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 01/16/2018
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#import "BarmojiPreferences.h"
#import "NSConcreteNotification.h" // for converting return key to dismiss the keyboard
#include <spawn.h>

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface BarmojiRootListController : PSListController <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) NSMutableArray *dynamicSpecsEmojiSource;
@property (strong, nonatomic) NSMutableArray *dynamicSpecsPredictiveBar;
@property (strong, nonatomic) NSMutableArray *dynamicSpecsBottomBar;
@end

@implementation BarmojiRootListController

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

    specifier = textEditCellWithName(@"Emojis:");
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
    
    //specifier = groupSpecifier(@"Predictive Bar");
    //setFooterForSpec(@"Replaces the text prediction bar with Barmoji, useful for non-iPhone X devices");
    //[_dynamicSpecsPredictiveBar addObject:specifier];

    specifier = [PSSpecifier preferenceSpecifierNamed:@"Scroll Direction" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"BarmojiListItemsController") cell:PSLinkListCell edit:nil];
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setKeyForSpec(@"BarmojiScrollDirection");
    [specifier setValues:[self scrollDirectionValues] titles:[self scrollDirectionTitles] shortTitles:[self scrollDirectionShortTitles]];
    [_dynamicSpecsPredictiveBar addObject:specifier];
}

- (void)createDynamicSpecsBottomBar {
    PSSpecifier *specifier;
    _dynamicSpecsBottomBar = [NSMutableArray new];

    //specifier = groupSpecifier(@"Bottom Bar");
    //setFooterForSpec(@"Default Values:\nLeft Offset = 60\nRight Offset = -60\nEmojis Height = -20\nFor full width set Left Offset = 0 and Right Offset = 0.");
    //[_dynamicSpecsBottomBar addObject:specifier];
    
    specifier = textEditCellWithName(@"Left Offset:");
    setClassForSpec(NSClassFromString(@"PSEditableTableCell"));
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setDefaultForSpec(@"60");
    setKeyForSpec(@"BarmojiBottomLeading");
    [_dynamicSpecsBottomBar addObject:specifier];
    
    specifier = textEditCellWithName(@"Right Offset:");
    setClassForSpec(NSClassFromString(@"PSEditableTableCell"));
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setDefaultForSpec(@"-60");
    setKeyForSpec(@"BarmojiBottomTrailing");
    [_dynamicSpecsBottomBar addObject:specifier];

    specifier = textEditCellWithName(@"Emojis Height:");
    setClassForSpec(NSClassFromString(@"PSEditableTableCell"));
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setDefaultForSpec(@"-20");
    setKeyForSpec(@"BarmojiBottomHeight");
    [_dynamicSpecsBottomBar addObject:specifier];
    
    specifier = subtitleSwitchCellWithName(@"Hide Globe Button");
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setKeyForSpec(@"BarmojiHideGlobe");
    [_dynamicSpecsBottomBar addObject:specifier];

    specifier = subtitleSwitchCellWithName(@"Hide Dictation Button");
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

        specifier = subtitleSwitchCellWithName(@"Enabled");
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        setKeyForSpec(@"BarmojiEnabled");
        [mutableSpecifiers addObject:specifier];

        specifier = groupSpecifier(@"Shown Emojis");
        [mutableSpecifiers addObject:specifier];

        specifier = segmentCellWithName(@"Shown Emojis");
        [specifier setProperty:(kIsDemo) ? @NO : @YES forKey:@"enabled"];
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        [specifier setValues:@[@(1), @(2)] titles:@[@"Recent", @"Custom"]];
        setDefaultForSpec(@1);
        setKeyForSpec(@"EmojiSource");
        [mutableSpecifiers addObject:specifier];

        int sourceType = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("EmojiSource"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
        if (sourceType == 2) {
            for(PSSpecifier *sp in _dynamicSpecsEmojiSource) {
                [mutableSpecifiers addObject:sp];
            }
        }
        
        specifier = groupSpecifier(@"Emojis Per Row");
        setFooterForSpec(@"Choose how many emojis showing per row.\nDefault Font Size = 24");
        [mutableSpecifiers addObject:specifier];
        
        specifier = segmentCellWithName(@"Emoji Per Row");
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        [specifier setValues:@[@(4), @(5), @(6), @(7), @(8), @(9)] titles:@[@"4", @"5", @"6", @"7", @"8", @"9"]];
        setDefaultForSpec(@6);
        setKeyForSpec(@"BarmojiEmojiPerRow");
        [mutableSpecifiers addObject:specifier];
        
        specifier = textEditCellWithName(@"Font Size:");
        setClassForSpec(NSClassFromString(@"PSEditableTableCell"));
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        setDefaultForSpec(@"24");
        setKeyForSpec(@"EmojiFontSize");
        [mutableSpecifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Haptic Feedback Type" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"BarmojiListItemsController") cell:PSLinkListCell edit:nil];
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        setKeyForSpec(@"BarmojiFeedbackType");
        [specifier setValues:[self activationTypeValues] titles:[self activationTypeTitles] shortTitles:[self activationTypeShortTitles]];
        [mutableSpecifiers addObject:specifier];
        
        specifier = groupSpecifier(@"Emojis Position");
        setFooterForSpec(@"Default Values:\nLeft Offset = 60\nRight Offset = -60\nEmojis Height = -20\nFor full width set Left Offset = 0 and Right Offset = 0.");
        [mutableSpecifiers addObject:specifier];

        specifier = segmentCellWithName(@"Emojis Position");
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        [specifier setValues:@[@(1), @(2)] titles:@[@"Predictive Bar", @"Bottom Bar"]];
        setDefaultForSpec(@1);
        setKeyForSpec(@"EmojisPosition");
        [mutableSpecifiers addObject:specifier];

        int emojisPositionType = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("EmojisPosition"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
        if (emojisPositionType == 2) {
            for(PSSpecifier *sp in _dynamicSpecsBottomBar) {
                [mutableSpecifiers addObject:sp];
            }
        } else {
            for(PSSpecifier *sp in _dynamicSpecsPredictiveBar) {
                [mutableSpecifiers addObject:sp];
            }
        }

        specifier = groupSpecifier(@"");
        setFooterForSpec(@"A respring is required to fully apply setting changes");
        [mutableSpecifiers addObject:specifier];

        specifier = buttonCellWithName(@"Respring");
        specifier->action = @selector(respring);
        [mutableSpecifiers addObject:specifier];

        specifier = groupSpecifier(@"Support");
        setFooterForSpec(@"Having Trouble? Get in touch and I'll help when I can");
        [mutableSpecifiers addObject:specifier];

        specifier = buttonCellWithName(@"Email Support");
        specifier->action = @selector(presentSupportMailController:);
        [mutableSpecifiers addObject:specifier];

        if(kIsDemo) {
			specifier = groupSpecifier(@"");
			[specifier setProperty:@(0) forKey:@"footerAlignment"];
			setFooterForSpec(@"\n\nBecome a supporter to unlock all configuration options. Learn more with the CPDD Connect app available on my repo or at https://cpdigitaldarkroom.com\n\n\n");
			[mutableSpecifiers addObject:specifier];
		}

		specifier = groupSpecifier(@"");
		[specifier setProperty:@(1) forKey:@"footerAlignment"];
		setFooterForSpec(@"Barmoji v2020.4.4\nCopyright © 2020 CP Digital Darkroom");
		[mutableSpecifiers addObject:specifier];

        specifier = groupSpecifier(@"");
		[specifier setProperty:@(1) forKey:@"footerAlignment"];
		setFooterForSpec(@"\nSpecial thanks to NSExceptional for their contributions in making Barmoji better.");
		[mutableSpecifiers addObject:specifier];

        _specifiers = [mutableSpecifiers copy];
    }

    return _specifiers;
}

- (NSArray *)activationTypeShortTitles {
    return @[
        @"None",
        @"Extra Light",
        @"Light",
        @"Medium",
        @"Strong",
        @"Strong 2",
        @"Strong 3"
    ];
}

- (NSArray *)activationTypeTitles {
    return @[
        @"None",
        @"Extra Light",
        @"Light",
        @"Medium",
        @"Strong",
        @"Strong 2",
        @"Strong 3"
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
        @"Horizontal", @"Vertical"
    ];
}

- (NSArray *)scrollDirectionValues {
    return @[
        @(UICollectionViewScrollDirectionHorizontal), @(UICollectionViewScrollDirectionVertical)
    ];
}

- (void)presentSupportMailController:(PSSpecifier *)spec {

    MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
    [composeViewController setSubject:@"Barmoji Support"];
    [composeViewController setToRecipients:[NSArray arrayWithObjects:@"CP Digital Darkroom <tweaks@cpdigitaldarkroom.support>", nil]];

    NSString *product = nil, *version = nil, *build = nil;
    product = (__bridge NSString *)MGCopyAnswer(kMGProductType, nil);
    version = (__bridge NSString *)MGCopyAnswer(kMGProductVersion, nil);
    build = (__bridge NSString *)MGCopyAnswer(kMGBuildVersion, nil);

    [composeViewController setMessageBody:[NSString stringWithFormat:@"\n\nCurrent Device: %@, iOS %@ (%@)", product, version, build] isHTML:NO];

    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", [NSString stringWithFormat:@"dpkg -l"]]];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task launch];

    NSData *data = [task.standardOutput fileHandleForReading].readDataToEndOfFile;

    [composeViewController addAttachmentData:data mimeType:@"text/plain" fileName:@"dpkgl.txt"];

    [self.navigationController presentViewController:composeViewController animated:YES completion:nil];
    composeViewController.mailComposeDelegate = self;

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
