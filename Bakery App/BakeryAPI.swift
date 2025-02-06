//
//  BakeryAPI.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 21/07/1446 AH.
import Foundation
import Combine

class BakeryAPI {
    private let baseURL = "https://api.airtable.com/v0/appXMW3ZsAddTpClm"
    private let token = "Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001"

    // Fetch chefs
    func fetchChefs(completion: @escaping (Data?) -> Void) {
        let url = URL(string: "\(baseURL)/chef")!
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching chefs: \(error)")
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }

    // Fetch users
    func fetchUsers(completion: @escaping (Data?) -> Void) {
        let url = URL(string: "\(baseURL)/user")!
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching users: \(error)")
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }

    func fetchCourses(completion: @escaping (Data?) -> Void) {
        let url = URL(string: "\(baseURL)/course")!
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching users: \(error)")
                completion(nil)
                return
            }

            completion(data)
        }

        task.resume()
    }


    // Fetch bookings
    func fetchBookings(completion: @escaping (Data?) -> Void) {
        let url = URL(string: "\(baseURL)/booking")!
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching bookings: \(error)")
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }
    

    // Create a new user
    func createUser(user: User, completion: @escaping (Data?) -> Void) {
        let url = URL(string: "\(baseURL)/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let userData = [
            "fields": [
                "id": user.id,
                "name": user.name,
                "email": user.email,
                "password": user.password
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: userData, options: [])
        } catch {
            print("Error serializing user data: \(error)")
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error creating user: \(error)")
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }

    // Create a new booking
    func createBooking(booking: Booking, completion: @escaping (Data?) -> Void) {
        let url = URL(string: "\(baseURL)/booking")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let bookingData = [
            "fields": [
                "course_id": booking.courseId,
                "user_id": booking.userId,
                "status": booking.status
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bookingData, options: [])
        } catch {
            print("Error serializing booking data: \(error)")
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error creating booking: \(error)")
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }
   
}

