//
//  Profile.swift
//  RSConnects
//
//  Created by Jack Frank on 5/8/23.
//

import Foundation
import UIKit

struct Profile: Hashable {
    var id: String
    var email: String
    var phone: String
    var username: String
    var image: UIImage
    var isAdmin: Bool
    var token: String
    
    static let `default` = Profile(id: "", email: "", phone: "", username: "", image: UIImage(imageLiteralResourceName: "ProfilePic"), isAdmin: false, token: "")
}
