import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/devices/domain/device_models.dart';

class DeviceRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _devicesCol(String companyId) =>
      _db.collection('companies').doc(companyId).collection('devices');

  // ── Cihaz listesi ────────────────────────────────────────────────────────

  Stream<List<FirestoreDevice>> watchDevices(String companyId) {
    return _devicesCol(companyId).snapshots().map(
          (snap) => snap.docs.map(FirestoreDevice.fromDoc).toList(),
        );
  }

  // ── Sensörler ────────────────────────────────────────────────────────────

  Stream<List<FirestoreSensor>> watchSensors(String companyId, String deviceId) {
    return _devicesCol(companyId)
        .doc(deviceId)
        .collection('sensors')
        .snapshots()
        .map((snap) => snap.docs.map(FirestoreSensor.fromDoc).toList());
  }

  // ── Röleler ──────────────────────────────────────────────────────────────

  Stream<List<FirestoreRelay>> watchRelays(String companyId, String deviceId) {
    return _devicesCol(companyId)
        .doc(deviceId)
        .collection('relays')
        .snapshots()
        .map((snap) => snap.docs.map(FirestoreRelay.fromDoc).toList());
  }

  // ── Provisioning — yeni cihaz ekle ───────────────────────────────────────

  Future<void> addDevice(
    String companyId,
    String deviceId,
    String deviceName,
  ) async {
    await _devicesCol(companyId).doc(deviceId).set({
      'device_name': deviceName,
      'device_status': false,
      'last_seen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Röle durumu güncelle ─────────────────────────────────────────────────

  Future<void> updateRelayStatus(
    String companyId,
    String deviceId,
    String relayId,
    bool status,
  ) async {
    await _devicesCol(companyId)
        .doc(deviceId)
        .collection('relays')
        .doc(relayId)
        .update({
      'relay_status': status,
      'reading_time': FieldValue.serverTimestamp(),
    });
  }
}
