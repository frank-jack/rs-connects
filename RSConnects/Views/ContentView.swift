//
//  ContentView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/8/23.
//

import SwiftUI
import Amplify

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    var body: some View {
        NavigationView {
            if modelData.showApp {
                VStack {
                    Button("Sign Out") {
                        Task {
                            await modelData.signOutLocally()
                        }
                    }
                    Button("check") {
                        print(modelData.profile)
                    }
                }
            } else {
                switch modelData.authState {
                case .signIn:
                    SignIn()
                        .environmentObject(modelData)
                case .signUp:
                    SignUp()
                        .environmentObject(modelData)
                case .confirmCode(let email, let username, let password):
                    Confirm(email: email, username: username, password: password)
                        .environmentObject(modelData)
                case .reset:
                    Reset()
                        .environmentObject(modelData)
                case .session(let user):
                    Session(user: user)
                        .environmentObject(modelData)
                }
            }
        }
        .onAppear() {
            modelData.setUpUser()
        }
    }
}

