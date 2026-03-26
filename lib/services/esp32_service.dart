import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../machine_state.dart';

enum SocketStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class SocketSnapshot {
  final SocketStatus status;
  final String endpoint;
  final String? message;

  const SocketSnapshot({
    required this.status,
    required this.endpoint,
    this.message,
  });
}

class Esp32Service {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  String _endpoint = '';

  final StreamController<MachineState> _telemetryController =
      StreamController<MachineState>.broadcast();
  final StreamController<SocketSnapshot> _connectionController =
      StreamController<SocketSnapshot>.broadcast();

  Stream<MachineState> get telemetryStream => _telemetryController.stream;
  Stream<SocketSnapshot> get connectionStream => _connectionController.stream;

  Future<void> connect(String endpoint) async {
    await disconnect();
    _endpoint = endpoint;

    _connectionController.add(
      SocketSnapshot(status: SocketStatus.connecting, endpoint: endpoint),
    );

    try {
      final uri = Uri.parse(endpoint);
      _channel = WebSocketChannel.connect(uri);
      _channelSubscription = _channel!.stream.listen(
        _handleMessage,
        onError: (Object error) {
          _connectionController.add(
            SocketSnapshot(
              status: SocketStatus.error,
              endpoint: _endpoint,
              message: error.toString(),
            ),
          );
        },
        onDone: () {
          _connectionController.add(
            SocketSnapshot(
              status: SocketStatus.disconnected,
              endpoint: _endpoint,
              message: 'Conexion cerrada',
            ),
          );
        },
      );

      _connectionController.add(
        SocketSnapshot(
          status: SocketStatus.connected,
          endpoint: endpoint,
          message: 'Conectado a ESP32',
        ),
      );

      requestSnapshot();
    } on FormatException {
      _connectionController.add(
        SocketSnapshot(
          status: SocketStatus.error,
          endpoint: endpoint,
          message: 'Endpoint no valido. Usa formato ws://IP:PUERTO',
        ),
      );
    } catch (error) {
      _connectionController.add(
        SocketSnapshot(
          status: SocketStatus.error,
          endpoint: endpoint,
          message: error.toString(),
        ),
      );
    }
  }

  void requestSnapshot() {
    sendCommand('get_status');
  }

  void sendCommand(String action, {Object? value}) {
    final payload = <String, dynamic>{
      'type': 'command',
      'action': action,
    };
    if (value != null) {
      payload['value'] = value;
    }

    try {
      _channel?.sink.add(jsonEncode(payload));
    } catch (error) {
      _connectionController.add(
        SocketSnapshot(
          status: SocketStatus.error,
          endpoint: _endpoint,
          message: 'No se pudo enviar el comando: $error',
        ),
      );
    }
  }

  void _handleMessage(dynamic rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage.toString());
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      final type = decoded['type']?.toString();
      if (type == null || type == 'telemetry' || type == 'status') {
        _telemetryController.add(MachineState.fromJson(decoded));
        return;
      }

      if (type == 'ack') {
        _connectionController.add(
          SocketSnapshot(
            status: SocketStatus.connected,
            endpoint: _endpoint,
            message: 'ACK: ${decoded['action'] ?? 'sin accion'}',
          ),
        );
      }
    } catch (_) {
      _connectionController.add(
        SocketSnapshot(
          status: SocketStatus.error,
          endpoint: _endpoint,
          message: 'Mensaje invalido recibido desde la ESP32',
        ),
      );
    }
  }

  Future<void> disconnect() async {
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    await _channel?.sink.close();
    _channel = null;

    if (_endpoint.isNotEmpty) {
      _connectionController.add(
        SocketSnapshot(
          status: SocketStatus.disconnected,
          endpoint: _endpoint,
        ),
      );
    }
  }

  Future<void> dispose() async {
    await disconnect();
    await _telemetryController.close();
    await _connectionController.close();
  }
}
