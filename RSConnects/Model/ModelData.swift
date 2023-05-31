//
//  ModelData.swift
//  RSConnects
//
//  Created by Jack Frank on 5/8/23.
//

import Foundation
import Amplify
import AWSCognitoAuthPlugin
import UIKit

enum AuthState {
    case signUp
    case signIn
    case session(user: AuthUser)
    case reset
}

final class ModelData: ObservableObject {
    @Published var profile = Profile.default
    @Published var groups = [Group]()
    @Published var posts = [Post]()
    @Published var users = [Profile]()
    @Published var showApp = false
    @Published var isEditing = ""
    @Published var isLoading = false
    init() {
        getPostData()
        getGroupData()
        getAllUserData()
    }
    
    func getImage(imageKey: String) async -> UIImage {
        let downloadTask = Amplify.Storage.downloadData(key: imageKey)
        for await progress in await downloadTask.progress {
            print("Progress: \(progress)")
        }
        do {
            let data = try await downloadTask.value
            print("Completed: \(data)")
            return UIImage(data: data) ?? UIImage(imageLiteralResourceName: "Empty")
        } catch {
            print("very bad")
            return UIImage(imageLiteralResourceName: "Empty")
        }
    }
    
    func putImage(image: UIImage, imageKey: String) {
        Task {
            do {
                let removedKey = try await Amplify.Storage.remove(key: imageKey)
                print("Deleted \(removedKey)")
            } catch {}
            let imageData = image.jpegData(compressionQuality: 0.1)!
            let uploadTask = Amplify.Storage.uploadData(
                key: imageKey,
                data: imageData
            )
            Task {
                for await progress in await uploadTask.progress {
                    print("Progress: \(progress)")
                }
            }
            do {
                let value = try await uploadTask.value
                print("Completed: \(value)")
            } catch {}
        }
    }
    
    func postImage(image: UIImage, imageKey: String) {
        Task {
            let imageData = image.jpegData(compressionQuality: 0.1)!
            let uploadTask = Amplify.Storage.uploadData(
                key: imageKey,
                data: imageData
            )
            Task {
                for await progress in await uploadTask.progress {
                    print("Progress: \(progress)")
                }
            }
            do {
                let value = try await uploadTask.value
                print("Completed: \(value)")
            } catch {}
        }
    }
    
    func deleteImage(imageKey: String) {
        Task {
            do {
                let removedKey = try await Amplify.Storage.remove(key: imageKey)
                print("Deleted \(removedKey)")
            } catch {}
        }
    }
    
