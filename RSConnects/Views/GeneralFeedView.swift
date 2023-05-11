//
//  GeneralFeedView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/10/23.
//

import SwiftUI

struct GeneralFeedView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var localPosts = [Post]()
    @State private var text = ""
    @State var searchText = ""
    var searchResults: [Post] {
        if searchText.isEmpty {
            return localPosts
        } else {
            return localPosts.filter { $0.text.contains(searchText) }
        }
    }
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(localPosts, id: \.self) { post in
                        if searchResults.contains(post) {
                            PostView(post: post)
                        }
                    }
                }
                Divider()
                    .frame(height: 3)
                HStack {
                    TextField("Post in General...", text: $text)
                    Spacer()
                    Button {
                        modelData.postPostData(post: Post(id: UUID().uuidString, userId: modelData.profile.id, text: text, groupId: "", image: ""))
                        text = ""
                    } label: {
                        Label("", systemImage: "arrow.up.circle.fill")
                            .font(.title)
                    }
                }
            }
            .onAppear() {
                localPosts = [Post]()
                for i in modelData.posts {
                    localPosts.append(i)
                }
            }
            .onChange(of: modelData.posts) {newValue in
                localPosts = [Post]()
                for i in modelData.posts {
                    localPosts.append(i)
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search in General...")
    }
}

