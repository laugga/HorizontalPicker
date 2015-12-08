//
//  LAPickerScrollView.h
//  Pods
//
//  Created by Luis Laugga on 12/5/15.
//
//

#import <UIKit/UIKit.h>

@interface LAPickerScrollView : UIScrollView

@end

@protocol LAPickerScrollViewDelegate <NSObject>

@optional

- (void)scrollViewTouchesDidBegin:(UIScrollView *)scrollView;
- (void)scrollViewTouchesDidEnd:(UIScrollView *)scrollView;

@end