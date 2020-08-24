//
//  ZoomViewController.swift
//  EPRINE_FAVICON
//
//  Created by Softsuave on 15/08/20.
//  Copyright © 2020 Mobile. All rights reserved.
//

import UIKit
import MobileRTC

class ZoomViewController: UIViewController {
    
    //MARK:- Constants
    let kSDKUserName: String = "Akbar"
    let kSDKUserID: String = "Fz7O2vnwRcOTnEnslhwtbg"
    var zak: String?
    var kSDKMeetNumber: String?
    let appShare: Bool = false
    var isInitial: Bool = true
    
    //MARK:- Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if(self.kSDKMeetNumber == "") {
            print("Please enter a meeting number")
            return
        } else {
            let auth = MobileRTC.shared().isRTCAuthorized()
            let getservice = MobileRTC.shared().getMeetingService()
            if let service = getservice {
                service.delegate = self
                service.customizeMeetingTitle("Sample meeting title")
                let user = MobileRTCMeetingStartParam4WithoutLoginUser.init()
                user.userType = MobileRTCUserType_APIUser
                user.meetingNumber = kSDKMeetNumber
                user.userName = kSDKUserName
                user.userID = kSDKUserID
                user.isAppShare = appShare
                user.zak = zak ?? ""
                let param = user
                
                let ret: MobileRTCMeetError = service.startMeeting(with: param)
                print("onStartMeeting: \(ret)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isInitial {
            self.navigationController?.popViewController(animated: true)
        }
        isInitial = false
    }
}

extension ZoomViewController: MobileRTCMeetingServiceDelegate {
    
    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
        print(" Meeting state: \(state)")
    }
    
}
