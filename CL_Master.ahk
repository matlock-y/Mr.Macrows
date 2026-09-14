#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================================================================
; 1. THE DATA LAYER (Your Single Source of Truth)
; ==============================================================================
Global FitGuides := Map()
Global LensDB := Map()

; --- Central Fitting Guides ---
FitGuides["Alcon"] := "
(
1. Use Max Plus Distance SE.
2. Determine Sensory Dominance (fogging).
3. Select ADD based on spectacle add:
   • LO: up to +1.25
   • MED: +1.50 to +2.00
   • HI: +2.25 to +2.50
4. Initial Fit: Same ADD in both eyes.
5. Enhance Near: Add +0.50D to NDE.
6. Enhance Dist: Add -0.25D to DE.
)"

FitGuides["Acuvue"] := "
(
1. Use Max Plus Distance SE.
2. Determine Sensory Dominance (fogging).
3. Select ADD based on spectacle add:
   • LOW: +0.75 to +1.25
   • MID: +1.50 to +1.75
   • HIGH: +2.00 to +2.50
4. Initial Fit: Same ADD in both eyes.
5. Enhance Near: Add +0.25D to NDE.
6. Enhance Dist: Add -0.25D to DE.
)"

FitGuides["BL"] := "
(
1. Use Max Plus Distance SE.
2. Determine Sensory Dominance.
3. Select ADD based on spectacle add:
   • LOW: +0.75 to +1.50
   • HIGH: +1.75 to +2.50
4. Initial Fit: Same ADD in both eyes.
5. Enhance Near: Add +0.25D to NDE.
6. Enhance Dist: Add -0.25D to DE.
)"

FitGuides["Biofinity"] := "
(
1. Use Max Plus Distance SE. Determine Sensory Dominance.
2. Initial Fit based on Spectacle Add:
   • +1.00 Add: D-Lens in DE / D-Lens in NDE
   • +1.50 Add: D-Lens in DE / D-Lens in NDE
   • +2.00 Add: D-Lens in DE / N-Lens in NDE
   • +2.50 Add: D-Lens in DE / N-Lens in NDE
3. Enhance Near: Add +0.25D to NDE, OR change NDE to N-Lens.
)"

FitGuides["Clariti"] := "
(
1. Use Max Plus Distance SE. Determine Sensory Dominance.
2. Select ADD based on spectacle add:
   • LOW: up to +2.25
   • HIGH: +2.50 to +3.00
3. Initial Fit: Same ADD in both eyes.
4. Enhance Near: Add +0.25D to NDE.
)"

FitGuides["MyDay"] := "
(
1. Use Max Plus Distance SE. Determine Sensory Dominance.
2. Select ADD based on spectacle add:
   • LOW: +0.75 to +1.25
   • MED: +1.50 to +1.75
   • HIGH: +2.00 to +2.50
3. Initial Fit: Same ADD in both eyes.
4. Enhance Near: Add +0.25D to NDE.
)"

; --- ALCON LENSES ---
LensDB["P1"] := {
    Family:      "Alcon Dailies",
    DisplayName: "P1",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 8.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: verofilcon A (SMARTSURFACE)
    Water:    51% Core | >80% Surface
    Diameter: 14.2
    Dk/t:     100
    Center:   0.09mm | Modulus: 0.6 MPa

    POWER RANGE
    -6.00 to +6.00D   (0.25D steps)
    +6.50 to +8.00D   (0.50D steps)
    -6.50 to -12.00D  (0.50D steps)

    ---------------------------------------------------------
    FIT SET AVAILABILITY
    Full parameters
    )"
}

LensDB["P1 Toric"] := {
    Family:      "Alcon Dailies",
    DisplayName: "P1 Toric",
    FitGuideKey: "",
    MinSph: -8.00, MaxSph: 4.00, MaxCyl: -2.25,
    Specs: "
    (
    Material: verofilcon A (Prism-ballast)
    Water:    51% Core | >80% Surface
    BC / Dia: 8.5 / 14.5
    Dk/t:     90

    SPHERE          CYLINDER             AXIS
    ---------------------------------------------------------------------
    +4.00 to +0.25  -0.75, -1.25, -1.75  10, 20, 70-110, 160-180 (10° steps)
    (0.25D steps)   -2.25                10, 20, 160, 170, 180
    ---------------------------------------------------------------------
    Plano to -6.00  -0.75, -1.25, -1.75  Full circle (10° steps)
    (0.25D steps)   -2.25                10, 20, 70-110, 160-180 (10° steps)
    ---------------------------------------------------------------------
    -6.50 to -8.00  -0.75, -1.25, -1.75  10, 20, 70-110, 160-180 (10° steps)
    (0.50D steps)   -2.25                10, 20, 160, 170, 180

    ---------------------------------------------------------
    FIT SET AVAILABILITY
    Sphere:   Plano to -8.00D (0.50D steps)
              +1.00 to +4.00D (1.00D steps)
    Cylinder: -0.75, -1.25, -1.75
    Axis:     10, 20, 80-110, 160-180
    )"
}

LensDB["DT1"] := {
    Family:      "Alcon Dailies",
    DisplayName: "DT1",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 6.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: delefilcon A (Water Gradient)
    Water:    33% Core | ~100% Surface
    BC / Dia: 8.5 / 14.1
    Dk/t:     156

    POWER RANGE
    -6.00 to +6.00D   (0.25D steps)
    -6.50 to -12.00D  (0.50D steps)

    ---------------------------------------------------------
    FIT SET AVAILABILITY
    Full parameters.
    )"
}

LensDB["DT1 Toric"] := {
    Family:      "Alcon Dailies",
    DisplayName: "DT1 Toric",
    FitGuideKey: "",
    MinSph: -8.00, MaxSph: 4.00, MaxCyl: -2.25,
    Specs: "
    (
    Material: delefilcon A (Prism-ballast)
    Water:    33% Core | ~100% Surface
    BC / Dia: 8.6 / 14.5
    Dk/t:     127

    SPHERE          CYLINDER             AXIS
    ---------------------------------------------------------------------
    +4.00 to +0.50  -0.75, -1.25, -1.75  10, 20, 70-110, 160-180 (10° steps)
    (0.25D steps)   -2.25                10, 20, 160, 170, 180
    ---------------------------------------------------------------------
    Plano to -6.00  -0.75, -1.25, -1.75  Full circle (10° steps)
    (0.25D steps)   -2.25                10, 20, 70-110, 160-180 (10° steps)
    ---------------------------------------------------------------------
    -6.50 to -8.00  -0.75, -1.25, -1.75  10, 20, 70-110, 160-180 (10° steps)
    (0.50D steps)   -2.25                10, 20, 160, 170, 180

    ---------------------------------------------------------
    FIT SET AVAILABILITY
    Sphere:   Plano to -8.00D (0.50D steps)
              +1.00 to +4.00D (1.00D steps)
    Cylinder: -0.75, -1.25, -1.75
    Axis:     10, 20, 80-110, 160-180
    )"
}

LensDB["DT1 MF"] := {
    Family:      "Alcon Dailies",
    DisplayName: "DT1 MF",
    FitGuideKey: "Alcon",
    MinSph: -10.00, MaxSph: 6.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: delefilcon A (Water Gradient)
    Water:    33% Core | ~100% Surface
    BC / Dia: 8.5 / 14.1
    Dk/t:     156

    POWER RANGE
    +6.00 to -10.00D  (0.25D steps)

    ADD POWERS
    LO (+0.75 to +1.25D) 
    MED (+1.50 to +2.00D)
    HI (+2.25 to +2.50D)

    ---------------------------------------------------------
    FIT SET AVAILABILITY
    Sphere: Plano to -10.00D (0.25D steps)
            +0.25 to +6.00D (0.50D steps after +4.50D)
    Adds:   LO, MED, HI
    )"
}

