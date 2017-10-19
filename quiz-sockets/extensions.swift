//
//  extensions.swift
//  quiz-sockets
//
//  Created by Morten Saabye Kristensen on 18/10/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import Foundation

extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
