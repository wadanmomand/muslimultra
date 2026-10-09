import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/zakat_storage_service.dart';
import '../../domain/models/zakat_calculation_result.dart';
import '../../domain/models/zakat_input.dart';
import '../../domain/services/zakat_calculator.dart';

final zakatStorageServiceProvider = Provider<ZakatStorageService>((ref) {
  return ZakatStorageService();
});

class ZakatInputNotifier extends StateNotifier<ZakatInput> {
  final ZakatStorageService _storage;

  ZakatInputNotifier(this._storage) : super(const ZakatInput()) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final saved = await _storage.loadZakatInput();
    state = saved;
  }

  void updateInput(ZakatInput newInput) {
    state = newInput;
    _storage.saveZakatInput(newInput);
  }

  void setNisabStandard(NisabStandard standard) {
    updateInput(state.copyWith(nisabStandard: standard));
  }

  void setCurrency(String currency) {
    updateInput(state.copyWith(currency: currency));
  }

  void setGoldPrice(double price) {
    updateInput(state.copyWith(goldPricePerGram: price));
  }

  void setSilverPrice(double price) {
    updateInput(state.copyWith(silverPricePerGram: price));
  }

  void setCashInHand(double amount) {
    updateInput(state.copyWith(cashInHand: amount));
  }

  void setBankSavings(double amount) {
    updateInput(state.copyWith(bankSavings: amount));
  }

  void setGoldGrams(double grams) {
    updateInput(state.copyWith(goldGrams: grams));
  }

  void setSilverGrams(double grams) {
    updateInput(state.copyWith(silverGrams: grams));
  }

  void setInvestments(double amount) {
    updateInput(state.copyWith(investments: amount));
  }

  void setBusinessInventory(double amount) {
    updateInput(state.copyWith(businessInventory: amount));
  }

  void setMoneyOwedToYou(double amount) {
    updateInput(state.copyWith(moneyOwedToYou: amount));
  }

  void setDebts(double amount) {
    updateInput(state.copyWith(debts: amount));
  }

  void setImmediateExpenses(double amount) {
    updateInput(state.copyWith(immediateExpenses: amount));
  }

  void resetAssetsAndDebts() {
    final reset = ZakatInput(
      nisabStandard: state.nisabStandard,
      currency: state.currency,
      goldPricePerGram: state.goldPricePerGram,
      silverPricePerGram: state.silverPricePerGram,
    );
    updateInput(reset);
  }
}

final zakatInputProvider = StateNotifierProvider<ZakatInputNotifier, ZakatInput>((ref) {
  final storage = ref.watch(zakatStorageServiceProvider);
  return ZakatInputNotifier(storage);
});

final zakatCalculationProvider = Provider<ZakatCalculationResult>((ref) {
  final input = ref.watch(zakatInputProvider);
  return ZakatCalculator.calculate(input);
});
