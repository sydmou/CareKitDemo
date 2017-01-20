//
//  CarePlan.swift
//  ZombieCare
//
//  Created by Chris Baxter on 09/06/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import Foundation
import CareKit

/**
    Struct which encapsulates the CarePlan
*/
public struct CarePlan {
    
     let planID: Int
     let title : String
     let carePlanDescription : String
     var activities : [Activity] = []
     var connections : [Contact] = []
    
    init (planID:Int, title:String, carePlanDescription: String) {
        
        self.planID = planID
        self.title = title
        self.carePlanDescription = carePlanDescription
    }
    
    func findAssessmentActivity(_ assessmentActivity: OCKCarePlanActivity) -> Assessment? {
        
        let activity = self.activities.filter(){ $0.identifier == assessmentActivity.identifier}
        
        guard activity.count == 1 else {return nil}
        
        let act = activity[0] as? Assessment
        
        return act
    }
 
    
    //Returns all CareKit activities
    func allCKActivities(_ completion:(_ activities: [OCKCarePlanActivity])-> Void) {
        
        
        let ckallActivities = activities.map( {
            
            $0.createCareKitActivity()
            
        })
        
        
        completion(ckallActivities)
    }
    
    // Filters and returns an array of CareKit Intervention OCKCarePlanActivity objects
    
    func interventionCKActivities(_ completion:(_ activities: [OCKCarePlanActivity])-> Void) {
    
        let interventionActivities = activities.filter(){$0.activityType == .Intervention}
        
        let ckinterventionActivities = interventionActivities.map( {
            
            $0.createCareKitActivity()
        
        })
        
        
        completion(ckinterventionActivities)
    }
    
    // Filters and returns an array of CareKit assessment OCKCarePlanActivity objects
    
    func assessmentCKActivities(_ completion:(_ activities: [OCKCarePlanActivity])-> Void) {
        
        let assessmentActivities = activities.filter(){$0.activityType == .Assessment}
        
        let ckassessmentActivities = assessmentActivities.map( {
            
            $0.createCareKitActivity()
            
        })
        
        
        completion(ckassessmentActivities)
    }
    
    func allCKContacts()-> [OCKContact] {
        
        let ckcontacts = connections.map( {
        
        $0.createCareKitContact()
        
        })
        
        return ckcontacts
        
    }
    
    mutating func AddContact(_ contact : ZCContact) {
    
        self.connections.append(contact)
    }
    
}

extension CarePlan : Equatable {}

public func ==(lhs: CarePlan, rhs: CarePlan) -> Bool {
    return lhs.planID == rhs.planID &&
        lhs.title == rhs.title
}


/**
 CarePlan conforms to the ZCAPIResponse protocol.  tthis implementation parses the json  careplan  and maps activities to local immutable Activity Struct

 */
extension CarePlan : ZCAPIResponse {
    
    init?(data:Data?) {
        
        do {
        
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
            
            guard
                let planID = json["planID"] as? Int,
                let title = json["title"] as? String,
                let desc = json["description"] as? String,
                let intervention_activities = json["intervention_activities"] as? Array<NSDictionary>,
                let assessment_activities = json["assessment_activities"] as? Array<NSDictionary>
                
            else { return nil }
            
            self.planID = planID
            self.title = title
            self.carePlanDescription = desc
            
            for intervention in intervention_activities {
                let activity = ZCActivity(json: JSON(intervention))
                activities.append(activity)
            }
            
            for assessment in assessment_activities {
                
                let activity = ZCAssessment(json: JSON(assessment))
                activities.append(activity)
            }
            
            
            if let contacts = json["connections"] as? Array<NSDictionary> {
                
                for contact in contacts {
                    let contact = ZCContact(json: JSON(contact))
                    connections.append(contact)
                }
            }
            
        }
        catch {
            print("Failed to initialise CarePlan")
            return nil
        }
        
    }
    
}
