//
//  LAPickerScrollView.m
//  Pods
//
//  Created by Luis Laugga on 12/5/15.
//
//

#import "LAPickerScrollView.h"

@implementation LAPickerScrollView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(scrollViewTouchesDidBegin:)]) {
        [self.delegate performSelector:@selector(scrollViewTouchesDidBegin:) withObject:self];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(scrollViewTouchesDidEnd:)]) {
        [self.delegate performSelector:@selector(scrollViewTouchesDidEnd:) withObject:self];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(scrollViewTouchesDidEnd:)]) {
        [self.delegate performSelector:@selector(scrollViewTouchesDidEnd:) withObject:self];
    }
}

@end
