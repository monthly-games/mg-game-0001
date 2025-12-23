import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();

  static Future<bool> hasSeenTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorial_completed') ?? false;
  }

  static Future<void> markTutorialComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
  }
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<TutorialStep> _steps = const [
    TutorialStep(
      title: 'Welcome to Tower Defense!',
      description: 'Build towers to defend against waves of monsters',
      icon: Icons.account_balance,
      iconPosition: Alignment.center,
    ),
    TutorialStep(
      title: 'Build Towers',
      description: 'Tap the BUILD button, select a tower type, then place it on the map',
      icon: Icons.add_business,
      iconPosition: Alignment.bottomCenter,
    ),
    TutorialStep(
      title: 'Manage Your Economy',
      description: 'Earn gold by defeating monsters. Use it wisely to upgrade towers!',
      icon: Icons.monetization_on,
      iconPosition: Alignment.topRight,
    ),
    TutorialStep(
      title: 'Start the Wave',
      description: 'When ready, tap NEXT WAVE to send monsters. Don\'t let them reach the end!',
      icon: Icons.play_arrow,
      iconPosition: Alignment.centerRight,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _completeTutorial();
    }
  }

  Future<void> _completeTutorial() async {
    await TutorialOverlay.markTutorialComplete();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: step.iconPosition,
                  child: Icon(
                    step.icon,
                    size: 100,
                    color: const Color(0xFFFFD700), // Gold color
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      step.description,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Progress indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _steps.length,
                        (index) => Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == _currentStep
                                ? const Color(0xFFFFD700)
                                : Colors.white30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Next button
                    SizedBox(
                      width: 200,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _currentStep == _steps.length - 1
                              ? 'START DEFENSE'
                              : 'NEXT',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Skip button
                    if (_currentStep < _steps.length - 1)
                      TextButton(
                        onPressed: _completeTutorial,
                        child: const Text(
                          'Skip Tutorial',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Alignment iconPosition;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconPosition,
  });
}
