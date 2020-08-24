//
//  UserStore.swift
//  EPRINE
//
//  Created by Mobile on 15/07/20.
//  Copyright © 2020 Mobile. All rights reserved.
//

import UIKit
import CoreLocation

class UserStore: NSObject {
    
    //MARK:- Shared Instance
    static var shared = UserStore()
    
    private override init() {
        super.init()
    }
    
    //MARK:- Key Vales
    var tokenKey       = "token"
    var deviceTokenKey = "device_token"
    var bioMetricKey   = "bioMetric"
    var rememberKey    = "remember"
    var usernameKey    = "username"
    var passwordKey    = "password"
    var zoomUserNameKey   = "zoomUserName"
    var zoomIdKey         = "zoomId"
    
    //MARK:- Cart Type
    var token: String {
        get {
            return UserDefaults.standard.value(forKey: tokenKey)  as? String ?? ""
        } set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
    
    var deviceToken: String {
        get {
            return UserDefaults.standard.value(forKey: deviceTokenKey) as? String ?? ""
        } set {
            UserDefaults.standard.set(newValue, forKey: deviceTokenKey)
        }
    }
    
    var boolBioMetric: Bool {
        get {
            return UserDefaults.standard.value(forKey: bioMetricKey) as? Bool ?? false
        } set {
            UserDefaults.standard.set(newValue, forKey: bioMetricKey)
        }
    }
    
    var boolRememberLogin: Bool {
        get {
            return UserDefaults.standard.value(forKey: rememberKey) as? Bool ?? false
        } set {
            UserDefaults.standard.set(newValue, forKey: rememberKey)
        }
    }
    
    var username: String {
        get {
            return UserDefaults.standard.value(forKey: usernameKey) as? String ?? ""
        } set {
            UserDefaults.standard.set(newValue, forKey: usernameKey)
        }
    }
    
    var password: String {
        get {
            return UserDefaults.standard.value(forKey: passwordKey) as? String ?? ""
        } set {
            UserDefaults.standard.set(newValue, forKey: passwordKey)
        }
    }
    
    var zoomUserName: String {
        get {
            return UserDefaults.standard.value(forKey: zoomUserNameKey) as? String ?? ""
        } set {
            UserDefaults.standard.set(newValue, forKey: zoomUserNameKey)
        }
    }
    
    var zoomId: String {
        get {
            return UserDefaults.standard.value(forKey: zoomIdKey) as? String ?? ""
        } set {
            UserDefaults.standard.set(newValue, forKey: zoomIdKey)
        }
    }
}
