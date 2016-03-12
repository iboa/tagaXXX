
TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

let i=255

while [ $i -gt 0 ]
do
   NETADDR=$NETADDRPART.$i
   echo
   echo processing $NETADDR
   
   ping -W 1 -c 1 $NETADDR
  
   if [ $? -eq 0 ]; then
      echo $NETADDR >> /tmp/probe2Found.out
   else
      echo $NETADDR >> /tmp/probe2Notfound.out
   fi

   let i=$i-1

done

echo




