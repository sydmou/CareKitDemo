//
//  Assessment.swift
//  ZombieCare
//
//  Created by Chris Baxter on 29/06/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import CareKit
import ResearchKit

let kBrainGroupIdentifier = "brain"

/*
 A protocol for Assessment Activities that extends the Actvity protocol
 */
protocol Assessment : Activity {
    
    var taskIdentifier : String  { get set }
    
    var steps : [ActivityStep] {get set}
    
    func createTask() -> ORKTask
}

/*
 A protocol for Activity Steps.
 */
protocol ActivityStep {
    
    var stepIdentifier : String  { get set }
    var question : String  { get set }
    var format :  StepFormat {get set}
    var unit : String  { get set }
    var maxValueDescription : String  { get set }
    var minValueDescription : String  { get set }
    var defaultValue : Int  { get set }
    var maxValue : Int  { get set }
    var minValue : Int  { get set }
    var step : Int  { get set }
    var vertical : Bool  { get set }
    
    init()
    init(json:JSON)
}

/*
 This extension provides an initaliser for Activty steps to parde the json
 */
extension ActivityStep {
    
    init(json:JSON) {
        
        self.init()
        
        self.stepIdentifier = json["identifier"].string!
        
        self.question = json["title"].string!
        
        self.format = StepFormat(rawValue: json["format"].string!)!
        
        switch self.format {
        case .Quantity:
            
            self.unit = json["unit"].string!
            
        case .Scale:
            
            self.maxValueDescription = json["maxvaluedescription"].string!
            self.minValueDescription = json["minvaluedescription"].string!
            self.defaultValue = json["defaultvalue"].int!
            self.minValue = json["minvalue"].int!
            self.maxValue = json["maxvalue"].int!
            self.step =  json["stepvalue"].int!
            self.vertical =  json["vertical"].bool!
            
            
        }
        
    }
}

/*
The Assessment extension provides an initaliser for parsing json. It has overrides the createCareKitActivity function
 to provide is own implemnetation as well as additional createTask() fucntion as it adopts the Assessment protocol
 */

extension Assessment {
    
    
    
    init(json: JSON) {
        
        self.init()
        
        self.parseActivityFields(json)
        
        
        let task = json["task"]
        
        self.taskIdentifier = task["identifier"].string!
        
        
        let taskSteps = task["steps"].array!
        
        for step in  taskSteps{
            
            let stepJson = step
            
            let zcStep = ZCActivityStep(json: stepJson)
            
            self.steps.append(zcStep)
        }
        
        
        
    }
    
    func createCareKitActivity() -> OCKCarePlanActivity{
        
        //creates a schedule based on the internal values for start and end dates
        let startDateComponents = NSDateComponents(date: self.startDate as Date, calendar: Calendar(identifier: Calendar.Identifier.gregorian))
        
        let activitySchedule: OCKCareSchedule!
        
        switch self.scheduleType {
        case .Weekly :
            activitySchedule = OCKCareSchedule.weeklySchedule(withStartDate: startDateComponents as DateComponents, occurrencesOnEachDay: self.schedule)
            
        case .Daily:
            activitySchedule = OCKCareSchedule.dailySchedule(withStartDate: startDateComponents as DateComponents, occurrencesPerDay: self.schedule[0].uintValue)
            
        }
        
        let activity = OCKCarePlanActivity.assessment(
            withIdentifier: identifier,
            groupIdentifier: groupIdentifier,
            title: title,
            text: text,
            tintColor: colour,
            resultResettable: true,
            schedule: activitySchedule,
            userInfo: nil)
        
        return activity
        
    }
    
    
    func createTask() -> ORKTask {
        
        var steps : [ORKQuestionStep] = []
        
        for step in self.steps {
            
            let stepidentifier = NSLocalizedString(step.stepIdentifier, comment: "")
            let stepquestion = NSLocalizedString(step.question, comment: "")
            
            var answerFormat : ORKAnswerFormat?
            
            switch step.format {
                
            case .Quantity:
                
                let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)!
                let unit = HKUnit(from: step.unit)
                answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .decimal)
                
                
            case .Scale:
                
                // Get the localized strings to use for the task.
                let maximumValueDescription = NSLocalizedString(step.maxValueDescription, comment: "")
                let minimumValueDescription = NSLocalizedString(step.minValueDescription, comment: "")
                
                // Create a question and answer format.
                answerFormat = ORKScaleAnswerFormat(
                    maximumValue: step.maxValue,
                    minimumValue: step.minValue,
                    defaultValue: step.defaultValue,
                    step: step.step,
                    vertical: step.vertical,
                    maximumValueDescription: maximumValueDescription,
                    minimumValueDescription: minimumValueDescription
                )
                
            }
            
            
            let questionStep = ORKQuestionStep(identifier: stepidentifier, title: stepquestion, answer: answerFormat)
            questionStep.isOptional = false
            
