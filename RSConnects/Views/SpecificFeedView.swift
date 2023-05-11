//
//  SpecificFeed.swift
//  RSConnects
//
//  Created by Jack Frank on 5/10/23.
//

import SwiftUI

struct SpecificFeedView: View {
    @EnvironmentObject var modelData: ModelData
    var group: Group
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
                TextField("Post in "+group.name+"...", text: $text)
                Spacer()
                Button {
                    modelData.postPostData(post: Post(id: UUID().uuidString, userId: modelData.profile.id, text: text, groupId: group.id, image: ""))
                    text = ""
                } label: {
                    Label("", systemImage: "arrow.up.circle.fill")
                        .font(.title)
                }
            }
        }
        .onAppear() {
            for i in modelData.posts {
                if i.groupId == group.id {
                    localPosts.append(i)
                }
            }
        }
        .onChange(of: modelData.posts) {newValue in
            localPosts = [Post]()
            for i in modelData.posts {
                if i.groupId == group.id {
                    localPosts.append(i)
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search in "+group.name+"...")
    }
}
