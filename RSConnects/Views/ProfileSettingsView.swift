//
//  ProfileSettingsView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/11/23.
//

import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var showDeleteConfirm = false
    @State private var deleteText = ""
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Link(destination: URL(string: "https://rodephshalom.org/")!) {
                        Label("Website", systemImage: "link")
                    }
                    Link(destination: URL(string: "https://www.freeprivacypolicy.com/live/3cbc3a03-bc64-4876-ae56-4aef46cc1fc0")!) {
                        Label("Privacy Policy", systemImage: "p.square.fill")
                    }
                }
                if modelData.profile.isAdmin {
                    Section(header: Text("Admin Features")) {
                        NavigationLink(destination: TextView(), label: {Label("Message Congregants", systemImage: "text.bubble")})
                    }
                }
                Section {
                    Button {
                        Task {
                            await modelData.signOutLocally()
                        }
                    } label: {
                        Label("Sign Out", systemImage: "door.left.hand.open")
                    }
                    if modelData.profile.id != "" {
                        Button {
                            showDeleteConfirm = true
                            deleteText = ""
                        } label: {
                            Label("Delete Account", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                        .alert("Delete Account", isPresented: $showDeleteConfirm, actions: {
                            TextField("Type 'delete'...", text: $deleteText)
                            Button(role: .destructive) {
                                if deleteText == "delete" {
                                    modelData.deleteUserData(profile: modelData.profile)
                                    var ids = [String]()
                                    for i in modelData.posts {
                                        if i.userId == modelData.profile.id {
                                            modelData.deletePostData(post: i)
                                            ids.append(i.id)
                                        }
                                    }
                                    for i in modelData.posts {
                                        if ids.contains(i.groupId) {
                                            modelData.deletePostData(post: i)
                                        }
                                    }
                                    Task {
                                        modelData.showApp = false
                                        await modelData.deleteUser()
                                        await modelData.signOutGlobally()
                                    }
                                }
                            } label: {
                                Text("Delete")
                            }
                        }, message: {
                            Text("Type 'delete' to confirm. This action cannot be undone.")
                        })
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView()
    }
}
