#! /bin/bash

until [ 'trump' = 'jailed' ]; do
	URL=https://gop.com/survey/mainstream-media-accountability-survey/

	WORDS_FILE=/usr/share/dict/words
	NAMES_FILE=/usr/share/dict/propernames

	NAME_RN=`od   -An -N4 -tu1 < /dev/urandom | sed 's/ //g'` 
	WORD_RN=`od   -An -N4 -tu1 < /dev/urandom | sed 's/ //g'` 

	NAMES_COUNT=`wc -l $NAMES_FILE | awk '{print $1}'`
	WORDS_COUNT=`wc -l $WORDS_FILE | awk '{print $1}'`

	NAME_LN=`expr $NAME_RN % $NAMES_COUNT`
	WORD_LN=`expr $WORD_RN % $WORDS_COUNT`

	NAME=`sed -n "$NAME_LN"p /usr/share/dict/propernames`
	WORD=`sed -n "$WORD_LN"p /usr/share/dict/words`

	EMAIL=`echo $WORD$NAME_LN@gmail.com`
	ZIP=`awk 'BEGIN{srand();print int(rand()*(100000-10000) + 10000) }'`

	CMD="curl -F 'full_name=$NAME $WORD' -F 'email=$EMAIL' -F  'postal_code=$ZIP' $URL"

	# Uncomment to test output
	# echo $CMD

	curl -F 'full_name=$NAME $WORD' -F 'email=$EMAIL' -F  'postal_code=$ZIP' $URL
done