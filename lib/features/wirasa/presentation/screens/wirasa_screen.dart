import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/wirasa/domain/madhhab.dart';
import 'package:muslim_ultra/features/wirasa/domain/heirs.dart';
import 'package:muslim_ultra/features/wirasa/presentation/providers/wirasa_providers.dart';

class WirasaScreen extends ConsumerStatefulWidget {
  const WirasaScreen({super.key});

  @override
  ConsumerState<WirasaScreen> createState() => _WirasaScreenState();
}

class _WirasaScreenState extends ConsumerState<WirasaScreen> {
  bool _showResults = false;

  @override
  Widget build(BuildContext context) {
    final selectedMadhhab = ref.watch(madhhabProvider);
    final heirs = ref.watch(heirsInputProvider);
    final calculation = ref.watch(wirasaCalculationProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final madhhabDetails = MadhhabDetails.forType(selectedMadhhab);

    return Scaffold(
      backgroundColor: AppColors.sandBackground,
      appBar: AppBar(
        backgroundColor: AppColors.midnightNavy,
        elevation: 0,
        title: Text(
          _t(context, 'wirasaTitle', 'Inheritance Calculator (Wirasa)'),
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.gold),
            tooltip: _t(context, 'reset', 'Reset'),
            onPressed: () {
              ref.read(heirsInputProvider.notifier).reset();
              setState(() {
                _showResults = false;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Madhhab selector card
            _buildMadhhabCard(context, selectedMadhhab, madhhabDetails, locale),
            const SizedBox(height: 16),

            // Heir counters section
            _buildSectionHeader(
              context,
              _t(context, 'enterHeirs', 'Enter Heirs of the Deceased'),
              Icons.people_outline,
            ),
            const SizedBox(height: 12),

            // Spouse section
            _buildCategoryCard(
              context,
              title: _t(context, 'spouseCategory', 'Spouse (Select One)'),
              children: [
                _buildRadioOrCounter(
                  title: _t(context, 'husband', 'Husband'),
                  value: heirs.husband,
                  maxValue: 1,
                  onChanged: (val) {
                    ref.read(heirsInputProvider.notifier).setHusband(val);
                  },
                ),
                const Divider(height: 1),
                _buildRadioOrCounter(
                  title: _t(context, 'wives', 'Wife / Wives (max 4)'),
                  value: heirs.wives,
                  maxValue: 4,
                  onChanged: (val) {
                    ref.read(heirsInputProvider.notifier).setWives(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Parents section
            _buildCategoryCard(
              context,
              title: _t(context, 'parentsCategory', 'Parents'),
              children: [
                _buildRadioOrCounter(
                  title: _t(context, 'father', 'Father'),
                  value: heirs.father,
                  maxValue: 1,
                  onChanged: (val) {
                    ref.read(heirsInputProvider.notifier).setFather(val);
                  },
                ),
                const Divider(height: 1),
                _buildRadioOrCounter(
                  title: _t(context, 'mother', 'Mother'),
                  value: heirs.mother,
                  maxValue: 1,
                  onChanged: (val) {
                    ref.read(heirsInputProvider.notifier).setMother(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Children section
            _buildCategoryCard(
              context,
              title: _t(context, 'childrenCategory', 'Children'),
              children: [
                _buildRadioOrCounter(
                  title: _t(context, 'sons', 'Sons'),
                  value: heirs.sons,
                  maxValue: 30,
                  onChanged: (val) {
                    ref.read(heirsInputProvider.notifier).setSons(val);
                  },
                ),
                const Divider(height: 1),
                _buildRadioOrCounter(
                  title: _t(context, 'daughters', 'Daughters'),
                  value: heirs.daughters,
                  maxValue: 30,
                  onChanged: (val) {
                    ref.read(heirsInputProvider.notifier).setDaughters(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Grandparents section
            _buildCategoryCard(
              context,
              title: _t(context, 'grandparentsCategory', 'Grandparents'),
              children: [
                _buildRadioOrCounter(
                  title: _t(context, 'paternalGrandfather', 'Paternal Grandfather'),
                  value: heirs.paternalGrandfather,
                  maxValue: 1,
                  onChanged: (val) {
                    ref.read(heirsInputProvider.notifier).setPaternalGrandfather(val);
                  },
                ),
                const Divider(height: 1),
                _buildRadioOrCounter(
                  title: _t(context, 'paternalGrandmother', 'Paternal Grandmother (Father\'s Mother)'),
                  value: heirs.paternalGrandmother,
                  maxValue: 1,
                  onChanged: (val) {
                    ref.read(heirsInputProvider.notifier).setPaternalGrandmother(val);
                  },
                ),
                const Divider(height: 1),
                _buildRadioOrCounter(
                  title: _t(context, 'maternalGrandmother', 'Maternal Grandmother (Mother\'s Mother)'),
                  value: heirs.maternalGrandmother,
                  maxValue: 1,
                  onChanged: (val) {
                    ref.read(heirsInputProvider.notifier).setMaternalGrandmother(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Siblings section
            _buildCategoryCard(
              context,
              title: _t(context, 'siblingsCategory', 'Siblings'),
              children: [
                _buildRadioOrCounter(
                  title: _t(context, 'fullBrothers', 'Full Brothers'),
                  value: heirs.fullBrothers,
                  maxValue: 30,
                  onChanged: (val) {
                    ref.read(heirsInputProvider.notifier).setFullBrothers(val);
                  },
                ),
                const Divider(height: 1),
                _buildRadioOrCounter(
                  title: _t(context, 'fullSisters', 'Full Sisters'),
                  value: heirs.fullSisters,
                  maxValue: 30,
                  onChanged: (val) {
                    ref.read(heirsInputProvider.notifier).setFullSisters(val);
                  },
                ),
                const Divider(height: 1),
                _buildRadioOrCounter(
                  title: _t(context, 'maternalSiblings', 'Maternal Siblings (Brother/Sister from Mother)'),
                  value: heirs.maternalSiblings,
                  maxValue: 30,
                  onChanged: (val) {
                    ref.read(heirsInputProvider.notifier).setMaternalSiblings(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Calculate Button
            ElevatedButton(
              key: const Key('calculate_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.midnightNavy,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  _showResults = true;
                });
              },
              child: Text(
                _t(context, 'calculateShares', 'Calculate Estate Distribution'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Results View
            if (_showResults) ...[
              _buildResultsSection(context, calculation, madhhabDetails, locale),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMadhhabCard(
    BuildContext context,
    FiqhMadhhab selected,
    MadhhabDetails details,
    String locale,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined, color: AppColors.midnightNavy),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _t(context, 'madhhabTitle', 'School of Fiqh (Madhhab)'),
                  style: const TextStyle(
                    color: AppColors.midnightNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _t(
              context,
              'madhhabSubtitle',
              'Select the fiqh you follow. Where scholars differ, calculation follows your selection.',
            ),
            style: TextStyle(
              color: AppColors.midnightNavy.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<FiqhMadhhab>(
            key: const Key('madhhab_dropdown'),
            isExpanded: true,
            initialValue: selected,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
              ),
            ),
            items: FiqhMadhhab.values.map((m) {
              final d = MadhhabDetails.forType(m);
              return DropdownMenuItem(
                value: m,
                child: Text(
                  '${d.localizedName(locale)} — ${d.localizedImam(locale)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.midnightNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                ref.read(madhhabProvider.notifier).setMadhhab(val);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.midnightNavy, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.midnightNavy,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.midnightNavy,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRadioOrCounter({
    required String title,
    required int value,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.midnightNavy,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 22, color: AppColors.midnightNavy),
            visualDensity: VisualDensity.compact,
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 28),
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.midnightNavy,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.gold),
            visualDensity: VisualDensity.compact,
            onPressed: value < maxValue ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(
    BuildContext context,
    CalculationResult result,
    MadhhabDetails madhhabDetails,
    String locale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Result Header
        _buildSectionHeader(
          context,
          _t(context, 'distributionResults', 'Distribution Breakdown'),
          Icons.pie_chart_outline,
        ),
        const SizedBox(height: 8),

        // Madhhab banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.midnightNavy,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.gavel, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_t(context, 'calculatedPer', 'Calculated per')} ${madhhabDetails.localizedName(locale)} (${madhhabDetails.localizedImam(locale)})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Mandatory Scholar Disclaimer Box
        _buildScholarDisclaimer(context),
        const SizedBox(height: 12),

        if (!result.isCovered) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Column(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 36),
                const SizedBox(height: 8),
                Text(
                  _t(context, 'caseNeedsScholar', 'This case needs a scholar — calculation not covered'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.midnightNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (result.unhandledReason != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    result.unhandledReason!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.midnightNavy.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ] else if (result.shares.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _t(context, 'noHeirsEntered', 'No heirs entered.'),
                style: const TextStyle(
                  color: AppColors.midnightNavy,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ] else ...[
          // Share cards
          ...result.shares.map((share) => _buildShareCard(context, share, locale)),

          // Notes / Ikhtilaf Explanation
          if (_getLocalizedNotes(result, locale).isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.midnightNavy),
                      const SizedBox(width: 6),
                      Text(
                        _t(context, 'fiqhNotes', 'Fiqh Rules Applied & Notes'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.midnightNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ..._getLocalizedNotes(result, locale).map(
                    (note) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: AppColors.midnightNavy, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              note,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.midnightNavy.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildScholarDisclaimer(BuildContext context) {
    return Container(
      key: const Key('scholar_disclaimer'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.menu_book, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _t(
                context,
                'scholarDisclaimer',
                'Educational estimate only — verify with a qualified mufti before any real distribution.',
              ),
              style: const TextStyle(
                color: AppColors.midnightNavy,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareCard(BuildContext context, HeirShare share, String locale) {
    final localizedTitle = share.localizedTitle(locale);
    final countLabel = share.count > 1 ? ' (${share.count})' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.midnightNavy.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$localizedTitle$countLabel',
                  style: const TextStyle(
                    color: AppColors.midnightNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${share.totalPercentage.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    color: AppColors.midnightNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_t(context, 'shareBasis', 'Share')}: ${share.baseFraction}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.midnightNavy.withValues(alpha: 0.7),
                ),
              ),
              if (share.count > 1)
                Text(
                  '${share.perPersonPercentage.toStringAsFixed(2)}% ${_t(context, 'perPerson', 'each')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.midnightNavy.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_t(context, 'evidence', 'Source')}: ${share.quranicBasis}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.midnightNavy.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getLocalizedNotes(CalculationResult result, String locale) {
    switch (locale) {
      case 'ar':
        return result.notesAr.isNotEmpty ? result.notesAr : result.notesEn;
      case 'ur':
        return result.notesUr.isNotEmpty ? result.notesUr : result.notesEn;
      default:
        return result.notesEn;
    }
  }

  String _t(BuildContext context, String key, String fallback) {
    return fallback;
  }
}
