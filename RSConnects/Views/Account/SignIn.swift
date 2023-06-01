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
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 420)
                .ignoresSafeArea()
            Spacer()
            VStack {
                TextField("Username", text: $username)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                Divider()
                    .padding(.horizontal)
                Spacer()
                    .frame(height: 10)
                SecureField("Password", text: $password)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                Divider()
                    .padding(.horizontal)
                Spacer()
            }
            Button("Sign In"){
                modelData.isLoading = true
                Task {
                    await modelData.signIn(username: username, password: password)
                    modelData.isLoading = false
                }
            }
            .font(.title2)
            .padding()
            .foregroundColor(Color("Yellow"))
            .background(Color("Blue"))
            .clipShape(Capsule())
            Spacer()
            Button("Forgot your password?") {
                modelData.showReset()
            }
            .border(.clear)
            Spacer()
                .frame(height: 10)
            Button("Sign In as a Guest") {
                modelData.profile = Profile.default
                modelData.showApp = true
            }
            .border(.clear)
            Spacer()
                .frame(height: 10)
            Button("Don't have an account? Sign up.") {
                modelData.showSignUp()
            }
            .border(.clear)
        }
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignIn()
    }
}
