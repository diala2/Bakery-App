import SwiftUI

struct HomePage: View {
    @ObservedObject var viewModel = BakeryViewModel()
    @State private var searchText = ""
    
    var body: some View {
        TabView {
            NavigationView {
                VStack(spacing: 20) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.gray)
                            .padding(.leading, 8) // Add padding to the left of the icon
                        
                        TextField("Search", text: $searchText)
                            .padding(10) // Add more padding to the text field
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    
                    // Upcoming Section
                    VStack(alignment: .leading) {
                        Text("Upcoming")
                            .font(.headline)
                          
                        VStack(spacing: 16) {
                            ForEach(filteredUpcomingEvents) { event in
                                upcomingEventCard(course: event)
                            }
                        }
                        
                        Text("Popular Courses")
                            .font(.headline)
                           
                    }
                    .padding(.horizontal)
                    
                    // Popular Courses Section
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredCourses) { course in
                                NavigationLink(destination: CourseDetailView(course: course)) {
                                    CourseCard(courseName: course.title,
                                               level: course.level,
                                               duration: "2h",
                                               date: formattedDate(course.startDate),
                                               imageName: course.imageUrl)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("Home Bakery")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(UIColor.systemGroupedBackground))
           
                .onAppear {
                    viewModel.fetchCourses() // Fetch courses when the view appears
                }
            }
        }
    }
    
    // Function to format date for display
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM - h:mm" // Adjust format as necessary
        return formatter.string(from: date)
    }
    
    // Function to filter upcoming events based on search text
    private var filteredUpcomingEvents: [Course] {
        if searchText.isEmpty {
            return viewModel.upcomingEvents
        } else {
            return viewModel.upcomingEvents.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Function to filter courses based on search text
    private var filteredCourses: [Course] {
        if searchText.isEmpty {
            return viewModel.courses
        } else {
            return viewModel.courses.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func upcomingEventCard(course: Course) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "hourglass")
                Text(formattedDate(course.startDate))
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                    .padding(.bottom, 2)
            }
            Text(course.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.gray) // Icon color for consistency
                Text(course.locationName) // Replace with actual location if available
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
struct CourseCard: View {
    var courseName: String
    var level: String
    var duration: String
    var date: String
    var imageName: String // Assuming this is a URL

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: imageName)) { phase in
                switch phase {
                case .empty:
                    ProgressView() // Show a loading indicator while the image is loading
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                        .clipped()
                case .failure:
                    Image(systemName: "photo") // Fallback image if loading fails
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                        .clipped()
                @unknown default:
                    EmptyView()
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(courseName)
                    .font(.headline)
                    .foregroundColor(Color(red: 92/255, green: 61/255, blue: 46/255))

                Text(level)
                    .font(.subheadline)
                    .padding(1)
                    .background(levelBackground(for: level))
                    .foregroundColor(levelTextColor(for: level))
                    .cornerRadius(10)

                // Duration with clock icon
                HStack(spacing: 4) {
                    Image(systemName: "hourglass")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                    Text(duration)
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }

                // Date with calendar icon
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                    Text(date)
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
            }
            .padding(.leading, 10)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(2)
        }
        .padding(.horizontal)
        .frame(height: 120)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

private func levelBackground(for level: String) -> Color {
    switch level.lowercased() {
    case "beginner":
        return Color(red: 92/255, green: 61/255, blue: 46/255) // Dark brown
    case "intermediate":
        return Color(red: 224/255, green: 192/255, blue: 151/255)
    case "advance":
        return  Color(red: 184/255, green: 92/255, blue: 56/255)
    default:
        return Color.gray // Default color
    }
}

// Function to determine text color based on the level name
private func levelTextColor(for level: String) -> Color {
    return Color.white // Set text color to white for better contrast
}

#Preview {
    HomePage()
}
