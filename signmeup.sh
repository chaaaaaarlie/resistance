#! /bin/bash

USER_AGENT="Mozilla/5.0 (Windows NT 6.1; rv:50.0) Gecko/20100101 Firefox/50.0"
URL=https://gop.com/survey/mainstream-media-accountability-survey/

WORDS_FILE=/usr/share/dict/words
NAMES_FILE=/usr/share/dict/propernames

until [ 'trump' = 'jailed' ]; do
	

	NAME_RN=`od   -An -N4 -tu1 < /dev/urandom | sed 's/ //g'` 
	WORD_RN=`od   -An -N4 -tu1 < /dev/urandom | sed 's/ //g'` 

	NAMES_COUNT=`wc -l $NAMES_FILE | awk '{print $1}'`
	WORDS_COUNT=`wc -l $WORDS_FILE | awk '{print $1}'`

	NAME_LN=`expr $NAME_RN % $NAMES_COUNT`
	WORD_LN=`expr $WORD_RN % $WORDS_COUNT`

	NAME=`sed -n "$NAME_LN"p /usr/share/dict/propernames`
	WORD=`sed -n "$WORD_LN"p /usr/share/dict/words | awk '{print(toupper(substr($1,1,1)),substr($1,2,length($1) - 1 ))}' | sed 's/ //g'`

	EMAIL=`echo $WORD$NAME_LN@gmail.com`
	ZIP=`awk 'BEGIN{srand();print int(rand()*(100000-10000) + 10000) }'`

	QBODY=""
	for i in `seq 1 8`; 
	do
		RSEED=`od   -An -N4 -tu1 < /dev/urandom | sed 's/ //g'`
		
		case `expr $RSEED % 3` in
			0)
				RESPONSE="Yes"
				;;
			1)	
				RESPONSE="No"
				;;
			2)
				RESPONSE="No opinion"
				;;
		esac
		QNUM=`awk -v seed=$RSEED 'BEGIN{srand(seed);print int(rand()*23 + 388) }'`
		QBODY="$QBODY -F 'question_"$QNUM"_1=$RESPONSE'"

	done

	CMD="curl -A '$USER_AGENT'-F 'full_name=$NAME $WORD' -F 'email=$EMAIL' -F  'postal_code=$ZIP' $QBODY $URL"

	# Uncomment to test output
	echo $CMD

	eval $CMD
done