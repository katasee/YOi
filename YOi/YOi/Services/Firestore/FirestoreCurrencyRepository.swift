import FirebaseAuth
import FirebaseFirestore

final class FirestoreCurrencyRepository: CurrencyRepository {
    private let db = Firestore.firestore()

    func save(_ currency: Currency) throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw AccountError.profileNotFound }

        db.collection("users")
            .document(uid)
            .updateData(["currency": currency.rawValue], completion: nil)
    }
}
