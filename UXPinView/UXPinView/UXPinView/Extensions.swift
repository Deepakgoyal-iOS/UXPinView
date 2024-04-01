//
//  Extensions.swift
//  UXPinView
//
//  Created by Deepak Goyal on 01/04/24.
//

import Foundation

extension String{
    
    var isDigit: Bool {
        get{
            guard isEmpty == false else { return false }
            guard let _ = Double(self) else { return false }
            return true
        }
    }
}
extension Array {
    
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        
        return self[index]
    }
}
