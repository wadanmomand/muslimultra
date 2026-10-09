import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/zakat_calculation_result.dart';
import '../../domain/models/zakat_input.dart';
import '../providers/zakat_providers.dart';

class ZakatCalculatorScreen extends ConsumerStatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  ConsumerState<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends ConsumerState<ZakatCalculatorScreen> {
  final _goldPriceCtrl = TextEditingController();
  final _silverPriceCtrl = TextEditingController();
  final _cashCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _goldGramsCtrl = TextEditingController();
  final _silverGramsCtrl = TextEditingController();
  final _investmentsCtrl = TextEditingController();
  final _inventoryCtrl = TextEditingController();
  final _receivablesCtrl = TextEditingController();
  final _debtsCtrl = TextEditingController();
  final _expensesCtrl = TextEditingController();

  final List<String> _currencies = ['USD', 'PKR', 'SAR', 'AED', 'INR', 'GBP', 'EUR'];
  bool _initializedFromState = false;

  final _currencyFormatter = NumberFormat('#,##0.00');

  @override
  void dispose() {
    _goldPriceCtrl.dispose();
    _silverPriceCtrl.dispose();
    _cashCtrl.dispose();
    _bankCtrl.dispose();
    _goldGramsCtrl.dispose();
    _silverGramsCtrl.dispose();
    _investmentsCtrl.dispose();
    _inventoryCtrl.dispose();
    _receivablesCtrl.dispose();
    _debtsCtrl.dispose();
    _expensesCtrl.dispose();
    super.dispose();
  }

  void _syncControllersWithInput(ZakatInput input) {
    _setTextIfChanged(_goldPriceCtrl, input.goldPricePerGram);
    _setTextIfChanged(_silverPriceCtrl, input.silverPricePerGram);
    _setTextIfChanged(_cashCtrl, input.cashInHand);
    _setTextIfChanged(_bankCtrl, input.bankSavings);
    _setTextIfChanged(_goldGramsCtrl, input.goldGrams);
    _setTextIfChanged(_silverGramsCtrl, input.silverGrams);
    _setTextIfChanged(_investmentsCtrl, input.investments);
    _setTextIfChanged(_inventoryCtrl, input.businessInventory);
    _setTextIfChanged(_receivablesCtrl, input.moneyOwedToYou);
    _setTextIfChanged(_debtsCtrl, input.debts);
    _setTextIfChanged(_expensesCtrl, input.immediateExpenses);
  }

  void _setTextIfChanged(TextEditingController ctrl, double value) {
    final text = value == 0.0 ? '' : (value % 1 == 0 ? value.toInt().toString() : value.toString());
    if (ctrl.text != text && (ctrl.text.isEmpty && value == 0.0)) {
      return;
    }
    if (ctrl.text != text && !_isUserEditing(ctrl, value)) {
      ctrl.text = text;
    }
  }

  bool _isUserEditing(TextEditingController ctrl, double value) {
    final parsed = double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0.0;
    return parsed == value;
  }

