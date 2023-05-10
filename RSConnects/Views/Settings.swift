//
//  Settings.swift
//  RSConnects
//
//  Created by Jack Frank on 5/10/23.
//

import SwiftUI

struct Settings: View {
    @EnvironmentObject var modelData: ModelData
    var body: some View {
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
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
