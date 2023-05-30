//
//  Reset.swift
//  RSConnects
//
//  Created by Jack Frank on 5/9/23.
//

import SwiftUI

struct Reset: View {
    @EnvironmentObject var modelData: ModelData
    @State private var username = ""
    @State private var code = ""
    @State private var newPassword = ""
    @State private var showConfirm = false
    @State private var text1 = "Cancel"
    @State private var text2 = ""
    var body: some View {
        VStack{
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 420)
                .ignoresSafeArea()
            Spacer()
            if !showConfirm {
                TextField("Username", text: $username)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                Divider()
                    .padding(.horizontal)
                Spacer()
                Button("Reset Password") {
                    Task {
                        await modelData.resetPassword(username: username)
                    }
                    showConfirm = true
                }
                .font(.title2)
                .padding()
                .foregroundColor(Color("Yellow"))
                .background(Color("Blue"))
                .clipShape(Capsule())
            }
            if showConfirm {
                TextField("Confirmation Code sent to your email", text: $code)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                Divider()
                    .padding(.horizontal)
                Spacer()
                    .frame(height: 10)
                SecureField("New Password", text: $newPassword)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                Divider()
                    .padding(.horizontal)
                Text(text2)
                Button("Confirm New Password") {
                    if newPassword.count < 8 {
                        text2 = "Password must be at least 8 characters"
                    } else {
                        Task {
                            await modelData.confirmResetPassword(username: username, newPassword: newPassword, confirmationCode: code)
                        }
                        modelData.showSignIn()
                    }
                    text1 = "New Password Confirmed"
                }
                .font(.title2)
                .padding()
                .foregroundColor(Color("Yellow"))
                .background(Color("Blue"))
                .clipShape(Capsule())
            }
            Button(text1) {
                modelData.showSignIn()
            }
        }
    }
}

struct Reset_Previews: PreviewProvider {
    static var previews: some View {
        Reset()
    }
}
