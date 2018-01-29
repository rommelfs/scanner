#!/bin/bash

# Import configuration
. scan.conf


# In case GNU parallel is supposed to be used, to the following:
# Create a "targets" file, format: [IP] [EMAIL] [NMAP OPTIONS]
# On command line, do: cat targets | parallel -r {}

# For use with a targets file
if [[ "$1" == "-r" ]]
then
        args=($2)
        TARGET=${args[0]}
        EMAIL=${args[1]}
        NMAP_OPTIONS=${args[@]:2:99}
else
# For use with command line arguments
        TARGET="$1"
        EMAIL="$2"
        shift; shift
        NMAP_OPTIONS="$@"
fi

INITIAL=false

# Check if we have custom Nmap options
if [ -z "$NMAP_OPTIONS" ]
then
        NMAP_OPTIONS="$NMAP_DEFAULT_OPTIONS"
fi

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
	echo "$EMAIL doesn't seem to be a valid email address."
	exit 1
fi

mkdir -p "$BASEDIR/scans/$TARGET/$DIR_NEW"
mkdir -p "$BASEDIR/scans/$TARGET/$DIR_OLD"
mkdir -p "$BASEDIR/scans/$TARGET/$DIR_ARCHIVE"
FILENAME_NEW=$BASEDIR/scans/$TARGET/$DIR_NEW/result.txt
FILENAME_OLD=$BASEDIR/scans/$TARGET/$DIR_OLD/result.txt
FILENAME_DIFF=$FILENAME_NEW.diff
DIRECTORY_ARCHIVE=$BASEDIR/scans/$TARGET/$DIR_ARCHIVE

# Check if we ran this before
if [ -e $FILENAME_NEW ]
then
        if [ -e $FILENAME_OLD ]
        then
                mv $FILENAME_OLD $DIRECTORY_ARCHIVE/scan-`date "+%Y%m%d-%s"`
        fi
        mv $FILENAME_NEW $FILENAME_OLD
else
        INITIAL=true
fi

# perform scan
if [ $INITIAL == true  ]
then
	$NMAP_BIN $NMAP_OPTIONS $TARGET -oX $FILENAME_NEW -oN $FILENAME_NEW.txt
        #cat $FILENAME_NEW.txt | mail -s "$EMAIL_SUBJECT_PREFIX $EMAIL_SUBJECT_INITIAL $TARGET" $EMAIL
        printf "$EMAIL_HEADER_INITIAL\n$EMAIL_BODY_INITIAL $TARGET:\n`cat $FILENAME_NEW.txt|sed -e 's/Nmap scan/Scan/'| grep -v 'scan initiated' | grep -v 'Starting Nmap'|grep -v 'Nmap done'`\n\n$EMAIL_FOOTER_INITIAL\n$EMAIL_INFO" | \
                mail -s "$EMAIL_SUBJECT_PREFIX $EMAIL_SUBJECT_INITIAL $TARGET" $EMAIL
        logger "Sent mail to $EMAIL: Initial network scan for $TARGET. See file $FILENAME_NEW for details"
	rm $FILENAME_NEW.txt
        exit 0
else
	$NMAP_BIN $NMAP_OPTIONS $TARGET -oX $FILENAME_NEW
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
                FILENAME_DIFF_ARCHIVE=$DIRECTORY_ARCHIVE/diff-`date "+%Y%m%d-%s"`
                mv $FILENAME_DIFF $FILENAME_DIFF_ARCHIVE
                logger "Sent mail to $EMAIL: network change detected for $TARGET. See file $FILENAME_DIFF_ARCHIVE for details"
        else
                logger "No change detected for target $TARGET"
        fi
fi
exit 0
