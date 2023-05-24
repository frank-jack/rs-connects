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
                if modelData.profile.isAdmin {
                    Section(header: Text("Admin Features")) {
                        NavigationLink(destination: TextView(), label: {Label("Text Congregants", systemImage: "text.bubble")})
                    }
                    Section {
                        Button {
                            Task {
                                await modelData.signOutLocally()
                            }
                        } label: {
                            Label("Sign Out", systemImage: "door.left.hand.open")
                        }
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
                                    Task {
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
