import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  runApp(const FuturisticAgricultureApp());
}

class FuturisticAgricultureApp extends StatelessWidget {
  const FuturisticAgricultureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farming Interface',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xff1b3c49),
        scaffoldBackgroundColor: const Color(0xff1b3c49),
        textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff00bfae), // IoT Green
          secondary: Color(0xff3d94d3), // Sky Blue
          surface: Color(0xff263238), // Dark Grey
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const OverviewPage(),
      const SensorsPage(),
      const DataInsightsPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: AdaptiveLayout(pages: pages, controller: _pageController),
      ),
    );
  }
}

class AdaptiveLayout extends StatelessWidget {
  final List<Widget> pages;
  final PageController controller;

  const AdaptiveLayout({
    super.key,
    required this.pages,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return Row(
            children: [
              Expanded(child: pages[0]),
              const VerticalDivider(width: 1, color: Color(0x4400bfae)),
              Expanded(child: pages[1]),
              const VerticalDivider(width: 1, color: Color(0x4400bfae)),
              Expanded(child: pages[2]),
            ],
          );
        } else {
          return Column(
            children: [
              Expanded(
                child: PageView(controller: controller, children: pages),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SmoothPageIndicator(
                  controller: controller,
                  count: pages.length,
                  effect: WormEffect(
                    dotColor: Colors.grey.shade800,
                    activeDotColor: Theme.of(context).colorScheme.primary,
                    dotHeight: 8,
                    dotWidth: 8,
                    type: WormType.thin,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class FrostedGlassCard extends StatelessWidget {
  final Widget child;
  const FrostedGlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            'Smart Farm Overview',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Real-time insights into your farm’s health, soil conditions, and more.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 32),
          FrostedGlassCard(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Icon(
                      Icons.agriculture,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Crop Health Monitoring',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'AI-powered crop disease prediction and growth status.',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class SensorsPage extends StatelessWidget {
  const SensorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IoT Sensors',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Live feed from IoT sensors monitoring soil moisture, temperature, and humidity.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: const [
                SensorItem(title: 'Soil Moisture', value: 60, unit: '%'),
                SensorItem(title: 'Temperature', value: 25.3, unit: '°C'),
                SensorItem(title: 'Humidity', value: 75, unit: '%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SensorItem extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  const SensorItem({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return FrostedGlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DataInsightsPage extends StatelessWidget {
  const DataInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Insights',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'AI-driven predictions and analysis for optimizing farm performance.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          FrostedGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Crop Yield Prediction',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Based on historical data, weather forecasts, and soil health.',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  SizedBox(height: 24),
                  LinearProgressIndicator(value: 0.75),
                  SizedBox(height: 16),
                  Text(
                    'Estimated Yield: 150 tons/ha',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
