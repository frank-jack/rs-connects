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
    @State private var selection: Tab = .feed
    enum Tab {
        case feed
        case groups
        case users
        case calendar
        case profile
    }
    var body: some View {
        if modelData.isLoading {
            LoadingView()
        } else {
            VStack {
                if modelData.showApp {
                    VStack {
                        TabView(selection: $selection) {
                            UsersView()
                                .tabItem {
                                    Label("Users", systemImage: "magnifyingglass")
                                }
                                .tag(Tab.users)
                            GroupsView()
                                .tabItem {
                                    Label("Groups", systemImage: "list.bullet")
                                }
                                .tag(Tab.groups)
                            GeneralFeedView()
                                .tabItem {
                                    Label("Feed", systemImage: "chart.bar.fill")
                                }
                                .tag(Tab.feed)
                            CalendarView()
                                .tabItem {
                                    Label("Calendar", systemImage: "calendar")
                                }
                                .tag(Tab.calendar)
                            TabProfileView(profile: modelData.profile)
                                .tabItem {
                                    Label("Profile", systemImage: "person.fill")
                                }
                                .tag(Tab.profile)
                            
                        }
                    }
                } else {
                    NavigationStack {
                        switch modelData.authState {
                        case .signIn:
                            SignIn()
                                .environmentObject(modelData)
                        case .signUp:
                            SignUp()
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
            }
            .onAppear() {
                modelData.setUpUser()
            }
        }
    }
}

