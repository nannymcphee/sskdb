//
//  MenuItem.swift
//  shealthcare
//
//  Created by Nguyên Duy on 4/20/19.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import Foundation

class MenuItem: NSObject, NSCoding, Codable {
    var name: String?
    var imageName: String?
    
    override init() {
    }
    
    init(name: String?, imageName: String?) {
        self.name = name
        self.imageName = imageName
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "word")
        aCoder.encode(self.imageName, forKey: "imageName")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as? String,
            imageName = aDecoder.decodeObject(forKey: "imageName") as? String
        self.init(name: name, imageName: imageName)
    }
}
