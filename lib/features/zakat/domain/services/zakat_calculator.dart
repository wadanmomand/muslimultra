import '../models/zakat_calculation_result.dart';
import '../models/zakat_input.dart';

class ZakatCalculator {
  static const double goldNisabGrams = 87.48;
  static const double silverNisabGrams = 612.36;
  static const double zakatRate = 0.025; // 2.5%

  static ZakatCalculationResult calculate(ZakatInput input) {
    final cashInHand = input.cashInHand < 0 ? 0.0 : input.cashInHand;
    final bankSavings = input.bankSavings < 0 ? 0.0 : input.bankSavings;
    final totalCashAndBank = cashInHand + bankSavings;

    final goldGrams = input.goldGrams < 0 ? 0.0 : input.goldGrams;
    final goldPrice = input.goldPricePerGram < 0 ? 0.0 : input.goldPricePerGram;
    final goldValue = goldGrams * goldPrice;

    final silverGrams = input.silverGrams < 0 ? 0.0 : input.silverGrams;
    final silverPrice = input.silverPricePerGram < 0 ? 0.0 : input.silverPricePerGram;
    final silverValue = silverGrams * silverPrice;

    final investments = input.investments < 0 ? 0.0 : input.investments;
    final inventory = input.businessInventory < 0 ? 0.0 : input.businessInventory;
    final totalInvestmentsAndBusiness = investments + inventory;

    final receivables = input.moneyOwedToYou < 0 ? 0.0 : input.moneyOwedToYou;
    final totalReceivables = receivables;

    final totalAssets = totalCashAndBank +
        goldValue +
        silverValue +
        totalInvestmentsAndBusiness +
        totalReceivables;

    final debts = input.debts < 0 ? 0.0 : input.debts;
    final immediateExpenses = input.immediateExpenses < 0 ? 0.0 : input.immediateExpenses;
    final totalDebtsAndLiabilities = debts + immediateExpenses;

    final rawNetWealth = totalAssets - totalDebtsAndLiabilities;
    final netWealth = rawNetWealth > 0 ? rawNetWealth : 0.0;

    final bool isGoldStandard = input.nisabStandard == NisabStandard.gold;
    final double nisabGrams = isGoldStandard ? goldNisabGrams : silverNisabGrams;
    final double pricePerGram = isGoldStandard ? goldPrice : silverPrice;
    final double nisabValue = nisabGrams * pricePerGram;

    final bool isEligible = nisabValue > 0 && netWealth >= nisabValue;
    final double zakatDue = isEligible ? netWealth * zakatRate : 0.0;

    return ZakatCalculationResult(
      totalCashAndBank: totalCashAndBank,
      goldValue: goldValue,
      silverValue: silverValue,
      totalInvestmentsAndBusiness: totalInvestmentsAndBusiness,
      totalReceivables: totalReceivables,
      totalAssets: totalAssets,
      totalDebtsAndLiabilities: totalDebtsAndLiabilities,
      netWealth: netWealth,
      nisabStandard: input.nisabStandard,
      nisabGrams: nisabGrams,
      pricePerGram: pricePerGram,
      nisabValue: nisabValue,
      isEligible: isEligible,
      zakatDue: zakatDue,
      currency: input.currency,
    );
  }
}
