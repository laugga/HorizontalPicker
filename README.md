# LAPickerView

## Introduction

LAPickerView is an horizontal *spinning-wheel* picker control view for iOS. 

It is similar to UIPickerView, but the user interface provided consists of columns instead of rows. It also follows the same semantics used for the *data source* and *delegate* methods. Please read the __Overview__ section for more details about usage.

## Requirements

* iOS 9.0 or later
* Suported devices: iPhone/iPad (*)

## How to use LAPickerView in your project

### Swift Package Manager

TODO 

1. Use LAPickerView in your project:

```swift
import LAPickerView
```

## Overview Tutorial

1. Add the LAPickerView to an existing UIView (ie. inside UIViewController's *viewDidLoad* method).

```obj-c
LAPickerView * pickerView = [[LAPickerView alloc] initWithFrame:self.view.frame];
pickerView.dataSource = self; // LAPickerViewDataSource protocol
pickerView.delegate = self;   // LAPickerViewDelegate protocol
[self.view addSubview:pickerView];
```

2. Implement the __LAPickerViewDataSource__ protocol:

```obj-c
- (NSInteger)numberOfComponentsInPickerView:(LAPickerView *)pickerView
{
    // return the number of components needed
}

- (NSInteger)pickerView:(LAPickerView *)pickerView numberOfColumnsInComponent:(NSInteger)component
{
    // return the number of columns for each component
}
```

3. Implement the __LAPickerViewDelegate__ protocol:

```obj-c
- (NSString *)pickerView:(LAPickerView *)pickerView titleForColumn:(NSInteger)column forComponent:(NSInteger)component
{
    // return the title for the specific column-component pair
}

- (void)pickerView:(LAPickerView *)pickerView didSelectColumn:(NSInteger)column inComponent:(NSInteger)component
{
    // called when a new, different column is selected following a user touch-based input
}
```

4. Additionally you can change the selected column position to __left__, __center__ or __right__. 

![Selection Alignment Options](https://raw.github.com/laugga/lapickerview/master/docs/figures/selection_alignment_options.png "Selection alignment options of LAPickerView: left, center, right")

```obj-c
pickerView.selectionAlignment = LAPickerSelectionAlignmentLeft; // Change selected column position to left
```

# Examples

## LAPickerViewOverview

The *LAPickerViewOverview* is a single-view example showing the LAPickerView and UIPickerView side-by-side. The selection is linked, so changing the selected column in the LAPickerView will trigger the UIPickerView to change to the corresponding row.

![LAPickerView Overview Example Screenshot](https://raw.github.com/laugga/lapickerview/master/docs/figures/overview_example_screenshot.png "LAPickerView Overview Example Screenshot")

## Roadmap

* Improve layout and autoresize constraints
* Fix click sound loudness
* Fix click sound while scrolling
* Improve selected to unselected state animation
* Implement 3D transform similar to UIPickerView
