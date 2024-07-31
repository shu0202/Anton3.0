
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


%% rhythm.lp
%%
%% Martin Brain
%% mjb@cs.bath.ac.uk
%% 20/05/09
%% 
%% Concepts by Georg Boenn, gboenn@glam.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% The encoding of rhythm is based on the concept of Farey trees
%% This encoding creates Farey trees and then creates a mapping to note positions
%% Note the duration is not computed here as the tree nodes are
%% effectively in the 'middle' of the note.

% We are using rhythm
rhythm(1).

%% There are several possible Farey Trees
%#const f=2.
%fareyTree(1..f).
fareyTree(P) :- part(P). %changed
%#domain fareyTree(F).

%% Parts map to Farey trees
%partToFareyTree(P,1).
partToFareyTree(P,P) :- part(P). %changed

%% Each Farey tree has a given depth
depth(F,MD + BD + DD) :- fareyTree(F), measureDepth(MD), meterDepth(F,BD), durationDepth(F,DD).
level(F,1..DE) :- fareyTree(F), depth(F,DE).



%% Each Farey tree is divided into three layers (top to bottom)
%% Measure, meter and note duration
%% (bars, time signature and note value)
%% Each of which has it's own rules

durationDepth(F,2) :- fareyTree(F). %changed

durationLevel(F,FL) :- fareyTree(F), depth(F,DE), durationDepth(F,DD), level(F,FL), FL > (DE - DD). %changed
durationLeafLevel(F,DE) :- fareyTree(F), depth(F,DE). %changed

meterLevel(F,FL) :- fareyTree(F), depth(F,DE), durationDepth(F,DD), meterDepth(F,BD), %changed
                   level(F,FL), FL <= (DE - DD), FL > (DE - (DD + BD)).
meterLeafLevel(F,DE - DD) :- fareyTree(F), depth(F,DE), durationDepth(F,DD). %xhanged

measureLevel(F,FL) :- fareyTree(F), depth(F,DE), durationDepth(F,DD), meterDepth(F,BD), 
                      level(F,FL), FL <= DE - (DD + BD). %changed
measureLeafLevel(F,DE - (DD + BD)) :- fareyTree(F), depth(F,DE), durationDepth(F,DD), meterDepth(F,BD). %changed







%% At each level of expansion there are at most N times
%% the number of nodes of the previous one
%% (At the moment 5 way expansion is not used)
maxExpansion(F,3) :- fareyTree(F). %changed
nodeLimit(F,1,1) :- fareyTree(F). %changed
nodeLimit(F,FL,ME**(FL-1)) :- fareyTree(F), level(F,FL), FL > 1, maxExpansion(F,ME). %changed

% Each level of the tree then has at that many possible nodes.
node(F,FL,0..NL-1) :- fareyTree(F), nodeLimit(F,FL,NL). %changed

%% The descendants of a node are the (maxExpansion) nodes on the level below
descendantOffset(F,0..ME-1) :- fareyTree(F), maxExpansion(F,ME). %changed
descendant(F,D,FL,ND,FL+1,(ME * ND) + D) :- fareyTree(F), possibleChromaticInterval(D), node(F,FL,ND), level(F,FL+1),
                                            descendantOffset(F,D), maxExpansion(F,ME). %changed

%% The root node is always present
present(F,1,0) :- fareyTree(F). %changed

%% Every present, non-leaf node expands up to 1,2,3 or 5 ways
possibleExpansion(F,1) :- fareyTree(F). %changed
possibleExpansion(F,2) :- fareyTree(F), 2 <= ME, maxExpansion(F,ME). %changed
possibleExpansion(F,3) :- fareyTree(F), 3 <= ME, maxExpansion(F,ME). %changed
possibleExpansion(F,5) :- fareyTree(F), 5 <= ME, maxExpansion(F,ME). %changed

1 { expand(F,FL,ND,E) : possibleExpansion(F,E)} 1 :-  fareyTree(F), present(F,FL,ND), not depth(F,FL). %changed tag

%% Only descendants less than the expansion are present
present(F,FL2,ND2) :-  fareyTree(F), possibleChromaticInterval(D), expand(F,FL1,ND1,E), descendant(F,D,FL1,ND1,FL2,ND2),
                      D < E, possibleExpansion(F,E). %changed




%% Map from nodes to time positions
%% Mapping increments each time a node is present
nodeStep(F,0,1) :- fareyTree(F). %changed
nodeStep(F,ND,T) :- fareyTree(F), part(P), not present(F,DLL,ND), nodeStep(F,ND-1,T),
                        node(F,DLL,ND), durationLeafLevel(F,DLL), ND > 0,
                        partToFareyTree(P,F), partTime(P,T). %changed
nodeStep(F,ND,T+1) :-   fareyTree(F), part(P), present(F,DLL,ND), nodeStep(F,ND-1,T),
                        node(F,DLL,ND), durationLeafLevel(F,DLL), ND > 0,
                        partToFareyTree(P,F), partTime(P,T). %changed

