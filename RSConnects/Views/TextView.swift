//
//  TextView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/24/23.
//

import SwiftUI

struct TextView: View {
    @EnvironmentObject var modelData: ModelData
    @State var searchText = ""
    var searchResults: [Profile] {
        if searchText.isEmpty {
            return modelData.users
        } else {
            return modelData.users.filter { $0.username.contains(searchText) }
        }
    }
    @State private var allSelected = false
    @State private var selectedUsers = [Profile]()
    @State private var message = ""
    @State private var showConfirmAlert = false
    var body: some View {
        NavigationStack {
            VStack {
                RefreshableScrollView {
                    ForEach(modelData.users, id: \.self) { user in
                        if searchResults.contains(user) {
                            Divider()
                                .frame(width: 3)
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        if self.selectedUsers.contains(user) {
                                            self.selectedUsers.removeAll(where: { $0 == user })
                                        } else {
                                            self.selectedUsers.append(user)
                                        }
                                    }
                                }) {
                                    HStack {
                                        HStack {
                                            Image(uiImage: user.image)
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color("Yellow"), lineWidth: 1)
                                                )
                                                .frame(width: 50, height: 50)
                                            Text(user.username)
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        Image(systemName: "checkmark")
                                            .opacity(self.selectedUsers.contains(user) ? 1.0 : 0.0)
                                    }
                                }
                                .frame(height: 50)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .refreshable {
                    do {
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        modelData.getAllUserData()
                    } catch {}
                }
                .searchable(text: $searchText, placement: .toolbar, prompt: "Search users...")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Toggle("Select All", isOn: $allSelected)
                    }
                }
                .onChange(of: allSelected) { newValue in
                    if allSelected {
                        selectedUsers = modelData.users
                    } else {
                        selectedUsers = [Profile]()
                    }
                }
                Divider()
                    .frame(height: 3)
                HStack {
                    TextField("Write message here...", text: $message, axis: .vertical)
                    Spacer()
                    Button {
                        showConfirmAlert = true
                    } label: {
                        Label("", systemImage: "paperplane.circle.fill")
                            .font(.title)
                    }
                    .alert("Send Message", isPresented: $showConfirmAlert, actions: {
                        Button("Cancel") {
                            showConfirmAlert = false
                        }
                        if selectedUsers.count > 0 && message.count > 0 {
                            Button("Confirm") {
                                var tokens = [String]()
                                for i in selectedUsers {
                                    tokens.append(i.token)
                                }
                                let params = ["tokens": tokens.description, "message": message] as! Dictionary<String, String>
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
                                selectedUsers = [Profile]()
                                message = ""
                            }
                        }
                    }, message: {
                        if selectedUsers.count == 0 {
                            Text("No congregants are selected...")
                        } else if message.count == 0 {
                            Text("No message has been written...")
                        } else {
                            Text("Are you sure you want to send this message as a push notification to these congregants?")
                        }
                    })
                }
            }
        }
        .navigationTitle("Message Congregants")
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView()
    }
}
