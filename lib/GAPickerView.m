/*
 
 GAPickerView.h
 GAPickerView
 
 Copyright (cc) 2012 Luis Laugga.
 Some rights reserved, all wrongs deserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
*/

#import "GAPickerView.h"

@implementation GAPickerView

@synthesize dataSource=_dataSource;
@synthesize delegate=_delegate;

@dynamic enableInputClicksWhenVisible;

#pragma mark -
#pragma mark Initialization

- (id)initWithFrame:(struct CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
    }
    return self;
}

#pragma mark -
#pragma mark UIView

- (void)layoutSubviews
{
    PrettyLog;
    
    CGPoint offset = CGPointZero;
    
    NSInteger numberOfComponents = 0;
    NSInteger numberOfColumns[10];
    
    if(_dataSource)
    {
        numberOfComponents = [_dataSource numberOfComponentsInPickerView:self];
        for(int component=0; component<numberOfComponents; ++component)
            numberOfColumns[component] = [_dataSource pickerView:self numberOfColumnsInComponent:component];
    
        if(_delegate)
        {
            CGRect columnRect = CGRectMake(0, 0, 50.0, self.frame.size.height/numberOfComponents);
            
            for(int component=0; component<numberOfComponents; ++component)
            {
                for(int column=0; column<numberOfColumns[component]; ++column)
                {
                    NSString * title = [_delegate pickerView:self titleForColumn:column forComponent:component];
                    
                    UILabel * label = [[UILabel alloc] init];
                    label.textColor = [UIColor whiteColor];
                    label.text = title;
                    label.textAlignment = UITextAlignmentCenter;
                    label.frame = CGRectMake(offset.x, offset.y, columnRect.size.width, columnRect.size.height);
                    [self addSubview:label];
                    
                    offset.x += columnRect.size.width;
                }
                
                offset.x = 0.0f;
                offset.y += columnRect.size.height;
            }
        }
    }
}

#pragma mark -
#pragma mark UIInputViewAudioFeedback

- (BOOL) enableInputClicksWhenVisible
{
    // call [[UIDevice currentDevice] playInputClick];

    return YES;
}

@end