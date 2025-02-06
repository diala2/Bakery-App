//
//  CourseDetailView.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 26/07/1446 AH.
//
import SwiftUI
import MapKit

struct CourseDetailView: View {
    var course: Course // Accept a Course object
    @ObservedObject var viewModel = BakeryViewModel() // Ensure this is the correct view model
    @State private var showingSignIn = false
    @State private var showingProfile = false
    @State private var chefName: String?
    @State private var showAlert = false // State for alert
    @State private var alertMessage = "" // Message to show in alert
    @StateObject private var userSession = UserSession() // StateObject for user session
    @State private var isLoading = false // Loading spinner state for booking

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
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
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                // About the Course
                Text("About the course:")
                    .font(.headline)
                    .padding(.vertical, 5)
                
                Text(course.description)
                    .font(.body)
                    .foregroundColor(.gray)
                
                Divider()
                
                // Chef Information
                HStack {
                    Text("Chef:")
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(chefName ?? "Unknown Chef")
                        .font(.body)
                        .foregroundColor(.black)
                    
                }
                .padding(.vertical, 5)
                
                // Additional Course Details
                VStack(alignment: .leading, spacing: 5) {
                    Text("Level: \(course.level)")
                        .font(.subheadline)
                    
                    HStack {
                        Text("Duration: 2h").position(x:266, y:-17) 
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        Spacer()
                        Text("Location: \(course.locationName)").position(x: 120, y: 4)
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                    }
                    Text("Date & time: \(formatDate(course.startDate)) - \(formatTime(course.startDate))").position(x: 98, y: -20)
                        .font(.subheadline)
                }
                .font(.body)
                .foregroundColor(.black)
                
                // Map View
                MapView(locationName: course.locationName)
                    .frame(height: 150) // Reduced height for map
                    .cornerRadius(10)
                
                // Booking Button
                Button(action: {
                    bookCourse() // Call the booking function when the button is tapped
                }) {
                    if isLoading {
                        ProgressView() // Show spinner while booking
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Book a space")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 184/255, green: 92/255, blue: 56/255))
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 10)
                .disabled(isLoading)
                .alert(isPresented: $showAlert) { // Alert configuration
                    Alert(
                        title: Text("Booking Status"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK")) {
                            if alertMessage == "Booking successful!" {
                                showingProfile = true // Navigate to ProfileView after successful booking
                            }
                        }
                    )
                }
            }
            .padding()
            .navigationTitle("Home Bakery")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadChefName()
            }
            .fullScreenCover(isPresented: $showingProfile) {
                ProfileView(userSession: userSession) // Pass the user session to ProfileView
            }
            .sheet(isPresented: $showingSignIn) {
                SignInView(isPresented: $showingSignIn, userSession: userSession, onSignInComplete: {
                    bookCourse() // Retry booking after signing in
                })
            }
        }
    }

        private func loadChefName() {
            guard let chefId = course.chefId else {
                chefName = "Unknown Chef"
                return
            }

            DispatchQueue.global().async {
                let fetchedName = viewModel.fetchChefName(for: chefId) ?? "Unknown Chef"
                DispatchQueue.main.async {
                    chefName = fetchedName
                }
            }
        }

        private func bookCourse() {
            guard let userId = userSession.user?.id else {
                showingSignIn = true // Show sign-in if user is not authenticated
                return
            }

            // Prevent duplicate bookings
            guard !userSession.bookedCourses.contains(where: { $0.id == course.id }) else {
                alertMessage = "You have already booked this course."
                showAlert = true
                return
            }

            isLoading = true // Show spinner during booking
            viewModel.bookCourse(courseId: course.id, userId: userId) { success in
                DispatchQueue.main.async {
                    isLoading = false // Hide spinner
                    if success {
                        userSession.bookedCourses.append(course)
                        alertMessage = "Booking successful!"
                    } else {
                        alertMessage = "Booking failed. Please try again."
                    }
                    showAlert = true
                }
            }
        }

        private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM" // Format to show only the month and day (e.g., "Dec 15")
            return formatter.string(from: date)
        }

        private func formatTime(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }

    // Map View using Geocoding
    struct MapView: UIViewRepresentable {
        var locationName: String
        @State private var coordinate: CLLocationCoordinate2D?

        func makeUIView(context: Context) -> MKMapView {
            let mapView = MKMapView()
            context.coordinator.mapView = mapView
            return mapView
        }

        func updateUIView(_ uiView: MKMapView, context: Context) {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(locationName) { (placemarks, error) in
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    return
                }
                guard let placemark = placemarks?.first, let location = placemark.location else {
                    print("No location found for \(locationName)")
                    return
                }
                self.coordinate = location.coordinate

                DispatchQueue.main.async {
                    let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    uiView.setRegion(region, animated: true)

                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location.coordinate
                    annotation.title = locationName
                    uiView.addAnnotation(annotation)
                }
            }
        }

        func makeCoordinator() -> Coordinator {
            return Coordinator()
        }

        class Coordinator {
            var mapView: MKMapView?
        }
    }

    struct CourseDetailView_Previews: PreviewProvider {
        static var previews: some View {
            let sampleCourse = Course(
                id: "1",
                title: "Babka Dough",
                description: "Learn new techniques, ingredients, and recipes when taking a baking class.",
                chefId: "recF8ocLPwiadavlP",
                level: "Intermediate",
                startDate: Date(),
                endDate: Date(),
                locationName: "Riyadh, Alnarjis",
                locationLatitude: 22.2,
                locationLongitude: 34.3,
                imageUrl: "Babka_Dough"
            )

            CourseDetailView(course: sampleCourse)
        }
    }