%% From this we derive a unique mapping from node to time step
timeToNode(P,1,0) :- part(P). %changed
timeToNode(P,T,ND) :- fareyTree(F), part(P), present(F,DLL,ND), nodeStep(F,ND-1,T-1),
                      node(F,DLL,ND), durationLeafLevel(F,DLL), ND > 0,
                      partToFareyTree(P,F), partTime(P,T). %changed

nodeStep(F,ND,T) :- nodeStep(F,ND,T).
#show nodeStep/3.

%% To make sure the mapping is 1 to 1 between present nodes and time steps
#const err_mtstn="More time steps than leaves on the Farey tree".
reason(err_mtstn).
error(1,1,err_mtstn) :- {timeToNode(P,T,ND) : node(F,DLL,ND)} 0, fareyTree(F), part(P),
                        durationLeafLevel(F,DLL),
                        partToFareyTree(P,F), partTime(P,T). %changed

#const err_ftstn="Fewer time steps than leaves on the Farey tree".
reason(err_ftstn).
error(1,1,err_ftstn) :- fareyTree(F), part(P), nodeStep(F,ND,TM+1), partToFareyTree(P,F),
                        partTimeMax(P,TM). %changed









%% All leaves of the measure layer must be the same length
#const err_mlnsl="Measure layer has divisions that are not of the same length".
reason(err_mlnsl).
error(1,1,err_mlnsl) :- fareyTree(F), measureLevel(F,FL), measureLevel(F,FL+1),
                         expand(F,FL,ND1,E1), expand(F,FL,ND2,E2),
                         ND1 < ND2, E1 != E2. %changed

%% All parts must have the same measure section
#const err_mldddft="Measure layer depth different in different Farey trees".
reason(err_mldddft).
error(1,1,err_mldddft) :- measureLevel(F1,FL), not measureLevel(F2,FL),
                           fareyTree(F1), fareyTree(F2), F1 != F2. %changed

#const err_mlncbft="Measure layer not consistant between Farey trees".
reason(err_mlncbft).
error(1,1,err_mlncbft) :- measureLevel(F1,FL), measureLevel(F1,FL+1),
                         measureLevel(F2,FL), measureLevel(F2,FL+1),
                         expand(F1,FL,ND,E1), expand(F2,FL,ND,E2), E1 != E2,
                         F1 != F2. %changed

%% Assert an ordering on the measure level to remove symmetries
#const err_dnml="Denormalised measure level".
reason(err_dnml).
error(1,1,err_dnml) :- fareyTree(F), possibleChromaticInterval(D), measureLevel(F,FL), measureLevel(F,FL+1), measureLevel(F,FL+2),
                       descendant(F,D,FL,ND1,FL+1,ND2),
                       expand(F,FL,ND1,E1), expand(F,FL,ND2,E2), E1 > E2. %changed

%% TODO - given previous rules we could probably simplify the two previous rules


%% Constraint to the requested number of measures
#const err_tfm="Too few measures".
reason(err_tfm).
error(1,1,err_tfm) :- 0 { present(F,MLL,ND) : node(F,MLL,ND) } ML - 1,
                      measureLimit(ML), measureLeafLevel(F,MLL), fareyTree(F). %changed

#const err_tmm="Too many measures".
reason(err_tmm).
error(1,1,err_tmm) :- ML + 1 { present(F,MLL,ND) : node(F,MLL,ND) },
                      measureLimit(ML), measureLeafLevel(F,MLL), fareyTree(F). %changed





%% Within one measure all meters must have the same duration
%% (Note the -1 to cover the branching from measure to meter layer)
%% The weird division constraint is making sure both are children of the same
%% node in the measure layer, given the known expansion rate
#const err_blim="Irregular meter".
reason(err_blim).
error(1,1,err_blim) :- fareyTree(F), meterLevel(F,FL), ND1 < ND2, E1 != E2,
                       expand(F,FL-1,ND1,E1), expand(F,FL-1,ND2,E2),
                       measureLeafLevel(F,MLL), maxExpansion(F,ME),
                       (ND1 / (ME**(FL - MLL))) == (ND2 / (ME**(FL - MLL))),
                       regularMeter(F). %changed

%% In many cases we want the meter to be the same for every measure for a given tree
#const err_bmm="Mixed meter".
reason(err_bmm).
error(1,1,err_bmm) :- fareyTree(F), meterLevel(F,FL), ND1 < ND2, E1 != E2,
                      expand(F,FL-1,ND1,E1), expand(F,FL-1,ND2,E2),
                      uniformMeter(F). %changed tag

%% In many cases we want the meter to be the same for every Farey tree.
#const err_bldddft="Meter layer depth different in different Farey trees".
reason (err_bldddft).
error(1,1,err_bnsfrt) :- fareyTree(F), meterLevel(F1,FL), not meterLevel(F2,FL),
                         fareyTree(F1), fareyTree(F2), F1 != F2,
                         sameMeter(F1,F2). %changed

