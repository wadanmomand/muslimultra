import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/home/presentation/screens/app_shell.dart';
import 'package:muslim_ultra/features/onboarding/presentation/providers/onboarding_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedGoal = 'understand_quran';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    await ref
        .read(onboardingCompletedProvider.notifier)
        .complete(learningGoal: _selectedGoal);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      await Geolocator.requestPermission();
    } catch (_) {}
    _nextPage();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress Bar / Stepper Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _currentPage
                              ? AppColors.gold
                              : (isDark
                                  ? AppColors.midnightNavyBorder
                                  : AppColors.sandBorder),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (i < 2) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildLanguageStep(context, l10n, isDark, currentLocale),
                  _buildLocationStep(context, l10n, isDark),
                  _buildGoalStep(context, l10n, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: Language Selection
  Widget _buildLanguageStep(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    Locale currentLocale,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.language_rounded,
              color: AppColors.gold,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.onboardingStepLanguageTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingStepLanguageSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color:
                  isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          _buildLanguageOption(
            key: const Key('lang_option_en'),
            title: 'English',
            subtitle: 'English interface & translations',
            code: 'en',
            isSelected: currentLocale.languageCode == 'en',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildLanguageOption(
            key: const Key('lang_option_ar'),
            title: 'العربية',
            subtitle: 'الواجهة والتفاسير باللغة العربية',
            code: 'ar',
            isSelected: currentLocale.languageCode == 'ar',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildLanguageOption(
            key: const Key('lang_option_ur'),
            title: 'اردو',
            subtitle: 'اردو زبان میں ترجمہ اور تفاسیر',
            code: 'ur',
            isSelected: currentLocale.languageCode == 'ur',
            isDark: isDark,
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              key: const Key('language_continue_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.midnightNavyDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _nextPage,
              child: Text(
                l10n.onboardingContinue,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required Key key,
    required String title,
    required String subtitle,
    required String code,
    required bool isSelected,
    required bool isDark,
  }) {
    return Material(
      color: isSelected
          ? (isDark ? AppColors.midnightNavyCardElevated : AppColors.sandCardElevated)
          : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppColors.gold
              : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
          width: isSelected ? 1.8 : 1,
        ),
      ),
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ref.read(localeProvider.notifier).setLanguage(code);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.sandTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.sandTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? AppColors.gold
                    : (isDark
                        ? AppColors.darkTextMuted
                        : AppColors.sandTextSecondary),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STEP 2: Location Permission (Needed for prayer times; skippable)
  Widget _buildLocationStep(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.gold,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.onboardingStepLocationTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingStepLocationSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color:
                  isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              key: const Key('location_enable_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.midnightNavyDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _requestLocationPermission,
              child: Text(
                l10n.onboardingLocationEnableBtn,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            key: const Key('location_skip_button'),
            onPressed: _nextPage,
            child: Text(
              l10n.onboardingLocationSkipBtn,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.sandTextSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: Learning Goal
  Widget _buildGoalStep(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: AppColors.gold,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.onboardingStepGoalTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingStepGoalSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color:
                  isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          _buildGoalOption(
            key: const Key('goal_option_understand_quran'),
            title: l10n.onboardingGoalUnderstandQuran,
            subtitle: l10n.onboardingGoalUnderstandQuranDesc,
            goalKey: 'understand_quran',
            icon: Icons.menu_book_outlined,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildGoalOption(
            key: const Key('goal_option_build_habits'),
            title: l10n.onboardingGoalBuildHabits,
            subtitle: l10n.onboardingGoalBuildHabitsDesc,
            goalKey: 'build_habits',
            icon: Icons.check_circle_outline,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildGoalOption(
            key: const Key('goal_option_memorize'),
            title: l10n.onboardingGoalMemorize,
            subtitle: l10n.onboardingGoalMemorizeDesc,
            goalKey: 'memorize',
            icon: Icons.bookmark_outline,
            isDark: isDark,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              key: const Key('onboarding_finish_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.midnightNavyDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _finishOnboarding,
              child: Text(
                l10n.onboardingGetStarted,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption({
    required Key key,
    required String title,
    required String subtitle,
    required String goalKey,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedGoal == goalKey;

    return Material(
      color: isSelected
          ? (isDark ? AppColors.midnightNavyCardElevated : AppColors.sandCardElevated)
          : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppColors.gold
              : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
          width: isSelected ? 1.8 : 1,
        ),
      ),
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedGoal = goalKey;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.sandTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.sandTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? AppColors.gold
                    : (isDark
                        ? AppColors.darkTextMuted
                        : AppColors.sandTextSecondary),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
