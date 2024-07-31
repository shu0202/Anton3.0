#!/bin/sh

# Martin Brain
# mjb@cs.bath.ac.uk
# 26/03/07
#
# An automated test script that makes sure that all of the good and valid examples
# can still be generated and that none of the bad examples can be generated.

# Set up the solver and parser strings
if [ "$SOLVER" = "" ]; then
    SOLVER="/Users/yeungivan/anaconda3/envs/Dissertation/bin/clasp"
fi

if [ "$GROUNDER" = "" ]; then
    GROUNDER="/Users/yeungivan/anaconda3/envs/Dissertation/bin/gringo"
fi


test () {
    example=$1
    task=$2

    echo -en "$example\t"
    generated=`./programBuilder.pl --task=$task --piece=$example | $GROUNDER | $SOLVER $N | ./countAnswerSets.pl`


    if [ "$generated" = "1" ]; then
	echo "pass"
    else
	echo "fail"
    fi
}

if [ $# != 0 ]; then
   # Only test the given test
   ex=$1
   bracket=$(basename $(dirname $ex))
   
   # should be good, valid or bad

   if [ "$bracket" = "bad" ]; then
       test $ex "diagnose"
   else
       test $ex "compose"
   fi

else

    # First make sure all of the good examples still work
    for ex in examples/good/* ; do
	test $ex "compose"
    done
    
    # Then the valid ones...
    for ex in examples/valid/* ; do
	test $ex "compose"
    done
    
    # Last check that none of the bad examples are possible
    for ex in examples/bad/* ; do
	test $ex "diagnose"
    done

fi

