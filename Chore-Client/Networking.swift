//
//  Networking.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/12/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation
import KeychainSwift
import Alamofire


enum imageUploadRoute {
    case userUpload
    case groupUpload
    
    func fileName()->String {
        let keychain = KeychainSwift()
        switch self {
        case .userUpload:
            let userID = keychain.get("id")
            return "User\(String(describing: userID!))Profile"
        case .groupUpload:
            let groupID = keychain.get("groupID")
            return "Group\(String(describing: groupID!))Profile"
        }
    }
    
    func Path()-> String {
        let keychain = KeychainSwift()
        switch self {
        case .userUpload:
            return "sessions"
        case .groupUpload:
            let groupID = keychain.get("groupID")
            return "groups/\(groupID!)"
        }
    }
    
    func Headers()-> [String: String] {
        let keychain = KeychainSwift()
        let token = keychain.get("token")
        let email = keychain.get("email")
        return ["x-User-Token": "\(token!)",
            "x-User-Email": email!]
    }
    
}

enum Route {
    
    case loginUser(email: String, password: String)
    case logoutUser
    case createUser(firstName: String, lastName: String, email: String, password: String, confirmation: String, username: String)
    case getUserGroups
    case createGroup(name: String)
    case createChore(name: String, due_date: String, penalty: String, reward: String, id: Int)
    case getGroupChores(chore_type: String, id: Int)
    case getCompletedGroupChores(chore_type: String, id: Int)
    case getUserChores
    case getUserCompletedChores
    case getGroupRequests
    case getChoreRequests(group_id: Int)
    case getUser(username: String)
    case sendGroupRequest(receiver_id: Int, group_id: Int, group_name: String)
    case groupRequestResponse(response: Bool, group_id: Int, request_id: Int)
    case takeChore(group_id: Int, chore_id: Int, user_id: Int)
    case sendChoreCompletionRequest(chore_id: Int)
    case choreRequestResponse(response: Bool, chore_id: Int, uuid: String, request_id: Int)
    case removeMember(group_id: Int, user_id: Int)
    
    func method() -> String {
        switch self {
        case .loginUser, .createUser, .createGroup, .createChore, .sendGroupRequest, .sendChoreCompletionRequest:
            return "POST"
        case .getUserGroups, .getGroupChores, .getUserChores, .getUserCompletedChores, .getGroupRequests, .getUser, .getChoreRequests, .getCompletedGroupChores:
            return "GET"
        case .logoutUser:
            return "DELETE"
        case .groupRequestResponse, .takeChore, .choreRequestResponse, .removeMember:
            return "PATCH"
        
        }
    }
    
    func path() -> String {
        switch self {
        case .loginUser, .logoutUser, .getUser:
            return "sessions"
        case .getUserGroups, .createGroup:
            return "groups"
        case .createUser:
            return "new_account"
        case let .createChore(_, _, _, _, id):
            return "groups/\(id)/chores"
        case let .getGroupChores(_, id):
            return "groups/\(id)/chores"
        case let .getCompletedGroupChores(_, id):
            return "groups/\(id)/completed_chores"
        case .getUserChores:
            return "chores/user"
        case .getUserCompletedChores:
            return "completed_chores/user"
        case .sendGroupRequest:
            return "requests"
        case  .getGroupRequests:
            return "fetch_group_requests"
        case .getChoreRequests:
            return "fetch_chore_completion_requests"
        case .sendChoreCompletionRequest:
            return "chore_completion_request"
        case let .groupRequestResponse(_, _, request_id):
            return "requests/\(request_id)"
        case let .takeChore(group_id, chore_id, _):
            return "groups/\(group_id)/chores/\(chore_id)"
        case let .choreRequestResponse(_, _, _, request_id):
            return "requests/\(request_id)"
        case let .removeMember(group_id, _):
            return "groups/\(group_id)/user/"
        }
    }
    
