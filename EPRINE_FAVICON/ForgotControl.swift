//
//  ForgotControl.swift
//  EPRINE_FAVICON
//
//  Created by Mobile on 10/09/20.
//  Copyright © 2020 Mobile. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class ForgotControl: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblForgot: UILabel!
    @IBOutlet weak var txtFldUserName: UITextField!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var lblCenter: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
       // txtFldUserName.text = "francol@adaptivetelehealth.com"
        btnReset.layer.cornerRadius = btnReset.frame.height / 2
        btnReset.layer.masksToBounds = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            lblCenter.text = "Don't worry \nJust fill user name/email and we will send you a link to reset your password."
            lblForgot.text = "Forgot your password?"
        } else {
            lblCenter.text = "Don't worry \nJust fill user name/email and we will send you a link to reset your password."
            lblForgot.text = "Forgot your \npassword?"
        }
    }
    
    let manager = ServerTrustManager(evaluators: ["eprine.adaptivetelehealth.com": DisabledTrustEvaluator()])
    lazy var session = Session(serverTrustManager: manager)
    
    func forgotPassword() {
        //  let fileURL = "eprine.test.adaptivetelehealth.com/api/recoverpass_json"
        let fileURL = "https://eprine.adaptivetelehealth.com/index.php/api/recoverpass.json"
        let parameters : Parameters = ["username": txtFldUserName.text!]
        HUD.show(.progress)
        
        
        session.request(fileURL, method: .post, parameters: parameters).responseJSON {
            response in
            print(response)
            HUD.hide()
            if let dict = response.value as? [String:Any] {
                if dict["status"] as! Int == 1 {
                    HUD.flash(.label(("Forgot Password Request Successful. \nPlease check your email for a link to reset your password.")), delay: 1.5)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.navigationController?.popViewController(animated: false)
                    }
                    
                }else {
                   HUD.flash(.label((dict["message"] as! String)), delay: 1.5)
                }
            }
        }
    }
    
    
    @IBAction func btnForgotAction(_ sender: UIButton) {
        if txtFldUserName.text != "" {
            forgotPassword()
        } else {
            HUD.flash(.label(("Enter username first")), delay: 1.5)
        }
        
    }
    

    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}
