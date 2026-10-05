# Muslim Ultra — App Scaffold & Modules

**Spec**: `PHASE1_SPEC.md` v2.0 · **Package**: `com.muslimultra.app`

## Overview
Muslim Ultra is built following a clean, feature-first architecture (`core/`, `features/`) with state managed via **Riverpod**.

### Milestone Progress
- **Milestone 1 (Scaffold & Design Tokens)**: Complete (Design tokens: Midnight Navy `#0A1628`, Gold `#C9A227`, Sand `#F5F0E6`; i18n EN/AR/UR + RTL).
- **Milestone 2 / Spec §3 M1 (Prayer & Qibla Module)**: Complete (On-device calculation, 12 methods including Morocco/Tunisia/Algeria/Jordan, Hanafi/Standard Asr, Athan notifications, quiet hours, Hijri date, Qibla compass ±2° tolerance).
- **Milestone 3 / Spec §3 M2 (Quran Reader Module)**: Complete (Tanzil Uthmani text, 114 Surahs, 30 Juz index, Saheeh International English & Jalandhry Urdu translations, EveryAyah CDN audio auto-advance, bookmarks, continue reading, font size controls, Ask Deen Companion context hook).
- **Milestone 4 / Spec §3 M3 (Deen Companion AI)**: Next.

---

## Quran Reader Module (Spec §3 M2)
- **Uthmani Tanzil Text & Directory**:
  - Full directory of 114 Surahs with revelation types, verse counts, and transliterations.
  - Complete 30 Juz directory with Arabic headers and starting verse references.
  - Bundled offline Uthmani Tanzil text ([tanzil_quran_data.dart](file:///c:/Users/muham/Desktop/muslim%20ultra/lib/features/quran/data/tanzil_quran_data.dart)).
- **Dual Translations (Al-Quran Cloud API & Cache)**:
  - English: **Saheeh International** (`en.sahih`)
  - Urdu: **Fateh Muhammad Jalandhry** (`ur.jalandhry`)
  - On-device local caching via [quran_storage_service.dart](file:///c:/Users/muham/Desktop/muslim%20ultra/lib/features/quran/data/quran_storage_service.dart).
- **Per-Ayah Audio & Auto-Advance (EveryAyah CDN)**:
  - Exact CDN pattern builder: `https://everyayah.com/data/{reciter_subpath}/{surah_3_digits}{ayah_3_digits}.mp3` ([audio_url_builder.dart](file:///c:/Users/muham/Desktop/muslim%20ultra/lib/features/quran/data/audio_url_builder.dart))
  - Auto-advance to next Ayah on playback completion + auto-scroll.
  - Selectable Reciters: Mishary Alafasy, Abdul Basit (Murattal), Mahmoud Al-Husary, Mohamed Al-Minshawi, Saad Al-Ghamdi, Abu Bakr Ash-Shatri.
- **Reading Controls & Bookmarks**:
  - Continue Reading persistent banner with instant 1-tap resume.
  - Per-Ayah bookmarking.
  - Arabic and Translation font-size sliders in appearance sheet.
- **Ask Deen Companion Hook**:
  - Dedicated "Ask AI" button on every Ayah passing surah name, ayah number, Arabic text, and translation context to the Deen Companion AI tab.

---

## Running the Project & Tests
```bash
# 1. Install dependencies
flutter pub get

# 2. Run static analyzer (clean: 0 issues)
flutter analyze

# 3. Run all unit & widget tests (22 tests passed)
flutter test

# 4. Launch app
flutter run
```

## Conventions
- **Design Tokens (Spec §8)**: Strict adherence to Midnight Navy (`#0A1628`), Celestial Gold (`#C9A227`), and Sand (`#F5F0E6`). Green/emerald colors are deliberately avoided per spec.
- **Typography**:
  - Latin/English: **Inter** / **Outfit**
  - Arabic & Quranic Text: **Amiri**
  - Urdu: **Noto Nastaliq Urdu** (with custom line-height scaling in [app_typography.dart](file:///c:/Users/muham/Desktop/muslim%20ultra/lib/features/quran/presentation/screens/surah_reader_screen.dart))
- **Feature-first folders**: each feature contains `data/`, `domain/`, `presentation/`
- **Riverpod for state**: no `setState` for shared state
- **Localization**: all user-visible strings via `AppLocalizations` — no hard-coded strings
- **Feature Naming**: AI Companion branded strictly as **Deen Companion** (Spec §1); Home shell branded as **Today** (Spec M5).
- **Privacy First**: on-device calculation (§7 of spec); analytics default OFF.
