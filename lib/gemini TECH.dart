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

class FuturisticApp extends StatelessWidget {
  const FuturisticApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a dark, futuristic theme for the entire application.
    return MaterialApp(
      title: 'AURA Interface',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xff0a0a0a),
        scaffoldBackgroundColor: const Color(0xff0a0a0a),
        textTheme: GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff00ffff), // Cyan
          secondary: Color(0xfff000ff), // Magenta
          surface: Color(0xff1a1a1a),
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

// Using TickerProviderStateMixin for animations.
class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _orbController;
  late final Animation<double> _orbAnimation;

  @override
  void initState() {
    super.initState();
    // Setting up a continuous pulsing animation for the central orb.
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The main content pages that will be adapted based on screen size.
    final List<Widget> pages = [
      ContentPageOne(animation: _orbAnimation),
      const ContentPageTwo(),
      const ContentPageThree(),
    ];

    return Scaffold(body: SafeArea(child: AdaptiveLayout(pages: pages)));
  }
}

// This widget is the core of the adaptive UI.
// It uses a LayoutBuilder to decide whether to show columns or a PageView.
class AdaptiveLayout extends StatelessWidget {
  final List<Widget> pages;
  const AdaptiveLayout({super.key, required this.pages});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();

    return LayoutBuilder(
      builder: (context, constraints) {
        // WIDE SCREEN LAYOUT (e.g., desktop, large tablets in landscape)
        if (constraints.maxWidth > 1200) {
          return Row(
            children: [
              Expanded(child: pages[0]),
              const VerticalDivider(width: 1, color: Color(0x4400ffff)),
              Expanded(child: pages[1]),
              const VerticalDivider(width: 1, color: Color(0x4400ffff)),
              Expanded(child: pages[2]),
            ],
          );
        }
        // MEDIUM SCREEN LAYOUT (e.g., small tablets)
        else if (constraints.maxWidth > 800) {
          return Row(
            children: [
              Expanded(child: pages[0]),
              const VerticalDivider(width: 1, color: Color(0x4400ffff)),
              Expanded(child: pages[1]),
            ],
          );
        }
        // NARROW SCREEN LAYOUT (e.g., mobile phones)
        else {
          return Column(
            children: [
              Expanded(
                child: PageView(controller: pageController, children: pages),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SmoothPageIndicator(
                  controller: pageController,
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

// A custom frosted glass widget for a layered, futuristic look.
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

// --- CONTENT PAGE 1: The AURA Core ---
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
          // Animated central orb with glow effect.
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
                    gradient: const RadialGradient(
                      colors: [Color(0xff00ffff), Color(0x0000ffff)],
                      stops: [0.0, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff00ffff).withOpacity(0.7),
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
            'AURA CORE ONLINE',
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
            'Neural interface synchronized. Bio-integration at 100%. Awaiting cognitive input.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// --- CONTENT PAGE 2: Data Streams ---
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
            'Cognitive Streams',
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
            'Real-time synaptic feedback and data flow.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: const [
                DataStreamItem(
                  title: 'Alpha Wave Sync',
                  value: 0.92,
                  success: true,
                ),
                DataStreamItem(
                  title: 'Subconscious Matrix',
                  value: 0.78,
                  success: true,
                ),
                DataStreamItem(
                  title: 'Quantum Entanglement',
                  value: 0.41,
                  success: false,
                ),
                DataStreamItem(
                  title: 'Memory Packet #74ab',
                  value: 1.0,
                  success: true,
                ),
                DataStreamItem(
                  title: 'Emotional Resonance',
                  value: 0.65,
                  success: true,
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
    return FrostedGlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }
}

// --- CONTENT PAGE 3: The Global Network ---
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
            'Global Mind Mesh',
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
            'Decentralized consciousness network status.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FrostedGlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // Placeholder for a more complex network visualization
                child: Center(
                  child: Icon(
                    Icons.hub_outlined,
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
              NetworkStat(value: '7.8B', label: 'Nodes'),
              NetworkStat(value: '99.9%', label: 'Uptime'),
              NetworkStat(value: '1.2 ZB', label: 'Data Flow'),
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
