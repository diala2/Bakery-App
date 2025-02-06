//
//  CoursesView.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 29/07/1446 AH.
//
import SwiftUI

struct CoursesView: View {
    @ObservedObject var viewModel = BakeryViewModel()

    var body: some View {
        TabView {
            // Main Navigation View
            NavigationView {
                VStack(spacing: 20) {
                    // Search Bar
                    TextField("Search", text: .constant(""))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    // Popular Courses Section
                    Text("Popular Courses")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // Courses Scroll View
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.courses) { course in
                                NavigationLink(destination: CourseDetailView(course: course)) {
                                    CourseCard(courseName: course.title,
                                               level: course.level,
                                               duration: "2h",
                                               date: formattedDate(course.startDate),
                                               imageName: course.imageUrl)
                                }
                                .buttonStyle(PlainButtonStyle()) // Optional: remove default link styling
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
}

// Ensure you have CourseDetailView defined to accept a Course object

// Course Card View
struct CourseCard2: View {
    var courseName: String
    var level: String
    var duration: String
    var date: String
    var imageName: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .cornerRadius(10)
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(courseName)
                    .font(.headline)
                    .foregroundColor(Color.black)
                Text(level)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                HStack {
                    Text(duration)
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                    Spacer()
                    Text(date)
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
            }
            .padding(.leading, 10)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .padding(.horizontal)
        .frame(height: 120)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    CoursesView()
}
