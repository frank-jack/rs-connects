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
                    Image(uiImage: modelData.users.first(where: {$0.id == post.userId})?.image ?? UIImage(imageLiteralResourceName: "ProfilePic"))
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color("Yellow"), lineWidth: 1)
                        )
                        .frame(width: 50, height: 50)
                    Text(modelData.users.first(where: {$0.id == post.userId})?.username ?? "Username Error")
                        .foregroundColor(.primary) +
                    Text(" •"+howLongAgo(posted: post.date))
                        .foregroundColor(.gray)
                    }
                })
                Spacer()
                if modelData.profile.id == post.userId {
                    if modelData.isEditing != post.id {
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
                } else {
                    Menu {
                        if modelData.profile.isAdmin {
                            Button(role: .destructive) {
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        Button(role: .destructive) {
                            var tokens = [String]()
                            for i in modelData.users {
                                if i.isAdmin {
                                    tokens.append(i.token)
                                }
                            }
                            let params = ["tokens": tokens.description, "message": "Comment "+post.id+" has been reported by "+modelData.profile.username+"."] as! Dictionary<String, String>
                            var request = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/texts")!)
                            request.httpMethod = "POST"
                            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
                            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                            let session = URLSession.shared
                            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                                print(response!)
                                do {
                                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                                    print(json)
                                } catch {
                                    print("error")
                                }
                            })
                            task.resume()
                        } label: {
                            Label("Report Comment", systemImage: "exclamationmark.bubble")
                        }
                    } label: {
                        Label("", systemImage: "ellipsis")
                            .foregroundColor(.gray)
                            .font(.title2)
                    }
                    .alert("Delete User's Comment", isPresented: $showDeleteAlert, actions: {
                        Button("Delete", role: .destructive, action: {
                            modelData.deletePostData(post: post)
                            for i in modelData.posts {
                                if i.groupId == post.id {
                                    modelData.deletePostData(post: i)
                                }
                            }
                        })
                    }, message: {
                        Text("Are you sure you want to delete this user's comment? This is an ADMIN ONLY ABILITY that cannot be reversed.")
                    })
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
                HStack {
                    Text(String(post.likes.count))
                        .foregroundColor(.gray)
                    if modelData.profile.id == "" {
                        Button {
                        } label: {
                            Label("", systemImage: "heart")
                                .foregroundColor(.gray)
                        }
                    } else {
                        if !post.likes.contains(modelData.profile.id) {
                            Button {
                                var likes = post.likes
                                likes.append(modelData.profile.id)
                                modelData.putPostData(post: Post(id: post.id, userId: post.userId, text: post.text, groupId: post.groupId, image: post.image, date: post.date, likes: likes))
                            } label: {
                                Label("", systemImage: "heart")
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Button {
                                var likes = post.likes
                                likes.remove(at: likes.firstIndex(where: {$0 == modelData.profile.id})!)
                                modelData.putPostData(post: Post(id: post.id, userId: post.userId, text: post.text, groupId: post.groupId, image: post.image, date: post.date, likes: likes))
                            } label: {
                                Label("", systemImage: "heart.fill")
                                    .foregroundColor(.pink)
                            }
                        }
                    }
                    Spacer()
                }
                Divider()
            }
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
