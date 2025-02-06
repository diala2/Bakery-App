//
//  SplashScreen.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 20/07/1446 AH.
//
import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false // State to control navigation

    var body: some View {
        NavigationView {
            VStack {
                // Logo Image
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100) // Adjust size as needed
                
                // Brand Name
                Text("Home Bakery")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 92/255, green: 61/255, blue: 46/255))
                Text("Baked to Perfection")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 92/255, green: 61/255, blue: 46/255))
            }
            .padding()
            .background(Color.white) // Background color
            .edgesIgnoringSafeArea(.all) // Extend to safe area
            .onAppear {
                // Set a timer to navigate after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isActive = true // Trigger navigation
                }
            }
            .background(
                NavigationLink(destination: HomePage(), isActive: $isActive) {
                    EmptyView()
                }
                .hidden() // Hide the NavigationLink
            )
        }
    }
}


#Preview {
    SplashScreen()
}
