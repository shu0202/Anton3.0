
%% Copyright (C) 2010 Martin Brain and Georg Boenn
%% 
%% This program is free software; you can redistribute it and/or
%% modify it under the terms of the GNU General Public License
%% as published by the Free Software Foundation; either version 2
%% of the License, or (at your option) any later version.
%% 
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%% 
%% You should have received a copy of the GNU General Public License
%% along with this program; if not, write to the Free Software
%% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
%% 02110-1301, USA.


%% quartet.lp
%%
%% 13/05/09
%%
%% Concepts by Georg Boenn, gboenn@glam.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% Rules for composing / analysising melodies for a quartet

%% This is a quartet
style(quartet).

%% There are four parts
part(1..4).

%% The top part plays the melody
melodicPart(1).

%% For chords we need to know the lowest part
lowestPart(4).

%% We need a range of up to 2 octaves (24 steps) for each part,
%% thus need 24 notes above and below the lowest / highest start
#const quartetBottomNote=1.
#const quartetTopNote=68.
note(quartetBottomNote..quartetTopNote).
bottomNote(quartetBottomNote).
topNote(quartetTopNote).

%% Starting positions are 1 - 5 - 1 - 5
#const err_isn="Incorrect starting note".
reason(err_isn).
error(1,1,err_isn) :- not choosenNote(1,1,44).
error(2,1,err_isn) :- not choosenNote(2,1,37).
error(3,1,err_isn) :- not choosenNote(3,1,32).
error(4,1,err_isn) :- not choosenNote(4,1,25).

%% No rests
#const err_nrfw="No rest for the wicked".
reason(err_nrfw).
error(P,T,err_nrfw) :- rest(P,T).

%% With three or more parts allow intervals of a major fourth
%% (5 semitones) between parts
validInterval(5).

#include "rules/notes.lp"
#include "rules/modes.lp"
#include "rules/progression.lp"
#include "rules/melody.lp"
#include "rules/harmony.lp"
#include "rules/chord.lp"
