<CsoundSynthesizer>
; BASIC INSTRUMENT
<CsInstruments>
sr = 44100
kr = 441
nchnls = 1
instr 1
;;ip = cpspch(p4) ;; 12ET
ip cps2pch p4, -2 ;; tuning table is cycle of fifths
p5 = ampdbfs(p5)
kamp = p5
a1 oscil kamp, ip, 1
a2 linseg 0, 0.1, 1, p3-0.2, 1, 0.1, 0
out a1 * a2
endin
</CsInstruments>

<CsScore>
f1 0 8192 10 1
;; Cycle of fifths tuning
f2 0 16 -2 1 1.06787109375 1.125 1.20135498046875 1.265625 1.35152435302734375 1.423828125 1.5 1.601806640625 1.6875 1.802032470703125 1.8984375

; Starting answer set 1
i1 0 0.5 9.00 -3
i1 + 0.5 8.10 -3
i1 + 0.5 9.00 -3
i1 + 0.5 8.07 -3
i1 + 0.5 8.10 -3
i1 + 0.5 8.09 -3
i1 + 0.5 8.10 -3
i1 + 0.5 8.05 -3
i1 + 0.5 8.07 -3
i1 + 0.5 8.05 -3
f0 5.5
s
; Finishing answer set 1


</CsScore>
</CsoundSynthesizer>
