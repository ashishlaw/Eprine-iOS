//
//  WebViewControl.swift
//  EPRINE
//
//  Created by Mobile on 15/07/20.
//  Copyright © 2020 Mobile. All rights reserved.
//https://eprine.adaptivetelehealth.com/index.php/api/login.json

import UIKit
import WebKit
import PKHUD
import OneSignal
import MobileRTC

class WebViewControl: UIViewController, UIWebViewDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    //MARK:- IBOutlets
    @IBOutlet weak var webView: WKWebView!
    
    //MARK:- Variables
    let appDel = UIApplication.shared.delegate as! AppDelegate
    var loadCount = 0
    let urlDemo = "https://eprine.test.adaptivetelehealth.com/index.php/login?deviceId="
    
    //Zoom related variables
    let kSDKUserName: String = UserStore.shared.zoomUserName
    let kSDKUserID: String = UserStore.shared.zoomId
    var zak: String?
    var kSDKMeetNumber: String?
    let appShare: Bool = false
    
    //MARK:- Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.progress)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
        var url  = urlDemo  //live
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                // Notification permission has not been asked yet, go for it!
            } else if settings.authorizationStatus == .denied {
                // Notification permission was previously denied, go to settings & privacy to re-enable
            } else if settings.authorizationStatus == .authorized {
                // Notification permission was already granted
                if let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId {
                    url  = self.urlDemo + userId // Live
                    url = "https://eprine.test.adaptivetelehealth.com/index.php/login/mobile_login/\(UserStore.shared.token)/\(UserStore.shared.deviceToken)"
                }
            }
        })
        let theConfiguration = WKWebViewConfiguration()
        theConfiguration.userContentController.add(self, name: "myApp")
        url = "https://eprine.test.adaptivetelehealth.com/index.php/login/mobile_login/\(UserStore.shared.token)/\(UserStore.shared.deviceToken)"
        print("url", url)
        let webKit = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height) ,configuration: theConfiguration)
        webKit.load(URLRequest(url: URL(string: url)!))
        webKit.navigationDelegate = self
        webKit.tag = 1111
        webKit.backgroundColor = .clear
        self.view.addSubview(webKit)
    }
    
    //MARK:- WebView delegates
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        loadCount += 1
        if loadCount == 2 {
            HUD.hide()
        }
        webView.evaluateJavaScript("document.getElementById('idLoginButton').click()", completionHandler: nil)
        let hitURL = "https://eprine.test.adaptivetelehealth.com/index.php/login"
        
        if webView.url == URL.init(string: hitURL) {
            print("UserLogout")
            UserStore.shared.boolBioMetric = false
            UserStore.shared.boolRememberLogin = false
            UserStore.shared.deviceToken = ""
            UserStore.shared.token = ""
            self.appDel.setLogin()
            
        }
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        }else{
            completionHandler(.useCredential, nil)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        guard let urlAsString = navigationAction.request.url?.absoluteString.lowercased() else { return }
        let url = URL.init(string: urlAsString)
        let paramters = url?.queryParameters
        if urlAsString.contains("adaptivetelehealth.zoom.us") {
            guard let zoomId = urlAsString.slice(from: "adaptivetelehealth.zoom.us/s/", to: "?zak=")else { return }
            guard let zak = paramters?["zak"] else { return }
            self.kSDKMeetNumber = zoomId
            self.zak = zak
            // if (UserStore.shared.zoomUserName != "") && (UserStore.shared.zoomId != "") {
            startZoomMeeting()
            // }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Script message ",message.body)
    }
    
    //MARK:- Notifications
    @objc func onDidReceiveData(_ notification:Notification) {
        print("notification.userInfo")
        if let data = notification.userInfo as? [String: String] {
            if (data["deviceId"]) != nil {
                // let  url  = "\(urlDemo)?deviceId=" + data["deviceId"]!
                let url = "https://eprine.test.adaptivetelehealth.com/index.php/login/mobile_login/\(UserStore.shared.token)/\(UserStore.shared.deviceToken)"
                let webView = self.view.viewWithTag(1111) as? WKWebView
                print("didReceive ", url)
                webView!.load(URLRequest(url: URL(string: url)!))
            }
        }
    }
    
    //MARK:- Start Zoom meeting
    func startZoomMeeting() {
        if(self.kSDKMeetNumber == "") {
            print("Please enter a meeting number")
            return
        } else {
            //let auth = MobileRTC.shared().isRTCAuthorized()
            let getservice = MobileRTC.shared().getMeetingService()
            if let service = getservice {
                service.delegate = self
                //service.customizeMeetingTitle("Sample meeting title")
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
}

extension WebViewControl: MobileRTCMeetingServiceDelegate {
    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
        print(" Meeting state: \(state)")
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
}

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

