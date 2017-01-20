//
//  HWCareMonthlySchedule.swift
//  HelloWorldCK
//
//  Created by Chris Baxter on 31/05/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import CareKit

open class ZCCareMonthlySchedule : OCKCareSchedule  {
    
    var calendar: Calendar?
    
    
    open class func monthlyScheduleWithStartDate(_ startDate: DateComponents,  occurrencesFromJanuaryToDecember: [NSNumber], monthsToSkip: UInt, endDate: DateComponents?) -> ZCCareMonthlySchedule? {
        
        guard occurrencesFromJanuaryToDecember.count == 12
            else { return nil}
        
        //TODO: Requires fixing after CareKit is updated to handle sub classes
        
//        let schedule = super.initWithStartDate(startDate: startDate, endDate: endDate, occurrences: occurrencesFromJanuaryToDecember, timeUnitsToSkip: monthsToSkip)
       
    
        
       
        return nil
        
    }
    
   
    
    override open var type: OCKCareScheduleType {
        return OCKCareScheduleType.other
    }
    
    override open func numberOfEvents(onDate day: DateComponents) -> UInt {
        
        calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        calendar!.timeZone = TimeZone(abbreviation: "UTC")!
        
        
        let startMonth = (calendar as NSCalendar?)?.ordinality(of: NSCalendar.Unit.month, in: NSCalendar.Unit.era, for: (self.startDate as NSDateComponents).date! )
        let endMonth = (calendar as NSCalendar?)?.ordinality(of: NSCalendar.Unit.month, in: NSCalendar.Unit.era, for: (day as NSDateComponents).date! )
        let monthsSinceStart = startMonth! - endMonth!
        let month = (calendar as NSCalendar?)?.component(NSCalendar.Unit.month, from: (day as NSDateComponents).date!)
        
        //TODO:  Add a unit test to verify this works
        let occurrences : UInt = ((UInt(monthsSinceStart) % (self.timeUnitsToSkip + 1)) == 0) ? self.occurrences[month!-1].uintValue : 0;
        
        return occurrences;
    }
    
    //MARK: NSSecureCoding Support

    required convenience public init?(coder aDecoder: NSCoder) {
        
        self.init(coder: aDecoder)
        
    }
    
    //MARK: NSCopying Support
    override open func copy(with zone: NSZone?) -> Any {
        
        let theCopy = super.copy(with: zone) as! ZCCareMonthlySchedule
        
        return theCopy
    }
    
    
    
    
    
    
}
