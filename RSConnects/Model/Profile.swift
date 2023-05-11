//
//  Profile.swift
//  RSConnects
//
//  Created by Jack Frank on 5/8/23.
//

import Foundation

struct Profile: Hashable {
    var id: String
    var email: String
    var phone: String
    var username: String
    var isAdmin: Bool
    
    static let `default` = Profile(id: "", email: "", phone: "", username: "", isAdmin: false)
}
