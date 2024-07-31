<CsoundSynthesizer>

<CsInstruments>
sr = 44100
kr = 441
nchnls  = 2

  giseed    =           .5
  giwtsin   =           1

instr 1                                                        ; flute

  ; initial variables   
  p5        =           ampdbfs(p5)
  iampscale =           20000                  ; overall amplitude scaling factor
  ifreq     cps2pch p4, -3
  ivibdepth =           abs(ifreq/1000.0)      ; vibrato depth relative to fundamental frequency
  iattack   =           0.08*(1.1-.2*giseed)   ; attack time with up to +-10% random deviation
  giseed    =           frac(giseed*105.947)   ; reset giseed
  idecay    =           0.08*(1.1-.2*giseed)   ; decay time with up to +-10% random deviation
  giseed    =           frac(giseed*105.947)
  ifiltcut  tablei      5, 2                   ; lowpass filter cutoff frequency

  iattack   =           (iattack<6/kr? 6/kr: iattack) ; minimal attack length
  idecay    =           (idecay<6/kr? 6/kr: idecay) ; minimal decay length
  isustain  =           p3-iattack-idecay
  p3        =           (isustain<5/kr? iattack+idecay+5/kr: p3) ; minimal sustain length
  isustain  =           (isustain<5/kr? 5/kr: isustain)
  iatt      =           iattack/6
  isus      =           isustain/4
  idec      =           idecay/6
  iphase    =           giseed                  ; use same phase for all wavetables
  giseed    =           frac(giseed*105.947)

                                                        ; vibrato block
  kvibdepth linseg      .1, .8*p3, 1, .2*p3, .7
  kvibdepth =           kvibdepth*ivibdepth     ; vibrato depth
  kvibdepthr            randi       .1*kvibdepth, 5, giseed ; up to 10% vibrato depth variation
  giseed    =           frac(giseed*105.947)
  kvibdepth =           kvibdepth+kvibdepthr
  ivibr1    =           giseed                  ; vibrato rate
  giseed    =           frac(giseed*105.947)
  ivibr2    =           giseed
  giseed    =           frac(giseed*105.947)

  kvibrate  linseg      2.5+ivibr1, p3, 4.5+ivibr2 ; if p6 positive vibrato gets faster
  kvibrater randi       .1*kvibrate, 5, giseed  ; up to 10% vibrato rate variation
  giseed    =           frac(giseed*105.947)
  kvibrate  =           kvibrate+kvibrater
  kvib      oscil       kvibdepth, kvibrate, giwtsin

  ifdev1    =           -.03*giseed             ; frequency deviation
  giseed    =           frac(giseed*105.947)
  ifdev2    =           .003*giseed
  giseed    =           frac(giseed*105.947)
  ifdev3    =           -.0015*giseed
  giseed    =           frac(giseed*105.947)
  ifdev4    =           .012*giseed
  giseed    =           frac(giseed*105.947)
  kfreqr    linseg      ifdev1, iattack, ifdev2, isustain, ifdev3, idecay, ifdev4
  kfreq     =           ifreq*(1+kfreqr)+kvib

if ifreq <  427.28 goto range1                          ; (cpspch(8.08) + cpspch(8.09))/2
if ifreq <  608.22 goto range2                          ; (cpspch(9.02) + cpspch(9.03))/2
if ifreq <  1013.7 goto range3                          ; (cpspch(9.11) + cpspch(10.00))/2
            goto        range4
                                                        ; wavetable amplitude envelopes
range1:                                         ; for low range tones
  kamp1     linseg      0, iatt, 0.002, iatt, 0.045, iatt, 0.146, iatt, 0.272, iatt, 0.072, iatt, 0.043, isus, 0.230, isus, 0.000, isus, 0.118, isus, 0.923, idec, 1.191, idec, 0.794, idec, 0.418, idec, 0.172, idec, 0.053, idec, 0
  kamp2     linseg      0, iatt, 0.009, iatt, 0.022, iatt, -0.049, iatt, -0.120, iatt, 0.297, iatt, 1.890, isus, 1.543, isus, 0.000, isus, 0.546, isus, 0.690, idec, -0.318, idec, -0.326, idec, -0.116, idec, -0.035, idec, -0.020, idec, 0
  kamp3     linseg      0, iatt, 0.005, iatt, -0.026, iatt, 0.023, iatt, 0.133, iatt, 0.060, iatt, -1.245, isus, -0.760, isus, 1.000, isus,  0.360, isus, -0.526, idec, 0.165, idec, 0.184, idec, 0.060, idec,  0.010, idec, 0.013, idec, 0
  iwt1      =           26                      ; wavetable numbers
  iwt2      =           27
  iwt3      =           28
  inorm     =           3949
            goto        end

range2:                                         ; for low mid-range tones 

  kamp1     linseg      0, iatt, 0.000, iatt, -0.005, iatt, 0.000, iatt, 0.030, iatt, 0.198, iatt, 0.664, isus, 1.451, isus, 1.782, isus, 1.316, isus, 0.817, idec, 0.284, idec, 0.171, idec, 0.082, idec, 0.037, idec, 0.012, idec, 0
  kamp2     linseg      0, iatt, 0.000, iatt, 0.320, iatt, 0.882, iatt, 1.863, iatt, 4.175, iatt, 4.355, isus, -5.329, isus, -8.303, isus,  -1.480, isus, -0.472, idec, 1.819, idec, -0.135, idec, -0.082, idec, -0.170, idec, -0.065, idec, 0
  kamp3     linseg      0, iatt, 1.000, iatt, 0.520, iatt, -0.303, iatt, 0.059, iatt, -4.103, iatt, -6.784, isus, 7.006, isus, 11, isus,  12.495, isus, -0.562, idec, -4.946, idec, -0.587, idec, 0.440, idec, 0.174, idec, -0.027, idec, 0
  iwt1      =           29
  iwt2      =           30
  iwt3      =           31
  inorm     =           27668.2
            goto        end

