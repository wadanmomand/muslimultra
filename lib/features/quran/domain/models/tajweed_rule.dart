import 'package:flutter/material.dart';

/// The 18 official Tajweed rules supported in Muslim Ultra
enum TajweedRuleType {
  ghunnah(
    id: 'ghunnah',
    ruleIndex: 0,
    darkColor: Color(0xFFFF9100), // Vibrant Orange
    lightColor: Color(0xFFE65100),
  ),
  hamzatWasl(
    id: 'hamzat_wasl',
    ruleIndex: 1,
    darkColor: Color(0xFF90A4AE), // Slate Grey
    lightColor: Color(0xFF546E7A),
  ),
  idghaamGhunnah(
    id: 'idghaam_ghunnah',
    ruleIndex: 2,
    darkColor: Color(0xFFFF6E40), // Deep Coral
    lightColor: Color(0xFFD84315),
  ),
  idghaamMutajanisayn(
    id: 'idghaam_mutajanisayn',
    ruleIndex: 3,
    darkColor: Color(0xFFFFB74D), // Warm Amber
    lightColor: Color(0xFFEF6C00),
  ),
  idghaamMutaqaribayn(
    id: 'idghaam_mutaqaribayn',
    ruleIndex: 4,
    darkColor: Color(0xFFFFD54F), // Honey Gold
    lightColor: Color(0xFFF57F17),
  ),
  idghaamNoGhunnah(
    id: 'idghaam_no_ghunnah',
    ruleIndex: 5,
    darkColor: Color(0xFFBCAAA4), // Muted Tan
    lightColor: Color(0xFF6D4C41),
  ),
  idghaamShafawi(
    id: 'idghaam_shafawi',
    ruleIndex: 6,
    darkColor: Color(0xFFFF8A65), // Warm Terracotta
    lightColor: Color(0xFFBF360C),
  ),
  ikhfa(
    id: 'ikhfa',
    ruleIndex: 7,
    darkColor: Color(0xFFCE93D8), // Electric Violet
    lightColor: Color(0xFF7B1FA2),
  ),
  ikhfaShafawi(
    id: 'ikhfa_shafawi',
    ruleIndex: 8,
    darkColor: Color(0xFFB39DDB), // Lavender Purple
    lightColor: Color(0xFF512DA8),
  ),
  iqlab(
    id: 'iqlab',
    ruleIndex: 9,
    darkColor: Color(0xFFFF4081), // Rose / Magenta
    lightColor: Color(0xFFC2185B),
  ),
  lamShamsiyyah(
    id: 'lam_shamsiyyah',
    ruleIndex: 10,
    darkColor: Color(0xFF78909C), // Cool Grey
    lightColor: Color(0xFF455A64),
  ),
  madd2(
    id: 'madd_2',
    ruleIndex: 11,
    darkColor: Color(0xFFFFE082), // Soft Gold
    lightColor: Color(0xFFF57F17),
  ),
  madd246(
    id: 'madd_246',
    ruleIndex: 12,
    darkColor: Color(0xFFFFB300), // Amber Gold
    lightColor: Color(0xFFFF8F00),
  ),
  madd6(
    id: 'madd_6',
    ruleIndex: 13,
    darkColor: Color(0xFFFF6F00), // Rich Dark Amber
    lightColor: Color(0xFFE65100),
  ),
  maddMunfasil(
    id: 'madd_munfasil',
    ruleIndex: 14,
    darkColor: Color(0xFFFF7043), // Apricot Amber
    lightColor: Color(0xFFD84315),
  ),
  maddMuttasil(
    id: 'madd_muttasil',
    ruleIndex: 15,
    darkColor: Color(0xFFFF1744), // Crimson Red
    lightColor: Color(0xFFC62828),
  ),
  qalqalah(
    id: 'qalqalah',
    ruleIndex: 16,
    darkColor: Color(0xFF29B6F6), // Sky Blue
    lightColor: Color(0xFF0277BD),
  ),
  silent(
    id: 'silent',
    ruleIndex: 17,
    darkColor: Color(0xFF78909C), // Dim Steel Grey
    lightColor: Color(0xFF546E7A),
  );

  final String id;
  final int ruleIndex;
  final Color darkColor;
  final Color lightColor;

  const TajweedRuleType({
    required this.id,
    required this.ruleIndex,
    required this.darkColor,
    required this.lightColor,
  });

