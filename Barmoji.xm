//
//  Barmoji.xm
//  Barmoji
//
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 01/16/2018
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#import "Barmoji.h"
#import "BarmojiCollectionView.h"

%hook UISystemKeyboardDockController

- (void)viewDidDisappear:(BOOL)animated {
	%orig;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	%orig;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(barmojiRotationUpdate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	%orig;
	self.dockView.barmoji.alpha = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? 0 : 1;
}

%new
- (void)barmojiRotationUpdate:(NSNotification *)notification {
	self.dockView.barmoji.alpha = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? 0 : 1;
}

%end

%hook UIKeyboardDockView
%property (retain, nonatomic) BarmojiCollectionView *barmoji;

- (instancetype)initWithFrame:(CGRect)frame {

	UIKeyboardDockView *dockView = %orig;
	if(dockView) {

		self.barmoji = [[BarmojiCollectionView alloc] init];
		self.barmoji.translatesAutoresizingMaskIntoConstraints = NO;
		[dockView addSubview:self.barmoji];

		[dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:60]];
		[dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-50]];
		[dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40]];
		[dockView addConstraint:[NSLayoutConstraint constraintWithItem:self.barmoji attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-22]];
	}
	return dockView;
}

%end

%ctor {
}