range3:                                         ; for high mid-range tones 

  kamp1     linseg      0, iatt, 0.005, iatt, 0.000, iatt, -0.082, iatt, 0.36, iatt, 0.581, iatt, 0.416, isus, 1.073, isus, 0.000, isus,  0.356, isus, .86, idec, 0.532, idec, 0.162, idec, 0.076, idec, 0.064, idec, 0.031, idec, 0
  kamp2     linseg      0, iatt, -0.005, iatt, 0.000, iatt, 0.205, iatt, -0.284, iatt, -0.208, iatt, 0.326, isus, -0.401, isus, 1.540, isus,  0.589, isus, -0.486, idec, -0.016, idec, 0.141, idec, 0.105, idec, -0.003, idec, -0.023, idec, 0
  kamp3     linseg      0, iatt, 0.722, iatt, 1.500, iatt, 3.697, iatt, 0.080, iatt, -2.327, iatt, -0.684, isus, -2.638, isus, 0.000, isus,  1.347, isus, 0.485, idec, -0.419, idec, -.700, idec, -0.278, idec, 0.167, idec, -0.059, idec, 0
  iwt1      =           32
  iwt2      =           33
  iwt3      =           34
  inorm     =           3775
            goto        end

range4:                                                 ; for high range tones 

  kamp1     linseg      0, iatt, 0.000, iatt, 0.000, iatt, 0.211, iatt, 0.526, iatt, 0.989, iatt, 1.216, isus, 1.727, isus, 1.881, isus, 1.462, isus, 1.28, idec, 0.75, idec, 0.34, idec, 0.154, idec, 0.122, idec, 0.028, idec, 0
  kamp2     linseg      0, iatt, 0.500, iatt, 0.000, iatt, 0.181, iatt, 0.859, iatt, -0.205, iatt, -0.430, isus, -0.725, isus, -0.544, isus, -0.436, isus, -0.109, idec, -0.03, idec, -0.022, idec, -0.046, idec, -0.071, idec, -0.019, idec, 0
  kamp3     linseg      0, iatt, 0.000, iatt, 1.000, iatt, 0.426, iatt, 0.222, iatt, 0.175, iatt, -0.153, isus, 0.355, isus, 0.175, isus, 0.16, isus, -0.246, idec, -0.045, idec, -0.072, idec, 0.057, idec, -0.024, idec, 0.002, idec, 0
  iwt1      =           35
  iwt2      =           36
  iwt3      =           37
  inorm     =           4909.05
            goto        end

end:
	kintense = p5/32000.
  kampr1    randi       .02*kamp1, 10, giseed   ; up to 2% wavetable amplitude variation
  giseed    =           frac(giseed*105.947)
  kamp1     =           (kamp1+kampr1) * kintense
  kampr2    randi       .02*kamp2, 10, giseed   ; up to 2% wavetable amplitude variation
  giseed    =           frac(giseed*105.947)
  kamp2     =           (kamp2+kampr2) * kintense
  kampr3    randi       .02*kamp3, 10, giseed   ; up to 2% wavetable amplitude variation
  giseed    =           frac(giseed*105.947)
  kamp3     =           (kamp3+kampr3) * kintense

  awt1      oscili      kamp1, kfreq, iwt1, iphase ; wavetable lookup
  awt2      oscili      kamp2, kfreq, iwt2, iphase
  awt3      oscili      kamp3, kfreq, iwt3, iphase
  asig      =           awt1+awt2+awt3
  asig      =           asig*(iampscale/inorm)
  kcut      linseg      0, iattack, ifiltcut, isustain, ifiltcut, idecay, 0 ; lowpass filter for brightness control
  afilt     tone        asig, kcut
  asig      balance     afilt, asig
            outs1        asig
endin 

instr 2						; oboe
; initial variables
  p5        =           ampdbfs(p5)
  iampscale =           20000                   ; overall amplitude scaling factor
  ifreq     cps2pch p4, -3
  ivibdepth =           abs(ifreq/1000.0)       ; vibrato depth relative to fundamental frequency
iattack		=	0.06 * (1.1 - .2*giseed); attack time with up to +-10% random deviation
  giseed    =           frac(giseed*105.947)    ; reset giseed
  idecay    =           0.15*(1.1-.2*giseed)    ; decay time with up to +-10% random deviation
  giseed    =           frac(giseed*105.947)
  ifiltcut  tablei      3, 2                    ; lowpass filter cutoff frequency
  iattack   =           (iattack<6/kr? 6/kr: iattack) ; minimal attack length
  idecay    =           (idecay<6/kr? 6/kr: idecay) ; minimal decay length
  isustain  =           p3-iattack-idecay
  p3        =           (isustain<5/kr? iattack+idecay+5/kr: p3) ; minimal sustain length
  isustain  =           (isustain<5/kr? 5/kr: isustain)
  iatt      =           iattack/6
  isus      =           isustain/4
  idec      =           idecay/6
  iphase    =           giseed                  ; use same phase for all wavetables
  giseed    =           frac(giseed*105.947)    ; vibrato block
  kvibdepth linseg                  .1, .8*p3, 1, .2*p3, .7
  kvibdepth =           kvibdepth*ivibdepth     ; vibrato depth
  kvibdepthr            randi       .1*kvibdepth, 5, giseed ; up to 10% vibrato depth variation
  giseed    =           frac(giseed*105.947)
  kvibdepth =           kvibdepth+kvibdepthr
  ivibr1    =           giseed                  ; vibrato rate
  giseed    =           frac(giseed*105.947)
  ivibr2    =           giseed
  giseed    =           frac(giseed*105.947)
  kvibrate  linseg      2.5+ivibr1, p3, 4.5+ivibr2 ; if p6 positive vibrato gets faster
  kvibrater randi       0.1*kvibrate, 5, giseed ; up to 10% vibrato rate variation
  giseed    =           frac(giseed*105.947)
  kvibrate  =           kvibrate+kvibrater
  kvib      oscil       kvibdepth, kvibrate, giwtsin
  ifdev1    =           -.01*giseed             ; frequency deviation
  giseed    =           frac(giseed*105.947)
  ifdev2    =           .002*giseed
  giseed    =           frac(giseed*105.947)
  ifdev3    =           -.001*giseed
  giseed    =           frac(giseed*105.947)
  ifdev4    =           -.003*giseed
  giseed    =           frac(giseed*105.947)
  kfreqr    linseg      ifdev1, iattack, ifdev2, isustain, ifdev3, idecay, ifdev4
  kfreq     =           ifreq*(1+kfreqr)+kvib
if ifreq <  337.9 goto range1				; (cpspch(8.04) + cpspch(8.05))/2
if ifreq <  480.29 goto range2				; (cpspch(8.10) + cpspch(8.11))/2
if ifreq <  810.96 goto range3				; (cpspch(9.07) + cpspch(9.08))/2
            goto        range4                  ; wavetable amplitude envelopes
