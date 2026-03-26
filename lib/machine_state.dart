class MachineState {
  final double currentTemp;
  final double targetTemp;
  final double rpm;
  final double pressure;
  final int usageMin;
  final String filamentStatus;
  final bool heaterOn;
  final bool machineConnected;
  final DateTime? lastUpdated;

  const MachineState({
    required this.currentTemp,
    required this.targetTemp,
    required this.rpm,
    required this.pressure,
    required this.usageMin,
    required this.filamentStatus,
    required this.heaterOn,
    required this.machineConnected,
    required this.lastUpdated,
  });

  factory MachineState.initial() {
    return const MachineState(
      currentTemp: 0,
      targetTemp: 0,
      rpm: 0,
      pressure: 0,
      usageMin: 0,
      filamentStatus: 'Sin datos',
      heaterOn: false,
      machineConnected: false,
      lastUpdated: null,
    );
  }

  MachineState copyWith({
    double? currentTemp,
    double? targetTemp,
    double? rpm,
    double? pressure,
    int? usageMin,
    String? filamentStatus,
    bool? heaterOn,
    bool? machineConnected,
    DateTime? lastUpdated,
  }) {
    return MachineState(
      currentTemp: currentTemp ?? this.currentTemp,
      targetTemp: targetTemp ?? this.targetTemp,
      rpm: rpm ?? this.rpm,
      pressure: pressure ?? this.pressure,
      usageMin: usageMin ?? this.usageMin,
      filamentStatus: filamentStatus ?? this.filamentStatus,
      heaterOn: heaterOn ?? this.heaterOn,
      machineConnected: machineConnected ?? this.machineConnected,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory MachineState.fromJson(Map<String, dynamic> json) {
    return MachineState(
      currentTemp: _asDouble(json['temp'] ?? json['currentTemp']),
      targetTemp: _asDouble(json['targetTemp'] ?? json['setpoint']),
      rpm: _asDouble(json['rpm']),
      pressure: _asDouble(json['pressure']),
      usageMin: _asInt(json['usageMin'] ?? json['usage']),
      filamentStatus:
          (json['filament'] ?? json['filamentStatus'] ?? 'Sin datos')
              .toString(),
      heaterOn: _asBool(json['heaterOn'] ?? json['power']),
      machineConnected: _asBool(json['connected'] ?? true),
      lastUpdated: DateTime.now(),
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _asInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    final raw = value?.toString().toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'on';
  }
}
