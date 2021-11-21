//
//  File.swift
//  
//
//  Created by Jack Hogan on 11/20/21.
//

import Foundation

public protocol CustomItem {
    /// An ID for the custom item type, will be used to split up custom rederers into sepearate declarations
    var id: String { get }
    
    /// Some data for the custom type
    var data: Any? { get }
}
