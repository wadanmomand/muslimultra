import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/zakat_input.dart';

class ZakatStorageService {
  static const String _prefZakatInputKey = 'zakat_calculator_inputs_v1';

  Future<void> saveZakatInput(ZakatInput input) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefZakatInputKey, json.encode(input.toJson()));
    } catch (_) {}
  }

  Future<ZakatInput> loadZakatInput() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefZakatInputKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> map = json.decode(raw) as Map<String, dynamic>;
        return ZakatInput.fromJson(map);
      }
    } catch (_) {}
    return const ZakatInput();
  }

  Future<void> clearInputsPreservingPrices() async {
    try {
      final current = await loadZakatInput();
      final reset = ZakatInput(
        nisabStandard: current.nisabStandard,
        currency: current.currency,
        goldPricePerGram: current.goldPricePerGram,
        silverPricePerGram: current.silverPricePerGram,
      );
      await saveZakatInput(reset);
    } catch (_) {}
  }
}
