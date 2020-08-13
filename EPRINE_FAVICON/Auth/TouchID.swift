//
//  TouchID.swift
//  EPRINE
//
//  Created by Mobile on 15/07/20.
//  Copyright © 2020 Mobile. All rights reserved.
//

import Foundation
import LocalAuthentication

class TouchID: NSObject {
    
    //MARK:- Shared Instance
    static let shared = TouchID()
    private override init() {}
    
    //MARK:- Authenticate Touch ID
    func authenticateUser(_ completeion:@escaping(_ success:Bool?,_ isAvailable:Bool?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        print("Now we can work further")
                        completeion(true, true)
                    } else {
                        print("Authentication failed")
                        completeion(false, true)
                    }
                }
            }
        } else {
            print("Touch ID not available")
            completeion(false, false)
        }
    }
}


