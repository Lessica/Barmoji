//
//  BarmojiEditableTextCell.m
//  barmoji
//  
//  Created by Juan Carlos Perez <carlos@jcarlosperez.me> 05/07/2019
//  © CP Digital Darkroom <admin@cpdigitaldarkroom.com> All rights reserved.
//

#import "BarmojiEditableTextCell.h"
#import "BarmojiPreferences.h"

@implementation BarmojiEditableTextCell
- (id)initWithStyle:(UITableViewCellStyle)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
	self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
    /*
	if (self) {
        [self textField].returnKeyType = UIReturnKeyDone;
    }
     */
	return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (string.length > 0) {
		return [self isEmoji:string];
	}

	return YES;
}

- (BOOL)isEmoji:(NSString *)character {
    UILabel *characterRender = [[UILabel alloc] initWithFrame:CGRectZero];
    characterRender.text = character;
    characterRender.backgroundColor = [UIColor blackColor];//needed to remove subpixel rendering colors
    [characterRender sizeToFit];

    CGRect rect = [characterRender bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0f);
    CGContextRef contextSnap = UIGraphicsGetCurrentContext();
    [characterRender.layer renderInContext:contextSnap];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGImageRef imageRef = [capturedImage CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel *width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    BOOL colorPixelFound = NO;

    int x = 0;
    int y = 0;
    while (y < height && !colorPixelFound) {
        while (x < width && !colorPixelFound) {

            NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;

            CGFloat red = (CGFloat)rawData[byteIndex];
            CGFloat green = (CGFloat)rawData[byteIndex+1];
            CGFloat blue = (CGFloat)rawData[byteIndex+2];

            CGFloat h, s, b, a;
            UIColor *c = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
            [c getHue:&h saturation:&s brightness:&b alpha:&a];

            b /= 255.0f;

            if (b > 0) {
                colorPixelFound = YES;
            }

            x++;
        }
        x=0;
        y++;
    }

    return colorPixelFound;
}

@end
