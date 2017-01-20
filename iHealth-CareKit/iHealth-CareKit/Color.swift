//
//  Color.swift
//  ZombieCare
//
//  Created by Chris Baxter on 20/06/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import UIKit


extension UIColor {
    
     static func ColorWithString(_ colorString: String)-> UIColor {
        
        switch colorString {
        case "Gold":
            return UIColor(red: 212.0/255.0, green: 175.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        case "Purple":
            return UIColor.purple
        case "Orange":
            return UIColor.orange
        default:
                fatalError("Not a valid colour")
        }
    }
    
    static func MaskTintColour()-> UIColor {
        
        return UIColor(red: 45.0/255.0, green: 192.0/255.0, blue: 112.0/255.0, alpha: 1.0)
    }
    
    static func ChartMainTintColour()-> UIColor {
        
        return UIColor(red: 45.0/255.0, green: 192.0/255.0, blue: 112.0/255.0, alpha: 1.0)
    }
    
    static func ChartAdherenceTintColour()-> UIColor {
        
        return UIColor(red: 116.0/255.0, green: 223.0/255.0, blue: 165.0/255.0, alpha: 1.0)
    }
    
    static func ZombieColour()-> UIColor {
        
        return UIColor(red: 163.0/255.0, green: 201.0/255.0, blue: 18.0/255.0, alpha: 1.0)
    }
}
