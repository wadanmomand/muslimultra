# Privacy Policy for Muslim Ultra

**Effective Date:** October 7, 2026  
**App Name:** Muslim Ultra (`com.muslimultra.app`)  
**Publisher:** Muslim Ultra Team  
**Contact:** privacy@muslimultra.app | support@muslimultra.app  

---

## 1. Introduction & Our Privacy-First Commitment

Muslim Ultra is designed from the ground up with a **strict privacy-first architecture**. We believe your religious practices, prayers, Quranic study, and spiritual inquiries are deeply personal. Unlike mainstream Islamic utilities, Muslim Ultra does not include advertising networks, commercial tracking SDKs, or third-party behavioral analytics.

---

## 2. Information We Process & Where It Stays

### A. Location Data (100% On-Device)
* **Purpose:** Precise calculation of daily Islamic prayer times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha) and calculation of the exact Qibla direction (bearing to the Holy Kaaba in Makkah at 21.4225° N, 39.8262° E).
* **Processing:** Handled entirely on your local device hardware using astronomical calculation algorithms and on-device magnetometer/accelerometer sensors.
* **Transmission:** **Zero location data leaves your device.** Your GPS coordinates are never transmitted to our servers, third-party APIs, or any analytics backend.

### B. Quran Reading, Bookmarks & Preferences (100% On-Device)
* **Purpose:** Remembering your reading position, saved bookmarks, chosen translation, audio reciter preference, and theme settings.
* **Storage:** Stored locally in your device's private sandboxed storage using `SharedPreferences`.
* **Transmission:** None.

### C. On-Device Utility AI Routing (100% On-Device)
* Questions regarding daily prayer times, the next upcoming prayer, current Qibla bearing, or the current Islamic Hijri date are intercepted and resolved locally on your device by our intent engine. **Zero network calls or remote LLM queries are made for utility inquiries.**

---

## 3. Data That Leaves Your Device (Deen Companion AI & Media)

### A. Deen Companion AI Inquiries
* **What is sent:** When you ask a general Islamic question (e.g., tafsir of a verse, Hadith explanation, or classical Fiqh viewpoints), the textual question, selected response language (English, Arabic, or Urdu), and your anonymous installation identifier are transmitted over encrypted HTTPS (TLS 1.3) to our backend gateway (hosted on Supabase Edge Functions).
* **How it is processed:**
  1. The gateway searches our verified, authentic Islamic knowledge base (Quran texts, Hisn al-Muslim supplications, and scholarly collections) using vector similarity search to find exact textual citations.
  2. The grounded text context and your prompt are passed to our language model provider (Google Gemini API / OpenAI API) to generate a structured, citation-backed response.
* **AI Provider Terms & Data Notice:** We utilize official developer APIs (including Google Gemini API). Under standard API terms, data processed through automated API endpoints is subject to the respective provider's developer data policies. While we do not associate queries with personal user identities, **you should not submit personally identifiable information (PII), confidential personal details, or sensitive private data in the chat interface.**

### B. Audio Playback & Translations
* **Audio Recitations:** Ayah-by-ayah audio streaming and downloads connect directly to the public EveryAyah CDN repository (`everyayah.com`).
* **Online Translations:** Supplemental translation downloads connect to verified public Quranic repositories over HTTPS.
* **Typography:** Fonts are rendered using system typography or the Google Fonts library.

---

## 4. Server-Side Storage & Data Retention

* **Response Cache:** To optimize performance and reduce redundant computations, anonymous question hashes (SHA-256) and their verified Islamic answers are cached in our database for **up to 14 days**, after which they automatically expire.
* **Rate-Limiting Counters:** An anonymous user identifier and daily counter are maintained in our rate-limiting table to enforce the 20 inquiries/day free-tier quota. This counter resets daily at midnight UTC.
* **Local Chat History:** Your conversation messages are stored locally on your device (up to 50 recent messages). You can permanently delete this history at any time by tapping the **"Clear History"** icon in the chat screen.

---

## 5. Third-Party Trackers & SDKs Audit

Muslim Ultra takes a zero-bloat stance:
* ❌ **No Commercial Ad SDKs** (No AdMob, Unity, AppLovin)
* ❌ **No Behavioral Analytics Trackers** (No Google Analytics, Firebase Analytics, Mixpanel, Segment)
* ❌ **No Third-Party Crash Reporting Trackers** (No Sentry, Crashlytics)

---

## 6. Children’s Privacy

Muslim Ultra does not knowingly collect or solicit personal information from children under the age of 13. The application provides general Islamic educational content and prayer utilities suitable for all ages.

---

## 7. Data Security

All network communications between the Muslim Ultra mobile application and our Supabase backend use industry-standard HTTPS encryption (TLS 1.3). Server infrastructure is maintained with strict row-level security (RLS) policies and security-definer RPC functions.

---

## 8. Changes to This Privacy Policy

We may update our Privacy Policy from time to time to reflect enhancements in application features or infrastructure. Any revisions will be reflected with an updated "Effective Date" at the top of this document.

---

## 9. Contact Us

If you have questions, feedback, or concerns regarding your privacy while using Muslim Ultra, please reach out to us at:
* **Email:** privacy@muslimultra.app
* **Support:** support@muslimultra.app
* **Project Repository:** https://github.com/wadanmomand/muslimultra.git
