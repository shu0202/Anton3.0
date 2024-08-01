% lilypound output is currently limited to 676 layers.
\version "2.10.33"
\paper { indent = 0\cm }
% Starting answer set 1
layerAB = {
	\clef treble 
<< { \key  c \major 
\set Score.timing = ##f
 c'1 e'1 d'1 b1 c'1 b1 d'1 c'1
 \bar "||" \break 
}
>>
}
% Finishing answer set 1


\score {
\new StaffGroup <<
\transpose  c c {\new Staff { \override Staff.TimeSignature #'break-visibility = #end-of-line-invisible \layerAB } }
>>
\layout {}
}
