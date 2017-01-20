//
//  Medication.swift
//  ZombieCare
//
//  Created by Chris Baxter on 21/06/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import Foundation

class Medication : NSObject,  NSCoding {
    
    let medication : String
    let imageURL : URL
    
    init?(medication : String, imageURL : URL ) {
        
        self.medication = medication
        self.imageURL = imageURL
    }
    
    
    // MARK: NSCoding
    required convenience init?(coder decoder: NSCoder) {
        
        let medication = decoder.decodeObject(forKey: "medication") as! String
        let imageURL = decoder.decodeObject(forKey: "imageURL")as! URL
        
        self.init(medication:medication, imageURL: imageURL)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.medication, forKey: "medication")
        coder.encode(self.imageURL, forKey: "imageURL")
        
    }
}