#const err_bnsfrt="Meter layer not consistant between Farey trees".
reason(err_bnsfrt).
error(1,1,err_bnsfrt) :- meterLevel(F1,FL), meterLevel(F2,FL),
                         expand(F1,FL-1,ND,E1), expand(F2,FL-1,ND,E2), E1 != E2,
                         F1 != F2, sameMeter(F1,F2).

%% TODO - same comment about simplification as before

%% Expansion by 1 is a little suspect in the meter layer
%% It is used for things like 3/4 and 6/8 but otherwise not
%% Thus we want any division by one to be done at the top of the meter layer
%% Minus one is to that the expansion from measure to meter is covered as well
#const err_blebo="Meter layer contains denormalised expansion by one".
reason(err_blebo).
error(1,1,err_blebo) :- fareyTree(F), meterLevel(F,FL), meterLevel(F,FL+1),
                        expand(F,FL-1,ND,E1), expand(F,FL,ND,1), E1 > 1. %changed




%% Time signatures are effectively sets of options for the meter level.
#const err_mdnmts="Meter does not match time signature".
reason(err_mdnmts).

%% They can be set per tree and will apply to all meters
regularMetric(F) :- fareyTree(F), treeTimeSignature(F,TS). %changed
uniformMetric(F) :- fareyTree(F), treeTimeSignature(F,TS). %changed


%% meterDepthConfig(F,TS) is only needed due to an algorithmic glitch
%% in GrinGo's domain predicate inference.  It should be possible to 
%% to use just treeTimeSignature(F,TS), but for domain predicate inference
%% to work, it's necessary to separate the predcates that infer meterDepth
%% and those that constrain the tree.

%added
% Categorize time signatures into 2-layer or 3-layer
%timeSignatureLayer("4/4", "2-layer").
%timeSignatureLayer("3/4", "2-layer").
%timeSignatureLayer("3/8", "3-layer").
%timeSignatureLayer("6/8", "3-layer").
%timeSignatureLayer("9/8", "3-layer").
%timeSignatureLayer("12/8", "3-layer").

% Derive wildcard time signature based on chosen time signature
%treeTimeSignature(F, TS) :- fareyTree(F), chosenTimeSignature(TS).
%wildcardTimeSignature(Layer) :- chosenTimeSignature(TS), timeSignatureLayer(TS, Layer).
%added

%% 2/2 (X X)
timeSignature("2/2").
%meterDepth(F,1) :- treeTimeSignature(F,"2/2").
meterDepth(F,1) :- fareyTree(F), meterDepthConfig(F,"2/2").
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"2/2"), expand(F,MLL,ND,E), E != 2. 




%% Generic two layer time signature
meterDepth(F,2) :- fareyTree(F), meterDepthConfig(F,"2-layer").
#count { 1:chosenTimeSignature("4/4");
    1:chosenTimeSignature("3/4") } = 1 :- wildcardTimeSignature("2-layer").
treeTimeSignature(F,TS) :- fareyTree(F), chosenTimeSignature(TS).
wildcardTimeSignature("2-layer").

%% 4/4 ((X X) (X X)) 
timeSignature("4/4").
%meterDepth(F,2) :- treeTimeSignature(F,"4/4").
meterDepth(F,2) :- fareyTree(F), meterDepthConfig(F,"4/4").
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"4/4"), expand(F,MLL,ND,E), E != 2. 
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL+1,ND),
                         treeTimeSignature(F,"4/4"), expand(F,MLL+1,ND,E), E != 2. 
%% 3/4 ((X X X))
timeSignature("3/4").
%meterDepth(F,2) :- treeTimeSignature(F,"3/4").
meterDepth(F,2) :- fareyTree(F), meterDepthConfig(F,"3/4").
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"3/4"), expand(F,MLL,ND,E), E != 1. 
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL+1,ND),
                         treeTimeSignature(F,"3/4"), expand(F,MLL+1,ND,E), E != 3.



 
%% Generic three layer time signature
meterDepth(F,3) :- fareyTree(F), meterDepthConfig(F,"3-layer").
#count { 1:chosenTimeSignature("3/8");
    1:chosenTimeSignature("6/8");
    1:chosenTimeSignature("9/8");
    1:chosenTimeSignature("12/8") } = 1 :- wildcardTimeSignature("3-layer").
treeTimeSignature(F,TS) :- fareyTree(F), chosenTimeSignature(TS).
wildcardTimeSignature("3-layer").


%% 3/8 (((X X X)))
timeSignature("3/8").
%meterDepth(F,3) :- treeTimeSignature(F,"3/8").
meterDepth(F,3) :- fareyTree(F), meterDepthConfig(F,"3/8").
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"3/8"), expand(F,MLL,ND,E), E != 1. 
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL+1,ND),
                         treeTimeSignature(F,"3/8"), expand(F,MLL+1,ND,E), E != 1.
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL+2,ND),
                         treeTimeSignature(F,"3/8"), expand(F,MLL+2,ND,E), E != 3.

