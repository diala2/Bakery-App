//
//  Course.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 26/07/1446 AH.
//

import Foundation
struct CourseResponse: Codable {
    let records: [CourseRecord]
}

struct CourseRecord: Codable {
    let id: String
    let fields: CourseFields // Assuming fields holds all necessary data
}

struct CourseFields: Codable{
    let locationLongitude: Double
    let locationName: String
    let locationLatitude: Double
    let title: String
    let imageUrl: String
    let level: String
    let endDate: TimeInterval
    let id: String
    let chefId: String
    let description: String
    let startDate: TimeInterval
   // let instructor: String // Ensure this is included

    enum CodingKeys: String, CodingKey {
        case locationLongitude = "location_longitude"
        case locationName = "location_name"
        case locationLatitude = "location_latitude"
        case title
        case imageUrl = "image_url"
        case level
        case endDate = "end_date"
        case id
        case chefId = "chef_id"
        case description
        case startDate = "start_date"
      //  case instructor
    }
}

struct Course: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    var chefId: String?
    let level: String
    let startDate: Date
    let endDate: Date
    let locationName: String
    let locationLatitude: Double
    let locationLongitude: Double
    let imageUrl: String
   // var instructor: String
}
