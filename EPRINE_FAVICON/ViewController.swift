//
//  ViewController.swift
//  EPRINE
//
//  Created by Mobile on 15/07/20.
//  Copyright © 2020 Mobile. All rights reserved.
//
import UIKit
import WebKit
import OneSignal
import Alamofire
import PKHUD
import JWTDecode

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
}

class ViewController: UIViewController {
    
    var token = String()
    var secure = true
    
    
    @IBOutlet weak var txtFldEmail: UITextField!
    @IBOutlet weak var txtFldPassword: UITextField!
    @IBOutlet weak var btnEye: UIButton!
    @IBOutlet weak var btnRemember: UIButton!
    @IBOutlet weak var btnBiometric: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        //let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    let manager = ServerTrustManager(evaluators: ["eprine.test.adaptivetelehealth.com": DisabledTrustEvaluator()])
    lazy var session = Session(serverTrustManager: manager)
    
    func loginApi() {
        //let fileURL = "https://eprine.adaptivetelehealth.com/index.php/api/login.json"
        let fileURL = "https://eprine.test.adaptivetelehealth.com/index.php/api/login.json"
        let parameters : Parameters = ["username": txtFldEmail.text!, "password": txtFldPassword.text!, "app_name": "eprine", "device_id": UserStore.shared.deviceToken]
        HUD.show(.progress)
        session.request(fileURL, method: .post, parameters: parameters).responseJSON {
            response in
            print(response)
            HUD.hide()
            if let dict = response.value as? [String:Any] {
                if dict["status"] as! Int == 1 {
                    UserStore.shared.deviceToken = dict["device_id"] as! String
                    let data = dict["data"] as! [String:Any]
                    self.token = (data["jwt"] as! [String:Any])["id_token"] as? String ?? ""
                    self.getZoomUserNameandIdFromToken(userToken: self.token)
                    UserStore.shared.token = self.token
                    if UserStore.shared.boolBioMetric {
                        let alert = UIAlertController(title: "BioMetrics authentication activated.", message: "", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebViewControl")
                            self.navigationController?.pushViewController(vc!, animated: true)
                        })
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebViewControl")
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                }else {
                    HUD.flash(.label((dict["Message"] as! String)), delay: 1.5)
                }
            }
        }
    }
    
    func getZoomUserNameandIdFromToken(userToken: String) {
        do {
            let jwt = try decode(jwt: userToken)
            let body = jwt.body
            let userData = body["userdata"]
            let test1 = userData as? NSMutableString
            guard let value = convertToDictionary(text: String.init(test1!)) else {
                return
            }
            if let userDetails = value.first {
                if let fullname = userDetails["full_name"] as? String, let zoomID = userDetails["zoom_id"] as? String {
                    UserStore.shared.zoomUserName = fullname
                    UserStore.shared.zoomId = zoomID
                }
            }
        } catch {
            print("Failed to decode JWT: \(error)")
        }
    }
    
    func convertToDictionary(text: String) -> [[String: Any]]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func setupUI() {
        btnLogin.layer.cornerRadius = btnLogin.frame.height / 2
        btnLogin.layer.masksToBounds = true
//        txtFldEmail.text = "eprine_provider@adaptivetelehealth.com"
//        txtFldPassword.text = "Password123!!!"
    }

    @IBAction func rememberAction(_ sender: UIButton) {
        if sender.currentImage == UIImage(named: "box_icon_fill") {
            sender.setImage(#imageLiteral(resourceName: "stroke_icon_unfill"), for: .normal)
            UserStore.shared.boolRememberLogin = false
        } else {
            sender.setImage(#imageLiteral(resourceName: "box_icon_fill"), for: .normal)
            UserStore.shared.boolRememberLogin = true
        }
    }
    
    @IBAction func biometricAction(_ sender: UIButton) {
        if sender.currentImage == UIImage(named: "box_icon_fill") {
            sender.setImage(#imageLiteral(resourceName: "stroke_icon_unfill"), for: .normal)
            UserStore.shared.boolBioMetric = false
        } else {
            sender.setImage(#imageLiteral(resourceName: "box_icon_fill"), for: .normal)
            UserStore.shared.boolBioMetric = true
        }
    }
    
    @IBAction func passSecureAction(_ sender: UIButton) {
        if sender.currentImage == UIImage(named: "passw-active") {
            sender.setImage(#imageLiteral(resourceName: "forgot_icon"), for: .normal)
            txtFldPassword.isSecureTextEntry = true
        } else {
            sender.setImage(#imageLiteral(resourceName: "passw-active"), for: .normal)
            txtFldPassword.isSecureTextEntry = false
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        if !(txtFldEmail.text?.isEmpty)! && !(txtFldPassword.text?.isEmpty)! {
            loginApi()
            UserStore.shared.username = txtFldEmail.text!
            UserStore.shared.password = txtFldPassword.text!
        }
    }
}

extension ViewController: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
       //Trust the certificate even if not valid
       let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
       completionHandler(.useCredential, urlCredential)
    }
}
