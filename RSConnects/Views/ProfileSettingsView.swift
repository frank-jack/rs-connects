//
//  ProfileSettingsView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/11/23.
//

import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var modelData: ModelData
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
                            
                        } label: {
                            Label("Delete Account", systemImage: "trash")
                                .foregroundColor(.red)
                        }
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
