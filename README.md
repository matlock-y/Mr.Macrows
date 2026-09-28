# Mr. Macrows: Clinical Charting Assistant

A powerful, custom **AutoHotkey v2.0** suite designed to automate and streamline clinical charting workflows for eye care practitioners (tailored for the specifications of Dr. Matlock Wyman). It integrates seamlessly with electronic health record (EHR) software to minimize repetitive typing, manage contact lens fits, and compile complex diagnostic assessments.

---
## Quick Start Instructions
* Download two files- mr-macrows.exe and starter_macrows.json
* Double click the .exe to launch, it will prompt you to select a json file. Select the starter_macrows.json file.
* Then you are good to go. Select ctrl + shift + r for a reference window of some of the functions and you can get rolling.
* The rest of this readme needs to be polished and I have yet to get to it. Just ignore for now please.
* Everything is a little messy, it'll get better I promise, just bear with me.
## 🚀 Key Features

### 1. Dynamic JSON Macro Loader & GUI Editor (`Ctrl + Shift + J`)
*   **Dynamic Registration:** Translates triggers and outputs stored in [matlock_macrows.json](file:///d:/8.28%20json/matlock_macrows.json) into active AutoHotkey hotstrings at runtime.
*   **Searchable Editor:** Add, update, delete, or search through shortcuts using the built-in management interface (`Ctrl + Shift + J`).
*   **Auto-Capitalization & Categories:** Organize macros by categories (e.g., *vision and seeing*, *imaging*, *general and medical*) with optional notes.

### 2. Clinical Assessment & Plan Menus
Interactive menus triggered by typing a simple abbreviation followed by a semicolon (`;`):
*   `cl;` **Contact Lens Fitting Menu:** Guides you through visual/physical comfort, fit type, brand, over-refraction adjustments, trials, and hygiene advice.
*   `dm;` **Diabetic Retinopathy (DR):** Formulates diagnostic codes and management plans based on DR stage, laterality, and Macular Edema (DME) status.
*   `ii;` **Imaging Interpretation Engine:** Simplifies reporting for rOCT, gOCT, Visual Fields (VF), Fundus Photos, Keratometry Topography, and IOL Master. Generates Indications, Findings, Quality, and Comparison history.
*   `dem;` **Demodex Checklist:** Displays a GUI symptom checker (Itchy, Watery, Gritty, AM Crust, etc.) and outputs standard treatment regimes (e.g., Xdemvy dosing instructions).
*   `ac;` **Allergic Conjunctivitis:** GUI symptom checklist routing to treatment plans (OTC drops vs. FML vs. Pred Acetate).
*   `cat;` **Cataract Assessor:** Formats cataract severity (mild, becoming VS, VS), laterality, and surgical recommendations (Sx not indicated, proceed, or defer).
*   `glc;` **Glaucoma Dashboard:** Floating dashboard to document POAG, suspect, or OHTN parameters including TMax, Pachymetry, Gonioscopy, and treatment.
*   `pvd;` **Posterior Vitreous Detachment:** Select laterality to prompt patient education and follow-up guidelines.
*   `mrx;` **Manifest Refraction Decisions:** Records if spec Rx was finalized, deferred (due to OSD or retinal pathology), or declined (in favor of OTC readers).

### 3. Rich Text A&P Scratchpad (`Ctrl + F4`)
*   Launches a floating, resizable RichEdit utility that sits on top of your windows.
*   Supports standard hotkeys: `Ctrl + B` (Bold), `Ctrl + I` (Italic), and `Ctrl + U` (Underline).
*   Instantly injects formatted text into the active EHR field.

### 4. Automated Check-Out Sequences
*   `Ctrl + F1` **Check-Out Only:** Automates mouse clicks to check a patient out of a room.
*   `Ctrl + F2` **Check-Out and Lock Chart:** Automates check-out and applies the chart lock command. The pt chart must be marked as completed/ done to work properly. 
*   **Escape Hatch:** Pressing `Escape` at any point instantly halts the automated clicking sequence.
*   **Custom Coordinate Mapping:** Read room-specific layout files (`Coordinates_2A.ahk`, `Coordinates_hallway.ahk`, etc.) dynamically.

### 5. Fast Paste Engine
*   Injects long strings of text almost instantly via the Windows clipboard to bypass sluggish EHR typing inputs.
*   Ensures Rich Text Formatting (HTML styling) and plain text fail-safes are copied and restored cleanly.

---

## 📁 File Structure

*   [1 Mr. Macrows_Master_Script.ahk](file:///d:/8.28%20json/1%20Mr.%20Macrows_Master_Script.ahk) — The master script that boots the environment, handles global hotkeys (Reload, Suspend, Scratchpad), and sets up configuration overrides.
*   [CL_Master.ahk](file:///d:/8.28%20json/CL_Master.ahk) — Contact lens database (`LensDB`) and fitting logic formulas (Alcon, Acuvue, B&L, Biofinity, Clariti, MyDay).
*   [MacroMenus.ahk](file:///d:/8.28%20json/MacroMenus.ahk) — Contains all clinical interactive GUI frameworks, menu builders, and text formatters (Glaucoma, Demodex, Refraction, etc.).
*   [json-loader.ahk](file:///d:/8.28%20json/json-loader.ahk) — Handles loading and parsing JSON strings, dynamic registration of AHK hotstrings, and houses the Macro Editor GUI.
*   [Coordinates.ahk](file:///d:/8.28%20json/Coordinates.ahk) — Default screen coordinates configuration used for automated check-outs.
*   [coordinates_required_functions.ahk](file:///d:/8.28%20json/coordinates_required_functions.ahk) — Coordinates click sequence executor, checking room-specific configurations and implementing security escape hooks.
*   [matlock_macrows.json](file:///d:/8.28%20json/matlock_macrows.json) — JSON data file containing all auto-capitalization and shorthand macros.

---

## ⚙️ Requirements & Installation

1.  Download and install **[AutoHotkey v2.0.18+](https://www.autohotkey.com/)** or later.
2.  Clone or download this repository directory to a local folder.
3.  Double-click `1 Mr. Macrows_Master_Script.ahk` to run.
4.  *(Optional)* Create room-specific coordinate files (e.g. `Coordinates_2A.ahk`) in the parent directory to allow coordinate-based automation on different monitors/rooms.

---

## ⌨️ Hotkey & Trigger Reference

### Hotkeys
| Hotkey | Action |
| :--- | :--- |
| `F12` | **Suspend/Resume Macros** (Toggles hotkeys on/off with visual ToolTip indicator) |
| `Ctrl + Shift + J` | **Open JSON Macro Editor** |
| `Ctrl + F4` | **Open RichEdit Scratchpad** |
| `Ctrl + F1` | **Run Automated Check-Out Flow** |
| `Ctrl + F2` | **Run Automated Check-Out & Lock Chart** |
| `Ctrl + Alt + R` | **Toggle Auto-Reloader** (Auto-reloads script when saving master script file) |
| `Escape` | **Cancel Checkout Flow** (Emergency break during automated click sequences) |

### Abbreviation Menu Triggers
Type the abbreviation in any text box followed by a semicolon:
*   `cl;` — Contact Lens fitting wizard.
*   `dm;` — Diabetic Retinopathy diagnostics.
*   `ii;` — Imaging Interpretation wizard.
*   `dem;` — Demodex symptoms & treatment checkbox sheet.
*   `ac;` — Allergic Conjunctivitis symptom & treatment checklist.
*   `cat;` — Cataracts assessment notes.
*   `glc;` — Glaucoma Dashboard GUI.
*   `pvd;` — PVD laterality & education template.
*   `mrx;` — Manifest Refraction assessment notes.
