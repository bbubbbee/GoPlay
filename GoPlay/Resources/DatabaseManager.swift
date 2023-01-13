//
//  DatabaseManager.swift
//  GoPlay
//
//  Created by Darren Borromeo on 13/1/2023.
//

import Foundation
import FirebaseDatabase


class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail     = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

// MARK: - Account Management

extension DatabaseManager {
    
    /// Checks is a user already exists via the given email.
    ///     - @param completion: returns true if the users email exists, false if it doesn't.
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        
        // Get safeEmail - database doesn't allow "." and "@".
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail     = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        // Check for safeEmail.
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            // If the value is a string, check to see if it's nil.
            guard snapshot.value as? String != nil else {
                completion(false)  // Email doesn't exist - create account.
                return
            }
            completion(true)       // Found email - don't create account.
        })
    }
    
    /// Add a user into the firebase database.
    /// A user is a child of the database. A child has a key: email, and a value: a dictionary of user information.
    ///
    /// Creates a collection (array) of users. --> Easily reference newly inserted users.
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        // Create a child of the database.
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name":  user.lastName,
        ], withCompletionBlock: { error, _ in
            
            // Error checker.
            guard error == nil else {
                print("Failed to write to database.")
                completion(false)
                return
            }
                        
            // Add user into array/collection of users. Craete this child ("users") from the parent database.
            // If the collection doesn't exist, make one and add the user.
            // If if it does exist, append the user into it.
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // Append to users dictionary.
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                else {
                    // Create that array.
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })//end - observeSingleEvent()
        })//end - setValue()
    }//end - func insertUser()
    
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
}

/// Strucutre of a user. 
struct ChatAppUser {
    let firstName:    String
    let lastName:     String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail     = safeEmail.replacingOccurrences(of: "@", with: "-")
        return          safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
