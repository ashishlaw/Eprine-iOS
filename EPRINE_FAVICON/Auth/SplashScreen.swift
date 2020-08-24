//
//  SplashScreen.swift
//  EPRINE
//
//  Created by Mobile on 15/07/20.
//  Copyright © 2020 Mobile. All rights reserved.
//

import UIKit
import LocalAuthentication

class SplashScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        TouchID.shared.authenticateUser { (success, errorStr) in
//            if success! {
//                let appDel = UIApplication.shared.delegate as! AppDelegate
//                appDel.setHome()
//            }
//        }
        
        touchAuthenticateUser()
        // Do any additional setup after loading the view.
    }
    
    let context = LAContext()
    var strAlertMessage = String()
    var error: NSError?
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    func touchAuthenticateUser() {
        // Device can use biometric authentication
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication,error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication,localizedReason:"Identify yourself!",reply: { [unowned self] (success, error) -> Void in
                DispatchQueue.main.async {
                    if( success ) {
                        self.appDel.setHome()
                    } else {
                        //If not recognized then
//                        self.popUp(title: "Please Authenticate", message: "Please unlock Infinite Backup to continue.", style: .alert, actionTitles: ["OK"], actions: [{ (_) in
                            self.touchAuthenticateUser()
//                            }])
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
            })
        } else {
            
        }
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
