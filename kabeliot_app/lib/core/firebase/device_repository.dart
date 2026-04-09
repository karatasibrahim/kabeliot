import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/devices/domain/device_models.dart' show FirestoreDevice;

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

  // ── Provisioning — yeni cihaz ekle ───────────────────────────────────────

  Future<void> addDevice(
    String companyId,
    String deviceId,
    String deviceName, {
    String? tbDeviceId,
  }) async {
    await _devicesCol(companyId).doc(deviceId).set({
      'device_name': deviceName,
      'device_status': false,
      'last_seen': FieldValue.serverTimestamp(),
      if (tbDeviceId != null) 'tb_device_id': tbDeviceId,
    }, SetOptions(merge: true));
  }

}