    func body() -> Data? {
        switch self {
        case let .loginUser(email, password):
            let encoder = JSONEncoder()
            let body: [String: String] = ["email": email, "password": password]
            let result = try? encoder.encode(body)
            return result!
        
        case let .createUser(firstName, lastName, email, password, confirmation, username):
            let encoder = JSONEncoder()
            let body: [String: String] = ["first_name": firstName, "last_name": lastName, "email": email, "password": password, "confirmation": confirmation, "username": username]
            let result = try? encoder.encode(body)
            return result!
            
        case let .createGroup(name):
            let encoder = JSONEncoder()
            let body: [String: String] = ["name": name]
            let result = try? encoder.encode(body)
            return result!
        
        case let .createChore(name, due_date, penalty, reward, _):
            let encoder = JSONEncoder()
            let body: [String: String] = ["name": name, "due_date": due_date, "penalty": penalty, "reward": reward]
            let result = try? encoder.encode(body)
            return result!
        case let .groupRequestResponse(response, group_id, _):
            let body: [String: Any] = ["response": response, "group_id": group_id]
            let result = try! JSONSerialization.data(withJSONObject: body, options: [])
            return result
        case let .sendGroupRequest(receiver_id, group_id, group_name):
            
            let body: [String: Any] = ["reciever_id": receiver_id, "group_id": group_id, "group_name": group_name, "request_type": 0]
            let result = try! JSONSerialization.data(withJSONObject: body, options: [])
            return result
        case let .sendChoreCompletionRequest(chore_id):
            let body: [String: Int] = ["chore_id": chore_id, "request_type": 3]
            let result = try! JSONSerialization.data(withJSONObject: body, options: [])
            return result
        case let .takeChore(_, _, user_id):
            let body: [String: Int] = ["user_id": user_id]
            let result = try! JSONSerialization.data(withJSONObject: body, options: [])
            return result
        case let .choreRequestResponse(response, chore_id, uuid, _):
            let body: [String: Any] = ["response": response, "chore_id": chore_id, "request_type": 3, "uuid": uuid]
            let result = try! JSONSerialization.data(withJSONObject: body, options: [])
            return result
        case let .removeMember(_, user_id):
            let body: [String: Int] = ["user_id": user_id]
            let result = try! JSONSerialization.data(withJSONObject: body, options: [])
            return result
        default:
            return nil
        }
        
    }
    
    func Parameters() -> [String: String] {
        switch self {
        case let .getGroupChores(chore_type, _):
            return ["chore_type": chore_type]
        case let .getCompletedGroupChores(chore_type, _):
            return ["chore_type": chore_type]
        case let .getUser(username):
            return ["username": username]
        case let .getChoreRequests(group_id):
            return ["group_id": String(group_id)]
        default:
            return [:]
        }
    }
    
    func headers() -> [String: String] {
        switch self {
        case .loginUser, .createUser:
            return ["Content-Type": "application/json"]
       
        default:
            let keychain = KeychainSwift()
            let token = keychain.get("token")
            let email = keychain.get("email")
            return ["Content-Type": "application/json",
                    "x-User-Token": "\(token!)",
                    "x-User-Email": email!]
        }
        
    }
    
}

class Network {
    static let instance = Network()
    
    let baseURL = "http://0.0.0.0:3000/v1/"
//    let baseURL = "https://chores-server.herokuapp.com/v1/"
    
    let session = URLSession.shared
    
    func fetch(route: Route, completion: @escaping (Data) -> Void) {
        let fullPath = baseURL + route.path()
        
        let pathURL = URL(string: fullPath)
        let fullPathURL = pathURL?.appendingQueryParameters(route.Parameters())
        var request = URLRequest(url: fullPathURL!)
        request.httpMethod = route.method()
        request.allHTTPHeaderFields = route.headers()
        request.httpBody = route.body()
        
        session.dataTask(with: request) { (data, resp, err) in
            
            if let data = data {
                completion(data)
            }
            
            }.resume()
    }
    
    func imageUpload(route: imageUploadRoute, imageData: Data) {
        let name = "image_file"
        let fileName = route.fileName()
        let fullPath = baseURL + route.Path()
        let fullURL = URL(string: fullPath)
        let headers = route.Headers()
        Alamofire.upload(multipartFormData: { (multiPartFormData) in
            
            multiPartFormData.append(imageData, withName: name, fileName: fileName, mimeType: "image/png")
            
        }, usingThreshold: UInt64.init(), to: fullURL!, method: .patch, headers: headers, encodingCompletion: { (result) in
            switch result{
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                })
                
                upload.responseJSON { response in
                    print(response.description)
                }
                
            case .failure(let encodingError):
                print(encodingError.localizedDescription)
            }
            
        })
    }
    
}



extension URL {
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        //
        return URL(string: URLString)!
    }
    // This is formatting the query parameters with an ascii table reference therefore we can be returned a json file
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
