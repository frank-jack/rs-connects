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
        NavigationStack {
            VStack {
                RefreshableScrollView {
                    ForEach(modelData.users, id: \.self) { user in
                        if searchResults.contains(user) {
                            Divider()
                                .frame(width: 3)
                            HStack {
                                NavigationLink(destination: ProfileView(profile: user), label: { HStack {
                                    Image(uiImage: user.image)
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color("Yellow"), lineWidth: 1)
                                        )
                                        .frame(width: 50, height: 50)
                                    Text(user.username)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                })
                                .frame(height: 50)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .refreshable {
                    do {
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        modelData.getAllUserData()
                    } catch {}
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search users...")
    }
}
