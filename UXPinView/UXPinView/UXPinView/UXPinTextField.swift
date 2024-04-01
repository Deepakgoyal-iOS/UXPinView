//
//  UXPinTextField.swift
//  UXPinView
//
//  Created by Deepak Goyal on 01/04/24.
//

import UIKit

protocol UXPinTextFieldDelegate: UITextFieldDelegate{
    func didDeleteBackward(_ textField: UXPinTextField)
    func didChangeText(_ textField: UITextField)
    func didBeginFirstResponder(_ textField: UITextField)
}

class UXPinTextField: UITextField{
    
    enum PPViewDisplayType{
        case Error
        case Default
        case Active
        case None
        case warning
        
        var color: UIColor{
            
            switch self {
            case .Error:
                return UIColor(red: 240/255, green:  0/255, blue: 0/255, alpha: 1)
            case .Default:
                return UIColor(red: 229/255, green:  229/255, blue: 229/255, alpha: 1)
            case .Active:
                return UIColor(red: 0/255, green:  71/255, blue: 212/255, alpha: 1)
            case .None:
                return .clear
            case .warning:
                return UIColor(red: 179/255, green:  134/255, blue: 17/255, alpha: 1)
            }
        }
    }
    
    override var text: String?{
        didSet{
            customDelegate?.didChangeText(self)
        }
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        customDelegate?.didDeleteBackward(self)
    }
    
    weak var customDelegate: UXPinTextFieldDelegate?{
        didSet{
            self.delegate = customDelegate
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(paste(_:))
    }
    
    override func becomeFirstResponder() -> Bool {
        self.setBorderType(.Active)
        self.customDelegate?.didBeginFirstResponder(self)
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        self.setBorderType(.Default)
        return super.resignFirstResponder()
    }
    
    func setBorderType(withBorderWidth width:CGFloat = 1,_ type: PPViewDisplayType){
        
        layer.borderWidth = width
        layer.borderColor = type.color.cgColor
     }
}
