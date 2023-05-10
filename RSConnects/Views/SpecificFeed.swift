//
//  SpecificFeed.swift
//  RSConnects
//
//  Created by Jack Frank on 5/10/23.
//

import SwiftUI

struct SpecificFeed: View {
    @EnvironmentObject var modelData: ModelData
    var group: Group
    @State private var localPosts = [Post]()
    @State private var text = ""
    var body: some View {
        VStack {
            ScrollView {
                ForEach(localPosts, id: \.self) { post in
                    VStack {
                        HStack {
                            Text(modelData.users.first(where: {$0.id == post.userId})?.username ?? "Username Error")
                            Spacer()
                        }
                        Text(post.text)
                        Image("Test")
                            .resizable()
                            .scaledToFit()
                        Divider()
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
    }
}