LensDB["P7"] := {
    Family:      "Alcon Reusables",
    DisplayName: "P7",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 8.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: serafilcon A 
    Water:    55%
    BC / Dia: 8.4 / 14.2
    Dk/t:     119

    POWER RANGE
    +8.00 to -12.00D  (0.25D steps to -8.00, then 0.50D)

    ---------------------------------------------------------
    FIT SET AVAILABILITY
    Full parameters minus | -0.25 to -12.00 (0.50D steps after -8.00)
    +0.50 to +8.00 (0.50D steps)
    )"
}

LensDB["P7 Toric"] := {
    Family:      "Alcon Reusables",
    DisplayName: "P7 Toric",
    FitGuideKey: "",
    MinSph: -10.00, MaxSph: 8.00, MaxCyl: -2.25,
    Specs: "
    (
    Material: serafilcon A (Prism-ballast)
    Water:    55%
    BC / Dia: 8.6 / 14.5
    Dk/t:     119

    SPHERE            CYLINDER              AXIS
    ---------------------------------------------------------------------
    +8.00 to -10.00 | -0.75, -1.25, -1.75, | Full circle (10° steps)
    (0.25D steps)   | -2.25                | 
    (0.50D steps after +/-6.50D)
    ---------------------------------------------------------
    FIT SET AVAILABILITY
    Sphere:   Plano to -6.00D (0.50D steps)
              +1.00 to +4.00 (1.00D steps)
    Cylinder: -0.75, -1.25, -1.75
    Axis:     Full circle 10° steps
    )"
}

LensDB["T30"] := {
    Family:      "Alcon Reusables",
    DisplayName: "T30",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 8.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: lehfilcon A (Water Gradient)
    Water:    55% Core | ~100% Surface
    BC / Dia: 8.4 / 14.2
    Dk/t:     154

    POWER RANGE
    +0.50 to +8.00D   (0.25D steps to +6.00, then 0.50D)
    -0.50 to -12.00D  (0.25D steps to -8.00, then 0.50D)

    ---------------------------------------------------------
    FIT SET AVAILABILITY
    Sphere: -0.50 to -12.00D (0.50D steps after -8.00) (full parameters)
            +0.50 to +8.00D (0.50D steps)
    )"
}

LensDB["T30 Toric"] := {
    Family:      "Alcon Reusables",
    DisplayName: "T30 Toric",
    FitGuideKey: "",
    MinSph: -10.00, MaxSph: 8.00, MaxCyl: -2.75,
    Specs: "
    (
    Material: lehfilcon A (Prism-ballast)
    Water:    55% Core | ~100% Surface
    BC / Dia: 8.6 / 14.5
    Dk/t:     122

    SPHERE             CYLINDER                     AXIS
    -----------------------------------------------------------------------
    +8.00 to -10.00   -0.75, -1.25, -1.75, -2.25  Full circle (10° steps)
    (0.50D steps after +/-6.50)    
    -----------------------------------------------------------------------
    *** -2.75 CYLINDER SPECIAL RANGE ***
    Plano to -6.00   -2.75                         10-30, 70-110, 150-180
    (0.50D steps)                                  (10° steps)
    +1.00 to +4.00                
    (1.00D steps)                        
    -----------------------------------------------------------------------
    FIT SET AVAILABILITY
    Sphere:   Plano to -6.00D (0.50D steps)
              Plano to +4.00D (1.00D steps)
    Cylinder: -0.75 to -2.25
    Axis:     Full circle (10° steps)
    )"
}

LensDB["T30 MF"] := {
    Family:      "Alcon Reusables",
    DisplayName: "T30 MF",
    FitGuideKey: "Alcon",
    MinSph: -10.00, MaxSph: 6.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: lehfilcon A (Water Gradient)
    Water:    55% Core | ~100% Surface
    BC / Dia: 8.4 / 14.2
    Dk/t:     154

    POWER RANGE
    +6.00 to -10.00D  (0.25D steps)

    ADD POWERS
    LO (+0.75 to +1.25D)
    MED (+1.50 to +2.00D)
    HI (+2.25 to +2.50D)

    ---------------------------------------------------------
    FIT SET AVAILABILITY (VERIFY)
    Sphere: +6.00 to -10.00 (0.25D steps)
    Adds:   LO, MED, HI
    )"
}

LensDB["T30 Toric MF"] := {
    Family:      "Alcon Reusables",
    DisplayName: "T30 Toric MF",
    FitGuideKey: "Alcon",
    MinSph: -6.00, MaxSph: 4.00, MaxCyl: -1.75,
    Specs: "
    (
    Material: lehfilcon A (Water Gradient)
    Water:    55% Core | ~100% Surface
    BC / Dia: 8.6 / 14.5
    Dk/t:     122

    SPHERE          CYLINDER             AXIS
    ---------------------------------------------------------------------
    +4.00 to -6.00  -0.75, -1.25, -1.75  10° to 180° (10° steps)
    (0.25D steps)

    ADD POWERS
    LO (+0.75 to +1.25D)
    MED (+1.50 to +2.00D)
    HI (+2.25 to +2.50D)

    ---------------------------------------------------------
    FIT SET AVAILABILITY
    Sphere:   Plano to -6.00D (0.50D steps after -2.50D)
    Cylinder: -1.25, -1.75
    Axis:     10-30, 70-110, 150-180
    Add:      LO, MED, HI
    )"
}

LensDB["Clariti"] := {
    Family:      "Cooper Dailies",
    DisplayName: "Clariti",
    FitGuideKey: "",
    MinSph: -10.00, MaxSph: 8.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: somofilcon A (Silicone Hydrogel)
    Water:    56%
    BC / Dia: 8.6 / 14.1
    Dk/t:     86

    POWER RANGE
    +0.50 to +8.00D   (0.25D steps up to +6.00, then 0.50D)
    -0.50 to -10.00D  (0.25D steps up to -6.00, then 0.50D)
    NO PLANO
    ---------------------------------------------------------
    FIT SET AVAILABILITY
    Plano to -10 (0.50D steps after -6.00) (Full minus parameters)
    Plano to +5.50 (0.25D steps between +1.00 and +3.00D)
    )"
}

LensDB["Clariti Toric"] := {
    Family:      "Cooper Dailies",
    DisplayName: "Clariti Toric",
    FitGuideKey: "",
    MinSph: -9.00, MaxSph: 4.00, MaxCyl: -2.25,
    Specs: "
    (
    Material: somofilcon A (Silicone Hydrogel)
    Water:    56%
    BC / Dia: 8.6 / 14.3
    Dk/t:     57

    SPHERE          CYLINDER             AXIS
    ---------------------------------------------------------------------
    Plano to -6.00  -0.75, -1.25, -1.75  Full circle (10° steps)
    (0.25D steps)   -2.25                10, 20, 70-110, 160-180
    ---------------------------------------------------------------------
    -6.50 to -9.00  -0.75, -1.25, -1.75  10, 20, 60-120, 160-180 (10° steps)
    (0.50D steps)
    ---------------------------------------------------------------------
    +0.25 to +4.00  -0.75, -1.25, -1.75  10, 20, 90, 160-180 (10° steps)
    (0.25D steps)
    -----------------------------------------------------------------------
    FIT SET AVAILABILITY
    Not in Office
    )"
}

