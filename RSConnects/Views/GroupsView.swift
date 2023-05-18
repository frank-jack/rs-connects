//
//  SpecificFeedView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/10/23.
//

import SwiftUI
import PhotosUI

struct GroupsView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var text = ""
    @State private var groupToBeDeleted = Group(id: "", name: "", image: UIImage(imageLiteralResourceName: "Placeholder"))
    @State private var showDeleteAlert = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var image = UIImage(imageLiteralResourceName: "Placeholder")
    @FocusState private var isFocused: Bool
    @State var searchText = ""
    var searchResults: [Group] {
        if searchText.isEmpty {
            return modelData.groups
        } else {
            return modelData.groups.filter { $0.name.contains(searchText) }
        }
    }
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if modelData.profile.isAdmin {
                        ForEach(modelData.groups, id: \.self) { group in
                            if searchResults.contains(group) {
                                HStack {
                                    NavigationLink(group.name) {
                                        SpecificFeedView(group: group)
                                    }
                                    Image(uiImage: group.image)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }
                        .onDelete { indexSet in //RESTRICT THIS TO BE ADMIN ONLY SOMEHOW
                            var temp = modelData.groups
                            temp.remove(atOffsets: indexSet)
                            for i in modelData.groups {
                                if !temp.contains(i) {
                                    groupToBeDeleted = i
                                }
                            }
                            showDeleteAlert = true
                        }
                        .alert("Delete Group", isPresented: $showDeleteAlert, actions: {
                            Button("Delete", role: .destructive, action: {
                                modelData.deleteGroupData(group: groupToBeDeleted)
                                for i in modelData.posts {
                                    if i.groupId == groupToBeDeleted.id {
                                        modelData.putPostData(post: Post(id: i.id, userId: i.userId, text: i.text, groupId: "", image: i.image, date: i.date, likes: i.likes))
                                    }
                                }
                            })
                        }, message: {
                            Text("Are you sure you want to delete this group? This will move all posts in this group into the general channel. This is an ADMIN ONLY ACTION and will affect many users.")
                        })
                    } else {
                        ForEach(modelData.groups, id: \.self) { group in
                            if searchResults.contains(group) {
                                HStack {
                                    NavigationLink(group.name) {
                                        SpecificFeedView(group: group)
                                    }
                                    Image(uiImage: group.image)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    do {
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        modelData.getGroupData()
                    } catch {}
                }
                if modelData.profile.isAdmin {
                    Divider()
                        .frame(height: 3)
                    VStack {
                        HStack {
                            TextField("Add group...", text: $text, axis: .vertical)
                                .focused($isFocused)
                            Spacer()
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                Label("", systemImage: "photo.stack.fill")
                            }
                            .onChange(of: selectedItem) { newItem in
                                Task {
                                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                        image = UIImage(data: data) ?? UIImage(imageLiteralResourceName: "Placeholder")
                                    }
                                }
                            }
                            Button {
                                modelData.postGroupData(group: Group(id: UUID().uuidString, name: text, image: image))
                                text = ""
                                image = UIImage(imageLiteralResourceName: "Placeholder")
                                isFocused = false
                            } label: {
                                Label("", systemImage: "arrow.up.square.fill")
                                    .font(.title)
                            }
                        }
                        if image != UIImage(imageLiteralResourceName: "Placeholder") {
                            Divider()
                                .frame(height: 3)
                            Button {
                                image = UIImage(imageLiteralResourceName: "Placeholder")
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
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search groups...")
    }
}
