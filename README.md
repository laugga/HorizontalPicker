# HorizontalPicker

## Introduction

LAUPickerView is an horizontal *spinning-wheel* picker control view for iOS.

It is similar to UIPickerView, but the user interface provided consists of columns instead of rows. It also follows the same semantics used for the *data source* and *delegate* methods. Please read the __Overview__ section for more details about usage.

## Requirements

* iOS 13.0 or later
* Suported devices: iPhone/iPad (*)

## How to use LAUPickerView in your project

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/laugga/HorizontalPicker.git", from: "0.3.0")
]
```

Or in Xcode, *File > Add Package Dependencies…* and enter the repository URL.

Then import it:

```swift
import HorizontalPicker
```

## Overview Tutorial

1. Add the LAUPickerView to an existing UIView (ie. inside UIViewController's *viewDidLoad* method).

```swift
let pickerView = LAUPickerView(frame: view.frame)
pickerView.dataSource = self // LAUPickerViewDataSource protocol
pickerView.delegate = self   // LAUPickerViewDelegate protocol
view.addSubview(pickerView)
```

2. Implement the __LAUPickerViewDataSource__ protocol:

```swift
func numberOfComponents(in pickerView: LAUPickerView) -> Int {
    // return the number of components needed
}

func pickerView(_ pickerView: LAUPickerView, numberOfColumnsInComponent component: Int) -> Int {
    // return the number of columns for each component
}
```

3. Implement the __LAUPickerViewDelegate__ protocol:

```swift
func pickerView(_ pickerView: LAUPickerView, titleForColumn column: Int, forComponent component: Int) -> String? {
    // return the title for the specific column-component pair
}

func pickerView(_ pickerView: LAUPickerView, didChangeColumn column: Int, inComponent component: Int) {
    // called when a new, different column is selected following a user touch-based input
}
```

Every method of the delegate has a default implementation, so only write the ones you need. Return a view from `pickerView(_:viewForColumn:forComponent:reusingView:)` instead of a title to supply your own column views.

The data source and the delegate are plain Swift protocols — the adopting type does not have to be an `NSObject` subclass.

4. The rows do not have to be known when the picker is created. Call `reloadData()` once the data source has them, and the picker rebuilds itself:

```swift
pickerView.reloadData()
```

5. Additionally you can change the selected column position to __left__, __center__ or __right__.

![Selection Alignment Options](https://raw.github.com/laugga/LAUPickerView/master/docs/figures/selection_alignment_options.png "Selection alignment options of LAUPickerView: left, center, right")

```swift
pickerView.selectionAlignment = .left // Change selected column position to left
```

# Examples

## LAUPickerViewExample

The *LAUPickerViewExample* is a single-view example showing the same three components twice: a LAUPickerView at the top and the native UIPickerView at the bottom. The selection is linked in both directions, so spinning a column of the horizontal picker moves the matching row of the native one, and spinning a row of the native one moves the column back — the port side by side with the control it is modelled on.

![LAUPickerView Overview Example Screenshot](https://raw.github.com/laugga/LAUPickerView/master/docs/figures/overview_example_screenshot.png "LAUPickerView Overview Example Screenshot")

## Building and testing

The package is pure Swift and iOS only, so it is built against a simulator rather than with `swift build`:

```sh
xcodebuild -scheme HorizontalPicker -destination 'generic/platform=iOS Simulator' build
xcodebuild test -scheme HorizontalPicker -destination 'platform=iOS Simulator,name=iPhone 17'
```

The example app lives in `examples/LAUPickerViewExample` and consumes the package from the repository root.

## Roadmap

* Improve layout and autoresize constraints
* Fix click sound loudness
* Fix click sound while scrolling
* Improve selected to unselected state animation
* Implement 3D transform similar to UIPickerView
