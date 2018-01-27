#!/bin/bash

# Import configuration
. scan.conf

TARGET="$1"
EMAIL="$2"
INITIAL=false



# Check if the IP address is correct and containing a netmask
echo $TARGET | egrep '^[0-9]{1,3}(\.[0-9]{1,3}){3}\/[0-9]{1,2}$'
if [ $? -gt 0 ]
then
	echo "$TARGET is not a valid IP address including a netmask (like 127.0.0.1/32)."
	exit 1
fi

# Check if the email is given
echo $EMAIL | egrep '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}'
if [ $? -gt 0 ]
then
	echo "$EMAIL is not a valid email address."
	exit 1
fi

mkdir -p $BASEDIR/scans/$TARGET/{new,old,historic}
FILENAME_NEW=$BASEDIR/scans/$TARGET/new/result.txt
FILENAME_OLD=$BASEDIR/scans/$TARGET/old/result.txt
FILENAME_DIFF=$FILENAME_NEW.diff
DIRECTORY_HISTORIC=$BASEDIR/scans/$TARGET/historic

# Check if we ran this before
if [ -e $FILENAME_NEW ]
then
        if [ -e $FILENAME_OLD ]
        then
                mv $FILENAME_OLD $DIRECTORY_HISTORIC/scan-`date "+%Y%m%d-%s"`
        fi
        mv $FILENAME_NEW $FILENAME_OLD
else
        INITIAL=true
fi
# perform scan

if [ $INITIAL == true  ]
then
	nmap --open -n -T4 $TARGET -oX $FILENAME_NEW -oN $FILENAME_NEW.txt
        #cat $FILENAME_NEW.txt | mail -s "$EMAIL_SUBJECT_PREFIX $EMAIL_SUBJECT_INITIAL $TARGET" $EMAIL
        printf "$EMAIL_HEADER_INITIAL\n$EMAIL_BODY_INITIAL $TARGET:\n`cat $FILENAME_NEW.txt|grep -v 'Nmap'`\n\n$EMAIL_FOOTER_INITIAL\n$EMAIL_INFO" | \
                mail -s "$EMAIL_SUBJECT_PREFIX $EMAIL_SUBJECT_INITIAL $TARGET" $EMAIL
        logger "Sent mail to $EMAIL: Initial network scan for $TARGET. See file $FILENAME_NEW for details"
	rm $FILENAME_NEW.txt
        exit 0
else
	nmap --open -n -T4 $TARGET -oX $FILENAME_NEW
fi

# test if we have two files to compare
if [ -e $FILENAME_NEW ] && [ -e $FILENAME_OLD ]
then
        ndiff -v $FILENAME_OLD $FILENAME_NEW > $FILENAME_DIFF
        if [ $? -gt 0 ]
        then
                cat $FILENAME_DIFF | grep PORT -A 999999 > $FILENAME_DIFF.mail
                #mail -s "Network change detected for $TARGET" $EMAIL < $FILENAME_DIFF.mail
                printf "$EMAIL_HEADER_CHANGE\n$EMAIL_BODY_CHANGE $TARGET:\n`cat $FILENAME_DIFF.mail`\n\n$EMAIL_FOOTER_CHANGE\n$EMAIL_INFO" | \
                    mail -s "$EMAIL_SUBJECT_PREFIX $EMAIL_SUBJECT_CHANGE $TARGET" $EMAIL
                rm $FILENAME_DIFF.mail
                FILENAME_DIFF_HISTORIC=$DIRECTORY_HISTORIC/diff-`date "+%Y%m%d-%s"`
                mv $FILENAME_DIFF $FILENAME_DIFF_HISTORIC
                logger "Sent mail to $EMAIL: network change detected for $TARGET. See file $FILENAME_DIFF_HISTORIC for details"
        else
                logger "No change detected for target $TARGET"
        fi
fi
exit 0
