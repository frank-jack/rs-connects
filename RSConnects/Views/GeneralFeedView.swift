//
//  GeneralFeedView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/10/23.
//

import SwiftUI

struct GeneralFeedView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var text = ""
    var body: some View {
        VStack {
            ScrollView {
                ForEach(modelData.posts, id: \.self) { post in
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
    }
}