  Color getColor(bool isDark) => isDark ? darkColor : lightColor;

  static final Map<int, TajweedRuleType> _byIndex = {
    for (final r in TajweedRuleType.values) r.ruleIndex: r,
  };

  static final Map<String, TajweedRuleType> _byId = {
    for (final r in TajweedRuleType.values) r.id: r,
  };

  static TajweedRuleType? fromIndex(int index) => _byIndex[index];
  static TajweedRuleType? fromId(String id) => _byId[id];
}

/// A single Tajweed annotation targeting a range of Unicode codepoints
class TajweedAnnotation {
  final TajweedRuleType rule;
  final int start;
  final int end;

  const TajweedAnnotation({
    required this.rule,
    required this.start,
    required this.end,
  });

  factory TajweedAnnotation.fromRawTuple(List<dynamic> tuple) {
    final ruleIdx = tuple[0] as int;
    final start = tuple[1] as int;
    final end = tuple[2] as int;

    final rule = TajweedRuleType.fromIndex(ruleIdx) ?? TajweedRuleType.silent;
    return TajweedAnnotation(
      rule: rule,
      start: start,
      end: end,
    );
  }
}

/// Builds colored TextSpan trees from Arabic text and annotations
class TajweedSpanBuilder {
  /// Checks if an Arabic codepoint is transparent (diacritic / harakah / Quranic sign).
  /// Transparent marks attach to the preceding base character and do not break cursive joining.
  static bool isTransparentMark(int code) {
    if (code >= 0x064B && code <= 0x065F) return true; // Tashkeel / Harakat
    if (code == 0x0670) return true; // Dagger Alif (Superscript Alef)
    if (code >= 0x06D6 && code <= 0x06ED) return true; // Quranic marks
    if (code >= 0x08D4 && code <= 0x08ED) return true; // Extended Quranic marks
    if (code >= 0x08F0 && code <= 0x08FF) return true;
    if (code >= 0x0610 && code <= 0x061A) return true;
    return false;
  }

  /// Checks if an Arabic codepoint is a Right-Joining only base letter.
  /// In Arabic script, a right-joining letter joins with the preceding letter (to its right in RTL),
  /// but NEVER joins with the following letter (to its left in RTL).
  static bool isRightJoiningOnly(int code) {
    return code == 0x0622 || // آ
        code == 0x0623 || // أ
        code == 0x0624 || // ؤ
        code == 0x0625 || // إ
        code == 0x0627 || // ا
        code == 0x0629 || // ة (Teh Marbuta)
        code == 0x062F || // د
        code == 0x0630 || // ذ
        code == 0x0631 || // ر
        code == 0x0632 || // ز
        code == 0x0648 || // و
        code == 0x0671 || // ٱ (Alef Wasla)
        code == 0x0672 || // ٲ
        code == 0x0673 || // ٳ
        code == 0x0675 || // ٵ
        (code >= 0x0688 && code <= 0x0699) || // Urdu / extended Dal, Thal, Reh, Zain
        (code >= 0x06C4 && code <= 0x06CB) || // Extended Waw
        code == 0x06CF ||
        code == 0x06EE ||
        code == 0x06EF;
  }

  /// Evaluates whether the boundary between runes[index] and runes[index + 1]
  /// is safe to split without breaking Arabic cursive ligatures or shaping.
  static bool isNonJoiningBoundary(List<int> runes, int index) {
    if (index < 0 || index >= runes.length - 1) return true;
    final curr = runes[index];
    final next = runes[index + 1];

    // Never split between a base character and an attached diacritic, or between diacritics
    if (isTransparentMark(next)) return false;

    // Whitespace or punctuation boundary is always safe
    if (curr <= 0x20 || next <= 0x20) return true;

    // Non-Arabic characters (e.g. ASCII test characters, Latin, digits) are non-joining
    final currIsArabic = (curr >= 0x0600 && curr <= 0x06FF) || (curr >= 0x08A0 && curr <= 0x08FF);
    final nextIsArabic = (next >= 0x0600 && next <= 0x06FF) || (next >= 0x08A0 && next <= 0x08FF);
    if (!currIsArabic || !nextIsArabic) return true;

    // Next character is isolated Hamza (never connects to previous character)
    if (next == 0x0621) return true;

    // Find the base character ending at `index` (skipping any transparent marks)
    int k = index;
    while (k >= 0 && isTransparentMark(runes[k])) {
      k--;
    }
    if (k < 0) return true;
    final baseCode = runes[k];

    // If base character is isolated Hamza or Right-Joining Only, it does NOT join to the next letter
    if (baseCode == 0x0621 || isRightJoiningOnly(baseCode)) {
      return true;
    }

    return false;
  }