    //Post Data
    func getPostData() {
        self.posts = [Post]()
        var getRequest = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/postData")!)
        getRequest.httpMethod = "GET"
        getRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let getSession = URLSession.shared
        let getTask = getSession.dataTask(with: getRequest, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print("json start")
                print(json)
                print("json end")
                if let jsonArray = json["Items"] as? [[String:Any]] {
                    for i in jsonArray {
                        DispatchQueue.main.async { [self] in
                            Task {
                                self.posts.append(Post(id: i["id"] as! String, userId: i["userId"] as! String, text: i["text"] as! String, groupId: i["groupId"] as! String, image: await getImage(imageKey: i["id"] as! String), date: i["date"] as! String, likes: i["likes"] as! [String]))
                            }
                        }
                    }
                }
            } catch {
                print("error")
            }
        })
        getTask.resume()
    }
    func postPostData(post: Post) {
        let params = ["id": post.id, "userId": post.userId, "text": post.text, "groupId": post.groupId, "date": post.date, "likes": post.likes.description] as! Dictionary<String, String>
        var request = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/postData")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                DispatchQueue.main.async { [self] in
                    self.posts.append(Post(id: post.id, userId: post.userId, text: post.text, groupId: post.groupId, image: post.image, date: post.date, likes: post.likes))
                    self.postImage(image: post.image, imageKey: post.id)
                }
            } catch {
                print("error")
            }
        })
        task.resume()
    }
    func putPostData(post: Post) {
        let params = ["id": post.id, "userId": post.userId, "text": post.text, "groupId": post.groupId, "date": post.date, "likes": post.likes.description] as! Dictionary<String, String>
        var request = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/postData")!)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                DispatchQueue.main.async { [self] in
                    if let i = self.posts.firstIndex(where: {$0.id == post.id}) {
                        posts[i] = Post(id: post.id, userId: post.userId, text: post.text, groupId: post.groupId, image: post.image, date: post.date, likes: post.likes)
                        self.putImage(image: post.image, imageKey: post.id)
                    }
                }
            } catch {
                print("error")
            }
        })
        task.resume()
    }
    func deletePostData(post: Post) {
        let params = ["id": post.id, "userId": post.userId, "text": post.text, "groupId": post.groupId, "date": post.date, "likes": post.likes.description] as! Dictionary<String, String>
        var request = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/postData")!)
        request.httpMethod = "DELETE"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                DispatchQueue.main.async { [self] in
                    if let i = self.posts.firstIndex(where: {$0.id == post.id}) {
                        posts.remove(at: i)
                    }
                    deleteImage(imageKey: post.id)
                }
            } catch {
                print("error")
            }
        })
        task.resume()
    }
    
    //Group Data
    func getGroupData() {
        self.groups = [Group]()
        var getRequest = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/groupData")!)
        getRequest.httpMethod = "GET"
        getRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let getSession = URLSession.shared
        let getTask = getSession.dataTask(with: getRequest, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print("json start")
                print(json)
                print("json end")
                if let jsonArray = json["Items"] as? [[String:Any]] {
                    for i in jsonArray {
                        DispatchQueue.main.async { [self] in
                            Task {
                                self.groups.append(Group(id: i["id"] as! String, name: i["name"] as! String, type: i["type"] as! String, image: await getImage(imageKey: i["id"] as! String)))
                            }
                        }
                    }
                }
            } catch {
                print("error")
            }
        })
        getTask.resume()
    }
    func postGroupData(group: Group) {
        let params = ["id": group.id, "type": group.type, "name": group.name] as! Dictionary<String, String>
        var request = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/groupData")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                DispatchQueue.main.async { [self] in
                    self.groups.append(Group(id: group.id, name: group.name, type: group.type, image: group.image))
                    self.postImage(image: group.image, imageKey: group.id)
                }
            } catch {
                print("error")
            }
        })
        task.resume()
    }
    func putGroupData(group: Group) {
        let params = ["id": group.id, "type": group.type, "name": group.name] as! Dictionary<String, String>
        var request = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/groupData")!)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                DispatchQueue.main.async { [self] in
                    if let i = self.groups.firstIndex(where: {$0.id == group.id}) {
                        groups[i] = Group(id: group.id, name: group.name, type: group.type, image: group.image)
                        self.putImage(image: group.image, imageKey: group.id)
                    }
                }
            } catch {
                print("error")
            }
        })
        task.resume()
    }
    func deleteGroupData(group: Group) {
        let params = ["id": group.id, "group": group.type, "name": group.name] as! Dictionary<String, String>
        var request = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/groupData")!)
        request.httpMethod = "DELETE"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                DispatchQueue.main.async { [self] in
                    if let i = self.groups.firstIndex(where: {$0.id == group.id}) {
                        groups.remove(at: i)
                    }
                    deleteImage(imageKey: group.id)
                }
            } catch {
                print("error")
            }
        })
        task.resume()
    }
    
    //User Data
    func getAllUserData() {
        self.users = [Profile]()
        var getRequest = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/userData")!)
        getRequest.httpMethod = "GET"
        getRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let getSession = URLSession.shared
        let getTask = getSession.dataTask(with: getRequest, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print("json start")
                print(json)
                print("json end")
                if let jsonArray = json["Items"] as? [[String:Any]] {
                    for i in jsonArray {
                        DispatchQueue.main.async { [self] in
                            Task {
                                var isAdmin = false
                                if i["isAdmin"] as! String == "true" {
                                    isAdmin = true
                                }
                                self.users.append(Profile(id: i["id"] as! String, email: i["email"] as! String, phone: i["phone"] as! String, username: i["username"] as! String, image: await getImage(imageKey: i["id"] as! String), isAdmin: isAdmin, token: i["token"] as! String))
                            }
                        }
                    }
                }
            } catch {
                print("error")
            }
        })
        getTask.resume()
    }
    func getUserData(id: String) {
        var getRequest = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/userData?"+id)!)
        getRequest.httpMethod = "GET"
        getRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let getSession = URLSession.shared
        let getTask = getSession.dataTask(with: getRequest, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print("json start")
                print(json)
                print("json end")
                DispatchQueue.main.async { [self] in
                    Task {
                        var email = ""
                        var phone = ""
                        var username = ""
                        var isAdmin = false
                        if let jsonArray = json["Items"] as? [[String:Any]],
                           let items = jsonArray.first {
                            email = items["email"] as! String
                        }
                        if let jsonArray = json["Items"] as? [[String:Any]],
                           let items = jsonArray.first {
                            phone = items["phone"] as! String
                        }
                        if let jsonArray = json["Items"] as? [[String:Any]],
                           let items = jsonArray.first {
                            username = items["username"] as! String
                        }
                        if let jsonArray = json["Items"] as? [[String:Any]],
                           let items = jsonArray.first {
                            let temp = items["isAdmin"] as! String
                            if temp == "true" {
                                isAdmin = true
                            }
                        }
                        self.profile = Profile(id: id, email: email, phone: phone, username: username, image: await getImage(imageKey: id), isAdmin: isAdmin, token: mainToken)
                    }
                }
            } catch {
                print("error")
            }
        })
        getTask.resume()
    }
    func postUserData(profile: Profile) {
        let params = ["id": profile.id, "email": profile.email, "phone": profile.phone, "username": profile.username, "isAdmin": String(profile.isAdmin), "token": profile.token] as! Dictionary<String, String>
        var request = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/userData")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                DispatchQueue.main.async { [self] in
                    self.users.append(Profile(id: profile.id, email: profile.email, phone: profile.phone, username: profile.username, image: profile.image, isAdmin: profile.isAdmin, token: profile.token))
                    self.postImage(image: profile.image, imageKey: profile.id)
                }
            } catch {
                print("error")
            }
        })
        task.resume()
        getUserData(id: profile.id)
    }
    func putUserData(profile: Profile) {
        let params = ["id": profile.id, "email": profile.email, "phone": profile.phone, "username": profile.username, "isAdmin": String(profile.isAdmin), "token": profile.token] as! Dictionary<String, String>
        var request = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/userData")!)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                DispatchQueue.main.async { [self] in
                    if let i = self.users.firstIndex(where: {$0.id == profile.id}) {
                        users[i] = Profile(id: profile.id, email: profile.email, phone: profile.phone, username: profile.username, image: profile.image, isAdmin: profile.isAdmin, token: profile.token)
                        self.putImage(image: profile.image, imageKey: profile.id)
                        if users[i].id == self.profile.id {
                            self.profile = users[i]
                        }
                    }
                }
            } catch {
                print("error")
            }
        })
        task.resume()
    }
    func deleteUserData(profile: Profile) {
        let params = ["id": profile.id, "email": profile.email, "phone": profile.phone, "username": profile.username, "isAdmin": String(profile.isAdmin), "token": profile.token] as! Dictionary<String, String>
        var request = URLRequest(url: URL(string: "https://lwo4s4n9a3.execute-api.us-east-1.amazonaws.com/dev/userData")!)
        request.httpMethod = "DELETE"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                DispatchQueue.main.async { [self] in
                    if let i = self.users.firstIndex(where: {$0.id == profile.id}) {
                        users.remove(at: i)
                    }
                    deleteImage(imageKey: profile.id)
                }
            } catch {
                print("error")
            }
        })
        task.resume()
    }
    
    //Auth Stuff
    @Published var authState: AuthState = .signIn
    func getCurrentAuthUser() async {
        do {
            let user = try await Amplify.Auth.getCurrentUser()
            authState = .session(user: user)
        } catch {
            authState = .signIn
        }
    }
    func showSignUp() {
        authState = .signUp
    }
    func showSignIn() {
        authState = .signIn
    }
    func showReset() {
        authState = .reset
    }
    func signUp(username: String, password: String, email: String, phone: String) async {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        do {
            _ = try await Amplify.Auth.signUp(
                username: username,
                password: password,
                options: options
            )
            print("SignUp Complete")
            await signIn(username: username, password: password)
            await postUserData(profile: Profile(id: try Amplify.Auth.getCurrentUser().userId, email: email, phone: phone, username: username, image: UIImage(imageLiteralResourceName: "ProfilePic"), isAdmin: false, token: mainToken))
        } catch let error as AuthError {
            print("An error occurred while registering a user \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func signIn(username: String, password: String) async {
        do {
            let signInResult = try await Amplify.Auth.signIn(
                username: username,
                password: password
                )
            if signInResult.isSignedIn {
                print("Sign in succeeded")
                await getUserData(id: try Amplify.Auth.getCurrentUser().userId)
            }
        } catch let error as AuthError {
            print("Sign in failed \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
        setUpUser()
    }
    
    func signOutLocally() async {
        let result = await Amplify.Auth.signOut()
        guard let signOutResult = result as? AWSCognitoSignOutResult
        else {
            print("Signout failed")
            return
        }
        print("Local signout successful: \(signOutResult.signedOutLocally)")
        switch signOutResult {
        case .complete:
            // Sign Out completed fully and without errors.
            print("Signed out successfully")

        case /*let*/ .partial(/*revokeTokenError, globalSignOutError, hostedUIError*/_,_,_): break
            // Sign Out completed with some errors. User is signed out of the device.
            
            /*if let hostedUIError = hostedUIError {
                print("HostedUI error  \(String(describing: hostedUIError))
            }

            if let globalSignOutError = globalSignOutError {
                // Optional: Use escape hatch to retry revocation of globalSignOutError.accessToken.
                print("GlobalSignOut error  \(String(describing: globalSignOutError))
            }

            if let revokeTokenError = revokeTokenError {
                // Optional: Use escape hatch to retry revocation of revokeTokenError.accessToken.
                print("Revoke token error  \(String(describing: revokeTokenError))
            }*/

        case .failed(let error):
            // Sign Out failed with an exception, leaving the user signed in.
            print("SignOut failed with \(error)")
        }
        setUpUser()
    }
    func signOutGlobally() async {
        let result = await Amplify.Auth.signOut(options: .init(globalSignOut: true))
        guard let signOutResult = result as? AWSCognitoSignOutResult
        else {
            print("Signout failed")
            return
        }
        showApp = false
        print("Local signout successful: \(signOutResult.signedOutLocally)")
        /*switch signOutResult {
        case .complete:
            // handle successful sign out
        case .failed(let error):
            // handle failed sign out
        case let .partial(revokeTokenError, globalSignOutError, hostedUIError):
            // handle partial sign out
        }*/
        setUpUser()
    }
    func resetPassword(username: String) async {
        do {
            let resetResult = try await Amplify.Auth.resetPassword(for: username)
            switch resetResult.nextStep {
                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                    print("Confirm reset password with code send to - \(deliveryDetails) \(String(describing: info))")
                case .done:
                    print("Reset completed")
            }
        } catch let error as AuthError {
            print("Reset password failed with error \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    func confirmResetPassword(username: String, newPassword: String, confirmationCode: String) async {
        do {
            try await Amplify.Auth.confirmResetPassword(
                for: username,
                with: newPassword,
                confirmationCode: confirmationCode
            )
            print("Password reset confirmed")
        } catch let error as AuthError {
            print("Reset password failed with error \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    func deleteUser() async {
        do {
            try await Amplify.Auth.deleteUser()
            print("Successfully deleted user")
        } catch let error as AuthError {
            print("Delete user failed with error \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    func setUpUser() {
        Task {
            do {
                let user = try? await Amplify.Auth.getCurrentUser()
                DispatchQueue.main.async { [self] in
                    if user != nil {
                        authState = .session(user: user!)
                        getUserData(id: user!.userId)
                        showApp = true
                    } else {
                        authState = .signIn
                        showApp = false
                    }
                }
            }
        }
    }
}
