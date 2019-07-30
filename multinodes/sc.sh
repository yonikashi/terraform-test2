#!/bin/bash -x
NODE1="'core-test-1': 'GCIYX5DXKY5BZMGRWTEZ23G7TIU234LILVWFEEHAPKKPUCH7BVKWZHXA'"
NODE2="'core-test-2': 'GCIYX5DXKY5BZMGRWTEZ23G7TIU234LILVWFEEHAPKKPUCH7BVKWZHXA',\}\""
#sed '/^export all=" /s/=.*$/= your-replacement/' setup-env.sh

#CONFIG_FILE=setup-env.sh
#TARGET_KEY=all
#REPLACEMENT_VALUE=$NODE1


#if grep -q "^[ ^I]*$TARGET_KEY[ ^I]*=.." "$CONFIG_FILE"; then
#   sed -i -e "s^A^\\([ ^I]*$TARGET_KEY[ ^I]*=[ ^I]*\\).*$^A\\1$REPLACEMENT_VALUE^A" "$CONFIG_FILE"
#else
#   echo "$TARGET_KEY = $REPLACEMENT_VALUE" >> "$CONFIG_FILE"
#fi

sed -E 's/^(export[[:blank:]]*all=..).*}/\1\'"$NODE1"'/' setup-env.sh


#echo $NODE1
