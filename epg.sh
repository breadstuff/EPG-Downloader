#!/bin/bash
# epg.sh, by exzessiv@onlinehome.de
#
# this script: 
# 				1. Grab EPG from URL (XML or GZ).
#				2. Grab EPG from Webgrab+ (external program).
#				3. Combines the data
#				4. Brings it to your TVHEADEND (optional).
# 
# requirements: Webgrab++
#
#
# command line: ./epg.sh
#				
# todo
# 


LOG="epg.log"

#read -n1 -r -p "Press any key to continue..." key

if [ ! -f "$LOG" ]; then touch "$LOG"; fi

#read -n1 -r -p "Press any key to continue..." key

echo "EPG start" | tee -a "$LOG"
/bin/date | tee -a  "$LOG"

#read -n1 -r -p "Press any key to continue..." key

# epg-download from Webgrab++ (additional Channels)
~/.wg++/run.sh
cp ~/.wg++/guide.xml ~/

#read -n1 -r -p "Press any key to continue..." key

cat guide.xml | socat - UNIX-CONNECT:/home/hts/.hts/tvheadend/epggrab/xmltv.sock

# epg-download from http://epg.geniptv.com/epg/epg.xml.gz
rm epg.xml.gz
wget 'http://epg.geniptv.com/epg/epg.xml.gz'
rm epg.xml
gzip -d epg.xml.gz

#stop TVH
echo TVH stoppen
service tvheadend stop

echo 1 > /proc/sys/vm/swappiness

#read -n1 -r -p "Press any key to continue..." key

i=$(date +'%Y%m%d%H%M' -d "+7 days")
echo $i

#read -n1 -r -p "Press any key to continue..." key

cat epg.xml | tv_grep --on-after now --on-before $i > epgg.xml
#cat guide.xml | tv_grep --on-after now --on-before 201711290000 > guideg.xml

#start TVH
#service tvheadend start
#sleep 180
# combine the epg-data
#cat epgg.xml guideg.xml > epgc.xml

#read -n1 -r -p "Press any key to continue..." key

echo TVH starten
service tvheadend start

#Warten bis xmltv.sock wieder da.
ss -x -a | grep "/home/hts/.hts/tvheadend/epggrab/xmltv.sock" >/dev/null
i=$?

while [ $i -eq 1 ]
        do
        ss -x -a | grep "/home/hts/.hts/tvheadend/epggrab/xmltv.sock" >/dev/null
        i=$?
        echo status xmltv.sock - socket not available!
        sleep 10
done
        echo status xmltv.sock - socket available!



# write data to xmltv-socket of tvheadend
#cat guide.xml | socat - UNIX-CONNECT:/home/hts/.hts/tvheadend/epggrab/xmltv.sock
#sleep 120
cat epgg.xml | socat - UNIX-CONNECT:/home/hts/.hts/tvheadend/epggrab/xmltv.sock
#echo "EPG stop" | tee -a "$LOG"

/bin/date | tee -a  "$LOG"