            steps.append(questionStep)
            
        }
        
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: steps)
        
        return task
    }
    
    func buildCustomResultForCarePlanEvent(_ event: OCKCarePlanEvent, result: TaskResult) -> OCKCarePlanEventResult {
        
        
        return OCKCarePlanEventResult(valueString: "\(result.correct)", unitString: "out of \(result.total)", userInfo: nil)
        
    }

    
    /*
     In this example we are just returning the first result.  You can extend this method to collate results from multiple steps or include different types of results
     for the different types of questios you might include, whether they are from researhkit or some custom task
     */
    func buildResultForCarePlanEvent(_ event: OCKCarePlanEvent, taskResult: ORKTaskResult) -> OCKCarePlanEventResult {
        
        
        // Get the first result for the first step of the task result.
        guard let firstResult = taskResult.firstResult as? ORKStepResult, let stepResult = firstResult.results?.first else { fatalError("Unexpected task results") }
        
        // Determine what type of result should be saved.
        if let scaleResult = stepResult as? ORKScaleQuestionResult, let answer = scaleResult.scaleAnswer {
            return OCKCarePlanEventResult(valueString: answer.stringValue, unitString: "out of 10", userInfo: nil)
        }
        else if let numericResult = stepResult as? ORKNumericQuestionResult, let answer = numericResult.numericAnswer {
            return OCKCarePlanEventResult(valueString: answer.stringValue, unitString: numericResult.unit, userInfo: nil)
        }
        
        //You can add further result types if required
        
        fatalError("Unexpected task result type")
    }
    
    /*
     Returns true if theresult for this assessment can be stored in HealthKit
     */
    func supportsHealthKit() ->Bool {
        
        //retreive the first step
        guard let firstStep = self.steps.first as? ZCActivityStep else {return false}
        
        if firstStep.format != .Quantity {
            return false
        }
        
        return true
    }
    
    func getHKQuantityType() -> HKQuantityType {
        
        //retreive the first step
        guard let firstStep = self.steps.first as? ZCActivityStep else {fatalError("Unable to retrieve Task step")}
       
        var quantityType : HKQuantityType
        
        switch firstStep.unit {
            case "lb":
                quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        default:
                fatalError("unit not supported")
        }
        
       return quantityType
        
    }
    
    func getHKUnit() -> HKUnit {
        
        //retreive the first step
        guard let firstStep = self.steps.first as? ZCActivityStep else {fatalError("Unable to retrieve Task step")}
       
        return HKUnit(from:firstStep.unit)
    }
    
    
    /// Builds a `HKQuantitySample` from the information in the supplied `ORKTaskResult`.
    func buildHKSampleWithTaskResult(_ result: ORKTaskResult) -> HKQuantitySample {
        
        
        // Get the first result for the first step of the task result.
        guard let firstResult = result.firstResult as? ORKStepResult, let stepResult = firstResult.results?.first else { fatalError("Unexpected task results") }
        
        
        let now = Date()
        let quantityType = getHKQuantityType()
        
        
        // Get the numeric answer for the result.
        var numericAnswer : Double = 0
        
        if let scaleResult = stepResult as? ORKScaleQuestionResult, let answer = scaleResult.scaleAnswer {
            numericAnswer = answer.doubleValue
        }
        else if let numericResult = stepResult as? ORKNumericQuestionResult, let answer = numericResult.numericAnswer {
            numericAnswer = answer.doubleValue
        }
        
        let hkUnit = self.getHKUnit()
        
        let quantity =  HKQuantity(unit: hkUnit, doubleValue: numericAnswer)
        
        return HKQuantitySample(type: quantityType, quantity: quantity, start: now, end: now)
    }
    
    
    /**
     Uses an NSMassFormatter to determine the string to use to represent the
     supplied `HKQuantitySample`.
     */
    func localizedUnitForSample(_ sample: HKQuantitySample) -> String {
        
        let formatter = MassFormatter()
        formatter.isForPersonMassUse = true
        formatter.unitStyle = .short
        
        let value = sample.quantity.doubleValue(for: self.getHKUnit())
        let formatterUnit = MassFormatter.Unit.pound
        
        return formatter.unitString(fromValue: value, unit: formatterUnit)
    }
}

/*
 ZCActivityStep struct provides a concrete implemtaiton for Activty Steps
 */
struct ZCActivityStep : ActivityStep {
    var stepIdentifier : String
    var question : String
    var format :  StepFormat
    var unit : String
    var maxValueDescription : String
    var minValueDescription : String
    var defaultValue : Int
    var maxValue : Int
    var minValue : Int
    var step : Int
    var vertical : Bool
    
    init() {
        stepIdentifier = ""
        question = ""
        format = .Quantity
        unit = ""
        maxValueDescription = ""
        minValueDescription = ""
        defaultValue = -1
        maxValue = 10
        minValue = 1
        step = 1
        vertical = true
    }
    
}

/*
 ZCAssessment struct provides a concrete implemtnation for Activty and Assessment protocols
 */

struct ZCAssessment : Activity, Assessment {
    var identifier : String
    var groupIdentifier: String
    var title : String
    var colour : UIColor? = nil
    var text : String
    var startDate : Date = Date()
    var schedule : [NSNumber] = []
    var scheduleType : ScheduleType
    var instructions : String? = nil
    var imageURL : URL? = nil
    var activityType: ActivityType = .Assessment
    var medication : Medication? = nil
    
    var taskIdentifier: String
    var steps : [ActivityStep] = []
    
    init() {
        
        identifier = ""
        groupIdentifier = ""
        title = ""
        text = ""
        scheduleType = .Daily
        taskIdentifier = ""
        
    }
    
    
}

