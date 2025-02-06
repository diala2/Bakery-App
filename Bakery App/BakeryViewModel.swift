//
//  BakeryViewModel.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 21/07/1446 AH.
//
import Foundation
import Combine

import UIKit
class BakeryViewModel: ObservableObject {
    private let bakeryAPI = BakeryAPI()
    @Published var userSession = UserSession()
    @Published var chefs: [Chef] = []
    @Published var users: [User] = []
    @Published var courses: [Course] = []
    @Published var bookings: [Booking] = []
    @Published var upcomingEvents: [Course] = [] // New property for upcoming events
    private let baseURL = "https://api.airtable.com/v0/appXMW3ZsAddTpClm"
    init() {
        fetchCourses()
        fetchChefs()  // Ensure chefs are fetched on initialization
        // Optionally fetch courses if needed
    }
  
    
    func fetchChefs() {
        bakeryAPI.fetchChefs { [weak self] data in
            guard let data = data else { return }
            do {
                let chefResponse = try JSONDecoder().decode(ChefResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.chefs = chefResponse.records.map { record in
                        Chef(id: record.id, name: record.fields.name, email: record.fields.email)
                    }
                }
            } catch {
                print("Error decoding chefs: \(error)")
            }
        }
    }
    func fetchChefName(for chefId: String) -> String?  {
        if let chef = chefs.first(where: { $0.id == chefId }) {
            return chefs.first(where: { $0.id == chefId })?.name
        }
        return nil
    }
    
    func fetchUsers() {
        bakeryAPI.fetchUsers { [weak self] data in
            guard let data = data else { return }
            do {
                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.users = userResponse.records.map { record in
                        User(id: record.id , name: record.fields.name, email: record.fields.email,password: record.fields.password)
                    }
                }
            } catch {
                print("Error decoding users: \(error)")
            }
            
        }
    }
    
    func fetchCourses() {
        bakeryAPI.fetchCourses { [weak self] data in
            guard let data = data else { return }
            do {
                let courseResponse = try JSONDecoder().decode(CourseResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.courses = courseResponse.records.map { record in
                        Course(
                            id: record.fields.id,
                            title: record.fields.title,
                            description: record.fields.description,
                            chefId: record.fields.chefId,
                            level: record.fields.level,
                            startDate: Date(timeIntervalSince1970: record.fields.startDate),
                            endDate: Date(timeIntervalSince1970: record.fields.endDate),
                            locationName: record.fields.locationName,
                            locationLatitude: record.fields.locationLatitude,
                            locationLongitude:record.fields.locationLongitude, // Ensure this is not optional
                            imageUrl: record.fields.imageUrl
                            // instructor: record.fields.instructor // Assuming instructor is in CourseFields
                        )
                    }
                    
                    // Filter upcoming events
                    self?.upcomingEvents = self?.courses.filter { $0.startDate > Date() } ?? []
                }
            } catch {
                print("Error decoding courses: \(error)")
            }
        }
    }
    
    func fetchBookings() {
            // Implement the logic to fetch bookings
            bakeryAPI.fetchBookings { data in
                guard let data = data else { return }
                do {
                    let bookingResponse = try JSONDecoder().decode(BookingResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.bookings = bookingResponse.records.map { record in
                            Booking(courseId:record.fields.courseId, userId: record.fields.userId, status: record.fields.status)
                        }
                    }
                } catch {
                    print("Failed to decode bookings: \(error)")
                }
            }
        }
    func getCourseById(_ courseId: String) -> Course? {
        return courses.first(where: { $0.id == courseId })
    }

    func fetchBookings2(for userId: String, completion: @escaping ([Booking]) -> Void) {
        // Simulate fetching data from an API
        bakeryAPI.fetchBookings { data in
            guard let data = data else {
                completion([]) // Return an empty array if no data
                return
            }

            do {
                let bookingResponse = try JSONDecoder().decode(BookingResponse.self, from: data)
                let bookings = bookingResponse.records.compactMap { record in
                    // Map API data into Booking objects
                    Booking(
                        courseId: record.fields.courseId,
                        userId: record.fields.userId,
                        status: record.fields.status
                    )
                }.filter { $0.userId == userId } // Filter by userId

                completion(bookings) // Return the filtered bookings
            } catch {
                print("Failed to decode bookings: \(error)")
                completion([]) // Return empty array on decoding error
            }
        }
    }
    func cancelBooking(for courseId: String, userId: String, completion: @escaping (Bool) -> Void) {
           // Implement the logic to cancel the booking in your backend
           // For example, you might make a network request to delete the booking
           // On success, call the completion handler with `true`
           // On failure, call the completion handler with `false`
           
           // Example:
           // networkService.cancelBooking(courseId: courseId, userId: userId) { success in
           //     completion(success)
           // }
           
           // For now, let's assume the cancellation is successful
           completion(true)
       }
   
    func checkBookingExists(recordId: String, completion: @escaping (Bool) -> Void) {
        let urlString = "\(baseURL)/bookings/\(recordId)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error checking booking: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(true)
                } else {
                    print("Booking not found. Status code: \(httpResponse.statusCode)")
                    completion(false)
                }
            }
        }

        task.resume()
    }
    // Create a new user
    func createUser(name: String, email: String, password: String, completion: @escaping () -> Void) {
        // Create a new User with an empty bookedCourses array
        let newUser = User(id: UUID().uuidString, name: name, email: email, password: password)
        
        bakeryAPI.createUser(user: newUser) { data in
            guard let data = data else { return }
            // Handle response if needed
            completion()
        }
    }
    
    // Create a booking
    func bookCourse(courseId: String, userId: String, completion: @escaping (Bool) -> Void) {
        let booking = Booking(courseId: courseId, userId: userId, status: "Pending")
        
        // Simulate an API call
        DispatchQueue.global().async {
            // Simulate a network delay
            sleep(1)
            
            // Here you would typically call your API to create a booking
            DispatchQueue.main.async {
                self.userSession.bookedCourses.append(
                    Course(id: courseId, title: "Course Title", description: "Description", chefId: userId, level: "Beginner", startDate: Date(), endDate: Date(), locationName: "Location", locationLatitude: 0.0, locationLongitude: 0.0, imageUrl: "ImageURL")
                )
                completion(true) // Call completion with success
            }
        
       
    }

     
    }

}
