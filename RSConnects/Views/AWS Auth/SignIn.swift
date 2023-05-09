//
//  SignIn.swift
//  RSConnects
//
//  Created by Jack Frank on 5/9/23.
//

import SwiftUI

struct SignIn: View {
    @EnvironmentObject var modelData: ModelData
    @State private var username = ""
    @State private var password = ""
    var body: some View {
        VStack {
            Spacer()
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            Button("Forgot your password?") {
                modelData.showReset()
            }
            Spacer()
            Button("Log In"){
                Task {
                    await modelData.signIn(username: username, password: password)
                }
            }
            Spacer()
            Button("Don't have an account? Sign up.") {
                modelData.showSignUp()
            }
        }
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignIn()
    }
}