%% 6/8 (((X X X) (X X X)))
timeSignature("6/8").
%meterDepth(F,3) :- treeTimeSignature(F,"6/8").
meterDepth(F,3) :- fareyTree(F), meterDepthConfig(F,"6/8").
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"6/8"), expand(F,MLL,ND,E), E != 1. 
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL+1,ND),
                         treeTimeSignature(F,"6/8"), expand(F,MLL+1,ND,E), E != 2.
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL+2,ND),
                         treeTimeSignature(F,"6/8"), expand(F,MLL+2,ND,E), E != 3.


%% 9/8 (((X X X) (X X X) (X X X)))
timeSignature("9/8").
%meterDepth(F,3) :- treeTimeSignature(F,"9/8").
meterDepth(F,3) :- fareyTree(F), meterDepthConfig(F,"9/8").
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"9/8"), expand(F,MLL,ND,E), E != 1. 
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL+1,ND),
                         treeTimeSignature(F,"9/8"), expand(F,MLL+1,ND,E), E != 3.
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL+2,ND),
                         treeTimeSignature(F,"9/8"), expand(F,MLL+2,ND,E), E != 3.

%% 12/8 (((X X X) (X X X)) ((X X X) (X X X)))
timeSignature("12/8").
%meterDepth(F,12) :- treeTimeSignature(F,"12/8").
meterDepth(F,12) :- fareyTree(F), meterDepthConfig(F,"12/8").
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"12/8"), expand(F,MLL,ND,E), E != 2. 
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL+1,ND),
                         treeTimeSignature(F,"12/8"), expand(F,MLL+1,ND,E), E != 2.
error(1,1,err_mdnmts) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL+2,ND),
                         treeTimeSignature(F,"12/8"), expand(F,MLL+2,ND,E), E != 3.




%% Work out meter strength
%% For leaves of the duration layer this is the number of first children
%% in the meter layer it is a descendant of.  This is then inherited by the
%% firstChildren in the duration layer.
meterStrengthMax(F,BD) :- fareyTree(F), meterDepth(F,BD). %changed
meterStrength(F,0..BSM) :- fareyTree(F), meterStrengthMax(F,BSM). %changed

%% Meter strength is created at the first level of the meter layer ...
nodeMeterStrength(F,MLL+1,ND2,1) :- fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL,ND1),
                                   descendant(F,0,MLL,ND1,MLL+1,ND2). %changed
nodeMeterStrength(F,MLL+1,ND2,0) :- possibleChromaticInterval(D), fareyTree(F), measureLeafLevel(F,MLL), node(F,MLL,ND1),
                                   descendant(F,D,MLL,ND1,MLL+1,ND2), D != 0. %changed


%% ... strengthened and passed to a first descendant in the layer ...
nodeMeterStrength(F,FL+1,ND2,BS+1) :- fareyTree(F), meterLevel(F,FL), meterLevel(F,FL+1), node(F,FL,ND1),
                                     descendant(F,0,FL,ND1,FL+1,ND2),
                                     nodeMeterStrength(F,FL,ND1,BS), meterStrength(F,BS). %changed

%% ... but not to the others ...
nodeMeterStrength(F,FL+1,ND2,0) :- fareyTree(F), possibleChromaticInterval(D), meterLevel(F,FL), meterLevel(F,FL+1), node(F,FL,ND1),
                                  descendant(F,D,FL,ND1,FL+1,ND2), D != 0,
                                  nodeMeterStrength(F,FL,ND1,BS), meterStrength(F,BS). %changed


%% ... and transmitted to the first descendants in the duration layer ...
nodeMeterStrength(F,BLL+1,ND2,BS) :- fareyTree(F), meterLeafLevel(F,BLL), node(F,BLL,ND1),
                                    descendant(F,0,BLL,ND1,BLL+1,ND2), BS > 0,
                                    nodeMeterStrength(F,BLL,ND1,BS), meterStrength(F,BS). %changed


%% ... and so on down through the first descendants.
nodeMeterStrength(F,FL+1,ND2,BS) :- fareyTree(F), durationLevel(F,FL), durationLevel(F,FL+1), node(F,FL,ND1),
                                   descendant(F,0,FL,ND1,FL+1,ND2), BS > 0,
                                   nodeMeterStrength(F,FL,ND1,BS), meterStrength(F,BS). %changed






%% Duration level

%% Work out duration length - this is given by the number of time the parents
%% expand by one
durationStepMax(F,DD) :- fareyTree(F), durationDepth(F,DD). %changed
durationStep(F,0..DS) :-fareyTree(F), durationStepMax(F,DS). %changed

%% Duration step is created by the division by more than one at the meter level
nodeDurationStep(F,BLL+1,ND2,0) :-  fareyTree(F), possibleChromaticInterval(D), meterLeafLevel(F,BLL), node(F,BLL,ND1),
                                    expand(F,BLL,ND1,1),
                                    descendant(F,D,BLL,ND1,BLL+1,ND2). %changed

nodeDurationStep(F,BLL+1,ND2,1) :-  fareyTree(F), possibleChromaticInterval(D), meterLeafLevel(F,BLL), node(F,BLL,ND1),
                                    expand(F,BLL,ND1,E), E > 1,
                                    descendant(F,D,BLL,ND1,BLL+1,ND2). %changed

