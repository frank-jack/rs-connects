//
//  ProfileView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/11/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var modelData: ModelData
    var profile: Profile
    @State private var localPosts = [Post]()
    @State private var showAdminAlert = false
    @State private var showSettings = false
    var body: some View {
        ZStack {
            if profile.id == modelData.profile.id {
                Text("")
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
                        ProfileSettingsView()
                    }
            }
            VStack {
                Text(profile.username)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                if profile.isAdmin {
                    Text("Admin")
                        .foregroundColor(.blue)
                        .font(.caption)
                } else {
                    if modelData.profile.isAdmin {
                        Button("Make Admin") {
                            showAdminAlert = true
                        }
                        .font(.caption)
                        .alert("Make Admin", isPresented: $showAdminAlert, actions: {
                            Button("Make Admin", role: .destructive, action: {
                                modelData.putUserData(profile: Profile(id: profile.id, email: profile.email, phone: profile.phone, username: profile.username, isAdmin: true))
                            })
                        }, message: {
                            Text("Are you sure you want to make this user an Admin? This will grant the user admin abilties and cannot be undone.")
                        })
                    }
                }
                VStack {
                    ScrollView {
                        Image("Test")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                        Spacer()
                        ForEach(localPosts, id: \.self) { post in
                            PostView(post: post)
                        }
                    }
                    Divider()
                        .frame(width: 3)
                }
                .onAppear() {
                    localPosts = [Post]()
                    for i in modelData.posts {
                        if i.userId == profile.id {
                            localPosts.append(i)
                        }
                    }
                }
                .onChange(of: modelData.posts) {newValue in
                    localPosts = [Post]()
                    for i in modelData.posts {
                        if i.userId == profile.id {
                            localPosts.append(i)
                        }
                    }
                }
            }
        }
    }
}
