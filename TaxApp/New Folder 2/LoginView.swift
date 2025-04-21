import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("logo-fb")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 120)
                    .padding(.vertical, 32)
                
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email Address", placeHolder: "name@example.com")
                        .autocapitalization(.none)
                    
                    InputView(text: $password, title: "Password", placeHolder: "Enter your Password", isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                ButtonView(label: "Sign in", icon: "arrow.right", formValid: formValid) {
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                }
                
                Spacer()
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden()
                } label: {
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 14))
                }
            }
        }
    }
}

extension LoginView: AuthenticationFormProtocol {
    var formValid: Bool {
        !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5
    }
}
