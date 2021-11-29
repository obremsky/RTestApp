//
//  URL+Extensions.swift
//  RTestApp
//
//  Created by Viacheslav Obremskyi on 04.11.2020.
//

import Foundation
import UIKit

extension URL {
    var isValid : Bool {
        return UIApplication.shared.canOpenURL(self)
    }
}
