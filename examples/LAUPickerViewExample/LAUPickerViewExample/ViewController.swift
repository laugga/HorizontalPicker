//
//  ViewController.swift
//  LAUPickerViewExample
//
//  Created by Ferreira Luis (Cembra Money Bank) on 11.08.22.
//

import UIKit
import HorizontalPicker

enum PickerComponents: CaseIterable {
    case aperture, shutterSpeed, isoSpeed
    
    var values: [Float] {
        switch self {
        case .aperture:
            return [ 1.0, 1.1, 1.2, 1.4, 1.6, 1.8, 2, 2.2, 2.5, 2.8, 3.2, 3.5, 4, 4.5,4.7, 5.0, 5.6, 6.3, 7.1, 8, 9, 10, 11, 13, 14, 16, 18, 20, 22 ]
        case .shutterSpeed:
            return [ 1, 1.3, 1.6, 2, 2.5, 3, 4, 5, 6, 8, 10, 13, 15, 20, 25, 30, 40, 50, 60, 80, 100, 125, 160, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600, 2000, 2500, 3200, 4000 ]
        case .isoSpeed:
            return [ 50, 64, 80, 100, 125, 160, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600, 2000, 2500 ]
        }
    }
}

class ViewController: UIViewController, LAUPickerViewDelegate, LAUPickerViewDataSource {
    
    // Picker View
    @IBOutlet var horizontalPickerView: LAUPickerView?
    @IBOutlet var verticalPickerView: LAUPickerView?
    
    private var highlightedComponent: Int = 0 {
        didSet {
            guard highlightedComponent != oldValue else {
                return
            }
            
            horizontalPickerView?.setSelectedColumnHighlighted(false, inComponent: oldValue, animated: true)
            verticalPickerView?.setSelectedColumnHighlighted(false, inComponent: oldValue, animated: true)
            horizontalPickerView?.setSelectedColumnHighlighted(true, inComponent: highlightedComponent, animated: true)
            verticalPickerView?.setSelectedColumnHighlighted(true, inComponent: highlightedComponent, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        horizontalPickerView?.dataSource = self
        horizontalPickerView?.delegate = self
        
        verticalPickerView?.dataSource = self
        verticalPickerView?.delegate = self
        
        horizontalPickerView?.setSelectedColumnHighlighted(true, inComponent: highlightedComponent, animated: false)
        verticalPickerView?.setSelectedColumnHighlighted(true, inComponent: highlightedComponent, animated: false)
        
        horizontalPickerView?.hidesUnselectedColumns = false
    }
    
    // MARK: - LAUPickerViewDataSource
    
    func numberOfComponents(in pickerView: LAUPickerView!) -> Int {
        return PickerComponents.allCases.count
    }
    
    func pickerView(_ pickerView: LAUPickerView!, numberOfColumnsInComponent component: Int) -> Int {
        switch component {
        case 0: // aperture
            return PickerComponents.aperture.values.count
        case 1: // shutter speed
            return PickerComponents.shutterSpeed.values.count
        case 2: // iso speed
            return PickerComponents.isoSpeed.values.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: LAUPickerView!, numberOfRowsInCompoment component: Int) -> Int {
        switch component {
        case 0: // aperture
            return PickerComponents.aperture.values.count
        case 1: // shutter speed
            return PickerComponents.shutterSpeed.values.count
        case 2: // iso speed
            return PickerComponents.isoSpeed.values.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: LAUPickerView!, heightForComponent component: Int) -> CGFloat {
        return 50.0
    }

    func pickerView(_ pickerView: LAUPickerView!, titleForColumn column: Int, forComponent component: Int) -> String! {
        switch component {
        case 0: // aperture
            return String(format: "%.1f", PickerComponents.aperture.values[column])
        case 1: // shutter speed
            return String(format: "%.1f", PickerComponents.shutterSpeed.values[column])
        case 2: // iso speed
            return String(format: "%.1f", PickerComponents.isoSpeed.values[column])
        default:
            return ""
        }
    }

    // MARK: - LAUPickerViewDelegate
    
    func pickerView(_ pickerView: LAUPickerView!, didChangeColumn column: Int, inComponent component: Int) {
        
        if pickerView == horizontalPickerView {
            verticalPickerView?.selectColumn(column, inComponent: component, animated: true)
        } else if pickerView == verticalPickerView {
            horizontalPickerView?.selectColumn(column, inComponent: component, animated: true)
        }
        
        highlightedComponent = component
    }
    
    func pickerView(_ pickerView: LAUPickerView!, didTouchUpColumn column: Int, inComponent component: Int) {
        highlightedComponent = component
    }
    
    func pickerView(_ pickerView: LAUPickerView!, didTouchUp touch: UITouch!, inComponent component: Int) {
        highlightedComponent = component
    }
}

