# Muslim Ultra — Google Play Console Submission Checklist
**App Title (Locked):** `Muslim Ultra: Quran & Prayer`  
**Application ID:** `com.muslimultra.app`  
**Release Binary:** `build/app/outputs/bundle/release/app-release.aab`  
**Contact Email:** `supportmuslimultra@gmail.com`  
**Privacy Policy URL:** `https://muslimultra-website.vercel.app/privacy-policy.html`  
**Website / Support URL:** `https://muslimultra-website.vercel.app/support.html`

---

## 📋 Step-by-Step Play Console Publishing Guide

### Step 1: Create App in Google Play Console
1. Navigate to **[Google Play Console](https://play.google.com/console)**.
2. Click **Create App**.
3. **App Name:** `Muslim Ultra: Quran & Prayer`
4. **Default Language:** English (United States) - `en-US`
5. **App or Game:** App
6. **Free or Paid:** Free
7. Accept Developer Program Policies and US export laws.

---

### Step 2: Main Store Listing Copy & Localizations
Refer to [`PLAY_STORE_LISTING.md`](file:///c:/Users/muham/Desktop/muslim%20ultra/PLAY_STORE_LISTING.md) for full multilingual copy:

#### English (United States) — Primary
- **Short Description (max 80 chars):**
  > Precision prayer times, Tanzil Quran, Qibla compass & citation-backed AI Deen.
- **Full Description (max 4000 chars):**
  > Copy the formatted full description directly from `PLAY_STORE_LISTING.md` Section 1.

#### Arabic (العربية) — Optional Localization
- **App Title:** `مسلم ألترا: القرآن وأوقات الصلاة`
- **Short Description:** `أوقات صلاة فلكية دقيقة، قرآن مصحف التنزيل، بوصلة القبلة، ورفيق الدين الذكي.`
- **Full Description:** Copy from `PLAY_STORE_LISTING.md` Section 2.

#### Urdu (اردو) — Optional Localization
- **App Title:** `مسلم الٹرا: قرآن اور نماز کے اوقات`
- **Short Description:** `فلکیاتی درستگی سے نماز کے اوقات، تنزیل قرآن، قبلہ نما اور دینی ساتھی AI۔`
- **Full Description:** Copy from `PLAY_STORE_LISTING.md` Section 3.

---

### Step 3: Store Graphics & Screenshots
Located in [`muslimultra-assets/`](file:///c:/Users/muham/Desktop/muslim%20ultra/muslimultra-assets/):

1. **App Icon (512×512 PNG, 32-bit, max 1MB):**
   - File: `muslimultra-assets/app-icon-quran-final-512.png` (or `assets/icon/app-icon-512.png`)
2. **Feature Graphic (1024×500 PNG / JPEG):**
   - File: `muslimultra-assets/feature-graphic-1024x500.png`
3. **Phone Screenshots (Upload 6–8 high-resolution 1080×2340 screenshots captured on device):**
   - **Screenshot 1:** Today / Prayer Times Dashboard (Gold countdown card, next prayer indicator).
   - **Screenshot 2:** Tanzil Quran Reader (Surah list, Arabic Uthmani text + Urdu/English translations).
   - **Screenshot 3:** Magnetic Qibla Compass (Kaaba azimuth dial & live calibration circle).
   - **Screenshot 4:** Deen Companion AI Chat (Asking a question with grounded bracketed citations).
   - **Screenshot 5:** Daily Sunnah Duas & Adhkar (Hisnul Muslim categories & audio player).
   - **Screenshot 6:** Settings & Privacy Guarantee (Calculation method selection & offline notice).

---

### Step 4: Complete Data Safety Questionnaire
Refer to [`PLAY_DATA_SAFETY.md`](file:///c:/Users/muham/Desktop/muslim%20ultra/PLAY_DATA_SAFETY.md) for exact form selections:
- **Does your app collect or share user data?** Select **Yes** (Ephemeral encrypted AI questions transmitted for processing).
- **Is all user data collected by your app encrypted in transit?** Select **Yes** (TLS 1.3 HTTPS).
- **Do you provide a way for users to request data deletion?** Select **Yes** (`supportmuslimultra@gmail.com`).
- **Location:** NOT collected on server (100% on-device astronomical solar computation).
- **Trackers / Ads / Telemetry:** **NONE** (0 analytics SDKs).
- **Messages / AI Queries:** Ephemeral 14-day server cache for abuse prevention and rate-limiting; not tied to identity.

---

### Step 5: App Content & Policy Questionnaires
1. **Privacy Policy:** `https://muslimultra-website.vercel.app/privacy-policy.html`
2. **Ads:** Select **"No, my app does not contain ads"**.
3. **App Access:** Select **"All functionality is available without restrictions"** (no credentials needed).
4. **Content Rating (IARC):**
   - Category: Reference / News / Educational.
   - Violence / Sexual content / Gambling: **No** to all.
   - Resulting rating: **Everyone / PEGI 3**.
5. **Target Audience & Content:**
   - Target age group: 13+ (or 18+).
   - Appeal to children: Yes/Neutral.
6. **Government Apps:** No.
7. **Financial Features:** No.

---

### Step 6: Release Track & AAB Upload
1. Navigate to **Release ➔ Production** (or **Closed Testing** / Internal testing if new personal Google Play developer account requiring 12 testers for 14 days).
2. Click **Create New Release**.
3. Upload: `build/app/outputs/bundle/release/app-release.aab`
4. **Release Name:** `1.0.0 (1)`
5. **Release Notes (English - en-US):**
   ```text
   Assalamu Alaikum! Welcome to Muslim Ultra v1.0.0:
   - Astronomical precision prayer times for global calculation methods
   - Full Tanzil Quran reader with English & Urdu translations and Sheikh Mishary audio
   - Live magnetic Qibla compass with real-time azimuth
   - Deen Companion AI for citation-backed authentic Islamic queries
   - Daily Sunnah Duas from Hisnul Muslim
   - Strict Privacy: Zero trackers, 100% on-device GPS calculations
   ```
6. Click **Save** and **Review Release**.

---

### Step 7: Keystore Backup & Security Warning
> [!WARNING]
> **CRITICAL KEYSTORE NOTICE:**
> The release keystore file (`muslim-ultra-keystore.jks`) is saved at:
> `C:\Users\muham\muslim-ultra-keystore.jks`  
>
> **Keystore Credentials:**
> - Alias: `muslimultra`
> - Keystore Password: `MuslimUltra2026!`
> - Key Password: `MuslimUltra2026!`
> - SHA-1 Fingerprint: `B4:8D:06:FD:F0:17:AB:6B:E3:5F:4D:E9:DF:2C:F7:E0:F5:C7:88:88`
> - SHA-256 Fingerprint: `94:CB:8A:46:40:25:3E:EC:3E:C3:40:EA:D4:E3:F6:DC:4D:7A:A2:E4:16:78:9D:CE:36:2D:A4:C5:04:3D:CD:89`
>
> **You MUST back up `muslim-ultra-keystore.jks` and these credentials to a secure password manager or offline drive. If this keystore is lost, you will NEVER be able to update Muslim Ultra on Google Play.**
