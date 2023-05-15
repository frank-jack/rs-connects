//
//  TruePostView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/15/23.
//

import SwiftUI

struct TruePostView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentationMode
    @State var post: Post
    @State private var comments = [Post]()
    @State private var editingText = ""
    @State private var showDeleteAlert = false
    @State private var text = ""
    var body: some View {
        VStack {
            RefreshableScrollView {
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
                            .alert("Delete Post", isPresented: $showDeleteAlert, actions: {
                                Button("Delete", role: .destructive, action: {
                                    modelData.deletePostData(post: post)
                                    for i in modelData.posts {
                                        if i.groupId == post.id {
                                            modelData.deletePostData(post: i)
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                })
                            }, message: {
                                Text("Are you sure you want to delete this post?")
                            })
                        } else {
                            Button {
                                modelData.isEditing = ""
                                modelData.putPostData(post: Post(id: post.id, userId: post.userId, text: editingText, groupId: post.groupId, image: post.image, date: post.date, likes: post.likes))
                                post.text = editingText
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
                            .multilineTextAlignment(.leading)
                        Image("Test")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        TextField(post.text, text: $editingText, axis: .vertical)
                        Image("Test")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    Divider()
                }
                .padding(.vertical, -20)
                ForEach(comments, id: \.self) { comment in
                    CommentView(post: comment)
                }
                Spacer()
            }
            .refreshable {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    modelData.getPostData()
                } catch {}
            }
            Divider()
                .frame(height: 3)
            if modelData.isEditing.count == 0 {
                HStack {
                    TextField("Comment on this post...", text: $text, axis: .vertical)
                    Spacer()
                    Button {
                        let date = Date()
                        let df = DateFormatter()
                        df.dateStyle = DateFormatter.Style.short
                        df.timeStyle = DateFormatter.Style.medium
                        modelData.postPostData(post: Post(id: UUID().uuidString, userId: modelData.profile.id, text: text, groupId: post.id, image: "", date: df.string(from: date), likes: []))
                        text = ""
                    } label: {
                        Label("", systemImage: "arrow.up.circle.fill")
                            .font(.title)
                    }
                }
            }
        }
        .onAppear {
            let df = DateFormatter()
            df.dateStyle = DateFormatter.Style.short
            df.timeStyle = DateFormatter.Style.medium
            var temp = [Post]()
            for i in modelData.posts {
                if i.groupId == post.id {
                    temp.append(i)
                }
            }
            comments = temp.sorted {df.date(from: $0.date)! > df.date(from: $1.date)!}
        }
        .onChange(of: modelData.posts) { newValue in
            let df = DateFormatter()
            df.dateStyle = DateFormatter.Style.short
            df.timeStyle = DateFormatter.Style.medium
            var temp = [Post]()
            for i in modelData.posts {
                if i.groupId == post.id {
                    temp.append(i)
                }
            }
            comments = temp.sorted {df.date(from: $0.date)! > df.date(from: $1.date)!}
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
