% lilypound output is currently limited to 676 layers.
\version "2.10.33"
\paper { indent = 0\cm }
% Starting answer set 1
layerAB = {
	\clef treble 
<< { \key  f \major 
\set Score.timing = ##f
 c'''1 f''1 a''1 g''1 a''1bes''1 g''1 c'''1bes''1 a''1
 \bar "||" \break 
}
>>
}
layerAC = {
	\clef treble 
<< { \key  f \major 
\set Score.timing = ##f
 f''1 f''1 f''1 e''1 e''1 d''1 d''1 c''1 d''1 f''1
 \bar "||" \break 
}
>>
}
layerAD = {
	\clef treble 
<< { \key  f \major 
\set Score.timing = ##f
 c''1 c''1 f'1 c''1 c'1 g'1bes'1 c''1 g'1 f'1
 \bar "||" \break 
}
>>
}
layerAE = {
	\clef treble 
<< { \key  f \major 
\set Score.timing = ##f
 f'1 c'1 c'1 c'1 c'1bes1bes1 a1bes1 c'1
 \bar "||" \break 
}
>>
}
% Finishing answer set 1


\score {
\new StaffGroup <<
\transpose  f c {\new Staff { \override Staff.TimeSignature #'break-visibility = #end-of-line-invisible \layerAB } }
\transpose  f c {\new Staff { \override Staff.TimeSignature #'break-visibility = #end-of-line-invisible \layerAC } }
\transpose  f c {\new Staff { \override Staff.TimeSignature #'break-visibility = #end-of-line-invisible \layerAD } }
\transpose  f c {\new Staff { \override Staff.TimeSignature #'break-visibility = #end-of-line-invisible \layerAE } }
>>
\layout {}
}
