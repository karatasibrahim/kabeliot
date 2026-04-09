class TbDevice {
  const TbDevice({required this.id, required this.name, required this.type});

  final String id;
  final String name;
  final String type;

  factory TbDevice.fromJson(Map<String, dynamic> json) => TbDevice(
        id: (json['id'] as Map<String, dynamic>)['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String? ?? 'default',
      );
}

class TbCredentials {
  const TbCredentials({required this.credentialsId});

  /// MQTT access token (username for TB MQTT broker)
  final String credentialsId;

  factory TbCredentials.fromJson(Map<String, dynamic> json) => TbCredentials(
        credentialsId: json['credentialsId'] as String,
      );
}

class TbTelemetryEntry {
  const TbTelemetryEntry({required this.ts, required this.value});

  final int ts;
  final dynamic value;
}
