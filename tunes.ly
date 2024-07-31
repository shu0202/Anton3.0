% lilypound output is currently limited to 676 layers.
\version "2.10.33"
\paper { indent = 0\cm }
% Starting answer set 1
layerAB = {
	\clef treble 
<< { \key  d \dorian 
\set Score.timing = ##f
 d'1 e'1 c'1 d'1 a'1 g'1 d'1 f'1 e'1 f'1 c''1 a'1 b'1 a'1 e''1 d''1
 \bar "||" \break 
}
>>
}
layerAC = {
	\clef treble 
<< { \key  d \dorian 
\set Score.timing = ##f
 d'1 g1 a1 g1 f1 g1 g1 f1 a1 a1 a1 d'1 d'1 d'1 c'1 d'1
 \bar "||" \break 
}
>>
}
% Finishing answer set 1


\score {
\new StaffGroup <<
\transpose  d c {\new Staff { \override Staff.TimeSignature #'break-visibility = #end-of-line-invisible \layerAB } }
\transpose  d c {\new Staff { \override Staff.TimeSignature #'break-visibility = #end-of-line-invisible \layerAC } }
>>
\layout {}
}
