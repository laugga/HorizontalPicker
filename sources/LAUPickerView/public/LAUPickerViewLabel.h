//
//  LAUPickerViewLabel.h
//  m-ios
//
//  Created by Luis Laugga on 15.09.15.
//  Copyright (c) 2015 Centralway Switzerland AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAUPickerViewLabel : UILabel

@property (nonatomic, copy) UIFont * highlightedFont;

- (void)setHighlightedFont:(UIFont *)highlightedFont;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@end
