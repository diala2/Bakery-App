import SwiftUI
struct SignInView: View {
    @Binding var isPresented: Bool // Binding to control pop-up visibility
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var errorMessage: String?
    @State private var isSigningIn = false
    @State private var isUserAuthenticated = false // Track authentication state
    @ObservedObject var userSession: UserSession // Use ObservedObject here
    
    var onSignInComplete: (() -> Void)? // Optional callback to handle post-sign-in actions
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Close Button
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top)
                
                // Email Text Field
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    TextField("Email", text: $email)
                        .onChange(of: email) { newValue in
                            if let firstLetter = newValue.first {
                                let lowercasedFirst = String(firstLetter).lowercased()
                                let restOfEmail = newValue.dropFirst()
                                email = lowercasedFirst + restOfEmail
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                
                // Password Text Field
                VStack(alignment: .leading) {
                    Text("Password")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        } else {
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Sign In Button
                Button(action: {
                    signIn()
                }) {
                    if isSigningIn {
                        ProgressView()
                    } else {
                        Text("Sign in")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 184/255, green: 92/255, blue: 56/255))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                // Error message display
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                // Navigation Link to ProfileView
                NavigationLink(destination: ProfileView(userSession: userSession), isActive: $isUserAuthenticated) {
                    EmptyView() // Hidden NavigationLink
                }
                
            }
            .padding(.vertical, 30)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .navigationTitle("Sign in")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    private func signIn() {
        isSigningIn = true
        errorMessage = nil
        
        let bakeryAPI = BakeryAPI()
        bakeryAPI.fetchUsers { data in // Use single parameter
            DispatchQueue.main.async {
                self.isSigningIn = false
                
                // Check if data is nil
                if data == nil {
                    self.errorMessage = "Invalid data received from the server. Please try again later."
                    return
                }
                
                // Attempt to decode the data
                do {
                    let userResponse = try JSONDecoder().decode(UserResponse.self, from: data!)
                    let users = userResponse.records.map { record in
                        User(id: record.fields.id ?? record.id, name: record.fields.name, email: record.fields.email, password: record.fields.password)
                    }
                    
                    // Check if the user exists
                    if let user = users.first(where: { $0.email == email && $0.password == password }) {
                        self.userSession.user = user // Update the UserSession
                        self.isUserAuthenticated = true // Set authentication state to true
                        self.isPresented = false // Close the sign-in view
                        self.onSignInComplete?() // Trigger the callback
                    } else {
                        self.errorMessage = "Invalid email or password."
                    }
                } catch {
                    // Display the same error message for any decoding or data-related errors
                    self.errorMessage = "Invalid data received from the server. Please try again later."
                }
            }
        }
    }}
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isPresented = true
        let userSession = UserSession()
        return SignInView(isPresented: $isPresented, userSession: userSession)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
