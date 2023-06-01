//
//  SignUp.swift
//  RSConnects
//
//  Created by Jack Frank on 5/9/23.
//

import SwiftUI
import iPhoneNumberField

struct SignUp: View {
    @EnvironmentObject var modelData: ModelData
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var text1 = ""
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 420)
                .ignoresSafeArea()
            Spacer()
            VStack {
                VStack {
                    TextField("Username", text: $username)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                    Divider()
                        .padding(.horizontal)
                    Spacer()
                        .frame(height: 10)
                }
                VStack {
                    TextField("Email", text: $email)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                    Divider()
                        .padding(.horizontal)
                    Spacer()
                        .frame(height: 10)
                }
                /*iPhoneNumberField("Phone Number", text: $phone)
                    .maximumDigits(10)
                    .padding(.horizontal)
                Divider()
                    .padding(.horizontal)
                Spacer()
                    .frame(height: 10)*/
                SecureField("Password", text: $password)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                Divider()
                    .padding(.horizontal)
            }
            Text(text1)
            Button("Sign Up") {
                if password.count < 8 {
                    text1 = "Password must be at least 8 characters"
                } else {
                    modelData.isLoading = true
                    Task {
                        await modelData.signUp(username: username, password: password, email: email, phone: phone)
                        modelData.isLoading = false
                    }
                }
            }
            .font(.title2)
            .padding()
            .foregroundColor(Color("Yellow"))
            .background(Color("Blue"))
            .clipShape(Capsule())
            Spacer()
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
