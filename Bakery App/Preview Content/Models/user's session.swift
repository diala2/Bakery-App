//
//  user's session.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 27/07/1446 AH.
//

import SwiftUI
import Combine

class UserSession: ObservableObject {
    @Published var user: User? // The currently signed-in user
    @Published var bookedCourses: [Course] = [] // Store booked courses

    // Initializer
    init(user: User? = nil) {
        self.user = user
    }

    // MARK: - Authentication Methods

    /// Sign in the user
    func signIn(user: User) {
        self.user = user
        // Fetch booked courses for the user (e.g., from a server or local storage)
        fetchBookedCourses(for: user)
    }

    /// Sign out the user
    func signOut() {
        self.user = nil
        self.bookedCourses = [] // Clear booked courses when signing out
    }

    /// Check if the user is signed in
    var isSignedIn: Bool {
        return user != nil
    }

    // MARK: - Booked Courses Management

    /// Fetch booked courses for the user
    private func fetchBookedCourses(for user: User) {
        // Simulate fetching booked courses from a server or local storage
        // Replace this with your actual data fetching logic
        let sampleCourses = [
            Course(id: "1", title: "Course Title", description: "Description", chefId: "", level: "Beginner", startDate: Date(), endDate: Date(), locationName: "Location", locationLatitude: 0.0, locationLongitude: 0.0, imageUrl: "ImageURL"),
            Course(id: "2", title: "Advanced Pastry Techniques", description: "Description", chefId: "", level: "Advanced", startDate: Date().addingTimeInterval(86400 * 2),endDate: Date(), locationName: "Culinary School", locationLatitude: 0.0, locationLongitude: 0.0,imageUrl: "baking2")
        ]
        self.bookedCourses = sampleCourses
    }

    /// Book a new course for the user
    func bookCourse(_ course: Course) {
        guard isSignedIn else {
            print("User must be signed in to book a course.")
            return
        }
        bookedCourses.append(course)
        // Optionally, sync with a server or local storage
    }

    /// Cancel a booked course
    func cancelCourse(_ courseId: String) {
        bookedCourses.removeAll { $0.id == courseId }
        // Optionally, sync with a server or local storage
    }
}
