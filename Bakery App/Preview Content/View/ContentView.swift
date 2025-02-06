//
//  ContentView.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 20/07/1446 AH.
//
import SwiftUI
struct ContentView: View {
    var body: some View {
        TabView {
            // Home View
            HomePage() // Replace with your actual HomeView
                .tabItem {
                    Label("Bake", systemImage: "Logo-3")
                }
            
            // Courses View
            CoursesView()
                .tabItem {
                    Label("Courses", systemImage: "Courses")
                }
            
            // Profile View
            ProfileView(userSession: UserSession())
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
#Preview {
    ContentView()
}
