#! /bin/bash


# Common variables
URL=https://gop.com/survey/mainstream-media-accountability-survey/
REF_URL=https://gop.com/mainstream-media-accountability-survey/


WORDS_FILE=/usr/share/dict/words
NAMES_FILE=/usr/share/dict/propernames
USER_AGENT_FILE=useragent.txt

export LC_CTYPE=C

until [ 'trump' = 'jailed' ]; do

    XSRF_TOKEN="p0pnUPqgfPXkNTXuOmztQLArp4POf4dG"
    #XSRF_TOKEN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    echo `date`
	#Generate 32-bit random integer
	RANDO=`od   -An -N4 -tu1 < /dev/urandom | sed 's/ //g'` 
	
	# Get # of lines in word/name files
	NAMES_COUNT=`wc -l $NAMES_FILE | awk '{print $1}'`
	WORDS_COUNT=`wc -l $WORDS_FILE | awk '{print $1}'`
	UA_COUNT=`wc -l $USER_AGENT_FILE | awk '{print $1}'`
	#Select random line in word/name files
	NAME_LN=`expr $RANDO % $NAMES_COUNT`
	WORD_LN=`expr $RANDO % $WORDS_COUNT`
	UA_LN=`expr $RANDO % $UA_COUNT`

	#Spit out random name and word; capitalize word
	NAME=`sed -n "$NAME_LN"p $NAMES_FILE`
	WORD=`sed -n "$WORD_LN"p $WORDS_FILE`
	USER_AGENT=`sed -n "$UA_LN"p $USER_AGENT_FILE`

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