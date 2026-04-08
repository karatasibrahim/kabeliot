import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/firebase/device_repository.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../domain/device_models.dart';

part 'live_data_provider.g.dart';

const _historyLength = 60;

/// Belirli bir sensörün son 60 değeri — Firestore snapshot'larından beslenir.
@riverpod
class LiveSensorData extends _$LiveSensorData {
  StreamSubscription<List<FirestoreSensor>>? _sub;

  @override
  List<double> build(String deviceId, int sensorIndex) {
    final session = ref.watch(authStateProvider);

    _sub?.cancel();

    if (session != null) {
      _sub = DeviceRepository()
          .watchSensors(session.companyId, deviceId)
          .listen((sensors) {
        if (sensorIndex < sensors.length) {
          final value = sensors[sensorIndex].value;
          state = [...state.skip(1), value];
        }
      });
    }

    ref.onDispose(() => _sub?.cancel());
    return List<double>.filled(_historyLength, 0.0);
  }

  double get currentValue => state.isEmpty ? 0 : state.last;
}
