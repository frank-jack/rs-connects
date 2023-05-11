//
//  SearchView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/11/23.
//

import SwiftUI

struct UsersView: View {
    @EnvironmentObject var modelData: ModelData
    @State var searchText = ""
    var searchResults: [Profile] {
        if searchText.isEmpty {
            return modelData.users
        } else {
            return modelData.users.filter { $0.username.contains(searchText) }
        }
    }
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(modelData.users, id: \.self) { user in
                        if searchResults.contains(user) {
                            Divider()
                                .frame(width: 3)
                            HStack {
                                NavigationLink(destination: ProfileView(profile: user), label: {HStack {
                                    Image("Test")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(Circle())
                                        .frame(width: 90, height: 90)
                                    Text(user.username)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, -20)
                                    Spacer()
                                }
                                })
                                .frame(height: 50)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search users...")
    }
}
