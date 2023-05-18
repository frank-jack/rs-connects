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
        VStack {
            Button("Sign Out") {
                Task {
                    await modelData.signOutLocally()
                }
            }
            Button("Print Profile") {
                print(modelData.profile)
            }
        }
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView()
    }
}
