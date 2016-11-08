# LAUPickerView

## Introduction

LAUPickerView is an horizontal *spinning-wheel* picker control view for iOS. 

It is similar to UIPickerView, but the user interface provided consists of columns instead of rows. It also follows the same semantics used for the *data source* and *delegate* methods. Please read the __Overview__ section for more details about usage.

## Requirements

* iOS 5.1 or later
* Suported devices: iPhone/iPad (*)

## How to use LAUPickerView in your project

### CocoaPods

1. Create or edit an existing text file named Podfile in your Xcode project directory:

```ruby
platform :ios, '5.1'

pod "LAUPickerView", '~> 0.2.0'
```

2. Install LAUPickerView in your project:

```bash
$ pod install
```

3. Open the Xcode workspace instead of the project file when building your project:

```bash
$ open YourProject.xcworkspace
```

4. Use LAUPickerView in your project:

```obj-c
#import <LAUPickerView/LAUPickerView.h>
```

### Framework

1. Import the LAUPickerView.framework to your project
2. Add '-ObjC' to *Other Linker Flag* in *Build Settings* target section (in order to load Objective-C class categories) 
3. Add LAUPickerView.framework to *Link Binary with Libraries* in *Build Phases* target section

You also need to add the following frameworks to your project:

* QuartzCore.framework
* CoreGraphics.framework
* AudioToolbox.framework

## Overview Tutorial

1. Add the LAUPickerView to an existing UIView (ie. inside UIViewController's *viewDidLoad* method).

```obj-c
LAUPickerView * pickerView = [[LAUPickerView alloc] initWithFrame:self.view.frame];
pickerView.dataSource = self; // LAUPickerViewDataSource protocol
pickerView.delegate = self;   // LAUPickerViewDelegate protocol
[self.view addSubview:pickerView];
```

2. Implement the __LAUPickerViewDataSource__ protocol:

```obj-c
- (NSInteger)numberOfComponentsInPickerView:(LAUPickerView *)pickerView
{
    // return the number of components needed
}

- (NSInteger)pickerView:(LAUPickerView *)pickerView numberOfColumnsInComponent:(NSInteger)component
{
    // return the number of columns for each component
}
```

3. Implement the __LAUPickerViewDelegate__ protocol:

```obj-c
- (NSString *)pickerView:(LAUPickerView *)pickerView titleForColumn:(NSInteger)column forComponent:(NSInteger)component
{
    // return the title for the specific column-component pair
}

- (void)pickerView:(LAUPickerView *)pickerView didSelectColumn:(NSInteger)column inComponent:(NSInteger)component
{
    // called when a new, different column is selected following a user touch-based input
}
```

4. Additionally you can change the selected column position to __left__, __center__ or __right__. 

![Selection Alignment Options](https://raw.github.com/laugga/LAUPickerview/master/docs/figures/selection_alignment_options.png "Selection alignment options of LAUPickerView: left, center, right")

```obj-c
pickerView.selectionAlignment = LAUPickerSelectionAlignmentLeft; // Change selected column position to left
```

# Examples

## LAUPickerViewOverview

The *LAUPickerViewOverview* is a single-view example showing the LAUPickerView and UIPickerView side-by-side. The selection is linked, so changing the selected column in the LAUPickerView will trigger the UIPickerView to change to the corresponding row.

![LAUPickerView Overview Example Screenshot](https://raw.github.com/laugga/LAUPickerview/master/docs/figures/overview_example_screenshot.png "LAUPickerView Overview Example Screenshot")

## Roadmap

* Improve layout and autoresize constraints
* Fix click sound loudness
* Fix click sound while scrolling
* Improve selected to unselected state animation
* Implement 3D transform similar to UIPickerView
