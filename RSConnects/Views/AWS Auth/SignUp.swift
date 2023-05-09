//
//  SignUp.swift
//  RSConnects
//
//  Created by Jack Frank on 5/9/23.
//

import SwiftUI

struct SignUp: View {
    @EnvironmentObject var modelData: ModelData
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    @State private var text1 = ""
    var body: some View {
        VStack {
            TextField("Username", text: $username)
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Text(text1)
            Button("Sign Up") {
                if password.count < 8 {
                    text1 = "Password must be at least 8 characters"
                } else {
                    Task {
                        await modelData.signUp(username: username, password: password, email: email)
                    }
                }
            }
            Button("Already have an account? Sign in.") {
                modelData.showSignIn()
            }
        }
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}
