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
    var body: some View {
        VStack {
            List {
                ForEach(modelData.groups, id: \.self) { group in
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
}
