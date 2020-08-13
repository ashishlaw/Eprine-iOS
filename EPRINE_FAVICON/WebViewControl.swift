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

class WebViewControl: UIViewController, UIWebViewDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    var loadCount = 0
    
    let urlDemo = "https://eprine.test.adaptivetelehealth.com/index.php/login?deviceId="
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
        
        url = "https://eprine.test.adaptivetelehealth.com/index.php/login/mobile_login/\(UserStore.shared.token)/\(UserStore.shared.deviceToken)"
        print("url", url)
        let webKit = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        webKit.load(URLRequest(url: URL(string: url)!))
        webKit.navigationDelegate = self
        webKit.tag = 1111
        webKit.backgroundColor = .clear
        self.view.addSubview(webKit)
    }
        
        
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            loadCount += 1
            if loadCount == 2 {
                HUD.hide()
            }
           // webView.stringByEvaluatingJavaScript(from: "document.getElementById('idLoginButton').click()")
            webView.evaluateJavaScript("document.getElementById('idLoginButton').click()", completionHandler: nil)
            if webView.url?.relativeString == "https://zvideo.adaptivetelehealth.com/?API_KEY=" {
                print("url matched")
            }
            
            let hitURL = "https://eprine.test.adaptivetelehealth.com/index.php/login"
           // let meetingURL = "https://zvideo.adaptivetelehealth.com/?API_KEY=4q6_BakLTE-IPKB3nhSG_A&signature=NHE2X0Jha0xURS1JUEtCM25oU0dfQS4xMTMxMTA1ODkuMTU4NTI5Mzg2OTAwMC4xLkJiZTkxaXZPUkF1RlpHUUxGeUpFY254c2dHdFI0Z1RVWGZDNlIxK0RKdEU9&name=Anne++Smith&meeting_number=113110589&company_name=&redirect_url=https%3A%2F%2Fabundant.adaptivetelehealth.com%2F"
            if webView.url == URL.init(string: hitURL) {
                print("UserLogout")
                UserStore.shared.boolBioMetric = false
                UserStore.shared.boolRememberLogin = false
                UserStore.shared.deviceToken = ""
                UserStore.shared.token = ""
                self.appDel.setLogin()
                
            }
//            else if webView.url == URL.init(string: meetingURL) {
//                print("hit meeting buutton")
//            }
            
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            }else{
                completionHandler(.useCredential, nil)
            }
            
        }
        
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
}