range1:                                         ; for low range tones
  kamp1     linseg      0, iatt, 0.056, iatt, -0.069, iatt, -0.236, iatt, -0.413, iatt, 0.000, iatt, 0.595, isus, 1.444, isus, 1.558, isus, 1.525, isus, 1.275, idec, 1.122, idec, 0.970, idec, 0.695, idec, 0.248, idec, 0.000, 0.2*idec, 0
  kamp2     linseg      0, iatt, 0.413, iatt, 1.457, iatt, 2.626, iatt, 3.283, iatt, 0.000, iatt, -2.634, isus, -2.653, isus, -3.077, isus, -2.853, isus, -1.397, idec, -0.563, idec, 0.155, idec, 1.314, idec, 1.940, idec, 1.000, 0.2*idec, 0
  kamp3     linseg      0, iatt, -0.028, iatt, 0.063, iatt, 0.238, iatt, 0.643, iatt, 1.000, iatt, 0.810, isus, -0.052, isus, -0.055, isus, 0.037, isus, 0.014, idec, 0.006, idec, -0.017, idec, -0.031, idec, -0.015, idec, 0.000, 0.2*idec, 0
  iwt1      =           38                      ; wavetable numbers
  iwt2      =           39
  iwt3      =           40
  inorm     =           10202.35
            goto        end
range2:                                         ; for low mid-range tones
  kamp1     linseg      0, iatt, 0.014, iatt, 0.096, iatt, 0.620, iatt, 2.172, iatt, 2.284, iatt, 2.309, isus, 1.627, isus, 1.565, isus, 1.592, isus, 1.48, idec, 1.33, idec, 1.13, idec, .82, idec, 0.54, idec, .13, idec, 0
  kamp2     linseg      0, iatt, -1.348, iatt, -3.222, iatt, -4.100, iatt, -4.815, iatt, -1.985, iatt, -2.524, isus, .205, isus, .613, isus, .853, isus, .54, idec, .22, idec, .03, idec, .09, idec, -0.038, idec, -0.037, idec, 0
  kamp3     linseg      0, iatt, 1.713, iatt, 4.041, iatt, 4.781, iatt, 3.260, iatt, -0.578, iatt, 0.593, isus, -.252, isus, -.803, isus, -1.014, isus, -.565, idec, -.175, idec, -.150, idec, -0.042, idec, .041, idec, 0.058, idec, 0
  iwt1      =           41
  iwt2      =           42
  iwt3      =           43
  inorm     =           11369.2
            goto        end
range3:                                         ; for high mid-range tones
  kamp1     linseg      0, iatt, 0.071, iatt, 0.055, iatt, -0.234, iatt, -0.689, iatt, -0.031, iatt, 0.395, isus, 2.026, isus, 2.263, isus, 1.476, isus, 1.846, idec, 1.754, idec, 1.000, idec, 0.387, idec, 0.215, idec, -0.006, idec, 0
  kamp2     linseg      0, iatt, 0.679, iatt, 1.738, iatt, 5.691, iatt, 7.474, iatt, 0.503, iatt, -2.897, isus, -10.116, isus, -10.649, isus, -7.904, isus, -7.383, idec, -5.589, idec, 0.000, idec, 3.391, idec, 2.780, idec, 0.906, idec, 0
  kamp3     linseg      0, iatt, -0.035, iatt, -0.015, iatt, 0.195, iatt, 0.902, iatt, 0.985, iatt, 0.866, isus, 0.062, isus, -0.054, isus, 0.390, isus, -0.004, idec, -0.114, idec, 0.000, idec, 0.085, idec, -0.073, idec, 0.004, idec, 0
  iwt1      =           44
  iwt2      =           45
  iwt3      =           46
  inorm     =           9944.2
            goto        end
range4:                                         ; for high range tones
  kamp1     linseg      0, iatt, 0.000, iatt, 0.006, iatt, 0.012, iatt, 0.052, iatt, 1.166, iatt, 2.659, isus, 3.893, isus, 4.059, isus, 4.068, isus, 2.985, idec, 1.747, idec, 0.948, idec, 0.405, idec, 0.088, idec, -0.002, idec, 0
  kamp2     linseg      0, iatt, 0.000, iatt, 6.061, iatt, 11.223, iatt, 24.547, iatt, 38.934, iatt, 0.0, isus, -53.648, isus, -60.149, isus, -67.900, isus, -34.233, idec, -14.753, idec, -0.239, idec, 3.768, idec, 0.143, idec, 0.754, idec, 0
  kamp3     linseg      0, iatt, 1.000, iatt, 0.849, iatt, 0.781, iatt, 0.577, iatt, 0.247, iatt, 0.064, isus, 6.269, isus, 5.853, isus, 3.976, isus, 3.051, idec, 0.980, idec, -0.086, idec, -0.554, idec, -0.128, idec, -0.013, idec, 0
  iwt1      =           47
  iwt2      =           48
  iwt3      =           49
  inorm     =           9008.8
            goto        end
end:
	kintense = p5/32000.
  kampr1    randi                   .02*kamp1, 10, giseed ; up to 2% wavetable amplitude variation
  giseed    =           frac(giseed*105.947)
  kamp1     =           (kamp1+kampr1) * kintense
  kampr2    randi                   .02*kamp2, 10, giseed ; up to 2% wavetable amplitude variation
  giseed    =           frac(giseed*105.947)
  kamp2     =           (kamp2+kampr2) * kintense
  kampr3    randi                   .02*kamp3, 10, giseed ; up to 2% wavetable amplitude variation
  giseed    =           frac(giseed*105.947)
  kamp3     =           (kamp3+kampr3) * kintense
  awt1      oscili      kamp1, kfreq, iwt1, iphase ; wavetable lookup
  awt2      oscili      kamp2, kfreq, iwt2, iphase
  awt3      oscili      kamp3, kfreq, iwt3, iphase
  asig      =           awt1+awt2+awt3
  asig      =           asig*(iampscale/inorm)
  kcut      linseg      0, iattack, ifiltcut, isustain, ifiltcut, idecay, 0 ; lowpass filter for brightness control
  afilt     tone        asig, kcut
  asig      balance     afilt, asig
;;  al,ar     pan2        asig, 0.25    ;; replaced for backwards compatability
  al        =           sqrt(0.25)*asig
  ar        =           (1-sqrt(0.25))*asig
            outs        al, ar
