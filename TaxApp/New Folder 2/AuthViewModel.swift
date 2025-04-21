import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol {
    var formValid: Bool { get }
}
@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?

    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
        }
    }

    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            print("DEBUG: Signed in user: \(String(describing: result.user.uid))")
            await fetchUser()
        } catch {
            print("DEBUG: Failed to login user \(error.localizedDescription)")
        }
    }

    func createUser(withEmail email: String, password: String, firstname: String, lastname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user

            let user = User(id: result.user.uid, firstName: firstname, lastName: lastname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("user").document(user.id).setData(encodedUser)

            print("DEBUG: User document created successfully for uid: \(user.id)")
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user \(error.localizedDescription)")
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out \(error.localizedDescription)")
        }
    }

    func deleteAccount() {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Firestore.firestore().collection("user").document(uid).delete()
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to delete user \(error.localizedDescription)")
        }
    }

    func fetchUser() async {
        do {
            guard let uid = Auth.auth().currentUser?.uid else {
                print("DEBUG: No current user found.")
                return
            }

            let document = Firestore.firestore().collection("user").document(uid)
            guard let snapshot = try? await document.getDocument() else {
                print("DEBUG: Document snapshot is nil.")
                return
            }

            if snapshot.exists {
                self.currentUser = try snapshot.data(as: User.self)
                print("DEBUG: Current user is \(String(describing: self.currentUser))")
            } else {
                print("DEBUG: No document exists for the given uid: \(uid)")
            }
        } catch {
            print("DEBUG: Failed to fetch user \(error.localizedDescription)")
        }
    }
}
