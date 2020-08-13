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

class WebViewControl: UIViewController, UIWebViewDelegate, WKNavigationDelegate , WKScriptMessageHandler {
    
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
        
        
        let theConfiguration = WKWebViewConfiguration()
        theConfiguration.userContentController.add(
            self,
            name: "myApp")

        
        url = "https://eprine.test.adaptivetelehealth.com/index.php/login/mobile_login/\(UserStore.shared.token)/\(UserStore.shared.deviceToken)"
        print("url", url)
        let webKit = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height) ,configuration: theConfiguration)
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
        //    if webView.url?.relativeString == "https://zvideo.adaptivetelehealth.com/?API_KEY=" {
          //      print("url matched")
            //}
            
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
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
       decisionHandler(.allow)
       guard let urlAsString = navigationAction.request.url?.absoluteString.lowercased() else {
           return
       }

      print("navigationAction ",urlAsString)
        
        let zoomBaseURl = "zoomus://zoom.us/start?confno="
        let token = "?token="
        let url = URL.init(string: urlAsString)
        let paramters = url?.queryParameters
        
        
        if urlAsString.contains("zoom.us/s"){
            print("Is zoom")
           // guard let zoomId = urlAsString.slice(from: "adaptivetelehealth.zoom.us/s/", to: "?zak=")else {return}
            guard let zoomId = paramters?["confno"] , let zak = paramters?["zak"] else {return}
            print("zoomId ",zoomId)
            let mainUrl = "\(zoomBaseURl)\(zoomId)&token=\(zak)"
            print("Main url ",mainUrl)
            if UIApplication.shared.canOpenURL(URL.init(string: mainUrl)!) {
                UIApplication.shared.open(URL.init(string: mainUrl)!, options: [:], completionHandler: nil)
            }
        }
//        else if urlAsString.contains("zoom.us/j"){
//                   print("Is zoom")
//                   guard let zoomId = urlAsString.slice(from: "adaptivetelehealth.zoom.us/j/", to: "?zak=")else {return}
//                   print("zoomId ",zoomId)
//            let tokenURL = token + ""
//                  let mainUrl = "\(zoomBaseURl)\(zoomId)"
//
//                   print("Main url ",mainUrl)
//                    if UIApplication.shared.canOpenURL(URL.init(string: mainUrl)!) {
//                                  UIApplication.shared.open(URL.init(string: mainUrl)!, options: [:], completionHandler: nil)
//                              }
//               }
        
    }
    
//zoomus://zoom.us/join?confno=94468084778&token=eyj6bv9za20ioij6bv9vmm0ilcjhbgcioijiuzi1niisinr5cci6ikpxvcj9.eyjhdwqioijjbgllbnqilcj1awqioijgejdpmnzud1jjt1rurw5zbgh3dgjniiwiaxnzijoid2viiiwic3r5ijo5oswid2nkijoiyxcxiiwiy2x0ijowlcjzdgsioijiodvuuzvfctawmlr6uuctx2pwng1jvfewr0nwsnm1zxjndeh2dmtgefzzlkjnvtrrm2n6uvvwu1yyefhwmnbmtvhssmffzdzlsg95wtnssgryqkznwef2u1u5b1riqxlowfjruvrsnfrtefvzblzazda4ek5ddg5qvdbbquf3elewskjkvzlwv1znemn6mefbmkyztveilcjlehaioje2mduwotuxndesimlhdci6mtu5nzmxote0mswiywlkijoirtfctjd5tvfteg1iu3vqum9nelhsusisimnpzci6iij9.mlv5gdgbu5n-4ckdpxiiesov6kz0u8k3oxhhrxpgejw
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        
        print("Script message ",message.body)
        
        
        
        
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