%% And propagated down the tree in a similar fashion
nodeDurationStep(F,FL+1,ND2,DS) :-  fareyTree(F), possibleChromaticInterval(D), durationLevel(F,FL), durationLevel(F,FL+1),
                                    expand(F,FL,ND1,1), node(F,FL,ND1),
                                    descendant(F,D,FL,ND1,FL+1,ND2),
                                    nodeDurationStep(F,FL,ND1,DS),
                                    durationStep(F,DS). %changed
                                    
nodeDurationStep(F,FL+1,ND2,DS+1) :-  fareyTree(F), possibleChromaticInterval(D), durationLevel(F,FL), durationLevel(F,FL+1),
                                      expand(F,FL,ND1,E), E > 1, node(F,FL,ND1),
                                      descendant(F,D,FL,ND1,FL+1,ND2),
                                      nodeDurationStep(F,FL,ND1,DS),
                                      durationStep(F,DS). %changed
                                    

%% Use these to infer note duration
timeStepDuration(P,T,DS) :- part(P), fareyTree(F), timeToNode(P,T,ND), partToFareyTree(P,F),
                            depth(F,DE), nodeDurationStep(F,DE,ND,DS). %changed







%%% Style info


regularMeter(F) :- fareyTree(F).
uniformMeter(F) :- fareyTree(F).
sameMeter(F1,F2) :- fareyTree(F1), fareyTree(F2), F1 != F2.


%% Division by greater than two should only be used at
%% the lowest level of note division
%% Minus one to catch the expansion from meter to duration
topLevelEvenDurationDivision(1).
#const err_demt2="Expansion by more than two at non-leaf duration level".
reason(err_demt2).
error(1,1,err_demt2) :- fareyTree(F), durationLevel(F,FL), not durationLeafLevel(F,FL),
                        expand(F,FL-1,ND,E), E > 2, topLevelEvenDurationDivision(1). %changed

%% Neighbouring divisions can only increase / decrease duration length by 1
#const err_sscid="Sudden significant change in duration".
reason(err_sscid).
error(P,T,err_sscid) :- part(P), timeStepDuration(P,T,DS1), timeStepDuration(P,T+1,DS2),
                        abs(DS1 - DS2) > 1. %changed

%% Just for fun, a few rules linking note duration and melodic effects

%% No fast leaps
#const err_nfl="No fast leaps".
reason(err_nfl).
error(P,T,err_nfl) :- part(P), leapAt(P,T), timeStepDuration(P,T,DS), DS > 1. %changed

%% Lowest and highest notes must also be slower
#const err_hnbs= "Highest note must be slow".
#const err_lnbs="Lowest note must be slow".
reason(err_hnbs).
reason(err_lnbs).

playsHeighestNote(P,T) :- part(P), note(N), choosenNote(P,T,N), lowestNote(P,N). %changed
playsLowestNote(P,T) :- part(P), note(N), choosenNote(P,T,N), lowestNote(P,N). %changed
error(P,T,err_hnbs) :- part(P), playsHeighestNote(P,T), timeStepDuration(P,T,DS), DS > 1. %changed
error(P,T,err_lnbs) :- part(P), playsLowestNote(P,T), timeStepDuration(P,T,DS), DS > 1. %changed

%% Shouldn't finish on a fast note
#const err_snffn="Should not finish on a fast note".
reason(err_snffn).
error(P,TM-1,err_snffn) :-  part(P), timeStepDuration(P,TM-1,DS), DS > 1, partTimeMax(P,TM). %changed
error(P,TM,err_snffn) :-  part(P), timeStepDuration(P,TM,DS), DS > 0, partTimeMax(P,TM). %changed










%% Hack overlapping rules
hackOverlap(F1,F2) :- sameMeter(F1,F2), topLevelEvenDurationDivision(1),
                      durationDepth(F1,2), durationDepth(F2,2).

%% First we do the top level, each tree can either divide by one or divide by two
same(F1,ND2,F2,ND2) :- possibleChromaticInterval(D), meterLeafLevel(F1,BLL), present(F1,BLL,ND1),
		       meterLeafLevel(F2,BLL), present(F2,BLL,ND1),
                       expand(F1,BLL,ND1,E), expand(F2,BLL,ND1,E),
                       descendant(F1,D,BLL,ND1,BLL+1,ND2), D < E,
                       descendant(F2,D,BLL,ND1,BLL+1,ND2),
                       hackOverlap(F1,F2), F1 < F2.

%% First node is first half of second node
firstFirstHalf(F1,ND2,F2,ND3) :- meterLeafLevel(F1,BLL), present(F1,BLL,ND1),
	                         meterLeafLevel(F2,BLL), present(F2,BLL,ND1),
                                 expand(F1,BLL,ND1,2), expand(F2,BLL,ND1,1),
                                 descendant(F1,0,BLL,ND1,BLL+1,ND2),
                                 descendant(F2,0,BLL,ND1,BLL+1,ND3),
                                 hackOverlap(F1,F2), F1 < F2.

