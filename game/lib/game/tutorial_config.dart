import 'package:mg_common_game/systems/tutorial/tutorial.dart';

const kOnboardingTutorial = TutorialSequence(
  id: 'onboarding',
  name: 'Simple Tower Defense Tutorial',
  steps: [
    TutorialStep(
      id: 'welcome',
      title: 'Welcome',
      description:
          'Learn the main goal and the first action before starting a run.',
    ),
    TutorialStep(
      id: 'core_action',
      title: 'Core Action',
      description:
          'Use the highlighted action to create progress during the session.',
    ),
    TutorialStep(
      id: 'reward',
      title: 'Rewards',
      description:
          'Complete objectives to earn currency, experience, and unlocks.',
    ),
    TutorialStep(
      id: 'return_loop',
      title: 'Return Stronger',
      description:
          'Upgrade, return to the next level, and repeat the loop with higher pressure.',
    ),
  ],
);
