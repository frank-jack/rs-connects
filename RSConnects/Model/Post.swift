//
//  Post.swift
//  RSConnects
//
//  Created by Jack Frank on 5/10/23.
//

import Foundation
import UIKit

struct Post: Hashable {
    var id: String
    var userId: String
    var text: String
    var groupId: String
    var image: UIImage
    var date: String
    var likes: [String]
}
