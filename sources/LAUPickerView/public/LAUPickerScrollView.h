//
//  LAUPickerScrollView.h
//  Pods
//
//  Created by Luis Laugga on 12/5/15.
//
//

#import <UIKit/UIKit.h>

@interface LAUPickerScrollView : UIScrollView

@end

@protocol LAUPickerScrollViewDelegate <NSObject>

@optional

- (void)scrollViewTouchesDidBegin:(UIScrollView *)scrollView  withTouch:(UITouch *)touch;
- (void)scrollViewTouchesDidEnd:(UIScrollView *)scrollView withTouch:(UITouch *)touch;

@end
