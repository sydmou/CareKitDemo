//
//  Activity.swift
//  ZombieCare
//
//  Created by Chris Baxter on 09/06/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import CareKit
import ResearchKit

/*
 Defines a few enums
 */
enum ActivityType: String {
        case Intervention
        case Assessment
}

enum ScheduleType: String {
    case Weekly
    case Daily
    
}

enum StepFormat : String {
    case Scale
    case Quantity
}

/*
 The activity protocol specifies the base activity properties and functions
 
 The base ACtivity protocol is used for Intervention activies
 */
protocol Activity {
    var identifier : String  { get set}
    var groupIdentifier : String  { get set}
    var title : String  { get set}
    var colour : UIColor?  { get set}
    var text : String  { get set}
    var startDate : Date  { get set}
    var schedule : [NSNumber]  { get  set}
    var scheduleType : ScheduleType  { get set}
    var instructions : String?   { get set}
    var imageURL : URL?   { get set}
    var activityType: ActivityType  { get set}
    var medication : Medication?  { get set}
    
    init()
    init(json: JSON)
    func createCareKitActivity() -> OCKCarePlanActivity
}



extension Activity {
    
//  A mutating function to allow Acticities or Assessments to intialiser base properties
    mutating func parseActivityFields(_ json: JSON) {
        
        
        self.identifier = json["identifier"].string!
        self.groupIdentifier = json["group_identifier"].string!
        self.title = json["title"].string!
        self.text = json["text"].string!
        
        let colourString = json["colour"].string!
        self.colour = UIColor.ColorWithString(colourString)
        
        if let instructionString = json["instructions"].string {
            self.instructions = instructionString
        }
        
        if let imageString = json["imageURL"].string {
            let componentsOfString = imageString.components(separatedBy: ".")
            
            if let pathForResource = Bundle.main.path(forResource: componentsOfString[0], ofType: componentsOfString[1]){
                self.imageURL = URL(fileURLWithPath: pathForResource)
            }
        }
        
        self.startDate = dateFromString(json["startdate"].string!)!
        self.scheduleType = ScheduleType(rawValue: json["scheduletype"].string!)!
        
        self.schedule = json["schedule"].string!.components(separatedBy: ",").map ( {
            NSNumber(value: Int32($0)! as Int32)
        })
        
        if let medication = json["medication"].string,
            let medicationImageString = json["medicationimage"].string {
            
            let componentsOfString = medicationImageString.components(separatedBy: ".")
            let pathForResource = Bundle.main.path(forResource: componentsOfString[0], ofType: componentsOfString[1])
            
            self.medication = Medication(medication: medication, imageURL: URL(fileURLWithPath: pathForResource!))
        }
        
    }
    
    init(json: JSON) {
        
        self.init()
        
        self.parseActivityFields(json)
        
    }
    
    
    func createCareKitActivity() -> OCKCarePlanActivity{
        
        //creates a schedule based on the internal values for start and end dates
        let startDateComponents = NSDateComponents(date: self.startDate, calendar: Calendar(identifier: Calendar.Identifier.gregorian))
        
        let activitySchedule: OCKCareSchedule!
        
        switch self.scheduleType {
        case .Weekly :
            activitySchedule = OCKCareSchedule.weeklySchedule(withStartDate: startDateComponents as DateComponents, occurrencesOnEachDay: self.schedule)
            
        case .Daily:
            activitySchedule = OCKCareSchedule.dailySchedule(withStartDate: startDateComponents as DateComponents, occurrencesPerDay: self.schedule[0].uintValue)
            
        }
        
        let activity = OCKCarePlanActivity.intervention(
            withIdentifier: identifier,
            groupIdentifier: nil,
            title: title,
            text: text,
            tintColor: colour,
            instructions: instructions,
            imageURL: imageURL,
            schedule: activitySchedule,
            userInfo: ["medication":medication!])
        
        return activity
        
    }
}






/**
 Struct that conforms to the Activity protocol to define either an intervention activity.
 */
struct ZCActivity : Activity {
    
    var identifier : String
    var groupIdentifier : String
    var title : String
    var colour : UIColor? = nil
    var text : String
    var startDate = Date()
    var schedule : [NSNumber]
    var scheduleType : ScheduleType
    var instructions : String? = nil
    var imageURL : URL? = nil
    var activityType: ActivityType = .Intervention
    var medication : Medication? = nil
    
    
    init() {
        
        identifier = ""
        groupIdentifier = ""
        title = ""
        colour = nil
        text = ""
        schedule = [NSNumber(value: 0 as Int32)]
        scheduleType = .Daily
        
    }
    
    
    
}




