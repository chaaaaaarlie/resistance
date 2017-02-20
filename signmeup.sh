#! /bin/bash


# Common variables
USER_AGENT="Mozilla/5.0 (Linux; Android 6.0.1; SM-G920V Build/MMB29K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.85 Mobile Safari/537.36"
URL=https://gop.com/survey/mainstream-media-accountability-survey/
REF_URL=https://gop.com/mainstream-media-accountability-survey/
XSRF_TOKEN=p0pnUPqgfPXkNTXuOmztQLArp4POf4dG

WORDS_FILE=/usr/share/dict/words
NAMES_FILE=/usr/share/dict/propernames

until [ 'trump' = 'jailed' ]; do
    
    echo `date`
	#Generate 32-bit random integer
	RANDO=`od   -An -N4 -tu1 < /dev/urandom | sed 's/ //g'` 
	
	WK_VER=`expr $RANDOM % 3`.`expr $RANDOM % 5`.`expr $RANDOM % 10`

	USER_AGENT="Mozilla/5.0 (iPhone; CPU iPhone OS 10_2_1 like Mac OS X) AppleWebKit/60"$WK_VER" (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/60"$WK_VER
	# Get # of lines in word/name files
	NAMES_COUNT=`wc -l $NAMES_FILE | awk '{print $1}'`
	WORDS_COUNT=`wc -l $WORDS_FILE | awk '{print $1}'`

	#Select random line in word/name files
	NAME_LN=`expr $RANDO % $NAMES_COUNT`
	WORD_LN=`expr $RANDO % $WORDS_COUNT`

	#Spit out random name and word; capitalize word
	NAME=`sed -n "$NAME_LN"p $NAMES_FILE`
	WORD=`sed -n "$WORD_LN"p $WORDS_FILE`

	WORD_UPPER=`echo $WORD | awk '{print(toupper(substr($1,1,1)))substr($1,2,length($1) - 1)}'`
	# email = last name ($WORD) + number + gmail.com
	EMAIL=`echo $WORD$NAME_LN@gmail.com`
	ZIP=`awk 'BEGIN{srand();printf("%05d", int(rand()*99998 )+ 1) }'`

	#Randomly answer 8 questions from survey with random answers
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
		# generate random question ID between 388-411 
		QNUM=`awk -v seed=$RSEED 'BEGIN{srand(seed);print int(rand()*23 + 388) }'`
		QBODY="$QBODY -F 'question_"$QNUM"_1=$RESPONSE'"

	done

	# Create curl call
	CMD="curl -A '$USER_AGENT' -F 'full_name=$NAME $WORD_UPPER' -F 'email=$EMAIL' -F  'postal_code=$ZIP' $QBODY -F 'csrfmiddlewaretoken=$XSRF_TOKEN' --referer $REF_URL $URL"

	# Uncomment to test output
	echo $CMD

	# Fire away
	eval $CMD
done