LensDB["Clariti MF"] := {
    Family:      "Cooper Dailies",
    DisplayName: "Clariti MF",
    FitGuideKey: "Clariti",
    MinSph: -12.00, MaxSph: 8.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: somofilcon A (Silicone Hydrogel)
    Water:    56%
    BC / Dia: 8.6 / 14.1
    Dk/t:     86

    POWER RANGE
    +8.00 to -10.00D  (0.25D steps)
    -10.50 to -12.00D (0.50D steps)

    ADD POWERS
    LOW  (0.75 to +1.25D)
    Med (+1.50 to +1.75)
    HIGH (+2.00 to +2.50D)
    ---------------------------------------------------------
    FIT SET AVAILABILITY
    Sphere:   +8.00 to -10.00 (0.25D steps)
              -10.50 to -12.00 (0.50D steps)
    Adds:     LOW, MED, HI
    )"
}

LensDB["MyDay"] := {
    Family:      "Cooper Dailies",
    DisplayName: "MyDay",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 8.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: stenfilcon A (Smart Silicone)
    Water:    54%
    BC / Dia: 8.4 / 14.2
    Dk/t:     100

    POWER RANGE
    +8.00 to -12.00D  (0.25D steps, 0.50D after +5.00 and -6.00D)
    NO PLANO
    -----------------------------------------------------------------------
    FIT SET AVAILABILITY
    Plano to -10.00D (0.50D steps after -6.00) (Full minus parameters)
    +0.50 to +6.00 (0.25D steps between +1.00 and +3.00D)
    )"
}

LensDB["MyDay Toric"] := {
    Family:      "Cooper Dailies",
    DisplayName: "MyDay Toric",
    FitGuideKey: "",
    MinSph: -10.00, MaxSph: 8.00, MaxCyl: -2.25,
    Specs: "
    (
    Material: stenfilcon A (Optimized Toric Lens Geometry)
    Water:    54%
    BC / Dia: 8.6 / 14.5
    Dk/t:     80

    SPHERE          CYLINDER             AXIS
    ---------------------------------------------------------------------
    +8.00 to -10.00 -0.75, -1.25, -1.75  Full circle 10° steps
                    -2.25                Full circle 10° steps
    (0.50D steps after +/-6.00D) 
    -----------------------------------------------------------------------
    FIT SET AVAILABILITY
    Sphere:   Plano to -7.00D (0.50D steps)
    Cylinder: -0.75 to -1.75
    Axis:     10, 20, 160-180, 80-110
    )"
}

LensDB["MyDay MF"] := {
    Family:      "Cooper Dailies",
    DisplayName: "MyDay MF",
    FitGuideKey: "MyDay",
    MinSph: -12.00, MaxSph: 8.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: stenfilcon A (Binocular Progressive System)
    Water:    54%
    BC / Dia: 8.4 / 14.2
    Dk/t:     100

    POWER RANGE
    +8.00 to -12.00D  (0.25D steps, 0.50D after -10.50D)

    ADD POWERS
    LOW (+0.75 to +1.25D)
    MED (+1.50 to +1.75D)
    HIGH (+2.00 to +2.50D)
    -----------------------------------------------------------------------
    FIT SET AVAILABILITY
    Sphere:  +4.00 to -9.00D (0.25D steps)
    Add: Low, Med, High
    )"
}

LensDB["MyDay Energy's"] := {
    Family:      "Cooper Dailies",
    DisplayName: "MyDay Energy's",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 8.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: stenfilcon A (DigitalBoost Tech)
    Water:    54%
    BC / Dia: 8.4 / 14.2
    Dk/t:     100

    POWER RANGE
    +8.00 to -12.00D  (0.25D steps, 0.50D after +5.00 and -6.00D)
    Note: Features a +0.30D boost
    -----------------------------------------------------------------------
    FIT SET AVAILABILITY
    Plano to -10.00D (0.50D steps after -6.00D)
    +0.50 to +4.00D (0.50D steps)
    )"
}

LensDB["BF / XR"] := {
    Family:      "Biofinity",
    DisplayName: "BF / XR",
    FitGuideKey: "",
    MinSph: -20.00, MaxSph: 15.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: comfilcon A (Aquaform Technology)
    Water:    48%
    BC / Dia: 8.6 / 14.0
    Dk/t:     160

    STANDARD RANGE (Biofinity)
    +8.00 to -12.00D  (0.25D steps, 0.50D after +/- 6.00D)

    XR RANGE (Made to Order)
    +8.50 to +15.00D  (0.50D steps)
    -12.50 to -20.00D (0.50D steps)

    ---------------------------------------------------------
    FIT SET AVAILABILITY (Verify in office)
    +8.00 to -9.50D (0.50D steps after +/-6.00D)
    XR Range: Made to Order
    )"
}

LensDB["BF Energy's"] := {
    Family:      "Biofinity",
    DisplayName: "BF Energy's",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 8.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: comfilcon A (DigitalZone Optics)
    Water:    48%
    BC / Dia: 8.6 / 14.0
    Dk/t:     160

    POWER RANGE
    +8.00 to -12.00D  (0.25D steps, 0.50D after +/- 6.00D)
    Note: Multiple front-surface aspheric curves
    -----------------------------------------------------------------------
    FIT SET AVAILABILITY
    Plano to -9.00D (0.25D steps)
    +0.50 to +6.00D (0.50D steps after +4.50)
    )"
}

LensDB["BF Toric / XR"] := {
    Family:      "Biofinity",
    DisplayName: "BF Toric / XR",
    FitGuideKey: "",
    MinSph: -20.00, MaxSph: 20.00, MaxCyl: -5.75,
    Specs: "
    (
    Material: comfilcon A (Optimized Toric Lens Geometry)
    Water:    48%
    BC / Dia: 8.7 / 14.5
    Dk/t:     116

    STANDARD RANGE
    SPHERE          CYLINDER             AXIS
    ---------------------------------------------------------------------
    +8.00 to -10.00 -0.75, -1.25, -1.75  10° to 180° (10° steps)
                    -2.25                
    (0.50D steps after +/-6.00D)

    XR RANGE (Made to Order)
    SPHERE           CYLINDER             AXIS
    ---------------------------------------------------------------------
    +20.00 to -20.0 -0.75 to -2.25       5° to 180° (5° steps)
    (0.50D steps after +8.50 and -10.50D)   

    +20.00 to -20.0 -2.75 to -5.75       5° to 180° (5° steps)
    (0.50D steps after +/-6.00D)   
    -----------------------------------------------------------------------
    FIT SET AVAILABILITY
    Sphere:   +6.00 to -6.00D (0.50D steps)
              Cylinder: -0.75 to -1.75
              Axis:     Full circle (10° steps)
    ---------
    Sphere:   -0.50 to -4.00D (0.50D steps)
              +1.00 to +3.00D (1.00D steps)
              Cylinder: -2.25
              Axis:     Full circle (10° steps)(?)
    )"
}

LensDB["BF MF"] := {
    Family:      "Biofinity",
    DisplayName: "BF MF",
    FitGuideKey: "Biofinity",
    MinSph: -10.00, MaxSph: 6.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: comfilcon A (Balanced Progressive)
    Water:    48%
    BC / Dia: 8.6 / 14.0
    Dk/t:     160

    POWER RANGE
    +6.00 to -10.00D  (0.25D steps, 0.50D after +/- 6.00D)

    ADD POWERS (D and N lenses available for all)
    +1.00, +1.50, +2.00, +2.50
    -----------------------------------------------------------------------
    FIT SET AVAILABILITY
    Sphere:   +4.00 to -6.00D (0.50D steps after -4.50D)
    Add: +1.00, +1.50, +2.00, +2.50 (D and N)
    )"
}

