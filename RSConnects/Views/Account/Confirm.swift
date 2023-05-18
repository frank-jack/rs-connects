//
//  Confirm.swift
//  RSConnects
//
//  Created by Jack Frank on 5/9/23.
//

import SwiftUI

struct Confirm: View {
    @EnvironmentObject var modelData: ModelData
    @State var confirmationCode = ""
    let email: String
    let username: String
    let password: String
    let phone: String
    var body: some View {
        VStack {
            Text("Email: \(email)")
            TextField("Confirmation Code sent to your email", text: $confirmationCode)
            Button("Confirm") {
                Task {
                    await modelData.confirm(for: username, with: confirmationCode, email: email, password: password, phone: phone)
                }
            }
            Button("Cancel") {
                modelData.showSignIn()
            }
        }
    }
}
