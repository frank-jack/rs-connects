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
    @State private var selection: Tab = .general
    enum Tab {
        case general
        case specific
    }
    @State private var showSettings = false
    var body: some View {
        NavigationView {
            if modelData.showApp {
                VStack {
                    TabView(selection: $selection) {
                        GeneralFeedView()
                            .tabItem {
                                Label("Feed", systemImage: "chart.bar.fill")
                            }
                            .tag(Tab.general)
                        SpecificFeedView()
                            .tabItem {
                                Label("Channels", systemImage: "list.bullet")
                            }
                            .tag(Tab.specific)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) { 
                        Button {
                            showSettings.toggle()
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    Settings()
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