endin 


instr 3                                                ; French horn

  ; initial variables   
  p5        =           ampdbfs(p5)
  iampscale =           20000                   ; overall amplitude scaling factor
  ifreq     cps2pch p4, -3
  ivibdepth =           abs(ifreq/1000.0)       ; vibrato depth relative to fundamental frequency
  iattack   =           0.09*(1.1-.2*giseed)    ; attack time with up to +-10% random deviation
  giseed    =           frac(giseed*105.947)    ; reset giseed
  idecay    =           0.1*(1.1-.2*giseed)     ; decay time with up to +-10% random deviation
  giseed    =           frac(giseed*105.947)
  ifiltcut  tablei      3, 2                    ; lowpass filter cutoff frequency

  iattack   =           (iattack<6/kr? 6/kr: iattack) ; minimal attack length
  idecay    =           (idecay<6/kr? 6/kr: idecay) ; minimal decay length
  isustain  =           p3-iattack-idecay
  p3        =           (isustain<5/kr? iattack+idecay+5/kr: p3) ; minimal sustain length
  isustain  =           (isustain<5/kr? 5/kr: isustain)
  iatt      =           iattack/6
  isus      =           isustain/4
  idec      =           idecay/6
  iphase    =           giseed                  ; use same phase for all wavetables
  giseed    =           frac(giseed*105.947)

                                                        ; vibrato block
  kvibdepth linseg      .1, .8*p3, 1, .2*p3, .7
  kvibdepth =           kvibdepth*ivibdepth     ; vibrato depth
  kvibdepthr            randi       .1*kvibdepth, 5, giseed ; up to 10% vibrato depth variation
  giseed    =           frac(giseed*105.947)
  kvibdepth =           kvibdepth+kvibdepthr
  ivibr1    =           giseed                  ; vibrato rate
  giseed    =           frac(giseed*105.947)
  ivibr2    =           giseed
  giseed    =           frac(giseed*105.947)

  kvibrate  linseg      2.5+ivibr1, p3, 4.5+ivibr2 ; if p6 positive vibrato gets faster
  kvibrater randi       .1*kvibrate, 5, giseed  ; up to 10% vibrato rate variation
  giseed    =           frac(giseed*105.947)
  kvibrate  =           kvibrate+kvibrater
  kvib      oscil       kvibdepth, kvibrate, giwtsin

  ifdev1    =           -.012*giseed            ; frequency deviation
  giseed    =           frac(giseed*105.947)
  ifdev2    =           .005*giseed
  giseed    =           frac(giseed*105.947)
  ifdev3    =           -.005*giseed
  giseed    =           frac(giseed*105.947)
  ifdev4    =           .009*giseed
  giseed    =           frac(giseed*105.947)
  kfreqr    linseg      ifdev1, iattack, ifdev2, isustain, ifdev3, idecay, ifdev4
  kfreq     =           ifreq*(1+kfreqr)+kvib

if ifreq <  113.26 goto range1                          ; (cpspch(6.09) + cpspch(6.10))/2
if ifreq <  152.055 goto range2                         ; (cpspch(7.02) + cpspch(7.03))/2
if ifreq <  202.74 goto range3                          ; (cpspch(7.07) + cpspch(7.08))/2
if ifreq <  270.32 goto range4                          ; (cpspch(8.00) + cpspch(8.01))/2
if ifreq <  360.43 goto range5                          ; (cpspch(8.05) + cpspch(8.06))/2
if ifreq <  480.29 goto range6                          ; (cpspch(8.10) + cpspch(8.11))/2
goto range7
                                                        ; wavetable amplitude envelopes
range1:                                         ; for low range tones
  kamp1     linseg      0, iatt, 0.000, iatt, 0.000, iatt, 0.298, iatt, 1.478, iatt, 1.901, iatt, 2.154, isus, 2.477, isus, 2.495, isus, 2.489, isus, 1.980, idec, 1.759, idec, 1.506, idec, 1.000, idec, 0.465, idec, 0.006, idec, 0
  kamp2     linseg      0, iatt, 0.000, iatt, 1.000, iatt, 2.127, iatt, 0.694, iatt, -0.599, iatt, -1.807, isus, -2.485, isus, -2.125, isus, -2.670, isus, -0.798, idec, -0.056, idec, -0.038, idec, 0.000, idec, 0.781, idec, 0.133, idec, 0
  kamp3     linseg      0, iatt, 1.000, iatt, 0.000, iatt, -4.131, iatt, 6.188, iatt, -1.422, iatt, 1.704, isus, 6.362, isus, 3.042, isus, 5.736, isus, -0.188, idec, -2.558, idec, -2.409, idec, 0.000, idec, -1.736, idec, 0.167, idec, 0
  iwt1      =           60                      ; wavetable numbers
  iwt2      =           61
  iwt3      =           62
  inorm     =           5137
            goto        end

range2:                                         ; for low mid-range tones 

  kamp1     linseg      0, iatt, 0.000, iatt, 0.000, iatt, 0.000, iatt, 0.308, iatt, 0.926, iatt, 1.370, isus, 3.400, isus, 3.205, isus, 3.083, isus, 2.722, idec, 2.239, idec, 2.174, idec, 1.767, idec, 1.098, idec, 0.252, idec, 0
  kamp2     linseg      0, iatt, 0.478, iatt, 1.000, iatt, 0.000, iatt, 4.648, iatt, 1.843, iatt, 5.242, isus, -.853, isus, -.722, isus, -.860, isus, -.547, idec, -.462, idec, -.380, idec, -.387, idec, -0.355, idec, -0.250, idec, 0
  kamp3     linseg      0, iatt, -0.107, iatt, 0.000, iatt, 1.000, iatt, -0.570, iatt, 0.681, iatt, -1.097, isus, 1.495, isus, 0.152, isus, 0.461, isus, 0.231, idec, 0.228, idec, 0.256, idec, 0.152, idec, 0.087, idec, 0.042, idec, 0
  iwt1      =           63
  iwt2      =           64
  iwt3      =           65
  inorm     =           35685
            goto        end