%% First node is second half of second node
firstSecondHalf(F1,ND2,F2,ND3) :- meterLeafLevel(F1,BLL), present(F1,BLL,ND1),
	                          meterLeafLevel(F2,BLL), present(F2,BLL,ND1),
                                  expand(F1,BLL,ND1,2), expand(F2,BLL,ND1,1),
                                  descendant(F1,1,BLL,ND1,BLL+1,ND2),
                                  descendant(F2,0,BLL,ND1,BLL+1,ND3),
                                  hackOverlap(F1,F2), F1 < F2.

%% Second node is first half of first node
secondFirstHalf(F1,ND2,F2,ND3) :- meterLeafLevel(F1,BLL), present(F1,BLL,ND1),
	                          meterLeafLevel(F2,BLL), present(F2,BLL,ND1),
                                  expand(F1,BLL,ND1,1), expand(F2,BLL,ND1,2),
                                  descendant(F1,0,BLL,ND1,BLL+1,ND2),
                                  descendant(F2,0,BLL,ND1,BLL+1,ND3),
                                  hackOverlap(F1,F2), F1 < F2.

%% Second node is second half of first node
secondSecondHalf(F1,ND2,F2,ND3) :- meterLeafLevel(F1,BLL), present(F1,BLL,ND1),
	                           meterLeafLevel(F2,BLL), present(F2,BLL,ND1),
                                   expand(F1,BLL,ND1,1), expand(F2,BLL,ND1,2),
                                   descendant(F1,0,BLL,ND1,BLL+1,ND2),
                                   descendant(F2,1,BLL,ND1,BLL+1,ND3),
                                   hackOverlap(F1,F2), F1 < F2.



%% Now the second layer

%% First if they are the same
%% Same and same expand gives
nodeOverlap(F1,ND2,F2,ND2) :- possibleChromaticInterval(D), same(F1,ND1,F2,ND1),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND1),
                              expand(F1,BLL+1,ND1,E), expand(F2,BLL+1,ND1,E),
                              descendant(F1,D,BLL+1,ND1,BLL+2,ND2), D < E,
                              descendant(F2,D,BLL+1,ND1,BLL+2,ND2),
                              hackOverlap(F1,F2), F1 < F2.

nodeOverlap(F1,ND2,F2,ND3) :- possibleChromaticInterval(D), same(F1,ND1,F2,ND1),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND1),
                              expand(F1,BLL+1,ND1,1), expand(F2,BLL+1,ND1,E), E != 1,
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND2), D < E,
                              descendant(F2,D,BLL+1,ND1,BLL+2,ND3),
                              hackOverlap(F1,F2), F1 < F2.

nodeOverlap(F1,ND2,F2,ND3) :- possibleChromaticInterval(D), same(F1,ND1,F2,ND1),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND1),
                              expand(F1,BLL+1,ND1,E), expand(F2,BLL+1,ND1,1), E != 1,
                              descendant(F1,D,BLL+1,ND1,BLL+2,ND2), D < E,
                              descendant(F2,0,BLL+1,ND1,BLL+2,ND3),
                              hackOverlap(F1,F2), F1 < F2.

nodeOverlap(F1,ND2,F2,ND3) :- same(F1,ND1,F2,ND1),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND1),
                              expand(F1,BLL+1,ND1,E1), expand(F2,BLL+1,ND1,E2),
                              E1 != 1, E2 != 1, E1 != E2,
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND2), D1 < E1,
                              descendant(F2,D2,BLL+1,ND1,BLL+2,ND3), D2 < E2,
                              hackOverlap(F1,F2), F1 < F2.


%% Now for the divisions by two
%% First node if first half of second
%% Expand the second by one overlaps all
%% Likewise expanding the second by two overlaps all descendants with the first descendants
nodeOverlap(F1,ND3,F2,ND4) :- firstFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,E1), expand(F2,BLL+1,ND2,E2), E2 <= 2,
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < E1,
                              descendant(F2,0,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by one and three gives overlaps with first two
nodeOverlap(F1,ND3,F2,ND4) :- firstFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,1), expand(F2,BLL+1,ND2,3),
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND1,BLL+2,ND4), D2 < 2,
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by two and three gives overlaps 
nodeOverlap(F1,ND3,F2,ND4) :- firstFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,2), expand(F2,BLL+1,ND2,3),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < 2,
                              descendant(F2,0,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- firstFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,2), expand(F2,BLL+1,ND2,3),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,1,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and three
