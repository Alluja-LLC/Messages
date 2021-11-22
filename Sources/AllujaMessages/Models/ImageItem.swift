//
//  File.swift
//  
//
//  Created by Jack Hogan on 11/19/21.
//

import Foundation
import SwiftUI

public protocol ImageItem {
    /// Image data, takes precedent over URL
    var imageData: Data? { get }

    /// The URL of the resource
    var imageURL: URL? { get }

    /// A placeholder while the image is loading
    func placeholder(forPhase phase: AsyncImagePhase) -> AnyView?
}