range3:                                         ; for high mid-range tones 

  kamp1     linseg      0, iatt, 0.039, iatt, 0.000, iatt, 0.000, iatt, 0.230, iatt, 0.216, iatt, 0.647, isus, 1.764, isus, 1.961, isus, 1.573, isus, 1.408, idec, 1.312, idec, 1.125, idec, 0.802, idec, 0.328, idec, 0.061, idec, 0
  kamp2     linseg      0, iatt, 1.142, iatt, 1.000, iatt, 0.000, iatt, -1.181, iatt, -3.005, iatt, -1.916, isus, 2.325, isus, 3.249, isus, 2.154, isus, 1.766, idec, 2.147, idec, 1.305, idec, 0.115, idec, 0.374, idec, 0.162, idec, 0
  kamp3     linseg      0, iatt, -0.361, iatt, 0.000, iatt, 1.000, iatt, 1.369, iatt, 1.865, iatt, 1.101, isus, -.677, isus, -.833, isus, -.437, isus, -.456, idec, -.465, idec, -.395, idec, -0.144, idec, -0.061, idec, -0.012, idec, 0
  iwt1      =           66
  iwt2      =           67
  iwt3      =           68
  inorm     =           39632
            goto        end

range4:                                         ; for high range tones 

  kamp1     linseg      0, iatt, 0.000, iatt, -0.147, iatt, -0.200, iatt,  0.453, iatt, -0.522, iatt, 0.000, isus, 2.164, isus, 1.594, isus, 2.463, isus, 1.506, idec, 1.283, idec, 0.618, idec, 0.222, idec, 0.047, idec, 0.006, idec, 0
  kamp2     linseg      0, iatt, 1.000, iatt, 16.034, iatt, 24.359, iatt, 12.399, iatt, 3.148, iatt, 0.000, isus, 8.986, isus, -2.516, isus, 13.268, isus, 0.541, idec, -2.107, idec, -11.221, idec, -14.179, idec, -7.152, idec, 5.327, idec, 0
  kamp3     linseg      0, iatt, 0.000, iatt, -0.318, iatt, -0.181, iatt, 0.861, iatt, 1.340, iatt, 1.000, isus, -1.669, isus, -0.669, isus, -2.208, isus, -0.709, idec, -0.388, idec, 0.641, idec, 1.101, idec, 0.817, idec, 0.018, idec, 0
  iwt1      =           69
  iwt2      =           70
  iwt3      =           71
  inorm     =           26576.1
            goto        end

range5:                                         ; for high range tones 

  kamp1     linseg      0, iatt, 2.298, iatt, 2.017, iatt, 2.099, iatt, 1.624, iatt, 0.536, iatt, 1.979, isus, -2.465, isus, -4.449, isus, -4.176, isus, -1.518, idec, -0.593, idec, 0.000, idec, 0.384, idec, 0.386, idec, 0.256, idec, 0
  kamp2     linseg      0, iatt, -1.498, iatt, -1.342, iatt, -0.983, iatt, -0.402, iatt, 0.572, iatt, -0.948, isus, 4.490, isus, 6.433, isus, 5.822, isus, 1.845, idec, 0.618, idec, 0.000, idec, -0.345, idec, -0.295, idec, -0.164, idec, 0
  kamp3     linseg      0, iatt, -0.320, iatt, 0.179, iatt, -0.551, iatt, -0.410, iatt, -0.417, iatt, -0.028, isus, -1.517, isus, -1.523, isus, -1.057, isus, 0.883, idec, 1.273, idec, 1.000, idec, 0.660, idec, 0.271, idec, 0.026, idec, 0
  iwt1      =           72
  iwt2      =           73
  iwt3      =           74
  inorm     =           26866.7
            goto        end

range6:                                         ; for high range tones 

  kamp1     linseg      0, iatt, 6.711, iatt, 4.998, iatt, 3.792, iatt, -0.554, iatt, -1.261, iatt, -5.584, isus, -4.633, isus, -0.384, isus,   -0.555, isus, -0.810, idec, 0.112, idec, 0.962, idec, 1.567, idec,      0.881, idec, 0.347, idec, 0
  kamp2     linseg      0, iatt, -5.829, iatt, -4.106, iatt, -3.135, iatt, 1.868, iatt, 1.957, iatt, 6.851, isus, 5.135, isus, 0.097, isus,        0.718, isus, 1.679, idec, 0.881, idec, -0.009, idec, -0.927, idec,      -0.544, idec, -0.225, idec, 0
  kamp3     linseg      0, iatt, 0.220, iatt, 0.177, iatt, 0.333, iatt, -0.302, iatt, 0.071, iatt, -0.563, isus, 0.338, isus, 1.214, isus,      0.840, isus, 0.103, idec, 0.003, idec, -0.114, idec, -0.049, idec,      -0.031, idec, -0.017, idec, 0
  iwt1      =           75
  iwt2      =           76
  iwt3      =           77
  inorm     =           31013.2
            goto        end

range7:                                         ; for high range tones 

  kamp1     linseg      0, iatt, 0.046, iatt, 0.000, iatt, 0.127, iatt, 0.686, iatt, 1.000, iatt, 1.171, isus, 0.000, isus, 0.667, isus, 0.969, isus, 1.077, idec, 1.267, idec, 1.111, idec, 0.964, idec, 0.330, idec, 0.047, idec, 0
  kamp2     linseg      0, iatt, 0.262, iatt, 1.000, iatt, 1.026, iatt, 0.419, iatt, 0.000, iatt, -0.172, isus, 0.000, isus, -0.764, isus, -0.547, isus, -0.448, idec, -0.461, idec, -0.199, idec, -0.015, idec,   0.432, idec, 0.120, idec, 0
  kamp3     linseg      0, iatt, -0.014, iatt, 0.000, iatt, 0.102, iatt, 0.006, iatt, 0.000, iatt, -0.016, isus, 1.000, isus, 0.753, isus, 0.367, isus, 0.163, idec, -0.030, idec, -0.118, idec, -0.207, idec, -0.103, idec, -0.007, idec, 0
  iwt1      =           78
  iwt2      =           79
  iwt3      =           80
  inorm     =           26633.5
            goto        end