LensDB["BF Toric MF"] := {
    Family:      "Biofinity",
    DisplayName: "BF Toric MF",
    FitGuideKey: "Biofinity",
    MinSph: -10.00, MaxSph: 10.00, MaxCyl: -5.75,
    Specs: "
    (
    Material: comfilcon A (Made to Order)
    Water:    48%
    BC / Dia: 8.7 / 14.5
    Dk/t:     116

    SPHERE             CYLINDER             AXIS
    ---------------------------------------------------------------------
    +10.00 to -10.0  -0.75 to -5.75       5° to 180° (5° steps)
    (0.50D steps after +/-6.50)

    ADD POWERS (D and N lenses available for all)
    +1.00, +1.50, +2.00, +2.50
    -----------------------------------------------------------------------
    FIT SET AVAILABILITY
    Made to Order 
    )"
}

LensDB["MiSight"] := {
    Family:      "Cooper Dailies",
    DisplayName: "MiSight",
    FitGuideKey: "",
    MinSph: -10.00, MaxSph: -0.25, MaxCyl: 0.00,
    Specs: "
    (
    Material: omafilcon A (Proclear Technology)
    Water:    60%
    BC / Dia: 8.7 / 14.2
    Dk/t:     28

    POWER RANGE (Myopia Treatment)
    -0.25 to -6.00D  (0.25D steps)
    -6.50 to -10.00D (0.50D steps)

    Note: Dual-focus concentric ring design for myopia control. 
    Features 2 treatment zones (+2.00D add) and 2 correction zones.
    ---------------------------------------------------------
    FIT SET AVAILABILITY
    -0.50 to -6.00D (0.25D steps)
    )"
}

LensDB["Acuvue Oasys"] := {
    Family:      "J&J Reusable",
    DisplayName: "Acuvue Oasys",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 8.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: senofilcon A
    Technology: Hydraclear Plus
    Water:    38%
    BC / Dia: 8.4 & 8.8 / 14.0
    Dk/t:     147
    Replacement: 2 week

    POWER RANGE
    +0.50 to +8.00D   (0.25D steps to +6.00, then 0.50D)
    -0.50 to -12.00D  (0.25D steps to -6.00, then 0.50D)
    )"
}

LensDB["Acuvue Oasys Toric"] := {
    Family:      "J&J Reusable",
    DisplayName: "Acuvue Oasys Toric",
    FitGuideKey: "",
    MinSph: -9.00, MaxSph: 6.00, MaxCyl: -2.75,
    Specs: "
    (
    Material: senofilcon A
    Technology: Hydraclear Plus; Blink Stabilized
    Water:    38%
    BC / Dia: 8.6 / 14.5
    Dk/t:     129
    Replacement: 2 week

    SPHERE          CYLINDER             AXIS
    ---------------------------------------------------------------------
    +6.00 to -6.00  -0.75, -1.25, -1.75  Full circle (10° steps)
    (0.25D steps)   -2.25, -2.75         
    --------------
    -6.50 to -9.00
    (0.50D steps)  
    )"
}

LensDB["Acuvue Oasys MF"] := {
    Family:      "J&J Reusable",
    DisplayName: "Acuvue Oasys MF",
    FitGuideKey: "Acuvue",
    MinSph: -9.00, MaxSph: 6.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: senofilcon A (Pupil Optimized Design)
    Technology: Hydraclear Plus
    Water:    38%
    BC / Dia: 8.4 / 14.3
    Dk/t:     147
    Replacement: 2 week

    POWER RANGE
    +6.00 to -9.00D   (0.25D steps)

    ADD POWERS
    LOW (+0.75 to +1.25D) 
    MID (+1.50 to +1.75D)
    HIGH (+2.00 to +2.50D)
    )"
}

LensDB["Acuvue Oasys 1-Day"] := {
    Family:      "J&J 1-Day",
    DisplayName: "Acuvue Oasys 1-Day",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 8.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: senofilcon A
    Technology: Hydraluxe
    Water:    38%
    BC / Dia: 8.5 & 9.0 / 14.3
    Dk/t:     121
    Replacement: Daily

    POWER RANGE
    +0.50 to +8.00D   (0.25D steps to +6.00, then 0.50D)
    -0.50 to -12.00D  (0.25D steps to -6.00, then 0.50D)
    )"
}

LensDB["Acuvue Oasys 1-Day Toric"] := {
    Family:      "J&J 1-Day",
    DisplayName: "Acuvue Oasys 1-Day Toric",
    FitGuideKey: "",
    MinSph: -9.00, MaxSph: 4.00, MaxCyl: -2.25,
    Specs: "
    (
    Material: senofilcon A 
    Technology: HydraLuxe; Blink Stabilized
    Water:    38%
    BC / Dia: 8.5 / 14.3
    Dk/t:     129
    Replacement: Daily

    SPHERE          CYLINDER             AXIS
    ---------------------------------------------------------------------
    Plano to -6.00  -0.75, -1.25, -1.75  Full circle (10° steps)
                    -2.25                10, 20, 70-110, 160-180
    ---------------------------------------------------------------------
    -6.50 to -9.00  -0.75, -1.25, -1.75  10, 20, 70-110, 160-180
    ---------------------------------------------------------------------
    +0.25 to +4.00  -0.75, -1.25, -1.75  10, 20, 70-110, 160-180
    )"
}

LensDB["Acuvue 1-Day Max"] := {
    Family:      "J&J 1-Day",
    DisplayName: "Acuvue 1-Day Max",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 8.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: senofilcon A (TearStable & OptiBlue)
    Water:    38%
    BC / Dia: 8.5 & 9.0 / 14.3
    Dk/t:     121
    Replacement: Daily

    POWER RANGE
    +0.50 to +8.00D   (0.25D steps to +6.00, then 0.50D)
    -0.50 to -12.00D  (0.25D steps to -6.00, then 0.50D)
    )"
}

LensDB["Acuvue Moist"] := {
    Family:      "J&J 1-Day",
    DisplayName: "Acuvue Moist",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 6.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: etafilcon A (Lacreon)
    Technology: Lacreon technology
    Water:    58%
    BC / Dia: 8.5 & 9.0 / 14.2
    Dk/t:     25.5
    Replacement: Daily

    POWER RANGE
    +6.00 to -12.00D   (0.50D steps after -6.00D)
    )"
}

LensDB["Acuvue Vita"] := {
    Family:      "J&J Reusable",
    DisplayName: "Acuvue Vita",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 8.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: senofilcon C
    Technology: HydraMax
    Water:    41%
    BC / Dia: 8.4 & 8.8 / 14.0
    Dk/t:     147
    Replacement: Monthly

    POWER RANGE
    +0.50 to +8.00D   (0.25D steps to +6.00, then 0.50D)
    -0.50 to -12.00D  (0.25D steps to -6.00, then 0.50D)
    )"
}

LensDB["Infuse"] := {
    Family:      "B&L",
    DisplayName: "Infuse",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 6.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: kalifilcon A (ProBalance Technology)
    Water:    55%
    BC / Dia: 8.6 / 14.2
    Dk/t:     134

    POWER RANGE
    +0.50 to +6.00D   (0.25D steps)
    -0.50 to -12.00D  (0.25D steps to -6.00, then 0.50D)
    )"
}

