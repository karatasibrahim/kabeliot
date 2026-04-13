import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/thingsboard/tb_websocket_service.dart';

part 'live_data_provider.g.dart';

const _historyLength = 60;

String _tbSensorKey(int index) => 'sensor_${index}_value';

/// Belirli bir sensörün son [_historyLength] değeri — ThingsBoard WebSocket'ten beslenir.
/// [deviceId] ThingsBoard device UUID'si.
/// Başlangıçta boş liste döner; ilk veri geldiğinde dolmaya başlar.
/// `state.isEmpty` → henüz veri yok; `state.isNotEmpty` → veri akıyor.
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
        final current = state.isEmpty
            ? List<double>.filled(_historyLength, value)
            : [...state.skip(1), value];
        state = current;
      }
    });

    ref.onDispose(() => _sub?.cancel());
    return const []; // boş → henüz veri yok
  }

  double get currentValue => state.isEmpty ? 0 : state.last;
}