end:
	kintense = p5/32000.
  kampr1    randi       .02*kamp1, 10, giseed   ; up to 2% wavetable amplitude variation
  giseed    =           frac(giseed*105.947)
  kamp1     =           (kamp1+kampr1) * kintense
  kampr2    randi       .02*kamp2, 10, giseed   ; up to 2% wavetable amplitude variation
  giseed    =           frac(giseed*105.947)
  kamp2     =           (kamp2+kampr2) * kintense
  kampr3    randi       .02*kamp3, 10, giseed   ; up to 2% wavetable amplitude variation
  giseed    =           frac(giseed*105.947)
  kamp3     =           (kamp3+kampr3) * kintense

  awt1      oscili      kamp1, kfreq, iwt1, iphase ; wavetable lookup
  awt2      oscili      kamp2, kfreq, iwt2, iphase
  awt3      oscili      kamp3, kfreq, iwt3, iphase
  asig      =           awt1+awt2+awt3
  asig      =           asig*(iampscale/inorm)
  kcut      linseg      0, iattack, ifiltcut, isustain, ifiltcut, idecay, 0 ; lowpass filter for brightness control
  afilt     tone        asig, kcut
  asig      balance     afilt, asig
;;  al,ar     pan2        asig, 0.75    ;; replaced for backwards compatability
  al        =           sqrt(0.75)*asig
  ar        =           (1-sqrt(0.75))*asig
            outs        al,ar
endin 

instr 4							; bassoon

; initial variables
  p5        =           ampdbfs(p5)
  iampscale =           20000                ; overall amplitude scaling factor
  ifreq     cps2pch p4, -3
  ivibdepth =           abs(ifreq/300.0)     ; vibrato depth relative to fundamental frequency
  iattack   =           0.04*(1.1-.2*giseed) ; attack time with up to +-10% random deviation
  giseed    =           frac(giseed*105.947) ; reset giseed
  idecay    =           0.1*(1.1-.2*giseed)  ; decay time with up to +-10% random deviation
  giseed    =           frac(giseed*105.947)
  ifiltcut  tablei      6, 2                 ; lowpass filter cutoff frequency
  iattack   =           (iattack<6/kr? 6/kr: iattack) ; minimal attack length
  idecay    =           (idecay<6/kr? 6/kr: idecay) ; minimal decay length
  isustain  =           p3-iattack-idecay
  p3        =           (isustain<5/kr? iattack+idecay+5/kr: p3) ; minimal sustain length
  isustain  =           (isustain<5/kr? 5/kr: isustain)
  iatt      =           iattack/6
  isus      =           isustain/4
  idec      =           idecay/6
  iphase    =           giseed                  ; use same phase for all wavetables
  giseed    =           frac(giseed*105.947)    ; vibrato block
  kvibdepth linseg                  .1, .8*p3, 1, .2*p3, .7
  kvibdepth =           kvibdepth*ivibdepth     ; vibrato depth
  kvibdepthr            randi       .1*kvibdepth, 5, giseed ; up to 10% vibrato depth variation
  giseed    =           frac(giseed*105.947)
  kvibdepth =           kvibdepth+kvibdepthr
  ivibr1    =           giseed                  ; vibrato rate
  giseed    =           frac(giseed*105.947)
  ivibr2    =           giseed
  giseed    =           frac(giseed*105.947)
  kvibrate  linseg      2.5+ivibr1, p3, 4.5+ivibr2 ; if p6 positive vibrato gets faster
  kvibrater randi                   .1*kvibrate, 5, giseed ; up to 10% vibrato rate variation
  giseed    =           frac(giseed*105.947)
  kvibrate  =           kvibrate+kvibrater
  kvib      oscil       kvibdepth, kvibrate, giwtsin
  ifdev1    =           -.007*giseed            ; frequency deviation
  giseed    =           frac(giseed*105.947)
  ifdev2    =           -.004*giseed
  giseed    =           frac(giseed*105.947)
  ifdev3    =           .001*giseed
  giseed    =           frac(giseed*105.947)
  ifdev4    =           .004*giseed
  giseed    =           frac(giseed*105.947)
  kfreqr    linseg      ifdev1, iattack, ifdev2, isustain, ifdev3, idecay, ifdev4
  kfreq     =           ifreq*(1+kfreqr)+kvib
  if ifreq      <  84.475        goto range1  ; (cpspch(6.04) + cpspch(6.05))/2
  if ifreq      <  120.07         goto range2  ; (cpspch(6.10) + cpspch(6.11))/2
  if ifreq      <  180.21         goto range3  ; (cpspch(7.05) + cpspch(7.06))/2
  if ifreq      <  270.32         goto range4  ; (cpspch(8.00) + cpspch(8.01))/2
  if ifreq      <  405.48         goto range5  ; (cpspch(8.07) + cpspch(8.08))/2
            goto        range6                  ; wavetable amplitude envelopes
range1:                                         ; for low range tones
  kamp1     linseg      0, iatt, 0.000, iatt, 0.054, iatt, 0.000, iatt, 0.248, iatt, 0.390, iatt, 0.931, isus, 1.264, isus, 1.256, isus, 1.160, isus, 1.049, idec, 1.044, idec, 1.000, idec, 0.904, idec, 0.611, idec, 0.029, idec, 0
  kamp2     linseg      0, iatt, 0.000, iatt, 0.531, iatt, 1.000, iatt, 1.063, iatt, 0.853, iatt, -0.158, isus, -0.074, isus, -0.041, isus, -0.064, isus, 0.002, idec, 0.006, idec, 0.000, idec, -0.078, idec, 0.068, idec, 0.022, idec, 0
  kamp3     linseg      0, iatt, 1.000, iatt, 1.743, iatt, 0.000, iatt, -1.556, iatt, -0.856, iatt, 2.652, isus, -1.290, isus, -0.665, isus, 1.013, isus, 1.561, idec, 0.959, idec, 0.000, idec, 0.518, idec, -0.728, idec, -0.285, idec, 0
  iwt1      =           98                      ; wavetable numbers
  iwt2      =           99
  iwt3      =           100
  inorm     =           18461.5
            goto        end
range2:                                         ; for low mid-range tones 
  kamp1     linseg      0, iatt, 0.000, iatt, 0.054, iatt, 0.000, iatt, 0.248, iatt, 0.390, iatt, 0.931, isus, 1.264, isus, 1.256, isus, 1.160, isus, 1.049, idec, 1.044, idec, 1.000, idec, 0.904, idec, 0.611, idec, 0.029, idec, 0
  kamp2     linseg      0, iatt, 0.000, iatt, 0.531, iatt, 1.000, iatt, 1.063, iatt, 0.853, iatt, -0.158, isus, -0.074, isus, -0.041, isus, -0.064, isus, 0.002, idec, 0.006, idec, 0.000, idec, -0.078, idec, 0.068, idec, 0.022, idec, 0
  kamp3     linseg      0, iatt, 1.000, iatt, 1.743, iatt, 0.000, iatt, -1.556, iatt, -0.856, iatt, 2.652, isus, -1.290, isus, -0.665, isus, 1.013, isus, 1.561, idec, 0.959, idec, 0.000, idec, 0.518, idec, -0.728, idec, -0.285, idec, 0
  iwt1      =           101
  iwt2      =           102
  iwt3      =           103
  inorm     =           11806.8
            goto        end
