//
//  LAUPickerViewLabel.m
//  m-ios
//
//  Created by Luis Laugga on 15.09.15.
//  Copyright (c) 2015 Centralway Switzerland AG. All rights reserved.
//

#import "LAUPickerViewLabel.h"

@interface LAUPickerViewLabel ()

@property (nonatomic, assign) CGAffineTransform toHighlightedTransform;
@property (nonatomic, assign) CGAffineTransform fromHighlightedTransform;
@property (nonatomic, copy) UIFont * defaultFont;

@end

@implementation LAUPickerViewLabel

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    frame.size = size;
    self.frame = frame;
}

- (void)setHighlightedFont:(UIFont *)highlightedFont
{
    _highlightedFont = [highlightedFont copy];
    _defaultFont = [self.font copy];
    
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    CGSize highlightSize = [self.text sizeWithAttributes:@{NSFontAttributeName:highlightedFont}];
    
    CGFloat highlightTransitionScale = highlightSize.width / size.width;
    CGFloat highlightTranisitionTranslation = floorf((highlightSize.width - size.width) / 2.0f);
    
    self.toHighlightedTransform = CGAffineTransformTranslate(CGAffineTransformMakeScale(highlightTransitionScale, highlightTransitionScale), highlightTranisitionTranslation, 0);
    self.fromHighlightedTransform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1.0f/highlightTransitionScale, 1.0f/highlightTransitionScale), -highlightTranisitionTranslation, 0);
}

- (void)setHighlighted:(BOOL)highlighted
{
    [self setHighlighted:highlighted animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted];
    
    [UIView animateWithDuration:0.15 animations:^{
        
        if (highlighted)
        {
            self.transform = self.toHighlightedTransform;
        }
        else
        {
            self.transform = self.fromHighlightedTransform;
        }
            
    } completion:^(BOOL finished) {
    
        if (highlighted)
        {
            self.font = self.highlightedFont;
            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }
        else
        {
            self.font = self.defaultFont;
            self.transform = CGAffineTransformIdentity;
        }
        
    }];
}

@end
