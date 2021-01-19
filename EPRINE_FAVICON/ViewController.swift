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

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var token = String()
    var secure = true
    var userList = [UserDetails]()
    
    
    @IBOutlet weak var txtFldEmail: UITextField!
    @IBOutlet weak var txtFldPassword: UITextField!
    @IBOutlet weak var btnEye: UIButton!
    @IBOutlet weak var btnRemember: UIButton!
    @IBOutlet weak var btnBiometric: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var userListTabbleView: UITableView!
    @IBOutlet weak var popupViewHeightCons: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        //let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    let manager = ServerTrustManager(evaluators: ["eprine.adaptivetelehealth.com": DisabledTrustEvaluator()])
    lazy var session = Session(serverTrustManager: manager)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell") as! UserListTableViewCell
        cell.userIdLabel.text = userList[indexPath.row].roleName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loginApi(selectedId: userList[indexPath.row].id ?? "")
        popUpView.isHidden = true
    }
    
    func loginApi(selectedId: String) {
        //let fileURL = "https://eprine.adaptivetelehealth.com/index.php/api/"
        let fileURL = "https://eprine.adaptivetelehealth.com/index.php/api/login.json"
        let parameters : Parameters = ["username": txtFldEmail.text!, "password": txtFldPassword.text!, "app_name": "eprine", "device_id": UserStore.shared.deviceToken, "user_id": selectedId]
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
                    UserStore.shared.token = self.token
                    if UserStore.shared.boolBioMetric {
                        let alert = UIAlertController(title: "BioMetrics authentication activated.", message: "", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            UserStore.shared.boolLogout = false
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebViewControl")
                            self.navigationController?.pushViewController(vc!, animated: true)
                        })
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        UserStore.shared.boolLogout = false
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebViewControl")
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                }else {
                    HUD.flash(.label((dict["Message"] as! String)), delay: 1.5)
                }
            }
        }
    }
    
    func checkLoginApi() {
        //let fileURL = "https://eprine.adaptivetelehealth.com/index.php/api/"
        let fileURL = "https://eprine.adaptivetelehealth.com/index.php/api/checkLogin.json"
        let parameters : Parameters = ["username": txtFldEmail.text!, "password": txtFldPassword.text!, "app_name": "eprine", "device_id": UserStore.shared.deviceToken]
        HUD.show(.progress)
        session.request(fileURL, method: .post, parameters: parameters).responseJSON {
            response in
            print(response)
            HUD.hide()
            if let dict = response.value as? [String:Any] {
                if dict["status"] as! Int == 1 {
                    let users = User()
                    users.convertDict(dictionary: dict["data"] as! [String: Any])
                    self.userList = users.userList ?? [UserDetails]()
                    if users.userList?.count == 0 || (users.userList?.count == 1) {
                        if let user = users.userList?.first {
                            self.loginApi(selectedId: user.id ?? "")
                        }
                    } else {
                        self.popUpView.isHidden = false
                        self.popupViewHeightCons.constant = (((users.userList?.count ?? 0) * 44) + 42) > 262 ? 262 : (CGFloat((users.userList?.count ?? 0) * 44) + 42)
                        self.userListTabbleView.reloadData()
                    }
                } else {
                    HUD.flash(.label((dict["Message"] as! String)), delay: 1.5)
                }
            }
        }
    }
    
    func setupUI() {
        btnLogin.layer.cornerRadius = btnLogin.frame.height / 2
        btnLogin.layer.masksToBounds = true
        if UserStore.shared.boolRememberLogin == true {
            txtFldEmail.text = UserStore.shared.username
            btnRemember.setImage(#imageLiteral(resourceName: "box_icon_fill"), for: .normal)
        }
        
//        txtFldPassword.text = "Password123!!!"
    }

    @IBAction func actionOnCancelBtn(_ sender: Any) {
        popUpView.isHidden = true
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
            checkLoginApi()
            UserStore.shared.username = txtFldEmail.text!
            UserStore.shared.password = txtFldPassword.text!
        }
    }
    @IBAction func forgotAction(_ sender: UIButton) {
        let control = storyboard?.instantiateViewController(withIdentifier: "ForgotControl")
        self.navigationController?.pushViewController(control!, animated: false)
    }
}

extension ViewController: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
       //Trust the certificate even if not valid
       let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
       completionHandler(.useCredential, urlCredential)
    }
}