LensDB["Infuse MF"] := {
    Family:      "B&L",
    DisplayName: "Infuse MF",
    FitGuideKey: "BL",
    MinSph: -10.00, MaxSph: 6.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: kalifilcon A (3-Zone Progressive)
    Water:    55%
    BC / Dia: 8.6 / 14.2
    Dk/t:     134

    POWER RANGE
    +6.00 to -10.00D  (0.25D steps)

    ADD POWERS
    LOW, HIGH
    ---------------------------------------------------------
    FIT SET AVAILABILITY
    +6.00 to -10.00D (0.25D steps)
    )"
}

LensDB["Ultra"] := {
    Family:      "B&L",
    DisplayName: "Ultra",
    FitGuideKey: "",
    MinSph: -12.00, MaxSph: 6.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: samfilcon A (MoistureSeal)
    Water:    46%
    BC / Dia: 8.5 / 14.2
    Dk/t:     163

    POWER RANGE
    +0.25 to +6.00D   (0.25D steps)
    -0.25 to -12.00D  (0.25D steps to -6.00, then 0.50D)
    )"
}

LensDB["Ultra Toric"] := {
    Family:      "B&L",
    DisplayName: "Ultra Toric",
    FitGuideKey: "",
    MinSph: -9.00, MaxSph: 4.00, MaxCyl: -2.75,
    Specs: "
    (
    Material: samfilcon A (OpticAlign)
    Water:    46%
    BC / Dia: 8.6 / 14.5
    Dk/t:     114

    SPHERE          CYLINDER             AXIS
    ---------------------------------------------------------------------
    +4.00 to -6.00  -0.75, -1.25, -1.75  10° to 180° (10° steps)
                    -2.25, -2.75         10° to 180° (10° steps)
    ---------------------------------------------------------------------
    -6.50 to -9.00  -0.75, -1.25, -1.75  10° to 180° (10° steps)
                    -2.25, -2.75         10° to 180° (10° steps)
    )"
}

LensDB["Ultra MF"] := {
    Family:      "B&L",
    DisplayName: "Ultra MF",
    FitGuideKey: "BL",
    MinSph: -10.00, MaxSph: 6.00, MaxCyl: 0.00,
    Specs: "
    (
    Material: samfilcon A (3-Zone Progressive)
    Water:    46%
    BC / Dia: 8.5 / 14.2
    Dk/t:     163

    POWER RANGE
    +6.00 to -10.00D  (0.25D steps)

    ADD POWERS
    LOW, HIGH
    )"
}

LensDB["Ultra Toric MF"] := {
    Family:      "B&L",
    DisplayName: "Ultra Toric MF",
    FitGuideKey: "BL",
    MinSph: -6.00, MaxSph: 4.00, MaxCyl: -2.75,
    Specs: "
    (
    Material: samfilcon A (OpticAlign)
    Water:    46%
    BC / Dia: 8.6 / 14.5
    Dk/t:     114

    SPHERE          CYLINDER             AXIS
    ---------------------------------------------------------------------
    +4.00 to -6.00  -0.75, -1.25, -1.75  10° to 180° (10° steps)
                    -2.25, -2.75         10° to 180° (10° steps)

    ADD POWERS
    LOW, HIGH
    )"
}

LensDB["Discontinued / Legacy"] := {
    Family:      "Graveyard",
    DisplayName: "Discontinued / Legacy",
    MinSph: 0.00, MaxSph: 0.00, MaxCyl: 0.00,
    Specs: "
    (
    === THE GRAVEYARD ===
    Check patient history. These lenses require a refit.

    ALCON
    - Focus Dailies (Refit -> DACP or P1)
    - Air Optix Aqua (Refit -> AO HydraGlyde)
    - FreshLook Families (Refit -> AO Colors / Dailies Colors)
    - DACP (Actively phasing out -> P1)

    JOHNSON & JOHNSON
    - 1-Day Acuvue TruEye (Refit -> Oasys 1-Day)
    - Acuvue Advance / Plus (Refit -> Oasys)
    - Acuvue 2 (Legacy/Restricted -> Oasys)

    COOPERVISION
    - Proclear 1-Day (Refit -> Clariti or MyDay)
    - Frequency 55 (Refit -> Biofinity)
    - Avaira Original (Refit -> Avaira Vitality or Biofinity)
    
    * Upcoming Discontinuations (Nov 1, 2026):
      - Clariti MF
      - Proclear MF Toric
      - Proclear XR Toric
      - Proclear XR MF
      
    * Upcoming Discontinuations (Nov 1, 2027):
      - Proclear Sphere
      - Proclear Toric
      - Proclear MF

    BAUSCH + LOMB
    - SofLens Families (Refit -> Ultra or Infuse)
    - PureVision Original (Refit -> Ultra)
    )"
}

; --- Define Trial Sets for Dynamic Suggestion Engine ---
LensDB["P1"].DefineProp("Trial", {Value: {SphSteps: [{Min: -8.00, Max: 0.00, Step: 0.50}, {Min: 1.00, Max: 4.00, Step: 1.00}]}})
LensDB["DT1"].DefineProp("Trial", {Value: {SphSteps: [{Min: -8.00, Max: 0.00, Step: 0.50}, {Min: 1.00, Max: 4.00, Step: 1.00}]}})
LensDB["P1 Toric"].DefineProp("Trial", {Value: {SphSteps: [{Min: -8.00, Max: 0.00, Step: 0.50}, {Min: 1.00, Max: 4.00, Step: 1.00}], Cyls: [-0.75, -1.25, -1.75], Axes: [{Min: 10, Max: 20, Step: 10}, {Min: 80, Max: 110, Step: 10}, {Min: 160, Max: 180, Step: 10}]}})
LensDB["DT1 Toric"].DefineProp("Trial", {Value: {SphSteps: [{Min: -8.00, Max: 0.00, Step: 0.50}, {Min: 1.00, Max: 4.00, Step: 1.00}], Cyls: [-0.75, -1.25, -1.75], Axes: [{Min: 10, Max: 20, Step: 10}, {Min: 80, Max: 110, Step: 10}, {Min: 160, Max: 180, Step: 10}]}})
LensDB["P7"].DefineProp("Trial", {Value: {SphSteps: [{Min: -12.00, Max: -8.00, Step: 0.50}, {Min: -8.00, Max: 8.00, Step: 0.25}]}})
LensDB["T30"].DefineProp("Trial", {Value: {SphSteps: [{Min: -12.00, Max: -8.00, Step: 0.50}, {Min: -8.00, Max: 8.00, Step: 0.25}]}})
LensDB["P7 Toric"].DefineProp("Trial", {Value: {SphSteps: [{Min: -6.00, Max: 0.00, Step: 0.50}, {Min: 1.00, Max: 4.00, Step: 1.00}], Cyls: [-0.75, -1.25, -1.75, -2.25], Axes: [{Min: 10, Max: 180, Step: 10}]}})
LensDB["T30 Toric"].DefineProp("Trial", {Value: {SphSteps: [{Min: -6.00, Max: 0.00, Step: 0.50}, {Min: 1.00, Max: 4.00, Step: 1.00}], Cyls: [-0.75, -1.25, -1.75, -2.25], Axes: [{Min: 10, Max: 180, Step: 10}]}})
LensDB["Clariti"].DefineProp("Trial", {Value: {SphSteps: [{Min: -10.00, Max: -6.50, Step: 0.50}, {Min: -6.00, Max: 6.00, Step: 0.25}]}})
LensDB["MyDay"].DefineProp("Trial", {Value: {SphSteps: [{Min: -10.00, Max: -6.50, Step: 0.50}, {Min: -6.00, Max: 6.00, Step: 0.25}]}})
LensDB["MyDay Toric"].DefineProp("Trial", {Value: {SphSteps: [{Min: -7.00, Max: 0.00, Step: 0.50}], Cyls: [-0.75, -1.25, -1.75], Axes: [{Min: 10, Max: 20, Step: 10}, {Min: 80, Max: 110, Step: 10}, {Min: 160, Max: 180, Step: 10}]}})
LensDB["BF / XR"].DefineProp("Trial", {Value: {SphSteps: [{Min: -9.50, Max: -6.00, Step: 0.50}, {Min: -5.75, Max: 5.75, Step: 0.25}, {Min: 6.00, Max: 8.00, Step: 0.50}]}})
LensDB["BF Toric / XR"].DefineProp("Trial", {Value: {SphSteps: [{Min: -6.00, Max: 6.00, Step: 0.50}], Cyls: [-0.75, -1.25, -1.75], Axes: [{Min: 10, Max: 180, Step: 10}]}})
LensDB["DT1 MF"].DefineProp("Trial", {Value: {SphSteps: [{Min: -10.00, Max: 6.00, Step: 0.25}]}})
LensDB["T30 MF"].DefineProp("Trial", {Value: {SphSteps: [{Min: -10.00, Max: 6.00, Step: 0.25}]}})
LensDB["T30 Toric MF"].DefineProp("Trial", {Value: {SphSteps: [{Min: -6.00, Max: 0.00, Step: 0.50}, {Min: 1.00, Max: 4.00, Step: 1.00}], Cyls: [-1.25, -1.75], Axes: [{Min: 10, Max: 30, Step: 10}, {Min: 70, Max: 110, Step: 10}, {Min: 150, Max: 180, Step: 10}]}})
LensDB["MyDay MF"].DefineProp("Trial", {Value: {SphSteps: [{Min: -9.00, Max: 4.00, Step: 0.25}]}})
LensDB["BF MF"].DefineProp("Trial", {Value: {SphSteps: [{Min: -6.00, Max: 4.00, Step: 0.25}]}})