nodeOverlap(F1,ND3,F2,ND4) :- firstFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < 2,
                              descendant(F2,0,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- firstFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,2,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,1,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.


%% The rest are similar but with slight permutations

%% Expand by one
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,E1), expand(F2,BLL+1,ND2,1),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < E1,
                              descendant(F2,0,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by two
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,E1), expand(F2,BLL+1,ND2,2),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < E1,
                              descendant(F2,1,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by one and three gives overlaps with last two
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,1), expand(F2,BLL+1,ND2,3),
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND2,BLL+2,ND4), 0 < D2, D2 <= 2,
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by two and three gives overlaps 
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,2), expand(F2,BLL+1,ND2,3),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < 2,
                              descendant(F2,1,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,2), expand(F2,BLL+1,ND2,3),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,2,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and three
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,1,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), 0 < D1, D1 < 3,
                              descendant(F2,2,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.




%% Similar for the inverse relations
%% Except the expand and descendant lines are switched
nodeOverlap(F1,ND3,F2,ND4) :- secondFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,E1), expand(F2,BLL+1,ND2,E2), E1 <= 2,
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND1,BLL+2,ND4), D2 < E2,
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and one gives overlaps with first two
nodeOverlap(F1,ND3,F2,ND4) :- secondFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,1),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < 2,
                              descendant(F2,0,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and two gives overlaps 
nodeOverlap(F1,ND3,F2,ND4) :- secondFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,2),
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND1,BLL+2,ND4), D2 < 2,
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- secondFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,2),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,1,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and three
nodeOverlap(F1,ND3,F2,ND4) :- secondFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND1,BLL+2,ND4), D2 < 2,
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- secondFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,2,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.


%% The rest are similar but with slight permutations

%% Expand by one
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,1), expand(F2,BLL+1,ND2,E2),
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND2,BLL+2,ND4), D2 < E2,
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by two
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,2), expand(F2,BLL+1,ND2,E2),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND2,BLL+2,ND4), D2 < E2,
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and one gives overlaps with last two
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,1),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), 0 < D1, D1 <= 2,
                              descendant(F2,0,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by two and three gives overlaps 
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,2),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND2,BLL+2,ND4), D2 < 2,
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,2),
                              descendant(F1,2,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,1,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and three
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,0,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,2,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND2,BLL+2,ND4), 0 < D2, D2 < 3,
                              hackOverlap(F1,F2), F1 < F2.






%% Finally, infer note overlap
%noteOverlap(P1,T1,P2,T2) :- timeToNode(P1,T1,ND1), partToFareyTree(P1,F1),
%                            timeToNode(P2,T2,ND2), partToFareyTree(P2,F2),
%                            nodeOverlap(F1,ND1,F2,ND2), P1 < P2, F1 != F2.
%% Should 'just work' with dotted notes

%% An alternative mapping - requires more atoms but less rules
timeToNodeOverlap(P1,T1,F2,ND2) :- part(P1), timeToNode(P1,T1,ND1), partToFareyTree(P1,F1),
				   nodeOverlap(F1,ND1,F2,ND2), F1 < F2. %changed
noteOverlap(P1,T1,P2,T2) :- part(P1), part(P2), timeToNodeOverlap(P1,T1,F2,ND2), timeToNode(P2,T2,ND2),
			    partToFareyTree(P2,F2), P1 < P2. %changed


noteOverlap(P1,T,P2,T) :-  fareyTree(F), part(P1), part(P2), partToFareyTree(P1,F), partToFareyTree(P2,F),
		           partTime(P1,T), partTime(P2,T), P1 < P2. %changed



%% Chording with rhythm assumes that all Farey trees have the same meter
%hackChords(1) :- sameMeter(F1,F2), fareyTree(F1), fareyTree(F2), F1 != F2, chordal(1). %changed
intermediate_1(F1, F2) :- sameMeter(F1, F2), fareyTree(F1), fareyTree(F2), F1 != F2. %new
hackChords(1) :- intermediate_1(F1, F2), chordal(1). %new

%% Each meter leaf node corresponds to a possible chord
possibleChord(PC) :- fareyTree(F), present(F,BLL,PC), meterLeafLevel(F,BLL), hackChords(1). %changed

% Hack to help the grounder
possibleChordDomain(PC) :- fareyTree(F), node(F,BLL,PC), meterLeafLevel(F,BLL), hackChords(1). %changed


%nextPossibleChord(PC1,PC2) :- possibleChord(PC1), possibleChord(PC2), PC1 < PC2,
%			      not possibleChord(PC3), possibleChordDomain(PC3)
%			      	  		    , PC1 < PC3, PC3 < PC2. %changed
intermediate_2(PC1, PC2, PC3) :- possibleChord(PC1), possibleChord(PC2), possibleChordDomain(PC3), PC1 < PC3, PC3 < PC2. %new
nextPossibleChord(PC1, PC2) :- possibleChord(PC1), possibleChord(PC2), possibleChordDomain(PC3), PC1 < PC2,
    not possibleChord(PC3), not intermediate_2(PC1, PC2, PC3). %new

			      	                     
%lastPossibleChord(PC1) :- possibleChord(PC1),
%		          not possibleChord(PC2), possibleChordDomain(PC2)
%			      			, PC1 < PC2. %changed
intermediate_3(PC1, PC2) :- possibleChord(PC1), possibleChordDomain(PC2), PC1 < PC2. %new
lastPossibleChord(PC1) :- possibleChord(PC1), possibleChordDomain(PC2),
    not possibleChord(PC2), not intermediate_3(PC1, PC2). %new


