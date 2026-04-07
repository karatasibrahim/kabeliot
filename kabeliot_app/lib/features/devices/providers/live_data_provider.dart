import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/mqtt/mqtt_providers.dart';

part 'live_data_provider.g.dart';

const _historyLength = 60;

/// Belirli bir sensör için son 60 anlık değeri tutar.
/// MQTT bağlıysa gerçek veri, bağlı değilse simülasyon fallback.
@riverpod
class LiveSensorData extends _$LiveSensorData {
  @override
  List<double> build(String deviceId, int sensorIndex) {
    final initial = List<double>.filled(_historyLength, _initialValue(sensorIndex));

    // sensorValueStream: MQTT bağlıysa gerçek, değilse simülasyon
    ref.listen(sensorValueStreamProvider(deviceId, sensorIndex), (_, next) {
      next.whenData((value) {
        state = [...state.skip(1), value];
      });
    });

    return initial;
  }

  double get currentValue => state.isEmpty ? 0 : state.last;

  static double _initialValue(int idx) => switch (idx % 11) {
        0 => 22.5,
        1 => 58.0,
        2 => 1013.0,
        3 => 220.0,
        4 => 4.5,
        5 => 3200.0,
        6 => 450.0,
        7 => 85.0,
        8 => 12.3,
        9 => 8.5,
        _ => 50.0,
      };
}
