import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyRepository {
  final _db = FirebaseFirestore.instance;

  /// Firebase Auth UID'si ile companies/{id}/users altında eşleşen dokümanı bulur.
  /// users dokümanlarında 'user_Uid' field = Firebase Auth UID.
  Future<({String companyId, String role})?> findCompanyAndRole(String uid) async {
    final snap = await _db
        .collectionGroup('users')
        .where('user_Uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    final companyId = doc.reference.parent.parent?.id;
    if (companyId == null) return null;
    final role = (doc.data()['role'] as String?) ?? 'viewer';
    return (companyId: companyId, role: role);
  }

  /// companies/{companyId} dökümanından email alanını okur.
  Future<String?> getCompanyEmail(String companyId) async {
    final doc = await _db.collection('companies').doc(companyId).get();
    return doc.data()?['email'] as String?;
  }
}
