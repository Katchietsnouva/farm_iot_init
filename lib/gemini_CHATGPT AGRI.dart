import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// To use google_fonts and smooth_page_indicator, add them to your pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   google_fonts: ^6.2.1
//   smooth_page_indicator: ^1.1.0

void main() {
  runApp(const FuturisticApp());
}

// Main application widget using the Agro-Nexus theme for consistency.
class FuturisticApp extends StatelessWidget {
  const FuturisticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agro-Nexus Interface',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xff0a0a0a),
        scaffoldBackgroundColor: const Color(0xff0a0a0a),
        textTheme: GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff00ff88), // Vibrant Green
          secondary: Color(0xfff0a000), // Amber/Orange
          surface: Color(0xff1a1a1a),
        ),
      ),
      home: const ShellPage(),
    );
  }
}

// This is the main shell of the app, controlling the top-level PageView.
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> with TickerProviderStateMixin {
  late final AnimationController _orbController;
  late final Animation<double> _orbAnimation;
  final PageController _mainPageController = PageController();

  @override
  void initState() {
    super.initState();
    // Animation controller for the orb on the first page.
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _orbAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _orbController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _orbController.dispose();
    _mainPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The two main pages of the application.
    final List<Widget> mainPages = [
      AgroNexusPage(animation: _orbAnimation),
      const SmartFarmPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _mainPageController,
                children: mainPages,
              ),
            ),
            // Main indicator for the two top-level pages.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SmoothPageIndicator(
                controller: _mainPageController,
                count: mainPages.length,
                effect: WormEffect(
                  dotColor: Colors.grey.shade800,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotHeight: 10,
                  dotWidth: 10,
                  type: WormType.thin,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A reusable adaptive layout widget.
class AdaptiveLayout extends StatelessWidget {
  final List<Widget> pages;
  const AdaptiveLayout({super.key, required this.pages});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();

    return LayoutBuilder(
      builder: (context, constraints) {
        // WIDE SCREEN LAYOUT: Shows content in columns.
        if (constraints.maxWidth > 1200) {
          return Row(
            children: [
              if (pages.isNotEmpty) Expanded(child: pages[0]),
              if (pages.length > 1)
                const VerticalDivider(width: 1, color: Color(0x4400bfae)),
              if (pages.length > 1) Expanded(child: pages[1]),
              if (pages.length > 2)
                const VerticalDivider(width: 1, color: Color(0x4400bfae)),
              if (pages.length > 2) Expanded(child: pages[2]),
            ],
          );
        }
        // NARROW SCREEN LAYOUT: Shows content in a swipeable PageView.
        else {
          return Column(
            children: [
              Expanded(
                child: PageView(controller: pageController, children: pages),
              ),
              // Sub-indicator for the pages within this section.
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0, top: 16.0),
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: pages.length,
                  effect: ExpandingDotsEffect(
                    dotColor: Colors.grey.shade700,
                    activeDotColor: Theme.of(context).colorScheme.secondary,
                    dotHeight: 6,
                    dotWidth: 6,
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

// A reusable frosted glass widget.
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

// ===================================================================
// == PAGE 1: AGRO-NEXUS INTERFACE (Your original design)
// ===================================================================

class AgroNexusPage extends StatelessWidget {
  final Animation<double> animation;
  const AgroNexusPage({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ContentPageOne(animation: animation),
      const ContentPageTwo(),
      const ContentPageThree(),
    ];
    return AdaptiveLayout(pages: pages);
  }
}

// --- CONTENT PAGE 1: The AGRO-NEXUS Core ---
class ContentPageOne extends StatelessWidget {
  final Animation<double> animation;
  const ContentPageOne({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: animation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.7),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Spacer(),
          Text(
            'AGRO-NEXUS CORE',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Theme.of(context).colorScheme.primary,
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Drone fleet synchronized. Soil sensor network at 100%. Awaiting cultivation parameters.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// --- CONTENT PAGE 2: Live Field Data Streams ---
class ContentPageTwo extends StatelessWidget {
  const ContentPageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Field Data Streams',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Theme.of(context).colorScheme.secondary,
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Real-time crop health and environmental metrics.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: const [
                DataStreamItem(
                  title: 'Soil Moisture Saturation',
                  value: 0.85,
                  success: true,
                ),
                DataStreamItem(
                  title: 'Photosynthesis Efficiency',
                  value: 0.95,
                  success: true,
                ),
                DataStreamItem(
                  title: 'Pest Infestation Probability',
                  value: 0.12,
                  success: true,
                ),
                DataStreamItem(
                  title: 'Nutrient Level Analysis',
                  value: 0.75,
                  success: true,
                ),
                DataStreamItem(
                  title: 'Automated Irrigation Cycles',
                  value: 0.33,
                  success: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DataStreamItem extends StatelessWidget {
  final String title;
  final double value;
  final bool success;

  const DataStreamItem({
    super.key,
    required this.title,
    required this.value,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: FrostedGlassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          success
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(value * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          success
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CONTENT PAGE 3: The Global Harvest Network ---
class ContentPageThree extends StatelessWidget {
  const ContentPageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Global Harvest Network',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Theme.of(context).colorScheme.primary,
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Interlinked autonomous farming operations.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FrostedGlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Icon(
                    Icons.agriculture_outlined,
                    size: 150,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NetworkStat(value: '1.2M', label: 'Active Harvesters'),
              NetworkStat(value: '99.98%', label: 'Network Integrity'),
              NetworkStat(value: '+12%', label: 'Yield Forecast'),
            ],
          ),
        ],
      ),
    );
  }
}

class NetworkStat extends StatelessWidget {
  final String value;
  final String label;
  const NetworkStat({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }
}

// ===================================================================
// == PAGE 2: SMART FARMING INTERFACE (The code you provided)
// ===================================================================

class SmartFarmPage extends StatelessWidget {
  const SmartFarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const OverviewPage(),
      const SensorsPage(),
      const DataInsightsPage(),
    ];
    return AdaptiveLayout(pages: pages);
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
          const Text(
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
          const Text(
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: FrostedGlassCard(
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
          const Text(
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
                children: [
                  const Text(
                    'Crop Yield Prediction',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Based on historical data, weather forecasts, and soil health.',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  LinearProgressIndicator(
                    value: 0.75,
                    color: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.white12,
                  ),
                  const SizedBox(height: 16),
                  const Text(
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
