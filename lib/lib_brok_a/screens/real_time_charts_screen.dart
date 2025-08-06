import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RealTimeChartsScreen extends StatefulWidget {
  const RealTimeChartsScreen({super.key});

  @override
  State<RealTimeChartsScreen> createState() => _RealTimeChartsScreenState();
}

class _RealTimeChartsScreenState extends State<RealTimeChartsScreen> {
  List<_SensorData> data = [];
  late ChartSeriesController _chartSeriesController;

  @override
  void initState() {
    super.initState();
    // Simulate real-time data
    Future.delayed(Duration(seconds: 2), updateDataSource);
  }

  void updateDataSource() {
    final now = DateTime.now();
    final newData = _SensorData(now, (20 + (5 * now.second % 10)));
    setState(() {
      data.add(newData);
      if (data.length > 20) data.removeAt(0);
      _chartSeriesController.updateDataSource(
        addedDataIndex: data.length - 1,
        removedDataIndex: 0,
      );
    });
    Future.delayed(Duration(seconds: 2), updateDataSource);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Sensor Data'),
      ),
      body: SfCartesianChart(
        series: <LineSeries<_SensorData, DateTime>>[
          LineSeries<_SensorData, DateTime>(
            dataSource: data,
            xValueMapper: (_SensorData sensor, _) => sensor.time,
            yValueMapper: (_SensorData sensor, _) => sensor.value,
            onRendererCreated: (controller) => _chartSeriesController = controller,
          ),
        ],
        primaryXAxis: DateTimeAxis(),
      ),
    );
  }
}

class _SensorData {
  final DateTime time;
  final double value;

  _SensorData(this.time, this.value);
}
