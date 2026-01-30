import 'package:flutter/material.dart';
import 'package:maternal_infant_care/presentation/pages/onboarding_page.dart';
import 'package:maternal_infant_care/presentation/widgets/animated_wave_background.dart';

class LandingPage extends StatefulWidget {
	const LandingPage({super.key});

	@override
	State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
		with SingleTickerProviderStateMixin {
	late final AnimationController _textController;

	@override
	void initState() {
		super.initState();
		_textController = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 900),
		)..forward();
	}

	@override
	void dispose() {
		_textController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			backgroundColor: colorScheme.surface,
			body: Stack(
				children: [
					const AnimatedWaveBackground(
						colors: [
							Color(0x33FFD700),
							Color(0x33CD853F),
							Color(0x33800000),
						],
					),
					SafeArea(
						child: Padding(
							padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									const Spacer(),
									FadeTransition(
										opacity: _textController,
										child: SlideTransition(
											position: Tween<Offset>(
												begin: const Offset(0, 0.08),
												end: Offset.zero,
											).animate(CurvedAnimation(
												parent: _textController,
												curve: Curves.easeOutCubic,
											)),
											child: Column(
												children: [
													Text(
														'Vatsalya',
														style: Theme.of(context)
																.textTheme
																.headlineMedium
																?.copyWith(
																	fontWeight: FontWeight.bold,
																	color: colorScheme.primary,
																	letterSpacing: 1.6,
																),
														textAlign: TextAlign.center,
													),
													const SizedBox(height: 8),
													Text(
														'Your mindful companion for mother & child care',
														style: Theme.of(context)
																.textTheme
																.bodyLarge
																?.copyWith(
																	color: colorScheme.onSurface
																			.withOpacity(0.7),
																	height: 1.3,
																),
														textAlign: TextAlign.center,
													),
												],
											),
										),
									),
									const Spacer(),
									ElevatedButton(
										onPressed: () {
											Navigator.of(context).pushReplacement(
												MaterialPageRoute(
													builder: (_) => const OnboardingPage(),
												),
											);
										},
										style: ElevatedButton.styleFrom(
											backgroundColor: colorScheme.secondary,
											foregroundColor: Colors.white,
											padding: const EdgeInsets.symmetric(vertical: 16),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(16),
											),
										),
										child: const Text(
											'Get Started',
											style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

