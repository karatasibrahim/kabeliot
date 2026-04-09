import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/thingsboard/tb_websocket_service.dart';

part 'live_data_provider.g.dart';

const _historyLength = 60;

String _tbSensorKey(int index) => 'sensor_$index';

/// Belirli bir sensörün son 60 değeri — ThingsBoard WebSocket'ten beslenir.
/// [deviceId] ThingsBoard device UUID'si.
@riverpod
class LiveSensorData extends _$LiveSensorData {
  StreamSubscription<Map<String, dynamic>>? _sub;

  @override
  List<double> build(String deviceId, int sensorIndex) {
    final tbWs = ref.watch(tbWebSocketServiceProvider);
    final key = _tbSensorKey(sensorIndex);

    _sub?.cancel();
    _sub = tbWs.subscribeToTelemetry(deviceId, [key]).listen((data) {
      if (data.containsKey(key)) {
        final raw = data[key];
        final value = (raw is num) ? raw.toDouble() : double.tryParse('$raw') ?? 0.0;
        state = [...state.skip(1), value];
      }
    });

    ref.onDispose(() => _sub?.cancel());
    return List<double>.filled(_historyLength, 0.0);
  }

  double get currentValue => state.isEmpty ? 0 : state.last;
}
