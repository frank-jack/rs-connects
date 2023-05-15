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
    @State private var temp = [Post]()
    @State private var showAdminAlert = false
    @State private var showSettings = false
    var body: some View {
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
                            modelData.putUserData(profile: Profile(id: profile.id, email: profile.email, phone: profile.phone, username: profile.username, image: profile.image, isAdmin: true))
                        })
                    }, message: {
                        Text("Are you sure you want to make this user an Admin? This will grant the user admin abilties and cannot be undone.")
                    })
                }
            }
            VStack {
                RefreshableScrollView {
                    Image("Test")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                    Spacer()
                    ForEach(localPosts, id: \.self) { post in
                        PostView(post: post)
                    }
                }
                .refreshable {
                    do {
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        modelData.getPostData()
                    } catch {}
                }
                Divider()
                    .frame(width: 3)
            }
            .onAppear() {
                let df = DateFormatter()
                df.dateStyle = DateFormatter.Style.short
                df.timeStyle = DateFormatter.Style.medium
                temp = [Post]()
                for i in modelData.posts {
                    if i.userId == profile.id {
                        temp.append(i)
                    }
                }
                localPosts = temp.sorted {df.date(from: $0.date)! > df.date(from: $1.date)!}
            }
            .onChange(of: modelData.posts) {newValue in
                let df = DateFormatter()
                df.dateStyle = DateFormatter.Style.short
                df.timeStyle = DateFormatter.Style.medium
                temp = [Post]()
                for i in modelData.posts {
                    if i.userId == profile.id {
                        temp.append(i)
                    }
                }
                localPosts = temp.sorted {df.date(from: $0.date)! > df.date(from: $1.date)!}
            }
        }
        .toolbar {
            if profile.id == modelData.profile.id {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            ProfileSettingsView()
        }
    }
}
