enum NisabStandard {
  silver,
  gold,
}

class ZakatInput {
  final NisabStandard nisabStandard;
  final String currency;
  final double goldPricePerGram;
  final double silverPricePerGram;

  // Assets
  final double cashInHand;
  final double bankSavings;
  final double goldGrams;
  final double silverGrams;
  final double investments;
  final double businessInventory;
  final double moneyOwedToYou;

  // Deductibles
  final double debts;
  final double immediateExpenses;

  const ZakatInput({
    this.nisabStandard = NisabStandard.silver,
    this.currency = 'USD',
    this.goldPricePerGram = 0.0,
    this.silverPricePerGram = 0.0,
    this.cashInHand = 0.0,
    this.bankSavings = 0.0,
    this.goldGrams = 0.0,
    this.silverGrams = 0.0,
    this.investments = 0.0,
    this.businessInventory = 0.0,
    this.moneyOwedToYou = 0.0,
    this.debts = 0.0,
    this.immediateExpenses = 0.0,
  });

  ZakatInput copyWith({
    NisabStandard? nisabStandard,
    String? currency,
    double? goldPricePerGram,
    double? silverPricePerGram,
    double? cashInHand,
    double? bankSavings,
    double? goldGrams,
    double? silverGrams,
    double? investments,
    double? businessInventory,
    double? moneyOwedToYou,
    double? debts,
    double? immediateExpenses,
  }) {
    return ZakatInput(
      nisabStandard: nisabStandard ?? this.nisabStandard,
      currency: currency ?? this.currency,
      goldPricePerGram: goldPricePerGram ?? this.goldPricePerGram,
      silverPricePerGram: silverPricePerGram ?? this.silverPricePerGram,
      cashInHand: cashInHand ?? this.cashInHand,
      bankSavings: bankSavings ?? this.bankSavings,
      goldGrams: goldGrams ?? this.goldGrams,
      silverGrams: silverGrams ?? this.silverGrams,
      investments: investments ?? this.investments,
      businessInventory: businessInventory ?? this.businessInventory,
      moneyOwedToYou: moneyOwedToYou ?? this.moneyOwedToYou,
      debts: debts ?? this.debts,
      immediateExpenses: immediateExpenses ?? this.immediateExpenses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nisabStandard': nisabStandard.name,
      'currency': currency,
      'goldPricePerGram': goldPricePerGram,
      'silverPricePerGram': silverPricePerGram,
      'cashInHand': cashInHand,
      'bankSavings': bankSavings,
      'goldGrams': goldGrams,
      'silverGrams': silverGrams,
      'investments': investments,
      'businessInventory': businessInventory,
      'moneyOwedToYou': moneyOwedToYou,
      'debts': debts,
      'immediateExpenses': immediateExpenses,
    };
  }

  factory ZakatInput.fromJson(Map<String, dynamic> json) {
    return ZakatInput(
      nisabStandard: json['nisabStandard'] == 'gold' ? NisabStandard.gold : NisabStandard.silver,
      currency: json['currency'] as String? ?? 'USD',
      goldPricePerGram: (json['goldPricePerGram'] as num?)?.toDouble() ?? 0.0,
      silverPricePerGram: (json['silverPricePerGram'] as num?)?.toDouble() ?? 0.0,
      cashInHand: (json['cashInHand'] as num?)?.toDouble() ?? 0.0,
      bankSavings: (json['bankSavings'] as num?)?.toDouble() ?? 0.0,
      goldGrams: (json['goldGrams'] as num?)?.toDouble() ?? 0.0,
      silverGrams: (json['silverGrams'] as num?)?.toDouble() ?? 0.0,
      investments: (json['investments'] as num?)?.toDouble() ?? 0.0,
      businessInventory: (json['businessInventory'] as num?)?.toDouble() ?? 0.0,
      moneyOwedToYou: (json['moneyOwedToYou'] as num?)?.toDouble() ?? 0.0,
      debts: (json['debts'] as num?)?.toDouble() ?? 0.0,
      immediateExpenses: (json['immediateExpenses'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
