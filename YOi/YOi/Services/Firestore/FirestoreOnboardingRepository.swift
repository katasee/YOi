import FirebaseAuth
import FirebaseFirestore

final class FirestoreOnboardingRepository: OnboardingRepository {
    private var db: Firestore { Firestore.firestore() }

    func save(_ step: OnboardingStep) throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw AccountError.profileNotFound }

        db.collection("users")
            .document(uid)
            .updateData(["onboardingStep": step.rawValue], completion: nil)
    }
}