range3:                                         ; for high mid-range tones 
  kamp1     linseg      0, iatt, 0.000, iatt, 0.017, iatt, 0.000, iatt, 0.254, iatt, 0.429, iatt, 0.637, isus, 1.089, isus, 1.055, isus, 1.040, isus, 1.017, idec, 0.994, idec, 0.998, idec, 0.601, idec, 0.208, idec, 0.026, idec, 0
  kamp2     linseg      0, iatt, 1.000, iatt, 2.060, iatt, 0.000, iatt, -0.602, iatt, -1.749, iatt, -2.181, isus, -1.200, isus, -0.438, isus, -.247, isus, .222, idec, 0.204, idec, 0.163, idec, 0.413, idec, 0.432, idec, 0.076, idec, 0
  kamp3     linseg      0, iatt, 0.000, iatt, 0.383, iatt, 1.000, iatt, 0.773, iatt, 0.702, iatt, 0.500, isus, -0.032, isus, -.057, isus, -.077, isus, -.066, idec, -.074, idec, -.239, idec, -.114, idec, -.086, idec, -0.004, idec, 0
  iwt1      =           104
  iwt2      =           105
  iwt3      =           106
  inorm     =           13936.9
            goto        end
range4:                                         ; for high range tones 
  kamp1     linseg      0, iatt, -0.006, iatt, 0.000, iatt, -0.052, iatt, 0.000, iatt, 0.111, iatt, 0.596, isus, 1.066, isus, 1.199, isus, 1.220, isus, 1.241, idec, 1.090, idec, 0.987, idec, 0.649, idec, 0.213, idec, 0.026, idec, 0
  kamp2     linseg      0, iatt, 0.433, iatt, 1.000, iatt, 1.122, iatt, 0.000, iatt, -0.548, iatt, -1.235, isus, -0.714, isus, -0.457, isus, -0.220, isus, -0.062, idec, -0.074, idec, -0.002, idec, 0.033, idec, 0.020, idec, 0.005, idec, 0
  kamp3     linseg      0, iatt, -0.019, iatt, 0.000, iatt, 0.358, iatt, 1.000, iatt, 1.265, iatt, 1.057, isus, 0.262, isus, 0.086, isus, 0.043, isus, 0.006, idec, 0.005, idec, 0.003, idec, 0.002, idec, 0.001, idec, 0.00, idec, 0
  iwt1      =           107
  iwt2      =           108
  iwt3      =           109
  inorm     =           9656
            goto        end
range5:                                         ; for high range tones 
  kamp1     linseg      0, iatt, 0.026, iatt, 0.076, iatt, 0.185, iatt, 0.368, iatt, 0.407, iatt, 0.437, isus, 0.977, isus, 1.040, isus, 1.050, isus, 0.993, idec, 0.960, idec, 1.033, idec, 0.816, idec, 0.220, idec, 0.014, idec, 0
kamp2	linseg	0, iatt, 0.000, iatt, 0.000, iatt, 0.000, iatt, 0.000, iatt, 0.000, iatt, 0.000, isus, 0.421, isus, 1.055, isus, 1.354, isus, 0.742, idec, -0.254, idec, -0.747, idec, -2.145, idec, -2.469, idec, -.231, idec, 0
  kamp3     linseg      0, iatt, 0.000, iatt, 0.000, iatt, 0.040, iatt, 0.231, iatt, 0.800, iatt, 1.373, isus, 0.048, isus, -0.150, isus, -0.228, isus, -0.167, idec, -0.103, idec, -0.148, idec, 0.033, idec, 0.159, idec, 0.017, idec, 0
  iwt1      =           110
  iwt2      =           111
  iwt3      =           112
  inorm     =           15143.7
            goto        end
range6:                                         ; for high range tones 
  kamp1     linseg      0, iatt, 0.034, iatt, 0.015, iatt, -0.028, iatt, 0.000, iatt, 0.153, iatt, 2.053, isus, 2.64, isus, 2.76, isus, 2.630, isus, 2.246, idec, 1.93, idec, 1.64, idec, 1.014, idec, 0.098, idec, 0.000, idec, 0
  kamp2     linseg      0, iatt, 0.028, iatt, 0.044, iatt, 0.570, iatt, 1.000, iatt, 2.814, iatt, -1.628, isus, -2.85, isus, -2.173, isus, -2.147, isus, -1.233, idec, -1.101, idec, 0.064, idec, 0.929, idec, 1.206, idec, 0.000, idec, 0
  kamp3     linseg      0, iatt, -0.615, iatt, -0.463, iatt, 0.450, iatt, 0.000, iatt, 1.812, iatt, 9.95, isus, 5.67, isus, 0.000, isus, -4.605, isus, 5.210, idec, 8.76, idec, 4.85, idec, -1.823, idec, 2.031, idec, 1.200, idec, 0
  iwt1      =           113
  iwt2      =           114
  iwt3      =           115
  inorm     =           5081
            goto        end
end:
	kintense = p5/32000.
  kampr1    randi                   .02*kamp1, 10, giseed ; up to 2% wavetable amplitude variation
  giseed    =           frac(giseed*105.947)
  kamp1     =           (kamp1+kampr1) * kintense
  kampr2    randi                   .02*kamp2, 10, giseed ; up to 2% wavetable amplitude variation
  giseed    =           frac(giseed*105.947)
  kamp2     =           (kamp2+kampr2) * kintense
  kampr3    randi                   .02*kamp3, 10, giseed ; up to 2% wavetable amplitude variation
  giseed    =           frac(giseed*105.947)
  kamp3     =           (kamp3+kampr3) * kintense
  awt1      oscili      kamp1, kfreq, iwt1, iphase ; wavetable lookup
  awt2      oscili      kamp2, kfreq, iwt2, iphase
  awt3      oscili      kamp3, kfreq, iwt3, iphase
  asig      =           awt1+awt2+awt3
  asig      =           asig*(iampscale/inorm)
  kcut      linseg      0, iattack, ifiltcut, isustain, ifiltcut, idecay, 0 ; lowpass filter for brightness control
  afilt     tone        asig, kcut
  asig      balance     afilt, asig
            outs2        asig
