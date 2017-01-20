//
//  Contact.swift
//  ZombieCare
//
//  Created by Chris Baxter on 08/08/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import CareKit
import ContactsUI

enum ContactType: String {
    case CareTeam
    case Personal
}

/*
 The contact protocol specifies the base contact properties and functions
 */
protocol Contact {
    var name : String  { get set}
    var relation : String  { get set}
    var colour : UIColor?  { get set}
    var phoneNumber : CNPhoneNumber?   { get set}
    var messageNumber : CNPhoneNumber?   { get set}
    var emailAddress : String?   { get set}
    var monogram : String?   { get set}
    var imageURL : URL?   { get set}
    var contactType: ContactType  { get set}
    
    init()
    init(json: JSON)
    init(contact: CNContact, relation : String)
    func createCareKitContact() -> OCKContact
}

extension Contact {

    init(json: JSON) {
        
        self.init()
        
     
        self.name = json["name"].string!
        self.relation = json["relation"].string!
        self.phoneNumber = CNPhoneNumber(stringValue: json["phoneNumber"].string!)
        self.messageNumber = CNPhoneNumber(stringValue: json["messageNumber"].string!)
        self.emailAddress = json["emailAddress"].string!
        self.monogram = json["monogram"].string!
        self.contactType = .CareTeam
        
        let colourString = json["colour"].string!
        self.colour = UIColor.ColorWithString(colourString)
        
        if let imageString = json["imageURL"].string {
            let componentsOfString = imageString.components(separatedBy: ".")
            
            if let pathForResource = Bundle.main.path(forResource: componentsOfString[0], ofType: componentsOfString[1]){
                self.imageURL = URL(fileURLWithPath: pathForResource)
            }
        }
        
    }
    
    init(contact: CNContact, relation : String) {
        
        self.init()
        
        
        self.name = CNContactFormatter.string(from: contact, style: .fullName)!
        self.relation = relation
        self.contactType = .Personal
        
        //Check for and add numbers
        if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
        
            for number in contact.phoneNumbers {
                if number.label == CNLabelPhoneNumberMobile || number.label == CNLabelPhoneNumberiPhone {
            
                    let phonenum = number.value 
                    self.phoneNumber = phonenum
                    self.messageNumber = phonenum
                    
                    break
                }
                
            }
        }
        
        if contact.isKeyAvailable(CNContactEmailAddressesKey) {
            
            for emailAddress in contact.emailAddresses {
                    self.emailAddress = emailAddress.value as? String
                    break
                
            }
        }
        
        let givenName = contact.givenName
        let familyName = contact.familyName
        
        self.monogram = "\(givenName[givenName.startIndex])\(familyName[familyName.startIndex])"
        
        
        self.colour = UIColor.ZombieColour()
        
        if let imageData = contact.imageData {
            
            //store the image and refrence the imageURL
            
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let pathForResource = documents + "/\(contact.familyName).data"
            do{
                try imageData.write(to: URL(fileURLWithPath: pathForResource), options: .atomicWrite)
                self.imageURL = URL(fileURLWithPath: pathForResource)
            }
            catch {
                self.imageURL = nil
            }
            
        }
        else {
            self.imageURL = nil
        }
        
        
        
    }
    
    
    
    func createCareKitContact() -> OCKContact{
        
        var image : UIImage? = nil
        if let imagePath = self.imageURL?.path {
         
            image = UIImage(contentsOfFile: imagePath)
        }
        
        let contactType: OCKContactType!
        
        switch self.contactType {
        case .CareTeam :
            contactType = OCKContactType.careTeam
            
        case .Personal:
            contactType = OCKContactType.personal
            
        }
        
        
        
        let contact = OCKContact(contactType: contactType, name: self.name, relation: self.relation, tintColor: self.colour, phoneNumber: self.phoneNumber, messageNumber: self.messageNumber, emailAddress: self.emailAddress, monogram: self.monogram!, image: image)
        
        return contact
    }

}

/*
Struct that conforms to the Contact protocol
*/
struct ZCContact : Contact {
    
    var name : String
    var relation : String
    var colour : UIColor? = nil
    var phoneNumber: CNPhoneNumber?
    var messageNumber: CNPhoneNumber?
    var emailAddress: String?
    var monogram: String?
    var imageURL : URL? = nil
    var contactType: ContactType = .CareTeam
    
    
    init() {
        
        name = ""
        relation = ""
        colour = nil
        
    }
    
    
    
}
