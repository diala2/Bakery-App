//
//  ProfileView.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 26/07/1446 AH.
//
import SwiftUI

struct ProfileView: View {
    @ObservedObject var userSession: UserSession
    @State private var bookedCourses: [Course] = [] // Store booked courses separately
    @StateObject private var viewModel = BakeryViewModel()
    
    var body: some View {
        TabView {
            VStack(spacing: 20) {
                if let user = userSession.user {
                    // User Profile Section
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(width: 60, height: 60)
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.orange)
                                    .frame(width: 30, height: 30)
                            }
                            
                            TextField("Username", text: .constant(user.name))
                                .padding(.vertical, 4)
                                .padding(.horizontal)
                                .foregroundColor(.black)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 1)
                        }
                        .padding(.horizontal)
                        
                        // Done Button
                        Button(action: {
                            // Action for done
                        }) {
                            Text("Done")
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 5)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    
                    // Separator
                    Divider()
                        .padding(.horizontal)
                    
                    // Booked Courses View
                    BookedCoursesView(bookedCourses: $bookedCourses, viewModel: viewModel, userSession: userSession)
                } else {
                    Text("Please sign in")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.vertical, 30)
            .background(Color(UIColor.systemBackground))
            .onAppear {
                // Fetch booked courses when the view appears
                if let userId = userSession.user?.id {
                    fetchBookedCourses(for: userId)
                }
            }
            
            
        }
    }
    
    private func fetchBookedCourses(for userId: String) {
        // Call viewModel to fetch bookings for the specific user
        viewModel.fetchBookings2(for: userId) { bookings in
            DispatchQueue.main.async {
                // Map the bookings to courses if needed
                let newBookedCourses = bookings.compactMap { booking in
                    // Assuming the viewModel or another method can fetch a course by its ID
                    return viewModel.getCourseById(booking.courseId)
                }
                
                // Remove duplicates based on the course ID
                let uniqueCourses = Array(Set(newBookedCourses.map { $0.id })).compactMap { courseId in
                    return newBookedCourses.first { $0.id == courseId }
                }
                
                // Update the user session with the unique booked courses
                userSession.bookedCourses = uniqueCourses
                
                // Log the fetched courses to debug
                print("Fetched courses: \(uniqueCourses)")
                
                // Log or handle cases where no bookings were found
                if uniqueCourses.isEmpty {
                    print("No booked courses found for user with ID \(userId).")
                } else {
                    print("Fetched \(uniqueCourses.count) booked courses for user with ID \(userId).")
                }
                
                // Update the state variable
                self.bookedCourses = uniqueCourses
            }
        }
        
    }
}






struct BookedCoursesView: View {
    @Binding var bookedCourses: [Course]
    @ObservedObject var viewModel: BakeryViewModel
    @ObservedObject var userSession: UserSession
    
    @State private var showCancelAlert: Bool = false
    @State private var courseToCancel: Course? = nil
    @State private var selectedCourse: Course? = nil // Track the selected course for navigation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if bookedCourses.isEmpty {
                    Text("You don’t have any booked courses.")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                    
                } else {
                    ForEach(bookedCourses, id: \.id) { course in
                        // Course Card
                        VStack(alignment: .leading, spacing: 10) {
                            // Course Image
                            AsyncImage(url: URL(string: course.imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView() // Show a loading indicator while the image is loading
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 275)
                                        .clipped()
                                        .cornerRadius(10)
                                case .failure:
                                    Image(systemName: "photo") // Fallback image if loading fails
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 275)
                                        .clipped()
                                        .cornerRadius(10)
                                @unknown default:
                                    EmptyView()
                                }
                            }

                            // Course Title
                            Text(course.title)
                                .font(.headline)
                                .fontWeight(.bold)

                            // Course Date
                            Text("Date: \(formatDate(course.startDate))")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            // Cancel Button
                            Button(action: {
                                courseToCancel = course
                                showCancelAlert = true
                            }) {
                                Text("Cancel Booking")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                        }
                     
                
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .padding(.bottom, 10)
                        .onTapGesture {
                            selectedCourse = course // Set the selected course when tapped
                        }
                    }
                }
            }
            .padding()
           
        
        }
        .sheet(item: $selectedCourse) { course in
            // Show the detailed course view as a sheet
            CourseDetailView2(course: course, onCancel: {
                selectedCourse = nil // Dismiss the sheet
            })
            
        }
        .alert(isPresented: $showCancelAlert) {
            Alert(
                title: Text("Cancel booking?"),
                message: Text("Do you want to cancel your booking"),
                primaryButton: .default(Text("No")) {
                    // Do nothing, just dismiss the alert
                },
                secondaryButton: .destructive(Text("Yes")) {
                    if let courseId = courseToCancel?.id {
                        cancelBooking(for: courseId)
                    }
                }
            )
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func cancelBooking(for courseId: String) {
        guard let userId = userSession.user?.id else { return }
        
        viewModel.cancelBooking(for: courseId, userId: userId) { success in
            if success {
                // Remove the course from the bookedCourses array
                DispatchQueue.main.async {
                    bookedCourses.removeAll { $0.id == courseId }
                }
            } else {
                // Handle the failure case, e.g., show an alert
                print("Failed to cancel booking for course ID: \(courseId)")
            }
        }
    }
}

// MARK: - Course Detail View
struct CourseDetailView2: View {
    let course: Course
    var onCancel: () -> Void // Callback to dismiss the sheet
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Course Image
                Image(course.imageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 275)
                    .clipped()
                    .cornerRadius(10)
                
                // Course Title
                Text(course.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                // About the Course
                Text("About the course:")
                    .font(.headline)
                    .padding(.vertical, 5)
                Text(course.description)
                    .font(.body)
                    .foregroundColor(.gray)
                
                // Additional Course Details
                VStack(alignment: .leading, spacing: 5) {
                    Text("Level: \(course.level)")
                    Text("Chef: \(course.chefId ?? "Unknown")")
                    Text("Duration: \(course.id)") // Adjust this based on your model
                    Text("Date: \(formatDate(course.startDate)) \(formatTime(course.startDate))")
                    Text("Location: \(course.locationName)")
                }
                .font(.body)
                .foregroundColor(.black)
                
                // Map View
                MapView(locationName: course.locationName)
                    .frame(height: 200)
                    .cornerRadius(10)
                
                // Cancel Button
                Button(action: {
                    onCancel() // Dismiss the sheet
                }) {
                    Text("Close")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let userSession = UserSession()
        userSession.user = User(
            id: "1",
            name: "John Doe",
            email: "john@example.com",
            password: "password"
        )

        return ProfileView(userSession: userSession)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
