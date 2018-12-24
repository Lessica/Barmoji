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
@end

@implementation BarmojiRootListController

-(id)specifiers {
  if(_specifiers == nil) {

    NSMutableArray *mutableSpecifiers = [NSMutableArray new];
    PSSpecifier *specifier;

    specifier = groupSpecifier(@"");
    [mutableSpecifiers addObject:specifier];

    specifier = subtitleSwitchCellWithName(@"Enabled");
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setKeyForSpec(@"BarmojiEnabled");
    [mutableSpecifiers addObject:specifier];

    specifier = groupSpecifier(@"Accessibility");
    setFooterForSpec(@"Enabling this option will disable the home gesture while the keyboard is presented.");
    [mutableSpecifiers addObject:specifier];

    specifier = subtitleSwitchCellWithName(@"Disable Home Gesture");
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setKeyForSpec(@"BarmojiDisablesGesture");
    [mutableSpecifiers addObject:specifier];

    specifier = groupSpecifier(@"Locations");
    setFooterForSpec(@"Bottom Bar: The default Barmoji implementation for iPhone X or devices who have enabled the iPhone X layout. \n\nReplace Predictive Bar: Replaces the text prediction bar with Barmoji, useful for non-iPhone X devices");
    [mutableSpecifiers addObject:specifier];

    specifier = subtitleSwitchCellWithName(@"Bottom Bar");
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    setKeyForSpec(@"BarmojiBottomEnabled");
    [mutableSpecifiers addObject:specifier];

    specifier = subtitleSwitchCellWithName(@"Replace Predictive Bar");
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

- (void)presentSupportMailController:(PSSpecifier *)spec {

  MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
  [composeViewController setSubject:@"Barmoji Support"];
  [composeViewController setToRecipients:[NSArray arrayWithObjects:@"CP Digital Darkroom <tweaks@cpdigitaldarkroom.support>", nil]];

  NSString *product = nil, *version = nil, *build = nil;
  product = (NSString *)MGCopyAnswer(kMGProductType);
  version = (NSString *)MGCopyAnswer(kMGProductVersion);
  build = (NSString *)MGCopyAnswer(kMGBuildVersion);

  [composeViewController setMessageBody:[NSString stringWithFormat:@"\n\nCurrent Device: %@, iOS %@ (%@)", product, version, build] isHTML:NO];

  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath: @"/bin/sh"];
  [task setArguments:@[@"-c", [NSString stringWithFormat:@"dpkg -l"]]];

  NSPipe *pipe = [NSPipe pipe];
  [task setStandardOutput:pipe];
  [task launch];

  NSData *data = [[[task standardOutput] fileHandleForReading] readDataToEndOfFile];
  [task release];

  [composeViewController addAttachmentData:data mimeType:@"text/plain" fileName:@"dpkgl.txt"];

  [self.navigationController presentViewController:composeViewController animated:YES completion:nil];
  composeViewController.mailComposeDelegate = self;
  [composeViewController release];

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
  [self dismissViewControllerAnimated: YES completion: nil];
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {

  [super setPreferenceValue:value specifier:specifier];

  int feedbackType = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiFeedbackType"), CFSTR("com.cpdigitaldarkroom.barmoji"))) intValue];
  BOOL bottom = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiBottomEnabled"), CFSTR("com.cpdigitaldarkroom.barmoji"))) boolValue];
  BOOL enabled = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiEnabled"), CFSTR("com.cpdigitaldarkroom.barmoji"))) boolValue];
  BOOL predictive = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("BarmojiPredictiveEnabled"), CFSTR("com.cpdigitaldarkroom.barmoji"))) boolValue];

  CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
  CFDictionaryAddValue(dictionary, @"feedbackType", CFBridgingRetain([NSNumber numberWithInt:feedbackType]));
  CFDictionaryAddValue(dictionary, @"bottom", CFBridgingRetain([NSNumber numberWithBool:bottom]));
  CFDictionaryAddValue(dictionary, @"enabled", CFBridgingRetain([NSNumber numberWithBool:enabled]));
  CFDictionaryAddValue(dictionary, @"predictive", CFBridgingRetain([NSNumber numberWithBool:predictive]));
  CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("com.cpdigitaldarkroom.barmoji.settings"), nil, dictionary, true);
  CFRelease(dictionary);
}

- (void)respring {
  pid_t pid;
  int status;
  const char* args[] = {"killall", "-9", "backboardd", NULL};
  posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
  waitpid(pid, &status, WEXITED);
}

@end
