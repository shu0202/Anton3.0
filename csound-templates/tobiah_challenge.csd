<CsoundSynthesizer>
<CsOptions>
; set command line options here

</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 1
nchnls = 2

giSineFunc ftgen 1, 0, 65536, 10, 1

instr 1, 2, 3, 4
  p5          =		ampdbfs(p5)
  iStartPitch cps2pch   p4, -2
  iEndPitch   cps2pch   p4, -2
  iVol        init      p5*0.5
  iAttack     init      0.1
  iDur        init      p3
  iDecay      init      iDur-iAttack
  iAttack     init      0.1

  iPanStart   init      (p1-1)/3
  iPanEnd     init      iPanStart

;***** INIT SECTION *****
;  iDur      init        p3
;  iVol      init        p4
;  iStartPitch           init        p5
;  iEndPitch init        p6

;  iAttack   init        p7
;  iDecay    init        iDur-iAttack

;  iPanStart init        p8
;  iPanEnd   init        p9

;***** SYNTH SECTION *****
  kEnv      linseg      0, iAttack, iVol, iDecay, 0
  kPitch    expseg      iStartPitch, iDur, iEndPitch
  aSig      oscili      kEnv, kPitch, giSineFunc

  kPan      linseg      iPanStart, iDur, iPanEnd

  aLeft     =           aSig*kPan
  aRight    =           aSig*(1-kPan)

            outs        aLeft, aRight

endin

</CsInstruments>
<CsScore>
f2 0 16 -2 1 1.06787109375 1.125 1.20135498046875 1.265625 1.35152435302734375 1.423828125 1.5 1.601806640625 1.6875 1.802032470703125 1.8984375

;; GENERATED TUNES GO HERE

</CsScore>
</CsoundSynthesizer>

