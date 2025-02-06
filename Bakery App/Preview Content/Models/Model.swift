//
//  Model.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 21/07/1446 AH.
//

import Foundation

struct Chef: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
  
}

struct ChefResponse: Codable {
    let records: [ChefRecord]
}

struct ChefRecord: Codable {
    let id: String
    let createdTime: String
    let fields: ChefFields
}



struct ChefFields: Codable {
    let id: String
    let name: String
    let email: String
    let password: String
}
