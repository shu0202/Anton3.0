
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


%% progression.lp
%%
%% 03/11/06
%%
%% Concepts by Georg Boenn, gboenn@glam.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% Rules for the progression of all parts, melodic and harmonic

%% Note selection
%% may move by any reasonable amount (i.e. not just step)
%% are allowed the same note repeatedly


%% The number of parts is given by the style
%#domain part(P).
%#domain part(P1).
%#domain part(P2).


%% Time steps are given independantly for each part
partTime(P,1..TM) :- part(P), partTimeMax(P,TM). %changed

%% Each part can only play one note at a given time
%% This is needed so that partial pieces can be supplied.
 :- 2 { choosenNote(P,T,NN) : note(NN), rest(P,T) }, part(P), partTime(P,T). %tag

%% At every time step the note may change
%% It changes by stepping (moving one note in the scale)
%% or leaping (moving more than one note)
%% These can either be upwards or downwards
#count { 1:changes(P,T); 1:repeated(P,T);
    1:toRest(P,T); 1:fromRest(P,T);
    1:incorrectProgression(P,T) } = 1 :- part(P), partTime(P,T), partTimeMax(P,TM), T != TM. %changed
#count { 1:stepAt(P,T); 1:leapAt(P,T) } = 1 :- part(P), changes(P,T), partTimeMax(P,TM), T != TM. %changed
#count { 1:downAt(P,T);   1:upAt(P,T) } = 1 :- part(P), changes(P,T), partTimeMax(P,TM), T != TM. %changed

stepDown(P,T) :- part(P), stepAt(P,T), downAt(P,T). %changed
stepUp(P,T)   :- part(P), stepAt(P,T),   upAt(P,T). %changed

leapDown(P,T) :- part(P), leapAt(P,T), downAt(P,T). %changed
leapUp(P,T)   :- part(P), leapAt(P,T),   upAt(P,T). %changed

#const err_ip="Incorrect progression".
reason(err_ip).
error(P,T,err_ip) :- part(P), incorrectProgression(P,T). %changed

%% We start by moving from rest
fromRest(P,0) :- part(P).

%% Sanity checks so on the transition to and from rests
%% These are constraints rather than errors as fromRest / toRest
%% aren't part of the example format.
 :- rest(P,T), not repeated(P,T), not fromRest(P,T), part(P). %changed
 :- fromRest(P,T), not rest(P,T), T > 0, part(P). %changed


%% A step is to the next note of the mode
%% This assumes that for every given mode either N+1 or N+2 is in the mode
%% - but not both
%% Equivalently either N-1 or N-2 is in the mode
stepSize(2).
stepSize(1).
stepSize(-1).
stepSize(-2).
%#domain stepSize(S).
%#domain stepSize(S1).
%#domain stepSize(S2).
%#domain stepSize(S3).

%% If we step, we must pick an amount to step by
1 { stepBy(P,T,SS) : stepSize(SS), SS < 0 } 1 :- part(P), stepDown(P,T). %changed
1 { stepBy(P,T,SS) : stepSize(SS), SS > 0 } 1 :- part(P), stepUp(P,T). %changed
% (note that because of the structure of the mode
%  there should only be one option for each of these)

%% Leaps can only use consonant intervals
%% Connected - no jumps of over 12 chromatic steps
%% nor are dissonant leaps allowed (1), (6), (8), (9), (10), (11)
leapSize(CI) :- consonantInterval(CI), CI != 0.
leapSize(-CI) :- consonantInterval(CI), CI != 0.
leapSize(12).
leapSize(-12).
%#domain leapSize(L).
%#domain leapSize(L1).
%#domain leapSize(L2).
%#domain leapSize(L3).

%% If we leap then we must leap by a given amount
{ leapBy(P,T,LS) : leapSize(LS), LS < 0 } = 1 :- part(P), leapDown(P,T). %changed
{ leapBy(P,T,LS) : leapSize(LS), LS > 0 } = 1 :- part(P), leapUp(P,T). %changed


%% Make it so
choosenNote(P,T + 1,N + S) :- stepSize(S), part(P), choosenNote(P,T,N), stepAt(P,T),
                              stepBy(P,T,S), note(N + S). %changed
choosenNote(P,T + 1,N + L) :- leapSize(L), part(P), choosenNote(P,T,N), leapAt(P,T),
                              leapBy(P,T,L), note(N + L). %changed
choosenNote(P,T + 1,N) :- part(P), choosenNote(P,T,N), repeated(P,T). %changed

rest(P,T + 1) :- part(P), rest(P,T), repeated(P,T). %changed
rest(P,T + 1) :- part(P), toRest(P,T). %changed
1 { choosenNote(P,T + 1,NN) : note(NN) } 1 :- part(P), fromRest(P,T). %changed
1 { choosenNote(P,1,NN)     : note(NN) } 1 :- part(P), fromRest(P,0). %changed

%% In some cases we only care about the chromatic position of a part, not the note
choosenChromatic(P,T,C) :- note(N), part(P), chromaticPosition(C), choosenNote(P,T,N), chromatic(N,C). %changed


%% Notes must be within the given range
%% Note this is not an 'error' as it can only be given by the program
%% not the user (assuming piece inputs are just a set of notes)
%% plus having notes 'outside' the usual range cause problems
%% with multiple simmultaneous notes.
 :- stepSize(S), part(P), note(N), choosenNote(P,T,N), stepAt(P,T), stepBy(P,T,S), not note(N + S). %changed
 :- leapSize(L), part(P), note(N), choosenNote(P,T,N), leapAt(P,T), leapBy(P,T,L), not note(N + L). %changed


%% Work out the range of the part
notePlayed(P,N) :- part(P), note(N), choosenNote(P,T,N). %changed

highestNote(P,N) :- part(P), note(N), notePlayed(P,N), not lowerThanHighestNote(P,N). %changed
lowerThanHighestNote(P,N-1) :- part(P), note(N), highestNote(P,N). %changed
lowerThanHighestNote(P,N-1) :- part(P), note(N), lowerThanHighestNote(P,N). %changed

lowestNote(P,N) :- part(P), note(N), notePlayed(P,N), not higherThanLowestNote(P,N).
higherThanLowestNote(P,N+1) :- part(P), note(N), lowestNote(P,N).
higherThanLowestNote(P,N+1) :- part(P), note(N), higherThanLowestNote(P,N).


%% Total range must not be more than 2 octaves
#const err_ro="Range over two octaves".
reason(err_ro).
error(P,TM,err_ro) :- part(P), note(N1), note(N2), lowestNote(P,N1), highestNote(P,N2), N1 + 24 < N2, partTimeMax(P,TM). %changed


