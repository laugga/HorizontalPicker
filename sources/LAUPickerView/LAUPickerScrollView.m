//
//  LAUPickerScrollView.m
//  Pods
//
//  Created by Luis Laugga on 12/5/15.
//
//

#import "LAUPickerScrollView.h"

@implementation LAUPickerScrollView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([touches count] > 1) {
        return; // ignore
    }
    
    if ([self.delegate respondsToSelector:@selector(scrollViewTouchesDidBegin:withTouch:)]) {
        [self.delegate performSelector:@selector(scrollViewTouchesDidBegin:withTouch:) withObject:self withObject:[touches anyObject]];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([touches count] > 1) {
        return; // ignore
    }
    
    if ([self.delegate respondsToSelector:@selector(scrollViewTouchesDidEnd:withTouch:)]) {
        [self.delegate performSelector:@selector(scrollViewTouchesDidEnd:withTouch:) withObject:self withObject:[touches anyObject]];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([touches count] > 1) {
        return; // ignore
    }
    
    if ([self.delegate respondsToSelector:@selector(scrollViewTouchesDidEnd:withTouch:)]) {
        [self.delegate performSelector:@selector(scrollViewTouchesDidEnd:withTouch:) withObject:self withObject:[touches anyObject]];
    }
}

@end
