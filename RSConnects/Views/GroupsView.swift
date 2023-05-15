//
//  SpecificFeedView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/10/23.
//

import SwiftUI

struct GroupsView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var text = ""
    @State private var groupToBeDeleted = Group(id: "", name: "", image: "")
    @State private var showDeleteAlert = false
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
                    ForEach(modelData.groups, id: \.self) { group in
                        if searchResults.contains(group) {
                            HStack {
                                NavigationLink(group.name) {
                                    SpecificFeedView(group: group)
                                }
                                Image("Test")
                                    .resizable()
                                    .scaledToFit()
                                    //.frame(width: 50, height: 50)
                            }
                        }
                    }
                    .onDelete { indexSet in
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
                                    modelData.putPostData(post: Post(id: i.id, userId: i.userId, text: i.text, groupId: "", image: i.image, date: i.date))
                                }
                            }
                        })
                    }, message: {
                        Text("Are you sure you want to delete this group?\nThis will move all posts in this group into the general channel.\nThis is an ADMIN ONLY ACTION and will affect many users.")
                    })
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
                    HStack {
                        TextField("Add group...", text: $text)
                        Spacer()
                        Button {
                            modelData.postGroupData(group: Group(id: UUID().uuidString, name: text, image: ""))
                            text = ""
                        } label: {
                            Label("", systemImage: "arrow.up.square.fill")
                                .font(.title)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search groups...")
    }
}
