
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


%% compose.lp
%%
%% Martin Brain
%% mjb@cs.bath.ac.uk
%% 27/03/08
%%
%% Uses the melodic and harmonic rules to generate valid pieces of music

%#hide.

mode(K) :- mode(K).
#show mode/1.

% #show style(C).
style(C) :- style(C).
#show style/1.

% #show part(P).
part(P) :- part(P).
#show part/1.

% #show partTime(P,T).
partTime(P,T) :- partTime(P,T).
#show partTime/2.
% #show partTimeMax(P,TM).
partTimeMax(P,TM) :- partTimeMax(P,TM).
#show partTimeMax/2.

% #show choosenNote(P,T,N).
choosenNote(P,T,N) :- choosenNote(P,T,N).
#show choosenNote/3.
% #show rest(P,T).
rest(P,T) :- rest(P,T).
#show rest/2.

% #show leapBy(P,T,L).
leapBy(P,T,L) :- leapBy(P,T,L).
#show leapBy/3.
% #show stepBy(P,T,S).
stepBy(P,T,S) :- stepBy(P,T,S).
#show stepBy/3.
% #show repeated(P,T).
repeated(P,T) :- repeated(P,T).
#show repeated/2.
% #show incorrectProgression(P,T).
incorrectProgression(P,T) :- incorrectProgression(P,T).
#show incorrectProgression/2.
% #show toRest(P,T).
toRest(P,T) :- toRest(P,T).
#show toRest/2.
% #show fromRest(P,T).
fromRest(P,T) :- fromRest(P,T).
#show fromRest/2.

% #show chordal(B).
chordal(B) :- chordal(B).
#show chordal/1.
% #show chord(T,TR).
chord(T,TR) :- chord(T,TR).
#show chord/2.
% #show chordPosition(T,TP).
chordPosition(T,TP) :- chordPosition(T,TP).
#show chordPosition/2.
% #show cadence(T,C).
cadence(T,C) :- cadence(T,C).
#show cadence/2.

% No errors are allowed
% #domain reason(R).
  :- reason(R), error(P,T,R).