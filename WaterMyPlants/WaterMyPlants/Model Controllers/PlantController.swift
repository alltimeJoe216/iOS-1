//
//  PlantController.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/21/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation
import CoreData

enum NetworkError2: Error {
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
    case noRep
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
enum NetworkError: Error {
    case failedSignUp, failedLogIn, noData, badData
    case notSignedIn, failedFetch, failedPost
}

typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void

class PlantController {
    
    //MARK: - Login Status
    enum LoginStatus {
        
        case notLoggedIn
        case loggedIn(Bearer)
        
        static var isLoggedIn: Self {
            
            if let bearer = PlantController.bearer {
                
                return .loggedIn(bearer)
                
            } else {
                
                return .notLoggedIn
            }
        }
    }
    
    // MARK: - Properties
    private let networkService = NetworkService()
    static var bearer: Bearer?
    var plants: [PlantRepresentation] = []
    
    private lazy var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    // MARK: - URLs
    
    private let baseURL: URL = URL(string: "https://water-my-plants-buildweek.herokuapp.com/api")!
    private lazy var signUpURL: URL = baseURL.appendingPathComponent("/auth/register")
    private lazy var logInURL: URL = baseURL.appendingPathComponent("/auth/login")
    private lazy var allPlantsURL: URL = baseURL.appendingPathComponent("/auth/plants")
    
    //MARK: - Authentication Methods
    //        ======================
    func signUp(for user: UserRepresentation, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        var request = postRequest(with: signUpURL)
        
        do {
            
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                
                if let error = error {
                    
                    print("Sign up failed with error: \(error.localizedDescription)")
                    return completion(.failure(.failedSignUp))
                    
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200
                    else {
                        
                        print("Sign up was unsuccessful.")
                        return completion(.failure(.failedSignUp))
                        
                }
                
                completion(.success(true))
            }
                
            .resume()
            
        } catch {
            
            print("Error encoding user: \(error.localizedDescription)")
            completion(.failure(.failedSignUp))
        }
    }
    
    func logIn(for user: UserRepresentation, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        var request = postRequest(with: logInURL)
        
        do {
            
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    
                    print("Log in failed with error: \(error.localizedDescription)")
                    return
                    
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200
                    
                    else {
                        
                        print("Log in was unsuccessful.")
                        return completion(.failure(.failedLogIn))
                        
                }
                
                guard let data = data else {
                    
                    print("No data was returned.")
                    return completion(.failure(.noData))
                    
                }
                
                do {
                    
                    Self.bearer = try self.jsonDecoder.decode(Bearer.self, from: data)
                    completion(.success(true))
                    
                } catch {
                    
                    print("Error decoding bearer: \(error.localizedDescription)")
                    completion(.failure(.failedLogIn))
                    
                }
                
            }
                
            .resume()
            
        } catch {
            
            print("Error encoding user: \(error.localizedDescription)")
            completion(.failure(.failedLogIn))
        }
    }
    
    func createNewPlant(plant: PlantRepresentation, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        guard case let .loggedIn(bearer) = LoginStatus.isLoggedIn
            
            else {
                
                return completion(.failure(.notSignedIn))
        }
        
        var request = plantHandler(with: allPlantsURL, with: bearer, requestType: .post)
        
        do {
            
            let newPlant = try jsonEncoder.encode(plant)
            
            print(String(data: newPlant, encoding: .utf8)!)
            request.httpBody = newPlant
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                
                if let error = error {
                    
                    print("Failed post with error: \(error.localizedDescription)")
                    return completion(.failure(.failedSignUp))
                    
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    
                    print("Posting recieved bad response.")
                    return completion(.failure(.failedSignUp))
                    
                }
                
                self.plants.append(plant)
                completion(.success(true))
                
            }
                
            .resume()
            
        } catch {
            
            print("Error encoding gig: \(error.localizedDescription)")
            completion(.failure(.failedPost))
            
        }
        
    }
    
    func fetchPlants(completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        guard case let .loggedIn(bearer) = LoginStatus.isLoggedIn else {
            
            return completion(.failure(.notSignedIn))
            
        }
        
        let request = plantHandler(with: allPlantsURL, with: bearer, requestType: .get)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                
                print("Failed to fetch gigs with error: \(error.localizedDescription)")
                return completion(.failure(.failedPost))
                
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200
                
                else {
                    
                    print("Fetch gigs recieved bad response.")
                    return completion(.failure(.failedPost))
                    
            }
            
            guard let data = data else { return completion(.failure(.badData))}
            
            do {
                
                let plants = try self.jsonDecoder.decode([PlantRepresentation].self, from: data)
                
                self.plants = plants
                completion(.success(true))
                
            } catch {
                
                print("Error decoding gigs: \(error.localizedDescription)")
                completion(.failure(.failedPost))
                
            }
        }
            
        .resume()
    }
    
    private func postRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func updatePlantRep(plant: Plant, with representation: PlantRepresentation) {
        plant.id = Int16(representation.identifier)
        plant.nickname = representation.nickname
        plant.species = representation.species
        plant.userID = representation.userID
        plant.h2oFrequency = representation.h2oFrequency
        plant.imageURL = representation.imageURL
    }
    
    private func plantHandler(with url: URL, with bearer: Bearer, requestType: HTTPMethod) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = requestType.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
