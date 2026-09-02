## 0.3.0

Improvements:

  - Rewritten in Swift. No Objective-C remains; the package builds as pure Swift
  - The data source and delegate contract is unchanged: a data source supplies
    the components and their columns, a delegate supplies the content and is
    told about selection
  - Rows can be supplied after init — reloadData() rebuilds all of its derived
    state, so a data source whose rows arrive later works the same way
  - Component frames follow the picker being laid out or resized
  - Unit tests covering the contract, selection, reloading, layout, the hidden
    column states and the scroll snapping

Other:

  - Deployment target raised from iOS 9 to iOS 13
  - Removed the stale LAUPickerView.xcodeproj, which referenced source paths
    that no longer exist; the Swift package is the build

## 0.2.0

Features:

  - Support for 'pickerView:viewForColumn:forComponent:reusingView:' delegate method.
	
Improvements:

  - Bug fixes
  - Updated examples

## 0.1.0

Features:

  - Left, Center or Right selection alignment (selection indicator position, layout)
  - Drag left or right
  - iOS click-input sound

Examples:

  - Overview example (LAUPickerView linked to UIPickerView and vice-versa)
 
Other:
  
  - Support for CocoaPods added