; ==============================================================================
; 2. THE DYNAMIC PARAMETER MENU SYSTEM (!p) - Structured 4-Column Layout
; ==============================================================================
Global ActiveParamGuis := Map()
Global CLMenu := Menu()

BuildMenu() {
    ; Explicitly group keys to build horizontal BarBreak layouts without map sorting issues
    MenuColumns := [
        {Header: "=== ALCON ===",   Families: ["Alcon Dailies", "Alcon Reusables"], Opts: ""},
        {Header: "=== COOPER ===",  Families: ["Cooper Dailies", "Biofinity"],     Opts: "BarBreak"},
        {Header: "=== J&J ===",     Families: ["J&J 1-Day", "J&J Reusable"],       Opts: "BarBreak"},
        {Header: "=== B&L ===",     Families: ["B&L"],                             Opts: "BarBreak"}
    ]
    
    For col in MenuColumns {
        CLMenu.Add(col.Header, ClearMenuClick, col.Opts)
        CLMenu.Disable(col.Header)
        
        For fam in col.Families {
            For lensKey, lensData in LensDB {
                if (lensData.Family == fam) {
                    CLMenu.Add(lensData.DisplayName, ShowParams)
                }
            }
        }
    }
    
    ; Place the graveyard cleanly at the cross-section
    CLMenu.Add() 
    CLMenu.Add(LensDB["Discontinued / Legacy"].DisplayName, ShowParams)
}
BuildMenu()

!p:: {
    CoordMode("Menu", "Screen")
    MenuX := (A_ScreenWidth / 2) - 150
    MenuY := A_ScreenHeight / 3
    CLMenu.Show(MenuX, MenuY)
}

ClearMenuClick(*) {
    return
}

ShowParams(ItemName, ItemPos, MyMenu) {
    Global ActiveParamGuis, LensDB, FitGuides

    TargetKey := ""
    For k, v in LensDB {
        if (v.DisplayName == ItemName) {
            TargetKey := k
            break
        }
    }

    if (TargetKey == "") {
        return
    }

    ParamGui := Gui("+AlwaysOnTop -Caption +Border", "CL_Params")
    ParamGui.BackColor := "White"

    CloseBtn := ParamGui.Add("Text", "x15 y15 cBlue BackgroundTrans", "Close")
    CloseBtn.SetFont("underline")
    CloseBtn.OnEvent("Click", CloseParamGui)

    ParamGui.SetFont("s11 bold", "Segoe UI")
    ParamGui.Add("Text", "x0 y15 w550 Center cBlack", ItemName " Parameters")
    
    ParamGui.SetFont("s8 norm", "Segoe UI")
    ParamGui.Add("Text", "w550 Center cGray", "Click and drag to move  •  Press Esc to close  •  Press Alt+P for Menu")
    ParamGui.Add("Text", "x10 y+5 w550 h1 0x10")

    ParamGui.SetFont("s10 cBlack", "Consolas")
    ParamGui.Add("Text", "x15 y+10 w540", LensDB[TargetKey].Specs)

    ; Safely check if FitGuideKey even exists on this object first
    GuideKey := LensDB[TargetKey].HasProp("FitGuideKey") ? LensDB[TargetKey].FitGuideKey : ""
    
    if (GuideKey != "" && FitGuides.Has(GuideKey)) {
        ParamGui.Add("Text", "x10 y+15 w550 h1 0x10")
        ParamGui.SetFont("s10 bold c003366", "Segoe UI")
        ParamGui.Add("Text", "x15 y+10 w540", "CLINICAL FITTING ALGORITHM")
        ParamGui.SetFont("s9 norm c003366", "Consolas")
        ParamGui.Add("Text", "x15 y+5 w540", FitGuides[GuideKey])
    }

    OnMessage(0x0201, DragWindow)

    ActiveParamGuis[ParamGui.Hwnd] := ParamGui

    ; Cascade position offset based on number of active parameter windows
    openCount := ActiveParamGuis.Count - 1
    offset := openCount * 30
    
    GuiX := ((A_ScreenWidth / 2) - 275) + offset
    GuiY := (A_ScreenHeight / 3) + offset
    ParamGui.Show("x" GuiX " y" GuiY " AutoSize NoActivate")
}

CloseParamGui(ctrlObj, *) {
    Global ActiveParamGuis
    if IsObject(ctrlObj) && ctrlObj.HasProp("Gui") {
        thisGui := ctrlObj.Gui
        ActiveParamGuis.Delete(thisGui.Hwnd)
        thisGui.Destroy()
    }
}

CloseActiveParamGui() {
    Global ActiveParamGuis
    activeHwnd := WinActive("A")
    if (ActiveParamGuis.Has(activeHwnd)) {
        thisGui := ActiveParamGuis[activeHwnd]
        ActiveParamGuis.Delete(activeHwnd)
        thisGui.Destroy()
    }
}

DragWindow(wParam, lParam, msg, hwnd) {
    Global ActiveParamGuis
    if (ActiveParamGuis.Has(hwnd)) {
        PostMessage(0xA1, 2,,, "ahk_id " hwnd)
    }
}

#HotIf WinActive("CL_Params")
Esc:: {
    CloseActiveParamGui()
}
#HotIf

; ==============================================================================
; 3. THE CONVERSION TOOL ENGINE (!c) - Horizontal 4-Column Layout
; ==============================================================================
global clGui := ""

