import 'package:flutter/material.dart';

class DeviceControlCard extends StatelessWidget {
  final String deviceName;
  final bool status;
  final Function(bool) onToggle;

  const DeviceControlCard({
    super.key,
    required this.deviceName,
    required this.status,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(deviceName),
        trailing: Switch(
          value: status,
          onChanged: onToggle,
        ),
      ),
    );
  }
}
