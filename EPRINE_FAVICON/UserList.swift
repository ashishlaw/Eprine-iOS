//
//  UserList.swift
//  EPRINE_FAVICON
//
//  Created by Sudhakar P on 24/12/20.
//  Copyright © 2020 Mobile. All rights reserved.
//

import Foundation

class User: NSObject {
    
    var userList: [UserDetails]?
    var totalCount: Int?
    
    override init() {
        super.init()
    }
    
    func convertDict(dictionary: [String: Any]) {
        if let list = dictionary["users"] as? NSArray {
            var tempList = [UserDetails]()
            list.forEach { (use) in
                if let user = use as? Dictionary<String, Any> {
                    tempList.append(UserDetails(id: user["id"] as? String, user: user["full_name"] as? String, roleName: user["role_name"] as? String))
                }
            }
            self.userList = tempList
        }
        self.totalCount = dictionary["total_users"] as? Int ?? 0
    }
}

class UserDetails: NSObject {
    var id: String?
    var userName: String?
    var roleName: String?
    
    init(id: String?, user: String?, roleName: String?) {
        self.id = id
        self.userName = user
        self.roleName = roleName
    }
}
