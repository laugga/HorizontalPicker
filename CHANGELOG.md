## 0.4.0

Removed:

  - setSelectedColumnHighlighted(_:inComponent:animated:). It has no counterpart
    in UIPickerView, and the highlight it set was left behind: the bolder font
    stayed on the column once the selection moved on, and the recycled cell
    carried it to columns that were never highlighted
  - The highlight machinery behind it — the cell's bold title font and
    setColumnHighlighted(_:animated:), the table view's isSelectedColumnHighlighted,
    and LAUPickerViewLabel's highlightedFont, scale transforms and animation.
    LAUPickerViewLabel remains as the label the picker draws a title in

## 0.3.0

Improvements:

  - Rewritten in Swift. No Objective-C remains; the package builds as pure Swift
  - No @objc anywhere in the interface either: the data source and delegate are
    plain Swift protocols, so an adopting type no longer has to be an NSObject
    subclass, and the optional delegate methods are default implementations
    rather than @objc optional requirements
  - The data source and delegate contract is unchanged: a data source supplies
    the components and their columns, a delegate supplies the content and is
    told about selection
  - Rows can be supplied after init — reloadData() rebuilds all of its derived
    state, so a data source whose rows arrive later works the same way
  - Component frames follow the picker being laid out or resized
  - Each component is a UICollectionView laid out by LAUPickerColumnLayout,
    which owns the column widths, the insets that place the selection
    indicator, the offset each column rests at and the snap at the end of a
    drag. The hand-rolled offsets, content size and scroll view subclass are
    gone, and columns are recycled rather than all built up front
  - The selected column is centred exactly under the selection indicator; the
    previous arithmetic left it 8.25pt to the left of centre
  - Unit tests covering the contract, selection, reloading, layout, the hidden
    column states, the selection geometry, column recycling and the scroll
    snapping
  - The example shows the picker above the native UIPickerView over the same
    values, with the selection linked in both directions

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