  /// Builds a list of TextSpans with Tajweed colors applied according to annotations.
  /// 
  /// Arabic shaping is preserved by only splitting color spans at non-joining boundaries
  /// (word boundaries or right-joining letter boundaries).
  /// Overlapping annotations: the later-starting rule wins.
  /// Out-of-range or malformed indices are handled safely.
  /// Any exception falls back gracefully to a single plain TextSpan.
  static List<InlineSpan> buildSpans({
    required String rawText,
    required List<TajweedAnnotation> annotations,
    required bool isDark,
    required TextStyle baseStyle,
    String? endMarker,
    TextStyle? endMarkerStyle,
  }) {
    if (rawText.isEmpty) return const [];

    try {
      // Strip leading U+FEFF if present (as per spec)
      final cleanText = rawText.startsWith('\uFEFF') ? rawText.substring(1) : rawText;
      final runes = cleanText.runes.toList();
      final totalRunes = runes.length;

      if (totalRunes == 0) return const [];

      // If no annotations, return plain text
      if (annotations.isEmpty) {
        return [
          TextSpan(text: cleanText, style: baseStyle),
          if (endMarker != null)
            TextSpan(text: endMarker, style: endMarkerStyle),
        ];
      }

      // Sort annotations: earlier start first. If start is identical, later appearance wins.
      final sorted = List<TajweedAnnotation>.from(annotations);

      // Partition runes into contiguous segments bounded ONLY by non-joining boundaries
      final List<int> breakPoints = [0];
      for (int i = 0; i < totalRunes - 1; i++) {
        if (isNonJoiningBoundary(runes, i)) {
          breakPoints.add(i + 1);
        }
      }
      breakPoints.add(totalRunes);

      // Group consecutive segments with the same active rule
      final List<InlineSpan> spans = [];
      int spanStart = 0;
      TajweedRuleType? spanRule;

      for (int b = 0; b < breakPoints.length - 1; b++) {
        final segStart = breakPoints[b];
        final segEnd = breakPoints[b + 1];

        // Determine active rule for this segment (later-starting rule wins on overlap)
        TajweedRuleType? segRule;
        for (final ann in sorted) {
          final start = ann.start.clamp(0, totalRunes);
          final end = ann.end.clamp(0, totalRunes);
          if (start < segEnd && end > segStart) {
            segRule = ann.rule;
          }
        }

        if (b == 0) {
          spanRule = segRule;
        } else if (segRule != spanRule) {
          // Emit chunk up to segStart
          final chunkText = String.fromCharCodes(runes.sublist(spanStart, segStart));
          final chunkColor = spanRule?.getColor(isDark) ?? baseStyle.color;
          spans.add(
            TextSpan(
              text: chunkText,
              style: baseStyle.copyWith(
                color: chunkColor,
                fontWeight: spanRule != null ? FontWeight.w600 : baseStyle.fontWeight,
              ),
            ),
          );
          spanStart = segStart;
          spanRule = segRule;
        }
      }

      // Emit trailing chunk
      if (spanStart < totalRunes) {
        final chunkText = String.fromCharCodes(runes.sublist(spanStart, totalRunes));
        final chunkColor = spanRule?.getColor(isDark) ?? baseStyle.color;
        spans.add(
          TextSpan(
            text: chunkText,
            style: baseStyle.copyWith(
              color: chunkColor,
              fontWeight: spanRule != null ? FontWeight.w600 : baseStyle.fontWeight,
            ),
          ),
        );
      }

      // Optional end marker (e.g. Ayah number glyph ﴿١﴾)
      if (endMarker != null) {
        spans.add(TextSpan(text: endMarker, style: endMarkerStyle));
      }

      return spans;
    } catch (_) {
      // Graceful fallback to uncolored plain text
      return [
        TextSpan(text: rawText, style: baseStyle),
        if (endMarker != null)
          TextSpan(text: endMarker, style: endMarkerStyle),
      ];
    }
  }
}
