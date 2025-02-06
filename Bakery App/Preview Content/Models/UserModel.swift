//
//  UserModel.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 21/07/1446 AH.
//
import Foundation

struct UserResponse: Codable {
    let records: [UserRecord]
}

struct UserRecord: Codable {
    let id: String
  
    let fields: UserFields
}

struct UserFields: Codable {
    let id: String
    let name: String
    let email: String
    let password: String
    // Correctly defined to hold an array of CourseRecord
}

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let password: String
  
}
