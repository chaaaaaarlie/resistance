#! /bin/bash

#Generates Randomized Responses to Trump's Election Day "Exit Poll"

# Common variables
URL=https://www.gop.com/election-day-exit-poll/
REF_URL=https://www.gop.com/election-day-exit-poll/ #https://www.gop.com/get-involved/?selected_tab=surveys
WORDS_FILE=/usr/share/dict/words
NAMES_FILE=/usr/share/dict/propernames

COOKIES=./cookies.txt

CURL_BIN="curl -s -c $COOKIES -b $COOKIES -e $REF_URL"

SUBNUM=0 #tracks the number of submissions

until [ 'trump' = 'jailed' ]; do
	QNUM=3250
	COUNT=0
	BOOL=0
	QBODY=""
	RESPONSE_NUM=0

	echo
	echo "Starting new session..."
	echo

	#make a .txt file for the cookie data
    touch $COOKIES

    echo -n "Getting CSRF token..."
	echo

	$CURL_BIN $URL > /dev/null
	wait ${!}

	XSRF_TOKEN="$(grep csrftoken $COOKIES | sed 's/^.*csrftoken[[:space:]]\s*//')"
	echo -n "Token obtained:"$XSRF_TOKEN
	echo

    echo `date`
    echo

	#Generate 32-bit random integer
	RANDO=`od   -An -N4 -tu1 < /dev/urandom | sed 's/ //g'` 
	
	#Generate a randomized user_agent
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

	echo "Generated User Info:"
	echo "FULL NAME: "$NAME $WORD_UPPER
	echo "EMAIL: " $EMAIL
	echo "ZIP: " $ZIP
	echo

	#answer all questions randomly

	until [ $COUNT = 10 ]; do	
		RSEED=`od   -An -N4 -tu1 < /dev/urandom | sed 's/ //g'`

		if [ $QNUM = 3250 ]
		then
			case $((RANDOM%2)) in
				0)
					RESPONSE="Yes"
					RESPONSE_NUM=0
					;;
				1)	
					RESPONSE="No"
					RESPONSE_NUM=1
					;;
			esac
		fi

		if [ $QNUM = 3251 ]
		then
			case $((RANDOM%2)) in
				0)
					RESPONSE="Donald J. Trump"
					RESPONSE_NUM=0
					;;
				1)	
					RESPONSE="Hillary Clinton"
					RESPONSE_NUM=1
					;;
			esac
		fi


		if [ $QNUM = 3252 ]
		then
			BOOL=$((RANDOM%2))
			if [ $BOOL = 1 ]
			then
				case $COUNT in
					0)
						RESPONSE="Radical islamic terrorism"
						RESPONSE_NUM=$COUNT
						;;
					1)	
						RESPONSE="The Supreme Court"
						RESPONSE_NUM=$COUNT
						;;
					2)	
						RESPONSE="Economy/jobs"
						RESPONSE_NUM=$COUNT
						;;
					3)	
						RESPONSE="Trade"
						RESPONSE_NUM=$COUNT
						;;
					4)	
						RESPONSE="Sanctity of life"
						RESPONSE_NUM=$COUNT
						;;
					5)	
						RESPONSE="ObamaCare"
						RESPONSE_NUM=$COUNT
						;;
					6)	
						RESPONSE="Religious liberties"
						RESPONSE_NUM=$COUNT
						;;
					7)	
						RESPONSE="Veteran care"
						RESPONSE_NUM=$COUNT
						;;
					8)	
						RESPONSE="Taxes"
						RESPONSE_NUM=$COUNT
						;;
					9)	
						RESPONSE="Debt"
						RESPONSE_NUM=$COUNT
						;;
				esac
			fi
			COUNT=$[$COUNT+1]
		fi

		#pack it into the curl data
		if [ $BOOL = 1 ] || [ $QNUM -lt 3252 ]
		then
		QBODY="$QBODY -F 'id_question_"$QNUM"_"$RESPONSE_NUM"=$RESPONSE'"
		fi

		#increment question number when appropriate
		if [ $QNUM -lt 3252 ]
		then
			QNUM=$[$QNUM+1]
		fi

	done
	# Create curl call

	CMD="curl -S -c $COOKIES -b $COOKIES -A '$USER_AGENT' -F 'id_full_name=$NAME $WORD_UPPER' -F 'id_email=$EMAIL' -F  'id_postal_code=$ZIP' $QBODY -F 'csrfmiddlewaretoken=$XSRF_TOKEN' -e $REF_URL $URL"

	# Uncomment to test output
	echo $CMD
	echo

	# Fire Away
	eval $CMD
	wait ${!}
	
	#Clean Up!
	echo "Deleting cookies..."
	echo
	rm $COOKIES

	#wait for a bit before doing it again
	echo "Cooling off for 10-20 seconds..."
	echo
	sleep `expr $RANDOM % 10 + 10`

	SUBNUM=$[$SUBNUM+1]

	echo "Session "$SUBNUM" finished!"
	echo
done