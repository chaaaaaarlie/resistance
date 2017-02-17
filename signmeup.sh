#! /bin/bash


# Common variables
USER_AGENT="Mozilla/5.0 (Windows NT 6.1; rv:50.0) Gecko/20100101 Firefox/50.0"
URL=https://gop.com/survey/mainstream-media-accountability-survey/

WORDS_FILE=/usr/share/dict/words
NAMES_FILE=/usr/share/dict/propernames

until [ 'trump' = 'jailed' ]; do
	
	#Generate 32-bit random integer
	RANDO=`od   -An -N4 -tu1 < /dev/urandom | sed 's/ //g'` 

	# Get # of lines in word/name files
	NAMES_COUNT=`wc -l $NAMES_FILE | awk '{print $1}'`
	WORDS_COUNT=`wc -l $WORDS_FILE | awk '{print $1}'`

	#Select random line in word/name files
	NAME_LN=`expr $RANDO % $NAMES_COUNT`
	WORD_LN=`expr $RANDO % $WORDS_COUNT`

	#Spit out random name and word; capitalize word
	NAME=`sed -n "$NAME_LN"p $NAMES_FILE`
	WORD=`sed -n "$WORD_LN"p $WORDS_FILE | awk '{print(toupper(substr($1,1,1)),substr($1,2,length($1) - 1 ))}' | sed 's/ //g'`

	# email = last name ($WORD) + number + gmail.com
	EMAIL=`echo $WORD$NAME_LN@gmail.com`
	ZIP=`awk 'BEGIN{srand();printf("%05d", int(rand()*99998 )+ 1) }'`

	#Randomly answer 8 questions from survey with random answers
	QBODY=""
	for i in `seq 1 8`; 
	do	
		case `expr $RANDO % 3` in
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
		# generate random question ID between 388-411 
		QNUM=`awk -v seed=$RANDO 'BEGIN{srand(seed);print int(rand()*23 + 388) }'`
		QBODY="$QBODY -F 'question_"$QNUM"_1=$RESPONSE'"

	done

	# Create curl call
	CMD="curl -A '$USER_AGENT' -F 'full_name=$NAME $WORD' -F 'email=$EMAIL' -F  'postal_code=$ZIP' $QBODY $URL"

	# Uncomment to test output
	echo $CMD

	# Fire away
	eval $CMD
done