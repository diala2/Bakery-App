//
//  Booking.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 26/07/1446 AH.
//
import Foundation
struct BookingResponse: Codable {
    let records: [BookingRecord]
}

struct BookingRecord: Codable {
    let id: String
    let createdTime: String
    let fields: BookingFields
}

struct BookingFields: Codable {
    let courseId: String
    let status: String
    let userId: String

    enum CodingKeys: String, CodingKey {
        case courseId = "course_id"
        case status
        case userId = "user_id"
    }
}

struct Booking: Codable {
    let courseId: String
    let userId: String
    let status: String
}
