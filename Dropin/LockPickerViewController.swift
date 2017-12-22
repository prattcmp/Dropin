//
//  LockPickerViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 12/21/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit

enum LockPickerDateType: String {
    case unlocked = "not locked"
    case minutes = "mins"
    case hours = "hrs"
    case days = "days"
}

protocol LockPickerViewControllerDelegate: class {
    func hideLockPicker(sender: LockPickerViewController, lockDuration: Int)
}

class LockPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var delegate: LockPickerViewControllerDelegate?
    
    let maxMins: Int! = 59
    let maxHrs: Int! = 23
    let maxDays: Int! = 7
    
    let dateTypes: [LockPickerDateType] = [.unlocked, .minutes, .hours, .days]
    let timeComponent: Int! = 0
    let dateTypeComponent: Int! = 1
    var maxTime: Int! = 0
    
    var lockPickerView: LockPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lockPickerView = LockPickerView()
        lockPickerView.pickerView.delegate = self
        lockPickerView.pickerView.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(goBack))
        lockPickerView.addGestureRecognizer(tap)
        lockPickerView.isUserInteractionEnabled = true

        self.view.addSubview(lockPickerView)
        
        lockPickerView.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }

    @objc func goBack() {
        let timeValue = lockPickerView.pickerView.selectedRow(inComponent: timeComponent) + 1 // indexes start at 0
        let dateType = dateTypes[lockPickerView.pickerView.selectedRow(inComponent: dateTypeComponent)]
        var lockDuration = 0
        
        if dateType == .minutes {
            lockDuration = timeValue * 60
        } else if dateType == .hours {
            lockDuration = timeValue * 60 * 60
        } else if dateType == .days {
            lockDuration = timeValue * 24 * 60 * 60
        }
        
        delegate?.hideLockPicker(sender: self, lockDuration: lockDuration)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // 1 component for numbers + 1 component for mins/hrs/days
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == timeComponent {
            return maxTime
        }
        if component == dateTypeComponent {
            return dateTypes.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == dateTypeComponent {
            switch row {
                case 0:
                    maxTime = 0
                case 1:
                    maxTime = maxMins // mins
                case 2:
                    maxTime = maxHrs // hrs
                case 3:
                    maxTime = maxDays // days
                default:
                    maxTime = maxMins // unknown
            }
            
            lockPickerView.pickerView.reloadAllComponents()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var string = String()
        
        if component == timeComponent {
            string = String((row + 1)) // rows start at 0
        }
        if component == dateTypeComponent {
            string = dateTypes[row].rawValue
        }
        
        return NSAttributedString(string: string, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
    }
}
