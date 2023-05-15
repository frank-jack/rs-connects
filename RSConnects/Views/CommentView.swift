//
//  CommentView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/15/23.
//

import SwiftUI

struct CommentView: View {
    @EnvironmentObject var modelData: ModelData
    var post: Post
    @State private var editingText = ""
    @State private var showDeleteAlert = false
    var body: some View {
        VStack {
            HStack {
                NavigationLink(destination: ProfileView(profile: modelData.users.first(where: {$0.id == post.userId}) ?? Profile.default), label: { HStack {
                    Image("Test")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 90, height: 90)
                    Text(modelData.users.first(where: {$0.id == post.userId})?.username ?? "Username Error")
                        .foregroundColor(.primary)
                        .padding(.horizontal, -20)
                    }
                })
                .padding(.horizontal, -20)
                Text("•"+howLongAgo(posted: post.date))
                    .font(.body)
                    .padding(.horizontal, 32.5)
                    .foregroundColor(.gray)
                Spacer()
                if modelData.profile.id == post.userId {
                    if modelData.isEditing != post.id{
                        Menu {
                            Button {
                                modelData.isEditing = post.id
                                editingText = post.text
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Label("", systemImage: "ellipsis")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                        .alert("Delete Comment", isPresented: $showDeleteAlert, actions: {
                            Button("Delete", role: .destructive, action: {
                                modelData.deletePostData(post: post)
                            })
                        }, message: {
                            Text("Are you sure you want to delete this comment?")
                        })
                    } else {
                        Button {
                            modelData.isEditing = ""
                            modelData.putPostData(post: Post(id: post.id, userId: post.userId, text: editingText, groupId: post.groupId, image: post.image, date: post.date, likes: post.likes))
                        } label: {
                            Label("", systemImage: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                        Button {
                            modelData.isEditing = ""
                        } label: {
                            Label("", systemImage: "x.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            VStack {
                if modelData.isEditing != post.id {
                    Text(post.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                } else {
                    TextField(post.text, text: $editingText, axis: .vertical)
                        .font(.subheadline)
                }
                Divider()
            }
            .padding(.vertical, -20)
        }
    }
    func howLongAgo(posted: String) -> String {
        let df = DateFormatter()
        df.dateStyle = DateFormatter.Style.short
        df.timeStyle = DateFormatter.Style.medium
        let datePosted = df.date(from: posted)!
        if Calendar.current.dateComponents([.day], from: datePosted, to: Date()).day! > 0 {
            return String(Calendar.current.dateComponents([.day], from: df.date(from: posted)!, to: Date()).day!)+"d"
        }
        if Calendar.current.dateComponents([.hour], from: datePosted, to: Date()).hour! > 0 {
            return String(Calendar.current.dateComponents([.hour], from: df.date(from: posted)!, to: Date()).hour!)+"h"
        }
        if Calendar.current.dateComponents([.minute], from: datePosted, to: Date()).minute! > 0 {
            return String(Calendar.current.dateComponents([.minute], from: df.date(from: posted)!, to: Date()).minute!)+"m"
        }
        if Calendar.current.dateComponents([.second], from: datePosted, to: Date()).second! > 0 {
            return String(Calendar.current.dateComponents([.second], from: df.date(from: posted)!, to: Date()).second!)+"s"
        }
        return "0s"
    }
}