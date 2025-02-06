//
//  MainTabView.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 29/07/1446 AH.
//
//
//import SwiftUI
//
//struct MainTab: View {
//    @ObservedObject var userSession = UserSession() // Ensure your user session is passed appropriately
//
//    var body: some View {
//        TabView {
//            HomePage()
//                .tabItem {
//                    Label("Bake", systemImage: "house")
//                }
//
//            CoursesView()
//                .tabItem {
//                    Label("Courses", systemImage: "book")
//                }
//
//            ProfileView(userSession: userSession)
//                .tabItem {
//                    Label("Profile", systemImage: "person")
//                }
//        }
//    }
//}
