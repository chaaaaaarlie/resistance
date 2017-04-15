#! /bin/bash

#Generates Randomized Responses to Trump's Election Day "Exit Poll"

# Common variables
URL=https://forms.whitehouse.gov/webform/suggestions-executive-branch-reorg
REF_URL=https://www.whitehouse.gov/reorganizing-the-executive-branch

FIRSTNAMES_FILE=first.txt
LASTNAMES_FILE=last.txt
PLACES_FILE=US.txt
USER_AGENTS_FILE=useragent.txt
COOKIES=./cookies.txt

# Get # of lines in word/name files
FIRSTNAMES_COUNT=`wc -l $FIRSTNAMES_FILE | awk '{print $1}'`
LASTNAMES_COUNT=`wc -l $LASTNAMES_FILE | awk '{print $1}'`
PLACES_COUNT=`wc -l $PLACES_FILE | awk '{print $1}'`
USER_AGENTS_COUNT=`wc -l $USER_AGENTS_FILE | awk '{print $1}'`

CURL_BIN="curl -s -c $COOKIES -b $COOKIES -e $REF_URL"

SUBNUM=0 #tracks the number of submissions

#until [ 'trump' = 'jailed' ]; do

	COUNT=0
	BOOL=0
	QBODY=""
	CITY=""
	STATE=""
	

	echo
	echo "Starting new session..."
	echo

	#make a .txt file for the cookie data
    touch $COOKIES

    #echo -n "Getting CSRF token..."
	#echo

	#$CURL_BIN $URL > /dev/null
	#wait ${!}

	XSRF_TOKEN="$(grep csrftoken $COOKIES | sed 's/^.*csrftoken[[:space:]]\s*//')"
	echo -n "Token obtained:"$XSRF_TOKEN
	echo

    echo `date`
    echo

	#Generate 32-bit random integer
	RANDO=`od   -An -N4 -tu1 < /dev/urandom | sed 's/ //g'` 
	
	#Generate a randomized user_agent
	#WK_VER=`expr $RANDOM % 3`.`expr $RANDOM % 5`.`expr $RANDOM % 10`
	#USER_AGENT="Mozilla/5.0 (iPhone; CPU iPhone OS 10_2_1 like Mac OS X) AppleWebKit/60"$WK_VER" (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/60"$WK_VER

	USER_AGENT_LN=`expr $RANDO % $USER_AGENTS_COUNT`
	echo $USER_AGENT_LN
	USER_AGENT=$( sed -n -e "$USER_AGENT_LN p" $USER_AGENTS_FILE)
 	echo $USER_AGENT


	#Select random line in word/name files
	FIRSTNAME_LN=`expr $RANDO % $FIRSTNAMES_COUNT`
	LASTNAME_LN=`expr $RANDO % $LASTNAMES_COUNT`
	

	#Spit out random first and last name
	FIRSTNAME=$( sed -n -e "$FIRSTNAME_LN p" $FIRSTNAMES_FILE)
	LASTNAME=$( sed -n -e "$LASTNAME_LN p" $LASTNAMES_FILE)
	
	FIRSTNAME=`echo $FIRSTNAME | awk '{print(toupper(substr($1,1,1)))substr($1,2,length($1) - 1)}'`
	LASTNAME=`echo $LASTNAME | awk '{print(toupper(substr($1,1,1)))substr($1,2,length($1) - 1)}'`

	EMAIL=`echo $FIRSTNAME.$LASTNAME@gmail.com`
	
	echo "Generated User Info:"
	echo "FULL NAME: "$FIRSTNAME $LASTNAME
	echo "EMAIL: " $EMAIL
	echo

	#question 1
	COUNT=0
	CHOICES=0
	while [ $COUNT -lt 148 ]; do
		BOOL=$((RANDOM%9999))
		if [ $BOOL -lt 100 ]
		then
			QBODY="$QBODY -F 'submitted[cabinet_agencies][]=$COUNT'"
			CHOICES=$[$CHOICES+1]
		fi
		COUNT=$[$COUNT+1]
	done
	if [ $CHOICES -eq 0 ]
		then
		QBODY="$QBODY -F 'submitted[cabinet_agencies][]=0'"
	fi

	#question 2
	COUNT=0
	CHOICES=0
	while [ $COUNT -lt 148 ]; do
		BOOL=$((RANDOM%9999))
		if [ $BOOL -lt 100 ]
		then
			QBODY="$QBODY -F 'submitted[select_other_agencies_boards_and_commissions_select_as_many_as_applicable][]=$COUNT'"
		fi
		COUNT=$[$COUNT+1]
	done
	if [ $CHOICES -eq 0 ]
		then
		QBODY="$QBODY -F 'submitted[select_other_agencies_boards_and_commissions_select_as_many_as_applicable][]=0'"
	fi

	#comments
	QBODY="$QBODY -F 'submitted[reform_comments]='"

	#question 3
	COUNT=0
	CHOICES=0
	while [ $COUNT -lt 148 ]; do
		BOOL=$((RANDOM%9999))
		if [ $BOOL -lt 100 ]
		then
			QBODY="$QBODY -F 'submitted[select_agencies_or_programs][]=$COUNT'"
		fi
		COUNT=$[$COUNT+1]
	done
	if [ $CHOICES -eq 0 ]
		then
		QBODY="$QBODY -F 'submitted[select_agencies_or_programs][]=0'"
	fi

	#question 4
	COUNT=0
	CHOICES=0
	while [ $COUNT -lt 148 ]; do
		BOOL=$((RANDOM%9999))
		if [ $BOOL -lt 100 ]
		then
			QBODY="$QBODY -F 'submitted[select_other_agencies_boards_and_commissions_select_as_many_as_applicable_b][]=$COUNT'"
		fi
		COUNT=$[$COUNT+1]
	done
	if [ $CHOICES -eq 0 ]
		then
		QBODY="$QBODY -F 'submitted[select_other_agencies_boards_and_commissions_select_as_many_as_applicable_b][]=0'"
	fi
	
	#comments
	QBODY="$QBODY -F 'submitted[list_specific_programs]='"

	#question 5
	RAND=$((RANDOM%6))
	QBODY="$QBODY -F 'submitted[select_why][select]=$RAND'"
	if [ $RAND -eq 5 ]
		then
		QBODY="$QBODY -F 'submitted[select_why][other]='"
	fi

	#contact information
	QBODY="$QBODY -F 'submitted[first_name]=$FIRST_NAME'"
	QBODY="$QBODY -F 'submitted[last_name]=$LAST_NAME'"
	QBODY="$QBODY -F 'submitted[email_address]=$EMAIL'"
	QBODY="$QBODY -F 'submitted[city]=$CITY'"
	QBODY="$QBODY -F 'submitted[state]=$STATE'"
	QBODY="$QBODY -F 'submitted[country]=United States'"
	#hidden data fields
	QBODY="$QBODY -F 'details[sid]='"
	QBODY="$QBODY -F 'details[page_num]=1'"
	QBODY="$QBODY -F 'details[page_count=1'"
	QBODY="$QBODY -F 'details[finished]=0'"
	QBODY="$QBODY -F 'form_build_id=form-V2W1naBNwza1JNNoMgRvaOItAeIJuhSb6q9E2qeroXU'"
	QBODY="$QBODY -F 'form_id=webform_client_form_301'"
	QBODY="$QBODY -F 'op=Submit'"

	# Create curl call

	CMD="curl -S -c $COOKIES -b $COOKIES -A '$USER_AGENT' $QBODY -F 'csrfmiddlewaretoken=$XSRF_TOKEN' -e $REF_URL $URL"

	# Uncomment to test output
	echo $CMD
	echo

	# Fire Away
	#eval $CMD
	#wait ${!}
	
	#Clean Up!
	echo "Deleting cookies..."
	echo
	#rm $COOKIES

	#wait for a bit before doing it again
	echo "Cooling off for 10-20 seconds..."
	echo
	#sleep `expr $RANDOM % 10 + 10`

	SUBNUM=$[$SUBNUM+1]

	echo "Session "$SUBNUM" finished!"
	echo
#done