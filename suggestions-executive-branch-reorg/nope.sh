#! /bin/bash

#Generates "no change" response to the Whitehouse Suggestions for Reorganizing the Executinve Branch survey

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

until [ 'trump' = 'jailed' ]; do

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

	#$CURL_BIN $URL > temp.html
	#wait ${!}

	#XSRF_TOKEN="$(grep csrftoken $COOKIES | sed 's/^.*csrftoken[[:space:]]\s*//')"

	#extract a form id from the temp.html file produced by the curl call above
	#MATCH=name\=\"form_build_id\"' 'value\=\"form\-
	#FORM_ID=$(grep "$MATCH" temp.html | sed s/^.*"$MATCH"// | cut -f1 -d\")

	#randomly generate a form id
	FORM_ID=`env LC_CTYPE=C tr -dc "a-zA-Z0-9\-\_" < /dev/urandom | head -c 43`

	#echo -n "Token obtained:"$XSRF_TOKEN
	#echo

    echo "The date: "`date`
    echo

	#Generate 32-bit random integer
	RANDO=`od   -An -N4 -tu1 < /dev/urandom | sed 's/ //g'` 
	
	#Generate a randomized user_agent
	#WK_VER=`expr $RANDOM % 3`.`expr $RANDOM % 5`.`expr $RANDOM % 10`
	#USER_AGENT="Mozilla/5.0 (iPhone; CPU iPhone OS 10_2_1 like Mac OS X) AppleWebKit/60"$WK_VER" (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/60"$WK_VER

	USER_AGENT_LN=`expr $RANDO % $USER_AGENTS_COUNT`
	USER_AGENT=$(sed -n -e "$USER_AGENT_LN p" $USER_AGENTS_FILE)
 	

 	PLACE_LN=`expr $RANDO % $PLACES_COUNT`
 	CITY=`awk "NR == $PLACE_LN {print; exit}" $PLACES_FILE | cut -d "	" -f 3`
 	STATE=`awk "NR == $PLACE_LN {print; exit}" $PLACES_FILE | cut -d "	" -f 4`

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
	echo "EMAIL: "$EMAIL
	echo "CITY: "$CITY
	echo "STATE: "$STATE
	echo "USER AGENT: "$USER_AGENT
	echo

	#question 1
	QBODY="$QBODY -F 'submitted[cabinet_agencies][]=0'"
	QBODY="$QBODY -F 'submitted[select_other_agencies_boards_and_commissions_select_as_many_as_applicable][]=0'"
	#comments
	QBODY="$QBODY -F 'submitted[reform_comments]='"
	QBODY="$QBODY -F 'submitted[select_agencies_or_programs][]=0'"
	QBODY="$QBODY -F 'submitted[select_other_agencies_boards_and_commissions_select_as_many_as_applicable_b][]=0'"
	QBODY="$QBODY -F 'submitted[list_specific_programs]='"
	QBODY="$QBODY -F 'submitted[select_why][select]=0'"

	#contact information
	QBODY="$QBODY -F 'submitted[first_name]=$FIRSTNAME'"
	QBODY="$QBODY -F 'submitted[last_name]=$LASTNAME'"
	QBODY="$QBODY -F 'submitted[email_address]=$EMAIL'"
	QBODY="$QBODY -F 'submitted[city]=$CITY'"
	QBODY="$QBODY -F 'submitted[state]=$STATE'"
	QBODY="$QBODY -F 'submitted[country]=United States'"
	#hidden data fields
	QBODY="$QBODY -F 'details[sid]='"
	QBODY="$QBODY -F 'details[page_num]=1'"
	QBODY="$QBODY -F 'details[page_count=1'"
	QBODY="$QBODY -F 'details[finished]=0'"
	QBODY="$QBODY -F 'form_build_id=form-$FORM_ID'"
	QBODY="$QBODY -F 'form_id=webform_client_form_301'"
	QBODY="$QBODY -F 'op=Submit'"

	# Create curl call

	CMD="curl -S -c $COOKIES -b $COOKIES -A '$USER_AGENT' $QBODY -e $REF_URL $URL"
	#CMD="curl -S -c $COOKIES -b $COOKIES -A '$USER_AGENT' $QBODY -F 'csrfmiddlewaretoken=$XSRF_TOKEN' -e $REF_URL $URL"

	# Uncomment to test output
	echo $CMD
	echo

	# Fire Away
	eval $CMD
	wait ${!}
	
	#Clean Up!
	echo "Deleting cookies..."
	rm $COOKIES
	#echo "Deleting site data..."
	#rm ./temp.html

	#wait for a bit before doing it again
	#echo "Cooling off for 10-20 seconds..."

	#sleep `expr $RANDOM % 10 + 10`

	SUBNUM=$[$SUBNUM+1]

	echo "Session "$SUBNUM" finished!"

done