%% The first note of each beat is in the possible chord
nodeInPossibleChord(F,BLL+1,ND,PC) :- fareyTree(F), present(F,BLL,PC), meterLeafLevel(F,BLL),
				      possibleChord(PC),
				      descendant(F,0,BLL,PC,BLL+1,ND), hackChords(1). %changed

nodeInPossibleChord(F,FL+1,ND2,PC) :- fareyTree(F), present(F,FL,ND1), durationLevel(F,FL), 
				      possibleChord(PC),
				      nodeInPossibleChord(F,FL,ND1,PC),
				      descendant(F,0,FL,ND1,FL+1,ND2), hackChords(1). %changed

%% Notes are in a chord if they correspond
noteInPossibleChord(P,T,PC) :- part(P), fareyTree(F), timeToNode(P,T,ND), partToFareyTree(P,F),
			       nodeInPossibleChord(F,DLL,ND,PC), possibleChord(PC),
			       durationLeafLevel(F,DLL), hackChords(1). %changed



% Move to the relevant task
% #hide.
rhythm(B) :- rhythm(B).
#show rhythm/1.
% Show fareyTree(F)
%fareyTree(F) :- fareyTree(F).
#show fareyTree/1.
% Show depth(F,D)
depth(F,D) :- depth(F,D).
#show depth/2.
% Show maxExpansion(F,E)
maxExpansion(F,E) :- maxExpansion(F,E).
#show maxExpansion/2.
% Show present(F,FL,ND)
present(F,FL,ND) :- present(F,FL,ND).
#show present/3.
% Show expand(F,FL,ND,E)
expand(F,FL,ND,E) :- expand(F,FL,ND,E).
#show expand/4.

% Show partToFareyTree(P,F)
partToFareyTree(P,F) :- partToFareyTree(P,F).
#show partToFareyTree/2.
% Show timeToNode(P,T,ND)
timeToNode(P,T,ND) :- timeToNode(P,T,ND).
#show timeToNode/3.

% Show measureLimit(ML)
measureLimit(ML) :- measureLimit(ML).
#show measureLimit/1.
% Show durationLevel(F,L)
durationLevel(F,L) :- durationLevel(F,L).
#show durationLevel/2.
% Show durationLeafLevel(F,L)
durationLeafLevel(F,L) :- durationLeafLevel(F,L).
#show durationLeafLevel/2.
% Show meterLevel(F,L)
meterLevel(F,L) :- meterLevel(F,L).
#show meterLevel/2.
% Show meterLeafLevel(F,L)
meterLeafLevel(F,L) :- meterLeafLevel(F,L).
#show meterLeafLevel/2.
% Show measureLevel(F,L)
measureLevel(F,L) :- measureLevel(F,L).
#show measureLevel/2.
% Show measureLeafLevel(F,L)
measureLeafLevel(F,L) :- measureLeafLevel(F,L).
#show measureLeafLevel/2.

% Show meterStrengthMax(F,BS)
meterStrengthMax(F,BS) :- meterStrengthMax(F,BS).
#show meterStrengthMax/2.
% Show meterStrength(F,BS)
meterStrength(F,BS) :- meterStrength(F,BS).
#show meterStrength/2.
% Show nodeMeterStrength(F,FL,ND,BS)
nodeMeterStrength(F,FL,ND,BS) :- nodeMeterStrength(F,FL,ND,BS).
#show nodeMeterStrength/4.

% Show durationStepMax(F,DS)
durationStepMax(F,DS) :- durationStepMax(F,DS).
#show durationStepMax/2.
% Show durationStep(F,DS)
durationStep(F,DS) :- durationStep(F,DS).
#show durationStep/2.
% Show nodeDurationStep(F,FL,ND,DS)
nodeDurationStep(F,FL,ND,DS) :- nodeDurationStep(F,FL,ND,DS).
#show nodeDurationStep/4.

% Show nodeOverlap(F1,ND1,F2,ND2)
nodeOverlap(F1,ND1,F2,ND2) :- nodeOverlap(F1,ND1,F2,ND2).
#show nodeOverlap/4.
% Show noteOverlap(P1,T1,P2,T2)
noteOverlap(P1,T1,P2,T2) :- noteOverlap(P1,T1,P2,T2).
#show noteOverlap/4.

% Show treeTimeSignature(F,TS)
treeTimeSignature(F,TS) :- treeTimeSignature(F,TS).
#show treeTimeSignature/2.
% Show meterDepthConfig(F,TS)
meterDepthConfig(F,TS) :- meterDepthConfig(F,TS).
#show meterDepthConfig/2.
% Show measureDepth(D)
measureDepth(D) :- measureDepth(D).
#show measureDepth/1.

% Show possibleChord(ND)
possibleChord(ND) :- possibleChord(ND).
#show possibleChord/1.
% Show noteInPossibleChord(P,T,PC)
noteInPossibleChord(P,T,PC) :- noteInPossibleChord(P,T,PC).
#show noteInPossibleChord/3.