!c:: {
    KeyWait("Alt")
    A_Clipboard := ""
    Sleep(100)
    Send("^{c}")
    
    if !ClipWait(3) {
        MsgBox("Failed to copy text.`n`n1. Make sure the text is highlighted.`n2. Try releasing the Alt key a little faster.")
        return
    }
    
    ; Clean up line breaks
    clipText := StrReplace(StrReplace(A_Clipboard, "`r", ""), "`n", "")
    
    ; =================================================================
    ; ADDITION: SANITIZE SNELLEN ACUITIES
    ; Removes 20/15, 20/30, etc. so the '20' isn't read as an axis
    ; =================================================================
    clipText := RegExReplace(clipText, "20/\d{2,3}[-+]?", "")
    
    pattern := "is)R\s*([+-]?\d+\.\d{2})(?:\s*(?:DS|SPH|([+-]?\d+\.\d{2})\s*(?:x\s*)?(\d{1,3})))?.*?L\s*([+-]?\d+\.\d{2})(?:\s*(?:DS|SPH|([+-]?\d+\.\d{2})\s*(?:x\s*)?(\d{1,3})))?"
    
    if RegExMatch(clipText, pattern, &match) {
        rSph := Float(match[1]), rCyl := (match[2] != "") ? Float(match[2]) : 0.0, rAxis := (match[3] != "") ? Integer(match[3]) : 0
        lSph := Float(match[4]), lCyl := (match[5] != "") ? Float(match[5]) : 0.0, lAxis := (match[6] != "") ? Integer(match[6]) : 0
        
        ; Filter out ADD powers caught as cylinders when no axis is present
        if (rAxis == 0) {
            rCyl := 0.0
        }
        if (lAxis == 0) {
            lCyl := 0.0
        }
        
        rData := ProcessCLRx(rSph, rCyl, rAxis)
        lData := ProcessCLRx(lSph, lCyl, lAxis)
        
        ShowRxGui(rData, lData, false)
    } else {
        MsgBox("Failed to match the pattern.`n`nClipboard:`n[" clipText "]", "Regex Failed")
    }
}

ShowRxGui(rData, lData, isMF) {
    global clGui
    if IsObject(clGui) {
        clGui.Destroy()
    }
    
    rOptions := EvaluateLenses(rData.sph, rData.cyl, rData.axis, isMF)
    lOptions := EvaluateLenses(lData.sph, lData.cyl, lData.axis, isMF)
    
    clGui := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox", "CL Suggestions")
    clGui.BackColor := "White"
    
    ; --- Top Header Region ---
    clGui.SetFont("s16 bold", "Segoe UI")
    clGui.Add("Text", "x20 y15 w420 c003366", "OD: " rData.text)
    clGui.Add("Text", "x450 y15 w420 c003366", "OS: " lData.text)
    
    clGui.SetFont("s10 bold c003366", "Segoe UI")
    mfCheck := clGui.Add("CheckBox", "x1000 y20 w150 Checked" isMF, "👓 Multifocal Mode")
    mfCheck.OnEvent("Click", (*) => ToggleMF(rData, lData, mfCheck.Value))
    
    clGui.Add("Text", "x10 y55 w1140 h1 0x10")
    
    ; --- Define Column Layout Definitions ---
    Columns := [
        {Header: "ALCON",       X: 20,  Families: ["Alcon Dailies", "Alcon Reusables"]},
        {Header: "COOPERVISION",X: 305, Families: ["Cooper Dailies", "Biofinity"]},
        {Header: "J&J",          X: 590, Families: ["J&J 1-Day", "J&J Reusable"]},
        {Header: "BAUSCH + LOMB",X: 875, Families: ["B&L"]}
    ]
    
    MaxY := 100 
    
    For col in Columns {
        currY := 70
        
        clGui.SetFont("s11 bold c003366", "Segoe UI")
        clGui.Add("Text", "x" col.X " y" currY " w260 Center", col.Header)
        currY += 25
        clGui.Add("Text", "x" col.X " y" currY " w250 h1 0x10")
        currY += 15
        
        For fam in col.Families {
            hasR := rOptions.Has(fam)
            hasL := lOptions.Has(fam)
            
            if (hasR || hasL) {
                clGui.SetFont("s10 bold cBlack", "Segoe UI")
                clGui.Add("Text", "x" col.X " y" currY " w195", fam)
                
                rText := hasR ? rOptions[fam].name " " rOptions[fam].rx "  " rOptions[fam].status : "Not Available"
                lText := hasL ? lOptions[fam].name " " lOptions[fam].rx "  " lOptions[fam].status : "Not Available"
                
                btn := clGui.Add("Button", "x" (col.X + 200) " y" (currY - 2) " w50 h22", "Copy")
                copyStr := fam (isMF ? " (Multifocal)`n" : "`n") "OD: " rText "`nOS: " lText
                btn.OnEvent("Click", CopyBtn_Click.Bind(copyStr))
                currY += 22
                
                clGui.SetFont("s9 norm cBlack", "Consolas")
                clGui.Add("Text", "x" col.X " y" currY " w250", "OD: " rText)
                currY += 16
                clGui.Add("Text", "x" col.X " y" currY " w250", "OS: " lText)
                currY += 25
                
                clGui.Add("Text", "x" col.X " y" currY " w250 h1 0x10") 
                currY += 15
            }
        }
        if (currY > MaxY) {
            MaxY := currY
        }
    }
    
    ; --- Dynamic Footer ---
    clGui.Add("Text", "x10 y" (MaxY - 5) " w1140 h1 0x10")
    clGui.SetFont("s9 norm cGray", "Segoe UI")
    clGui.Add("Text", "x20 y" (MaxY + 8) " w1120 Center", "[ Press Esc to close ]")
    
    clGui.Show("NoActivate AutoSize")
}

ToggleMF(rData, lData, state) {
    ShowRxGui(rData, lData, state)
}

CopyBtn_Click(textToCopy, *) {
    A_Clipboard := textToCopy
    ToolTip("Copied to clipboard!")
    SetTimer(() => ToolTip(), -1500)
}

EvaluateLenses(sph, cyl, axis, isMF) {
    options := Map()
    
    ; Define the 7 target family names we want to suggest in our columns
    targetFamilies := ["Alcon Dailies", "Alcon Reusables", "Cooper Dailies", "Biofinity", "J&J 1-Day", "J&J Reusable", "B&L"]
    
    for fam in targetFamilies {
        bestLens := ""
        
        ; Find the best matching lens in this family
        for name, lens in LensDB {
            if (lens.Family != fam)
                continue
                
            ; Check if it matches MF modality
            hasMF := InStr(name, "MF") > 0 || (lens.HasProp("FitGuideKey") && lens.FitGuideKey != "")
            if (isMF != hasMF)
                continue
                
            ; Check if it matches Toric vs. Sphere modality
            isToric := (lens.MaxCyl < 0)
            patientHasCyl := (cyl != 0)
            if (patientHasCyl != isToric)
                continue
                
            ; Check if patient's sphere is within lens power range
            if (sph < lens.MinSph || sph > lens.MaxSph)
                continue
                
            ; Check if patient's cylinder is within lens cylinder limit
            if (patientHasCyl && cyl < lens.MaxCyl)
                continue
                
            ; If we reach here, this lens is a match!
            ; Combine multiple lenses in the same family if applicable (e.g. "P1 / DT1")
            if (bestLens == "") {
                bestLens := lens
            } else {
                if (!InStr(bestLens.DisplayName, lens.DisplayName)) {
                    ; Create a combined lens object
                    combinedDisplayName := bestLens.DisplayName " / " lens.DisplayName
                    combinedMinSph := Min(bestLens.MinSph, lens.MinSph)
                    combinedMaxSph := Max(bestLens.MaxSph, lens.MaxSph)
                    combinedMaxCyl := Min(bestLens.MaxCyl, lens.MaxCyl)
                    
                    ; Keep reference to original lenses for trial checks
                    origLenses := []
                    if (bestLens.HasProp("Lenses")) {
                        origLenses := bestLens.Lenses
                    } else {
                        origLenses.Push(bestLens)
                    }
                    origLenses.Push(lens)
                    
                    bestLens := {
                        Family: fam,
                        DisplayName: combinedDisplayName,
                        MinSph: combinedMinSph,
                        MaxSph: combinedMaxSph,
                        MaxCyl: combinedMaxCyl,
                        Lenses: origLenses
                    }
                }
            }
        }
        
        if (bestLens != "") {
            ; Determine closest available prescription for this lens
            rxDetails := GetClosestRx(bestLens, sph, cyl, axis)
            
            ; Determine trial set status
            status := GetTrialStatus(bestLens, rxDetails.sph, rxDetails.cyl, rxDetails.axis)
            
            rxStr := (rxDetails.cyl == 0) ? Format("{:+.2f} DS", rxDetails.sph) : Format("{:+.2f} {:+.2f} x {:03}", rxDetails.sph, rxDetails.cyl, rxDetails.axis)
            options[fam] := {name: bestLens.DisplayName, rx: rxStr, status: status}
        }
    }
    return options
}

