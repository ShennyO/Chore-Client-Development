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
    case createUser(firstName: String, lastName: String, email: String, password: String, username: String)
    case getUserGroups
    case createGroup(name: String)
    case createChore(name: String, due_date: String, penalty: String, reward: String, id: Int)
    case getChores(chore_type: String, id: Int)
    
    func method() -> String {
        switch self {
        case .loginUser, .createUser, .createGroup, .createChore:
            return "POST"
        case .getUserGroups, .getChores:
            return "GET"
        case .logoutUser:
            return "DELETE"
        }
    }
    
    func path() -> String {
        switch self {
        case .loginUser, .logoutUser:
            return "sessions"
        case .getUserGroups, .createGroup:
            return "groups"
        case .createUser:
            return "new_account"
        case let .createChore(_, _, _, _, id):
            return "groups/\(id)/chores"
        case let .getChores(_, id):
            return "groups/\(id)/chores"
        }
    }
    
    func body() -> Data? {
        switch self {
        case let .loginUser(email, password):
            let encoder = JSONEncoder()
            let body: [String: String] = ["email": email, "password": password]
            let result = try? encoder.encode(body)
            return result!
        
        case let .createUser(firstName, lastName, email, password, username):
            let encoder = JSONEncoder()
            let body: [String: String] = ["first_name": firstName, "last_name": lastName, "email": email, "password": password, "username": username]
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
        
        default:
            return nil
        }
        
    }
    
    func Parameters() -> [String: String] {
        switch self {
        case let .getChores(chore_type, _):
            return ["chore_type": chore_type]
        default:
            return [:]
        }
    }
    
    func headers() -> [String: String] {
        let keychain = KeychainSwift()
        let token = keychain.get("token")
        let email = keychain.get("email")
        return ["Content-Type": "application/json",
                "Authorization": "\(token!)",
                "Email": email!]
    }
    
}

class Network {
    static let instance = Network()
    
    let baseURL = "localhost:3000/v1/"
    //    let baseURL = "http://127.0.0.1:5000/"
    
    let session = URLSession.shared
    
    func fetch(route: Route, token: String, completion: @escaping (Data) -> Void) {
        let fullPath = baseURL + route.path()
        
        let pathURL = URL(string: fullPath)
        let fullPathURL = pathURL?.appendingQueryParameters(route.Parameters())
        var request = URLRequest(url: fullPathURL!)
        request.httpMethod = route.method()
//        request.allHTTPHeaderFields = route.headers(authorization: token)
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