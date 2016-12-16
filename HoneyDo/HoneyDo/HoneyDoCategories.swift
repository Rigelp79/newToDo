//
//  HoneyDoCategories.swift
//  HoneyDo
//
//  Created by Rigel Preston on 10/30/16.
//  Copyright © 2016 Rigel Preston. All rights reserved.
//

import UIKit

class HoneyDoCategories: NSObject {
    var name = ""
    var items = [HoneydolistItem]()
    
    
    init(name: String) {
        self.name = name
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        items = aDecoder.decodeObject(forKey: "Items") as! [HoneydolistItem]
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(items, forKey: "Items")
    }

}
