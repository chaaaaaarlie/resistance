#! /bin/bash


# Common variables
USER_AGENT="Mozilla/5.0 (Linux; Android 6.0.1; SM-G920V Build/MMB29K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.85 Mobile Safari/537.36"
URL=https://gop.com/president-trump-first-50-survey/
REF_URL=https://gop.com/president-trump-first-50-survey/
WORDS_FILE=/usr/share/dict/words
NAMES_FILE=/usr/share/dict/propernames
COOKIES=$PWD/cookies.txt
CURL_BIN="curl -s -c $COOKIES -b $COOKIES -e $REF_URL"

until [ 'trump' = 'jailed' ]; do

	#make a .txt file for the cookie data
    touch $COOKIES

    echo -n "get csrftoken ..."
	echo
	$CURL_BIN $URL > /dev/null
	XSRF_TOKEN="$(grep csrftoken $COOKIES | sed 's/^.*csrftoken[[:space:]]\s*//')"

	echo -n "token obtained:"$XSRF_TOKEN
	echo

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

	#answer all questions randomly, skip last two
	QBODY=""
	QNUM=3500
	for i in `seq 1 24`; 
	do	
		RSEED=`od   -An -N4 -tu1 < /dev/urandom | sed 's/ //g'`
	
		case `expr $RSEED % 3` in
			0)
				RESPONSE="Approve"
				;;
			1)	
				RESPONSE="Disapprove"
				;;
			2)
				RESPONSE="No opinion"
				;;
		esac
		
		#increment question number
		QNUM=$[$QNUM+1]
		QBODY="$QBODY -F 'id_question_0_"$QNUM"=$RESPONSE'"

	done

	# Create curl call

	CMD="curl -s -c $COOKIES -b $COOKIES -e -A '$USER_AGENT' -F 'id_full_name=$NAME $WORD_UPPER' -F 'id_email=$EMAIL' -F  'id_postal_code=$ZIP' $QBODY -F 'csrfmiddlewaretoken=$XSRF_TOKEN' --referer $REF_URL $URL"

	# Uncomment to test output
	echo $CMD

	# Fire Away
	eval $CMD
	
	#Clean Up!
	echo "finish session"
	rm $COOKIES
done