  double _parseValue(String text) {
    if (text.trim().isEmpty) return 0.0;
    final cleaned = text.replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputState = ref.watch(zakatInputProvider);
    final calculation = ref.watch(zakatCalculationProvider);

    if (!_initializedFromState && (inputState.goldPricePerGram > 0 || inputState.silverPricePerGram > 0 || inputState.cashInHand > 0)) {
      _syncControllersWithInput(inputState);
      _initializedFromState = true;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.zakatCalculator,
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.gold),
            tooltip: l10n.rulesInfoTitle,
            onPressed: () => _showRulesInfoSheet(context, l10n, isDark),
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded, color: AppColors.gold),
            tooltip: l10n.resetCalculator,
            onPressed: () => _confirmReset(context, l10n, isDark),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            Text(
              l10n.zakatSubtitle,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(context, l10n, inputState, isDark),
            const SizedBox(height: 16),
            _buildMetalPricesCard(context, l10n, inputState, isDark),
            const SizedBox(height: 20),
            _buildAssetsCard(context, l10n, inputState, isDark),
            const SizedBox(height: 20),
            _buildDebtsCard(context, l10n, inputState, isDark),
            const SizedBox(height: 24),
            _buildSummaryCard(context, l10n, calculation, isDark),
            const SizedBox(height: 20),
            _buildDisclaimerCard(context, l10n, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    AppLocalizations l10n,
    ZakatInput input,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.currency,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: input.currency,
                    dropdownColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    items: _currencies.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(zakatInputProvider.notifier).setCurrency(val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.nisabStandard,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildNisabOption(
                  title: l10n.silverStandard,
                  subtitle: '612.36g',
                  isSelected: input.nisabStandard == NisabStandard.silver,
                  isDark: isDark,
                  onTap: () => ref.read(zakatInputProvider.notifier).setNisabStandard(NisabStandard.silver),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildNisabOption(
                  title: l10n.goldStandard,
                  subtitle: '87.48g',
                  isSelected: input.nisabStandard == NisabStandard.gold,
                  isDark: isDark,
                  onTap: () => ref.read(zakatInputProvider.notifier).setNisabStandard(NisabStandard.gold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.nisabStandardNote,
            style: TextStyle(
              color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNisabOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withValues(alpha: 0.18)
              : (isDark ? AppColors.midnightNavy : AppColors.sandBackground),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.gold : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? AppColors.gold
                    : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetalPricesCard(
    BuildContext context,
    AppLocalizations l10n,
    ZakatInput input,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on_outlined, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.metalPrices,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.metalPricesHint,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildNumberInput(
                  controller: _goldPriceCtrl,
                  label: l10n.goldPricePerGram,
                  prefix: '${input.currency} ',
                  isDark: isDark,
                  onChanged: (val) {
                    ref.read(zakatInputProvider.notifier).setGoldPrice(_parseValue(val));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberInput(
                  controller: _silverPriceCtrl,
                  label: l10n.silverPricePerGram,
                  prefix: '${input.currency} ',
                  isDark: isDark,
                  onChanged: (val) {
                    ref.read(zakatInputProvider.notifier).setSilverPrice(_parseValue(val));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsCard(
    BuildContext context,
    AppLocalizations l10n,
    ZakatInput input,
    bool isDark,
  ) {
    final goldCalculated = input.goldGrams * input.goldPricePerGram;
    final silverCalculated = input.silverGrams * input.silverPricePerGram;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.assetsCategory,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildNumberInput(
            controller: _cashCtrl,
            label: l10n.cashInHand,
            prefix: '${input.currency} ',
            isDark: isDark,
            onChanged: (val) {
              ref.read(zakatInputProvider.notifier).setCashInHand(_parseValue(val));
            },
          ),
          const SizedBox(height: 12),
          _buildNumberInput(
            controller: _bankCtrl,
            label: l10n.bankSavings,
            prefix: '${input.currency} ',
            isDark: isDark,
            onChanged: (val) {
              ref.read(zakatInputProvider.notifier).setBankSavings(_parseValue(val));
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNumberInput(
                  controller: _goldGramsCtrl,
                  label: l10n.goldWeightGrams,
                  prefix: 'g ',
                  helperText: goldCalculated > 0
                      ? '≈ ${input.currency} ${_currencyFormatter.format(goldCalculated)}'
                      : null,
                  isDark: isDark,
                  onChanged: (val) {
                    ref.read(zakatInputProvider.notifier).setGoldGrams(_parseValue(val));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberInput(
                  controller: _silverGramsCtrl,
                  label: l10n.silverWeightGrams,
                  prefix: 'g ',
                  helperText: silverCalculated > 0
                      ? '≈ ${input.currency} ${_currencyFormatter.format(silverCalculated)}'
                      : null,
                  isDark: isDark,
                  onChanged: (val) {
                    ref.read(zakatInputProvider.notifier).setSilverGrams(_parseValue(val));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNumberInput(
            controller: _investmentsCtrl,
            label: l10n.investmentsShares,
            prefix: '${input.currency} ',
            isDark: isDark,
            onChanged: (val) {
              ref.read(zakatInputProvider.notifier).setInvestments(_parseValue(val));
            },
          ),
          const SizedBox(height: 12),
          _buildNumberInput(
            controller: _inventoryCtrl,
            label: l10n.businessInventory,
            prefix: '${input.currency} ',
            isDark: isDark,
            onChanged: (val) {
              ref.read(zakatInputProvider.notifier).setBusinessInventory(_parseValue(val));
            },
          ),
          const SizedBox(height: 12),
          _buildNumberInput(
            controller: _receivablesCtrl,
            label: l10n.moneyOwedToYou,
            prefix: '${input.currency} ',
            isDark: isDark,
            onChanged: (val) {
              ref.read(zakatInputProvider.notifier).setMoneyOwedToYou(_parseValue(val));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDebtsCard(
    BuildContext context,
    AppLocalizations l10n,
    ZakatInput input,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.money_off_csred_outlined, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.deductiblesCategory,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildNumberInput(
            controller: _debtsCtrl,
            label: l10n.debtsOwed,
            prefix: '${input.currency} ',
            isDark: isDark,
            onChanged: (val) {
              ref.read(zakatInputProvider.notifier).setDebts(_parseValue(val));
            },
          ),
          const SizedBox(height: 12),
          _buildNumberInput(
            controller: _expensesCtrl,
            label: l10n.immediateExpenses,
            prefix: '${input.currency} ',
            isDark: isDark,
            onChanged: (val) {
              ref.read(zakatInputProvider.notifier).setImmediateExpenses(_parseValue(val));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    AppLocalizations l10n,
    ZakatCalculationResult res,
    bool isDark,
  ) {
    final standardName = res.nisabStandard == NisabStandard.silver ? 'Silver' : 'Gold';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFFFFFFF), const Color(0xFFFAF7F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                  l10n.zakatSummary,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: res.isEligible
                      ? AppColors.gold.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: res.isEligible ? AppColors.gold : Colors.grey,
                  ),
                ),
                child: Text(
                  res.isEligible ? l10n.zakatStatusEligible : l10n.zakatStatusNotEligible,
                  style: TextStyle(
                    color: res.isEligible ? AppColors.gold : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildSummaryRow(l10n.totalAssets, '${res.currency} ${_currencyFormatter.format(res.totalAssets)}', isDark),
          const SizedBox(height: 8),
          _buildSummaryRow(l10n.totalDebts, '- ${res.currency} ${_currencyFormatter.format(res.totalDebtsAndLiabilities)}', isDark, isDeduction: true),
          const Divider(height: 20, color: Color(0x33D4AF37)),
          _buildSummaryRow(
            l10n.netWealth,
            '${res.currency} ${_currencyFormatter.format(res.netWealth)}',
            isDark,
            isBold: true,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            '${l10n.nisabThreshold} ($standardName ${res.nisabGrams}g)',
            res.nisabValue > 0
                ? '${res.currency} ${_currencyFormatter.format(res.nisabValue)}'
                : 'Enter ${standardName.toLowerCase()} rate',
            isDark,
            isMuted: true,
          ),
          const SizedBox(height: 20),

          // Total Zakat Payable Highlight Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold),
            ),
            child: Column(
              children: [
                Text(
                  l10n.zakatAmountDue,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${res.currency} ${_currencyFormatter.format(res.zakatDue)}',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
    bool isDeduction = false,
    bool isMuted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isMuted
                  ? (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary)
                  : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: isDeduction
                ? Colors.red[400]
                : (isBold
                    ? AppColors.gold
                    : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary)),
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerCard(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.privacy_tip_outlined, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.scholarDisclaimer,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required String prefix,
    required bool isDark,
    required ValueChanged<String> onChanged,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
          fontSize: 12,
        ),
        prefixText: prefix,
        prefixStyle: const TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        helperText: helperText,
        helperStyle: const TextStyle(color: AppColors.gold, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, AppLocalizations l10n, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        title: Text(
          l10n.resetCalculator,
          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.resetConfirm,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(zakatInputProvider.notifier).resetAssetsAndDebts();
              _cashCtrl.clear();
              _bankCtrl.clear();
              _goldGramsCtrl.clear();
              _silverGramsCtrl.clear();
              _investmentsCtrl.clear();
              _inventoryCtrl.clear();
              _receivablesCtrl.clear();
              _debtsCtrl.clear();
              _expensesCtrl.clear();
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text('Reset', style: TextStyle(color: AppColors.midnightNavy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRulesInfoSheet(BuildContext context, AppLocalizations l10n, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.menu_book_rounded, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text(
                    l10n.rulesInfoTitle,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                icon: Icons.percent_rounded,
                title: 'Zakat Rate: 2.5%',
                desc: 'Levied annually on net wealth exceeding the Nisab threshold.',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: Icons.scale_rounded,
                title: 'Nisab Standard',
                desc: l10n.nisabStandardNote,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: Icons.home_outlined,
                title: 'Exempt Items (Non-Zakatable)',
                desc: l10n.nonZakatableInfo,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: Icons.calendar_today_outlined,
                title: 'Hawl (1 Lunar Year)',
                desc: l10n.hawlInfo,
                isDark: isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.gold, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
