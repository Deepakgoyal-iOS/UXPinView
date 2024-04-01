//
//  UXPinView.swift
//  Powerplay
//
//  Created by Deepak Goyal on 14/04/23.
//

import UIKit

protocol UXPinViewDelegate: AnyObject{
    func didUpdatePin(withUpdatedText text: String?, isValidPin: Bool)
}

class UXPinView: UIView{
    
    @IBOutlet weak var pinStack: UIStackView!
    private var digitCount = 5
    weak var delegate: UXPinViewDelegate?
    private var pinText: String{
        get{
            return pinStack.arrangedSubviews.reduce("", { $0 + (($1 as? UITextField)?.text ?? "")})
        }
    }
    
    init(withDigitCount count: Int){
        super.init(frame: .zero)
        digitCount = count
        fromNib()
        setUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fromNib()
        setUI()
    }
    
    @discardableResult
    func fromNib() -> UIView?{
        
        let nibName = String(describing: Self.self)
        guard let contentView = Bundle.main.loadNibNamed(nibName, owner: self)?.first as? UIView else { return nil }
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(contentView)
        return contentView
    }
    
    func setDigitCount(_ count: Int){
        digitCount = count
        guard pinStack != nil else { return }
        setUI()
    }
    
    private func setUI(){
        
        clearArrangedSubviewStack()
        let range = 1...digitCount
        range.forEach{ index in addPinTextField(withTag: index) }
    }
    
    private func clearArrangedSubviewStack(){
        self.pinStack.arrangedSubviews.forEach{
            self.pinStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    private func addPinTextField(withTag tag: Int){
        let field = UXPinTextField()
        field.layer.cornerRadius = 4
        field.layer.masksToBounds = true
        field.font = .systemFont(ofSize: 16, weight: .semibold)
        field.textColor = .black
        field.customDelegate = self
        field.tag = tag
        field.clearsOnBeginEditing = true
        field.keyboardType = .decimalPad
        field.textAlignment = .center
        field.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
        field.setBorderType(.Default)
        pinStack.addArrangedSubview(field)
        field.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func clearOTP(){
        pinStack.arrangedSubviews.forEach({  ($0 as? UITextField)?.text = "" })
        self.pinStack.arrangedSubviews.first?.becomeFirstResponder()
        self.pinStack.arrangedSubviews.first?.resignFirstResponder()
    }
}
extension UXPinView: UXPinTextFieldDelegate{
    
    func didBeginFirstResponder(_ textField: UITextField) {
        
        let updatedPin = pinText
        if updatedPin.count == digitCount{
            delegate?.didUpdatePin(withUpdatedText: updatedPin, isValidPin: updatedPin.isDigit && updatedPin.count == digitCount)
        }
    }
    
    func didDeleteBackward(_ textField: UXPinTextField) {
        textField.text = ""
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if !string.isEmpty, !string.isDigit{
            return false
        }
        
        let newString = getResultedText(fromTextField: textField, range: range, replacementText: string)
        if newString.count > 1{
            setText(newString.trimmingCharacters(in: .whitespacesAndNewlines), fromTag: textField.tag)
        }
        
        return newString.count <= 1
    }
    
    private func getResultedText(fromTextField textField: UITextField, range: NSRange, replacementText: String) -> String{
        
        guard let _text = textField.text else { return replacementText }
        
        if let textRange = Range(range, in: _text){
            return _text.replacingCharacters(in: textRange, with: replacementText)
        }
        return replacementText
    }

    private func setText(_ text: String, fromTag tag: Int){
        
        let chars = Array(text.prefix(digitCount))
        
        var tfPins = [Int: UITextField?]()
        pinStack.arrangedSubviews.forEach({ tfPins[$0.tag] = $0 as? UITextField })
        let range = tag...min(digitCount, (tag + text.count - 1))
        range.forEach { index in
            tfPins[index]??.text = String(chars[safeIndex: index-tag] ?? " ").trimmingCharacters(in: .whitespacesAndNewlines)
        }

    }
    
    //Triggers on every text change
    @objc func didChangeText(_ textField: UITextField){
                
        let tag = (textField.text?.isEmpty ?? true) ? textField.tag - 1 : textField.tag + 1
        let _ = tag > digitCount ? textField.resignFirstResponder() : becomeFirstResponder(forTag: tag)
        
        let updatedPin = pinText
        delegate?.didUpdatePin(withUpdatedText: updatedPin, isValidPin: updatedPin.isDigit && updatedPin.count == digitCount)
    }
    
    @discardableResult
    private func becomeFirstResponder(forTag tag: Int) -> Bool?{
        pinStack.arrangedSubviews.filter({ $0.tag == tag }).first?.becomeFirstResponder()
    }
}
