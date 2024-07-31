% lilypound output is currently limited to 676 layers.
\version "2.10.33"
\paper { indent = 0\cm }
% Starting answer set 1
layerAB = {
	\clef treble 
<< { \key  f \major 
\set Score.timing = ##f
 c'1 f'1 d'1 e'1 d'1 g1bes1 a1 g1 f1
 \bar "||" \break 
}
>>
}
% Finishing answer set 1


\score {
\new StaffGroup <<
\transpose  f c {\new Staff { \override Staff.TimeSignature #'break-visibility = #end-of-line-invisible \layerAB } }
>>
\layout {}
}
