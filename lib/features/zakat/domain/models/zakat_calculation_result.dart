import 'zakat_input.dart';

class ZakatCalculationResult {
  final double totalCashAndBank;
  final double goldValue;
  final double silverValue;
  final double totalInvestmentsAndBusiness;
  final double totalReceivables;
  final double totalAssets;
  
  final double totalDebtsAndLiabilities;
  final double netWealth;

  final NisabStandard nisabStandard;
  final double nisabGrams;
  final double pricePerGram;
  final double nisabValue;
  final bool isEligible;
  final double zakatDue;
  final String currency;

  const ZakatCalculationResult({
    required this.totalCashAndBank,
    required this.goldValue,
    required this.silverValue,
    required this.totalInvestmentsAndBusiness,
    required this.totalReceivables,
    required this.totalAssets,
    required this.totalDebtsAndLiabilities,
    required this.netWealth,
    required this.nisabStandard,
    required this.nisabGrams,
    required this.pricePerGram,
    required this.nisabValue,
    required this.isEligible,
    required this.zakatDue,
    required this.currency,
  });
}
