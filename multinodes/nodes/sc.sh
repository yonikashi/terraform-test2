#!/bin/bash

echo -n "\"{" >> allnodes.txt
for (( c=1; c<$1; c++ ))
do
stellar-core --genseed | sed -e 's/^Public: //' | sed -e 's/^Secret seed: //' >> core-test-$c
echo -n "'core-test-$c': " >> allnodes.txt

echo -n "'$(cat core-test-$c | sed '2!d')'" >> allnodes.txt
echo -n ", " >> allnodes.txt
#rm core-test-$c
seed=$(cat core-test-$c | sed '1!d')
sed '/^export[[:blank:]]*self_node_name=/ s/$/'"\"core-test-$c\""'/' .setup-env.sh.TMPL >> setup.$c
sed '/^export[[:blank:]]*self_node_seed=/ s/$/'"\"$seed\""'/' setup.$c >> setup-env-a.$c
rm setup.$c
done
stellar-core --genseed | sed -e 's/^Public: //' | sed -e 's/^Secret seed: //' >> core-test-$1
echo -n "'core-test-$1': " >> allnodes.txt
echo -n "'$(cat core-test-$1 | sed '2!d')'" >> allnodes.txt
#rm core-test-$1
echo -n "}\"" >> allnodes.txt

seed=$(cat core-test-$1 | sed '1!d')
sed '/^export[[:blank:]]*self_node_name=/ s/$/'"\"core-test-$1\""'/' .setup-env.sh.TMPL >> setup.$1
sed '/^export[[:blank:]]*self_node_seed=/ s/$/'"\"$seed\""'/' setup.$1 >> setup-env-a.$1
rm setup.$1
##########################################
allnodes=$(cat allnodes.txt)
for (( c=1; c<=$1; c++ ))
do
sed '/^export[[:blank:]]*all_nodes=/ s/$/'"$allnodes"'/'  setup-env-a.$c >> setup-env.$c
rm setup-env-a.$c
rm core-test-$c
done
rm allnodes.txt