endin

</CsInstruments>

<CsScore>
f1 0 8192 10 1

f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240

f3 0 16 -2 1 1.06787109375 1.125 1.20135498046875 1.265625 1.35152435302734375 1.423828125 1.5 1.601806640625 1.6875 1.802032470703125 1.8984375

f26 0 4097 -10 2000 489 74 219 125 9 33 5 5 
f27 0 4097 -10 2729 1926 346 662 537 110 61 29 7 
f28 0 4097 -10 2558 2012 390 361 534 139 53 22 10 13 10 

f29 0 4097 -10 12318 8844 1841 1636 256 150 60 46 11 
f30 0 4097 -10 1229 16 34 57 32 
f31 0 4097 -10 163 31 1 50 31 

f32 0 4097 -10 4128 883 354 79 59 23 
f33 0 4097 -10 1924 930 251 50 25 14
f34 0 4097 -10 94 6 22 8 

f35 0 4097 -10 2661 87 33 18 
f36 0 4097 -10 174 12
f37 0 4097 -10 314 13
f38 0 4097 -10 1684 1550 1439 1767 1811 796 343 284 150 94 142 68 87 49 18 
f39 0 4097 -10 221 213 106 95 14 14 8 3 
f40 0 4097 -10 687 1970 878 1887 1479 1229 309 236 70 101 190 62  
f41 0 4097 -10 1585 1857 2574 1403 1064 426 239 109 96 111 17   
f42 0 4097 -10 939 1120 1305 24 637 249 55 45 2  
f43 0 4097 -10 829 973 1041 30 486 182 38 33  
f44 0 4097 -10 2078 1983 1873 449 223 115 90 27 
f45 0 4097 -10 151 32 4 4 4 1 
f46 0 4097 -10 2776 4033 3040 558 461 112 202 
f47 0 4097 -10 2044 1092 80 120 
f48 0 4097 -10 37 4 2 1
f49 0 4097 -10 31 14 21 32 4 5 7 
f60 0 4097 -10 478 1277 2340 4533 2413 873 682 532 332 364 188 258 256 114 80 68 36
f61 0 4097 -10 414 906 831 507 268 36
f62 0 4097 -10 74 50 68 156 50 48 52 66 

f63 0 4097 -10 677 2663 4420 1597 1236 780 581 325 415 201 212 202 156 26 
f64 0 4097 -10 648 1635 828 149 89 41  
f65 0 4097 -10 1419 3414 901 503 204 146 

f66 0 4097 -10 1722 14359 5103 1398 2062 696 652 266 264 176 164 75  
f67 0 4097 -10 1237 2287 237 72 
f68 0 4097 -10 2345 7796 1182 266 255 193 85 

f69 0 4097 -10 9834 16064 2259 1625 1353 344 356 621 195 155 77 98
f70 0 4097 -10 377 193 41
f71 0 4097 -10 8905 10946 1180 1013 506 125 48

f72 0 4097 -10 16460 4337 1419 1255 43 205 81 73 60 38 
f73 0 4097 -10 16569 5563 1838 1852 134 340 129 159 162 99 
f74 0 4097 -10 10383 4175 858 502 241 165 

f75 0 4097 -10 15341 5092 1554 640 101  
f76 0 4097 -10 16995 6133 1950 788 136  
f77 0 4097 -10 22560 9285 4691 1837 342 294 307 222 288 103 

f78 0 4097 -10 19417 5904 1666 913 266 55 81 46  
f79 0 4097 -10 11940 1211 111 38
f80 0 4097 -10 25132 6780 2886 1949 507 505 466 488 336 121 
f98 0 4097 -10 533 733 1561 2311 2952 2752 1507 988 1250 1408 1086 773 521 696 456 285 249 697 532 304 238 244 295 120 80 53 125 126 194 132 105 60 54 53 62 54 48 25 
f99 0 4097 -10 382 616 1047 1557 1695 810 512 375 377 437 604 541 433 374 224 113 97 45 63 48 18 16 8 3 3 12 4   
f100 0 4097 -10 71 65 54 70 48 14 0 2 3 8 10 7 3 1 3 1 1
f101 0 4097 -10 533 733 1561 2311 2952 1552 9 1007 388 350 308 586 573 221 396 256 85 249 100 70 24 5 15 20 14 
f102 0 4097 -10 382 616 1047 1557 1695 210 112 75 77 137 204 241 133 74 24 13 17 45 63 48 18 16 8 3 3 12 4 
f103 0 4097 -10 71 65 54 70 48 14 0 2 3 8 10 7 3 1 3 1 1
f104 0 4097 -10 843 4712 4927 4526 908 518 205 1400 944 550 647 300 294 48 137 62 63 168 111 16 
f105 0 4097 -10 253 207 90 12 10 1 11 12 1 8 1 2 5 3 3 1 3 5 3 7 2 2 0 2 1 6 9 13 9 8 13 2 
f106 0 4097 -10 839 3426 3548 2161 139 171 177 119 88 163 76 57 69 54 52 42 24 34 18 36 11 
f107 0 4097 -10 1767 5682 1287 510 728 1482 327 169 199 158 106 109 131 40 46 39 63 55 34 28 21 2 
f108 0 4097 -10 643 766 147 14 66 67 24 12 12 4 5 10 8 8 3 8 7 8 4 0 4 1 
f109 0 4097 -10 979 4325 716 130 208 95 113 25 78 24 13 12 18 19 18 7 17 8 7 4 1 
f110 0 4097 -10 2574 10673 2732 1609 475 412 60 147 183 105 85 63 32 83 15 9 21 4 
f111 0 4097 -10 115 36 8 25 12 13 4 6 14 5 16 14 7 8 2 3 1 
f112 0 4097 -10 1717 3125 177 284 153 99 20 7 10 26 6 12 39 25 11 3 5 4 2 
f113 0 4097 -10 1410 766 451 339 48 10 2 17 4 3 4 5 3 3  
f114 0 4097 -10 585 34 32 34 4 6 1 2 1 1 
f115 0 4097 -10 30 21


;; GENERATED TUNES GO HERE

</CsScore>
</CsoundSynthesizer>


