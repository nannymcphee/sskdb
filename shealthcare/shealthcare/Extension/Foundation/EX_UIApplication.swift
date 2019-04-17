//
//  EX_UIApplication.swift
//  shealthcare
//
//  Created by SangWooKim on 12/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import Foundation

extension UIApplication {
    
    func applicationVersion() -> String {
        
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    func applicationBuild() -> String {
        
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    func versionBuild() -> String {
        let version = self.applicationVersion()
        let build = self.applicationBuild()
        
        return "v\(version)(\(build))"
    }
}
