# Google Play Console — Data Safety Form Responses

**App Name:** Muslim Ultra  
**Package Name:** `com.muslimultra.app`  
**Version:** 1.0.0+1 (Beta MVP)  

---

## 1. Overview Questions

| Question | Answer | Notes |
| :--- | :--- | :--- |
| **Does your app collect or share any of the required user data types?** | **Yes** | Ephemeral search queries for Deen Companion AI + Anonymous rate-limit ID. |
| **Is all user data collected by your app encrypted in transit?** | **Yes** | All endpoints enforce HTTPS (TLS 1.3). |
| **Do you provide a way for users to request that their data be deleted?** | **Yes** | In-app "Clear History" deletes local conversations. Cached queries auto-expire in 14 days. |
| **Does your app target children under 13?** | **No** | General audience application (Rated Everyone). |

---

## 2. Detailed Data Types Declaration

### A. Location
* **Precise Location (GPS):** **NOT COLLECTED / NOT SHARED**
  * *Declaration:* The app accesses GPS locally on the device to compute prayer times and compass bearing to the Kaaba. This data is processed strictly in memory and is **never transmitted off the user's device**.

### B. Personal Info (Name, Email, Phone, User IDs)
* **Name, Email, Phone Number, Physical Address:** **NOT COLLECTED**
* **Account Credentials / Passwords:** **NOT COLLECTED** (No mandatory sign-in required for MVP).

### C. Messages & User Content
* **In-app queries (Deen Companion AI questions):**
  * **Collected?** Yes
  * **Shared?** Yes (Sent to LLM Provider: Google Gemini / OpenAI API for answer synthesis)
  * **Purposes:**
    * ✅ **App Functionality** (Providing grounded Islamic answers with citations)
  * **Ephemeral processing?** Yes (Cached anonymously for max 14 days to improve response speed, then purged)
  * **Linked to user identity?** **No** (Anonymous text query)
  * **Optional or Required?** Optional (Only when user actively submits a question in the AI tab)

### D. Device or Other Identifiers
* **Anonymous Installation / User Identifier:**
  * **Collected?** Yes
  * **Shared?** No
  * **Purposes:**
    * ✅ **App Functionality** (Enforcing 20 free inquiries / day rate-limiting counter)
    * ✅ **Security & Fraud Prevention** (Preventing bot abuse of edge functions)
  * **Linked to user identity?** **No**
  * **Optional or Required?** Required for AI tab usage; reset daily at midnight UTC.

### E. App Activity & Analytics
* **In-App Search History:** Not collected on servers. Stored only in local device memory.
* **Analytics / Behavioral Tracking:** **NOT COLLECTED** (0 analytics SDKs).
* **Crash Logs & Diagnostic Info:** **NOT COLLECTED** (0 crash logging SDKs).

---

## 3. Play Store Security & Privacy Policy Declaration

* **Privacy Policy URL:** `https://wadanmomand.github.io/muslimultra/privacy-policy.html` *(or hosted via GitHub repository `https://github.com/wadanmomand/muslimultra/blob/main/PRIVACY_POLICY.md`)*
* **Target Audience:** Everyone (3+)
* **Ads Declaration:** "No, my app does not contain ads."
* **Government Apps:** "No, this app is not an official government app."
* **Financial Features:** "No, this app does not provide financial services."