GetClosestRx(lens, sph, cyl, axis) {
    if (lens.HasProp("Lenses")) {
        bestRx := ""
        bestDist := 999.0
        for subLens in lens.Lenses {
            subRx := GetClosestRx(subLens, sph, cyl, axis)
            dist := Abs(subRx.sph - sph) + Abs(subRx.cyl - cyl)
            if (dist < bestDist) {
                bestDist := dist
                bestRx := subRx
            }
        }
        return bestRx
    }
    
    ; 1. Round Sphere
    transitionMin := -6.00
    transitionMax := InStr(lens.DisplayName, "MyDay") ? 5.00 : 6.00
    
    clampedSph := Max(lens.MinSph, Min(lens.MaxSph, sph))
    
    step := 0.25
    if (clampedSph < transitionMin || clampedSph > transitionMax) {
        step := 0.50
    }
    
    finalSph := Round(clampedSph / step) * step
    
    ; 2. Round Cylinder & Axis
    finalCyl := 0.0
    finalAxis := 0
    
    if (lens.MaxCyl < 0) {
        supportedCyls := [-0.75, -1.25, -1.75, -2.25]
        if (lens.MaxCyl <= -2.75)
            supportedCyls.Push(-2.75)
            
        if (InStr(lens.DisplayName, "XR")) {
            val := -3.25
            while (val >= lens.MaxCyl) {
                supportedCyls.Push(val)
                val -= 0.50
            }
        }
        
        closestCyl := 0.0
        minCylDist := 999.0
        for c in supportedCyls {
            dist := Abs(cyl - c)
            if (dist < minCylDist) {
                minCylDist := dist
                closestCyl := c
            }
        }
        finalCyl := closestCyl
        
        axisStep := InStr(lens.DisplayName, "XR") ? 5 : 10
        if (axis > 0) {
            finalAxis := Round(axis / axisStep) * axisStep
            if (finalAxis <= 0)
                finalAxis := 180
            if (finalAxis > 180)
                finalAxis := finalAxis - 180
        } else {
            finalAxis := 180
        }
    }
    
    return {sph: finalSph, cyl: finalCyl, axis: finalAxis}
}

GetTrialStatus(lens, sph, cyl, axis) {
    if (lens.HasProp("Lenses")) {
        hasTrial := false
        hasCloseMatch := false
        for subLens in lens.Lenses {
            status := GetTrialStatus(subLens, sph, cyl, axis)
            if (status == "✅ Trial")
                hasTrial := true
            else if (status == "🟡 Close Match")
                hasCloseMatch := true
        }
        if (hasTrial)
            return "✅ Trial"
        if (hasCloseMatch)
            return "🟡 Close Match"
        return "📦 Order"
    }

    if (InStr(lens.Specs, "Not in Office")) {
        return "🚫 Not in Ofc / 📦 Order"
    }
    
    if (!lens.HasProp("Trial") || !lens.Trial) {
        if (InStr(lens.Family, "J&J") || InStr(lens.Family, "B&L"))
            return "🚫 No Fit Set"
        if (InStr(lens.DisplayName, "XR"))
            return "📦 MTO"
        return "📦 Order"
    }
    
    if (IsTrialAvailable(lens, sph, cyl, axis))
        return "✅ Trial"
        
    sphOffsets := [-0.50, -0.25, 0.0, 0.25, 0.50]
    cylOffsets := [-0.50, -0.25, 0.0, 0.25, 0.50]
    axisOffsets := [-10, 0, 10]
    
    for ds in sphOffsets {
        for dc in cylOffsets {
            for da in axisOffsets {
                testSph := sph + ds
                testCyl := cyl + dc
                testAxis := axis + da
                while (testAxis <= 0)
                    testAxis += 180
                while (testAxis > 180)
                    testAxis -= 180
                    
                if (IsTrialAvailable(lens, testSph, testCyl, testAxis))
                    return "🟡 Close Match"
            }
        }
    }
    
    return "📦 Order"
}

IsTrialAvailable(lens, sph, cyl, axis) {
    if (!lens.HasProp("Trial") || !lens.Trial)
        return false
        
    trial := lens.Trial
    
    ; 1. Check sphere
    sphOk := false
    for range in trial.SphSteps {
        if (sph >= range.Min && sph <= range.Max) {
            diff := sph - range.Min
            if (Mod(Round(diff, 4), range.Step) == 0 || Mod(Round(diff, 4), range.Step) == range.Step) {
                sphOk := true
                break
            }
        }
    }
    if (!sphOk)
        return false
        
    ; 2. Check cylinder
    if (cyl == 0) {
        if (trial.HasProp("Cyls") && trial.Cyls.Length > 0)
            return false
        return true
    } else {
        if (!trial.HasProp("Cyls") || trial.Cyls.Length == 0)
            return false
        cylOk := false
        for c in trial.Cyls {
            if (Round(cyl, 4) == Round(c, 4)) {
                cylOk := true
                break
            }
        }
        if (!cylOk)
            return false
    }
    
    ; 3. Check axis
    if (axis == 0)
        return true
    if (!trial.HasProp("Axes") || trial.Axes.Length == 0)
        return false
        
    for r in trial.Axes {
        if (axis >= r.Min && axis <= r.Max) {
            diff := axis - r.Min
            if (Mod(diff, r.Step) == 0)
                return true
        }
    }
    return false
}

ProcessCLRx(sph, cyl, axis) {
    if (cyl > 0) {
        sph := sph + cyl
        cyl := -cyl
        axis := (axis > 90) ? axis - 90 : axis + 90
    }
    
    m1 := sph, m2 := sph + cyl
    v_m1 := m1 / (1 - 0.012 * m1), v_m2 := m2 / (1 - 0.012 * m2)
    newSph := v_m1, newCyl := v_m2 - v_m1
    
    finalSph := Round(newSph * 4) / 4
    cylInt := Round(newCyl * 4) 
    
    if (cylInt > -3) {
        finalCyl := 0
    } else {
        if (Mod(cylInt, 2) == 0) {
            cylInt := cylInt + 1 
        }
        finalCyl := cylInt / 4
    }
    
    formattedText := (finalCyl == 0) ? Format("{:+.2f} DS", finalSph) : Format("{:+.2f} {:+.2f} x {:03}", finalSph, finalCyl, axis)
    return {text: formattedText, sph: finalSph, cyl: finalCyl, axis: axis}
}

#HotIf WinExist("CL Suggestions")
Esc:: {
    global clGui
    if IsObject(clGui) {
        clGui.Destroy()
    }
}
#HotIf