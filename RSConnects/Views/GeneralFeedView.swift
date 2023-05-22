//
//  GeneralFeedView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/10/23.
//

import SwiftUI
import PhotosUI

struct GeneralFeedView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var localPosts = [Post]()
    @State private var text = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var image = UIImage(imageLiteralResourceName: "Empty")
    @FocusState private var isFocused: Bool
    @State var searchText = ""
    var searchResults: [Post] {
        if searchText.isEmpty {
            return localPosts
        } else {
            return localPosts.filter { $0.text.contains(searchText) }
        }
    }
    var body: some View {
        NavigationStack {
            VStack {
                RefreshableScrollView {
                    ForEach(localPosts, id: \.self) { post in
                        if searchResults.contains(post) {
                            PostView(post: post)
                        }
                    }
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
                    VStack {
                        HStack {
                            TextField("Post in General...", text: $text, axis: .vertical)
                                .focused($isFocused)
                            Spacer()
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                Label("", systemImage: "photo.stack.fill")
                            }
                            .onChange(of: selectedItem) { newItem in
                                Task {
                                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                        image = UIImage(data: data) ?? UIImage(imageLiteralResourceName: "Empty")
                                    }
                                }
                            }
                            Button {
                                let date = Date()
                                let df = DateFormatter()
                                df.dateStyle = DateFormatter.Style.short
                                df.timeStyle = DateFormatter.Style.medium
                                modelData.postPostData(post: Post(id: UUID().uuidString, userId: modelData.profile.id, text: text, groupId: "", image: image, date: df.string(from: date), likes: []))
                                text = ""
                                image = UIImage(imageLiteralResourceName: "Empty")
                                isFocused = false
                            } label: {
                                Label("", systemImage: "arrow.up.circle.fill")
                                    .font(.title)
                            }
                        }
                        if image != UIImage(imageLiteralResourceName: "Empty") {
                            Divider()
                                .frame(height: 3)
                            Button {
                                image = UIImage(imageLiteralResourceName: "Empty")
                            } label: {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            }
                        }
                    }
                }
            }
            .onAppear() {
                let df = DateFormatter()
                df.dateStyle = DateFormatter.Style.short
                df.timeStyle = DateFormatter.Style.medium
                var temp = [Post]()
                for i in modelData.posts {
                    if i.groupId == "" {
                        temp.append(i)
                    }
                }
                localPosts = temp.sorted {df.date(from: $0.date)! > df.date(from: $1.date)!}
            }
            .onChange(of: modelData.posts) { newValue in
                let df = DateFormatter()
                df.dateStyle = DateFormatter.Style.short
                df.timeStyle = DateFormatter.Style.medium
                var temp = [Post]()
                for i in modelData.posts {
                    if i.groupId == "" {
                        temp.append(i)
                    }
                }
                localPosts = temp.sorted {df.date(from: $0.date)! > df.date(from: $1.date)!}
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search in General...")
    }
}

