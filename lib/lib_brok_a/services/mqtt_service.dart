import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final MqttServerClient client;

  MqttService()
      : client = MqttServerClient('broker.hivemq.com', 'flutter_client') {
    client.setProtocolV311();
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.logging(on: false);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
  }

  Future<void> connect() async {
    try {
      await client.connect();
    } catch (e) {
      print('Connection failed: $e');
      client.disconnect();
    }
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atMostOnce);
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>> getMessageStream() {
    return client.updates!;
  }

  static void onConnected() => print('MQTT Connected');
  static void onDisconnected() => print('MQTT Disconnected');
}
