import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeoDimension',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark().copyWith(
          primary: Colors.cyanAccent,
          secondary: Colors.purpleAccent,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            foreground:
                Paint()
                  ..shader = LinearGradient(
                    colors: [Colors.cyanAccent, Colors.purpleAccent],
                  ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.white70,
            height: 1.8,
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat();

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              // Parallax App Bar
              // SliverAppBar(
              //   expandedHeight: constraints.maxHeight * 0.7,
              //   floating: false,
              //   pinned: true,
              //   flexibleSpace: FlexibleSpaceBar(
              //     title: Text(
              //       'NEO-DIMENSION',
              //       style: TextStyle(
              //         fontWeight: FontWeight.w900,
              //         letterSpacing: 4,
              //       ),
              //     ),
              //     background: _buildHeroBackground(),
              //   ),
              // ),

              // Main Content
              SliverToBoxAdapter(
                child: ResponsiveGrid(
                  children: [
                    FeatureCard(
                      title: 'Quantum Interface',
                      description:
                          'Adaptive surfaces that reshape based on cognitive input',
                      icon: Icons.auto_awesome,
                    ),
                    FeatureCard(
                      title: 'Neural Sync',
                      description:
                          'Biometric integration for thought-controlled navigation',
                      icon: Icons.science,
                    ),
                    FeatureCard(
                      title: 'Holographic Matrix',
                      description:
                          'Volumetric displays with spatial recognition',
                      icon: Icons.visibility_outlined,
                    ),
                    FeatureCard(
                      title: 'Chrono Stream',
                      description:
                          'Temporal data visualization across multiple timelines',
                      icon: Icons.timeline,
                    ),
                    FeatureCard(
                      title: 'Nano Fabrication',
                      description:
                          'Molecular-scale adaptive material generation',
                      icon: Icons.construction,
                    ),
                    FeatureCard(
                      title: 'Ethereal Network',
                      description: 'Quantum-entangled communication protocol',
                      icon: Icons.language,
                    ),
                  ],
                ),
              ),

              // Glass Morphism Section
              SliverToBoxAdapter(
                child: Container(
                  height: constraints.maxHeight * 0.8,
                  child: GlassMorphismSection(),
                ),
              ),

              // Footer
              SliverToBoxAdapter(child: FooterSection()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    stops: [0.1, 1.0],
                    radius: _animation.value * 0.8,
                  ),
                ),
              ),
            );
          },
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.black],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxHeight > 0) {
                    return CustomPaint(
                      painter: ParticlePainter(_animation.value),
                    );
                  }
                  return SizedBox();
                },
              );
            },
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Beyond Digital Horizons',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 30),
              AnimatedButton(),
            ],
          ),
        ),
      ],
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double time;

  ParticlePainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rnd = Random();
    final paint =
        Paint()
          ..color = Colors.cyanAccent.withOpacity(0.3)
          ..blendMode = BlendMode.plus;

    for (int i = 0; i < 100; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final radius = rnd.nextDouble() * 3 + 1;
      final offset = Offset(x, y);

      canvas.drawCircle(offset, radius, paint);
    }

    // Draw animated connection lines
    for (int i = 0; i < 30; i++) {
      final startX = rnd.nextDouble() * size.width;
      final startY = rnd.nextDouble() * size.height;
      final endX = startX + sin(time * 2 * pi + i) * 50;
      final endY = startY + cos(time * 2 * pi + i) * 50;

      final linePaint =
          Paint()
            ..color = Colors.purpleAccent.withOpacity(0.2)
            ..strokeWidth = 0.8
            ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedButton extends StatefulWidget {
  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _btnController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _btnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _btnController.forward(),
      onTapUp: (_) => _btnController.reverse(),
      onTapCancel: () => _btnController.reverse(),
      onTap: () {},
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [Colors.cyanAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            'ACTIVATE SYSTEM',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.black,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(0.2),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade900.withOpacity(0.7),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: Colors.cyanAccent),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;

  ResponsiveGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 2;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: children,
        );
      },
    );
  }
}

class GlassMorphismSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated background
        Positioned.fill(
          child: AnimatedContainer(
            duration: Duration(seconds: 30),
            decoration: BoxDecoration(
              gradient: SweepGradient(
                center: Alignment.center,
                colors: [
                  Colors.purple.withOpacity(0.1),
                  Colors.transparent,
                  Colors.cyan.withOpacity(0.1),
                  Colors.transparent,
                  Colors.purple.withOpacity(0.1),
                ],
                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // Glass cards
        Center(
          child: Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              GlassCard(title: 'Synaptic Processor', value: '9.8 THz'),
              GlassCard(title: 'Neural Latency', value: '0.4ms'),
              GlassCard(title: 'Quantum Bandwidth', value: '128 ZB/s'),
            ],
          ),
        ),
      ],
    );
  }
}

class GlassCard extends StatelessWidget {
  final String title;
  final String value;

  const GlassCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    foreground:
                        Paint()
                          ..shader = LinearGradient(
                            colors: [Colors.cyanAccent, Colors.purpleAccent],
                          ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.black, Colors.purple.withOpacity(0.1)],
        ),
      ),
      child: Column(
        children: [
          Text(
            'QUANTUM INTERFACE SYSTEM v2.7',
            style: TextStyle(letterSpacing: 3, color: Colors.white54),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 30,
            runSpacing: 20,
            children: [
              Icon(Icons.circle, color: Colors.cyanAccent, size: 10),
              Icon(Icons.circle, color: Colors.purpleAccent, size: 10),
              Icon(Icons.circle, color: Colors.cyanAccent, size: 10),
            ],
          ),
          SizedBox(height: 30),
          Text(
            '© 2025 NEO-DIMENSION | HYPERSPACE TECHNOLOGIES',
            style: TextStyle(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
