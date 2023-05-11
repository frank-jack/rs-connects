//
//  PostView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/11/23.
//

import SwiftUI

struct PostView: View {
    @EnvironmentObject var modelData: ModelData
    var post: Post
    @State private var isEditing = false
    @State private var editingText = ""
    @State private var showDeleteAlert = false
    var body: some View {
        VStack {
            HStack {
                Text(modelData.users.first(where: {$0.id == post.userId})?.username ?? "Username Error")
                Spacer()
                if modelData.profile.id == post.userId {
                    if !isEditing {
                        Button {
                            isEditing = true
                            editingText = post.text
                        } label: {
                            Label("", systemImage: "pencil")
                                .foregroundColor(.gray)
                        }
                    } else {
                        Button {
                            isEditing = false
                            modelData.putPostData(post: Post(id: post.id, userId: post.userId, text: editingText, groupId: post.groupId, image: post.image))
                        } label: {
                            Label("", systemImage: "checkmark.circle.fill")
                                .font(.title2)
                        }
                    }
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Label("", systemImage: "trash")
                            .foregroundColor(.gray)
                    }
                    .alert("Delete Post", isPresented: $showDeleteAlert, actions: {
                        Button("Delete", role: .destructive, action: {
                            modelData.deletePostData(post: post)
                        })
                    }, message: {
                        Text("Are you sure you want to delete this post?")
                    })
                }
            }
            if !isEditing {
                Text(post.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image("Test")
                    .resizable()
                    .scaledToFit()
            } else {
                TextField(post.text, text: $editingText)
                Image("Test")
                    .resizable()
                    .scaledToFit()
            }
            Divider()
        }
    }
}
