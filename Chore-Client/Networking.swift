//
//  Networking.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/12/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation
import KeychainSwift


enum Route {
    
    case loginUser(email: String, password: String)
    case logoutUser
    case createUser(firstName: String, lastName: String, email: String, password: String, confirmation: String, username: String)
    case getUserGroups
    case createGroup(name: String)
    case createChore(name: String, due_date: String, penalty: String, reward: String, id: Int)
    case getGroupChores(chore_type: String, id: Int)
    case getUserChores
    case getGroupRequests
    case getChoreRequests
    case getUser(username: String)
    case sendGroupRequest(receiver_id: Int, group_id: Int, group_name: String)
    case requestResponse(response: Bool, group_id: Int, request_id: Int)
    case takeChore(group_id: Int, chore_id: Int, user_id: Int)
    case sendChoreCompletionRequest(chore_id: Int)
    
    func method() -> String {
        switch self {
        case .loginUser, .createUser, .createGroup, .createChore, .sendGroupRequest, .sendChoreCompletionRequest:
            return "POST"
        case .getUserGroups, .getGroupChores, .getUserChores, .getGroupRequests, .getUser, .getChoreRequests:
            return "GET"
        case .logoutUser:
            return "DELETE"
        case .requestResponse, .takeChore:
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
        case .getUserChores:
            return "chores/user"
        case .sendGroupRequest:
            return "requests"
        case  .getGroupRequests:
            return "fetch_group_requests"
        case .getChoreRequests:
            return "fetch_chore_completion_requests"
        case .sendChoreCompletionRequest:
            return "chore_completion_request"
        case let .requestResponse(_, _, request_id):
            return "requests/\(request_id)"
        case let .takeChore(group_id, chore_id, _):
            return "groups/\(group_id)/chores/\(chore_id)"
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
        case let .requestResponse(response, group_id, _):
            let body: [String: Any] = ["response": response, "group_id": group_id]
            let result = try! JSONSerialization.data(withJSONObject: body, options: [])
            return result
        case let .sendGroupRequest(receiver_id, group_id, group_name):
            
            let body: [String: Any] = ["reciever_id": receiver_id, "group_id": group_id, "group_name": group_name, "request_type": 0]
            let result = try! JSONSerialization.data(withJSONObject: body, options: [])
            return result
        case let .sendChoreCompletionRequest(chore_id):
            let body: [String: Int] = ["chore_id": chore_id, "request_type": 1]
            let result = try! JSONSerialization.data(withJSONObject: body, options: [])
            return result
        case let .takeChore(_, _, user_id):
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
        case let .getUser(username):
            return ["username": username]
        default:
            return [:]
        }
    }
    
    func headers() -> [String: String] {
        switch self {
        case .loginUser:
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
    //    let baseURL = "http://127.0.0.1:5000/"
    
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
