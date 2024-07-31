<CsoundSynthesizer>

<CsInstruments>
sr = 44100
kr = 441
nchnls = 1
instr 1
ip = cpspch(p4)
a1 oscil 32000, ip, 1
a2 linseg 0, 0.1, 1, p3-0.2, 1, 0. 1, 0
out a1 * a2
endin
</CsInstruments>

<CsScore>
f1 0 8192 10 1

i1 0 0.5 8.00
i1 + . 7.11
i1 + . 8.00
i1 + . 8.04
i1 + . 8.02
i1 + . 8.00
f0 3.5
s

i1 0 0.5 8.00
i1 + . 7.11
i1 + . 7.09
i1 + . 8.00
i1 + . 8.02
i1 + . 8.00
f0 3.5
s

i1 0 0.5 8.00
i1 + . 7.11
i1 + . 7.09
i1 + . 7.04
i1 + . 7.02
i1 + . 7.00
f0 3.5
s

i1 0 0.5 8.00
i1 + . 7.11
i1 + . 7.09
i1 + . 8.04
i1 + . 8.02
i1 + . 8.00
f0 3.5
s

i1 0 0.5 8.00
i1 + . 8.02
i1 + . 8.00
i1 + . 7.09
i1 + . 7.11
i1 + . 8.00
f0 3.5
s

</CsScore>
</CsoundSynthesizer>
