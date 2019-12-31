//
//  BarmojiPreferencesListController.mm
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 01/16/2018
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#import "BarmojiPreferences.h"
#include <spawn.h>

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface BarmojiRootListController : PSListController <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) NSMutableArray *dynamicSpecs;
@end

@implementation BarmojiRootListController

- (instancetype)init {
    self = [super init];
        if (self) {
        [self createDynamicSpecs];
    }
    return self;
}

- (void)createDynamicSpecs {
    PSSpecifier *specifier;
    _dynamicSpecs = [NSMutableArray new];

    specifier = groupSpecifier(@"");
    [_dynamicSpecs addObject:specifier];

    specifier = textEditCellWithName(@"Emojis:");
    setClassForSpec(NSClassFromString(@"BarmojiEditableTextCell"));
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setDefaultForSpec(@"");
    setPlaceholderForSpec(@"Your Favorite Emojis");
    setKeyForSpec(@"CustomEmojis");
    [_dynamicSpecs addObject:specifier];
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
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        [specifier setValues:@[@(1), @(2)] titles:@[@"Recent", @"Custom"]];
        setDefaultForSpec(@1);
        setKeyForSpec(@"EmojiSource");
        [mutableSpecifiers addObject:specifier];

        int sourceType = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("EmojiSource"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
        if (sourceType == 2) {
            for(PSSpecifier *sp in _dynamicSpecs) {
                [mutableSpecifiers addObject:sp];
            }
        }

        specifier = groupSpecifier(@"Bottom Bar");
        setFooterForSpec(@"The default Barmoji implementation for iPhone X or devices who have enabled the iPhone X layout.");
        [mutableSpecifiers addObject:specifier];

        specifier = subtitleSwitchCellWithName(@"Enabled");
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        setKeyForSpec(@"BarmojiBottomEnabled");
        [mutableSpecifiers addObject:specifier];

        specifier = subtitleSwitchCellWithName(@"Full Width");
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        setKeyForSpec(@"BarmojiFullWidthBottom");
        [mutableSpecifiers addObject:specifier];

        specifier = groupSpecifier(@"Predictive Bar");
        setFooterForSpec(@"Replaces the text prediction bar with Barmoji, useful for non-iPhone X devices");
        [mutableSpecifiers addObject:specifier];

        specifier = subtitleSwitchCellWithName(@"Enabled");
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        setKeyForSpec(@"BarmojiPredictiveEnabled");
        [mutableSpecifiers addObject:specifier];

        specifier = groupSpecifier(@"Haptic Feedback");
        [mutableSpecifiers addObject:specifier];

        specifier = [PSSpecifier preferenceSpecifierNamed:@"Feedback Type" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"BarmojiListItemsController") cell:PSLinkListCell edit:nil];
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        setKeyForSpec(@"BarmojiFeedbackType");
        [specifier setValues:[self activationTypeValues] titles:[self activationTypeTitles] shortTitles:[self activationTypeShortTitles]];
        [mutableSpecifiers addObject:specifier];

        specifier = groupSpecifier(@"Layout");
        setFooterForSpec(@"Scroll direction only applies to the Predictive Bar location.");
        [mutableSpecifiers addObject:specifier];

        specifier = [PSSpecifier preferenceSpecifierNamed:@"Scroll Direction" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"BarmojiListItemsController") cell:PSLinkListCell edit:nil];
        [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
        setKeyForSpec(@"BarmojiScrollDirection");
        [specifier setValues:[self scrollDirectionValues] titles:[self scrollDirectionTitles] shortTitles:[self scrollDirectionShortTitles]];
        [mutableSpecifiers addObject:specifier];

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

    NSData *data = [[[task standardOutput] fileHandleForReading] readDataToEndOfFile];

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

    int feedbackType = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiFeedbackType"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
    BOOL bottom = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiBottomEnabled"), CFSTR("com.cpdigitaldarkroom.barmoji"))) boolValue];
    BOOL enabled = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiEnabled"), CFSTR("com.cpdigitaldarkroom.barmoji"))) boolValue];
    BOOL fullWidth = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiFullWidthBottom"), CFSTR("com.cpdigitaldarkroom.barmoji"))) boolValue];
    BOOL predictive = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiPredictiveEnabled"), CFSTR("com.cpdigitaldarkroom.barmoji"))) boolValue];

    NSDictionary *dictionary = @{
        @"feedbackType": @(feedbackType),
        @"fullwidth": @(fullWidth),
        @"bottom": @(bottom),
        @"enabled": @(enabled),
        @"predictive": @(predictive)
    };
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDistributedCenter(),
        CFSTR("com.cpdigitaldarkroom.barmoji.settings"),
        nil, (__bridge CFDictionaryRef)dictionary, true);
}

- (void)shouldShowCustomEmojiSpecifiers:(BOOL)show {
    if (show) {
        [self insertContiguousSpecifiers:_dynamicSpecs afterSpecifierID:@"EmojiSource" animated:YES];
    } else {
        [self removeContiguousSpecifiers:_dynamicSpecs animated:YES];
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
