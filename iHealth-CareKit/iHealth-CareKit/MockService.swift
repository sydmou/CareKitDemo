//
//  MockService.swift
//  ZombieCare
//
//  Created by Chris Baxter on 09/06/2016.
//  Copyright © 2016 Catalyst Mobile Ltd. All rights reserved.
//

import Foundation

struct MockService : ZCService {
    
    
    func request<T : ZCAPIResource, R : ZCAPIResponse>(_ resource: T, completion: (_ response: R?, _ error: NSError?)-> Void) {
        
        print("Loading Mock CarePlan Data")
        
        if let path = Bundle.main.path(forResource: resource.path, ofType: "json"),
               let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)),
               let mockresponse = R(data: jsonData) {
        
            
            completion(mockresponse, nil)
            
        }
        else {
            
            let err = NSError(domain: "MockBackendErrorDomain", code: 0, userInfo: nil)
            completion(nil, err)
        }        
        
    }
    
}
