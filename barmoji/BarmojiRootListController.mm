//
//  BarmojiPreferencesListController.mm
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 01/16/2018
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#import "BarmojiPreferences.h"

@interface BarmojiRootListController : PSListController <MFMailComposeViewControllerDelegate>
@end

@implementation BarmojiRootListController

-(id)specifiers {
  if(_specifiers == nil) {

    NSMutableArray *mutableSpecifiers = [NSMutableArray new];
    PSSpecifier *specifier;

    specifier = groupSpecifier(@"Haptic Feedback");
    [mutableSpecifiers addObject:specifier];

    specifier = subtitleSwitchCellWithName(@"Enabled");
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji.settings" forKey:@"PostNotification"];
    setKeyForSpec(@"BarmojiEnabled");
    [mutableSpecifiers addObject:specifier];

    specifier = [PSSpecifier preferenceSpecifierNamed:@"Feedback Type" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"BarmojiListItemsController") cell:PSLinkListCell edit:nil];
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji" forKey:@"defaults"];
    [specifier setProperty:@"com.cpdigitaldarkroom.barmoji.settings" forKey:@"PostNotification"];
    setKeyForSpec(@"BarmojiFeedbackType");
    [specifier setValues:[self activationTypeValues] titles:[self activationTypeTitles] shortTitles:[self activationTypeShortTitles]];
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
    @1, @2, @3, @4, @5, @6
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

@end
