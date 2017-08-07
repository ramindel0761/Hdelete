#!/usr/bin/env bash
#Edited by : @Releas_Dev
memTotal_b=free -b |grep Mem |awk '{print $2}'
memFree_b=free -b |grep Mem |awk '{print $4}'
memBuffer_b=free -b |grep Mem |awk '{print $6}'
memCache_b=free -b |grep Mem |awk '{print $7}'
memTotal_m=free -m |grep Mem |awk '{print $2}'
memFree_m=free -m |grep Mem |awk '{print $4}'
memBuffer_m=free -m |grep Mem |awk '{print $6}'
memCache_m=free -m |grep Mem |awk '{print $7}'
CPUPer=top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'
hdd=df -lh | awk '{if ($6 == "/") { print $5 }}' | head -1 | cut -d'%' -f1
uptime=uptime
time=date 
calendar=cal 
ProcessCnt=ps -A | wc -l
memUsed_b=$(($memTotal_b-$memFree_b))
memUsed_m=$(($memTotal_m-$memFree_m))
memUsedPrc=$((($memUsed_b*100)/$memTotal_b))
f=3 b=4
for j in f b; do
  for i in {0..7}; do
    printf -v $j$i %b "\e[${!j}${i}m"
  done
done
bld=$'\e[1m'
rst=$'\e[0m'

echo -e "$f2 STARTING LUANCHING BOT$rst"
echo ""
sleep 1
echo -e "\e[1mOperation : \e[96mStarting Bot\e[0m"
echo -e "\e[1mSource : \e[94m Stour Team Projection Aguest 2017\e[0m"
echo -e "\e[38;5;82mDeveloper : \e[38;5;226mPouya @Releas_Dev\e[0m"
echo -e "\e[1m**********************************\e[0m"
sleep 2
echo -e "\e[1mTime : \e[45m$time\e[0m \e[1"
echo -e "\e[1mCalendar : $calendar\e[0m"
echo -e "\e[1m**********************************"
echo -e "Total Ram :\e[96m $memTotal_m MB \e[296m\e[0m"
sleep 0.5
echo -e "\e[1m**********************************"
echo -e "Ram Used : \e[91m$memUsed_m MB  =  $memUsedPrc%\e[0m"
sleep 0.5
echo -e "\e[1m**********************************"
echo -e "CPU Used : \e[92m""$CPUPer""%\e[0m"
sleep 0.5
echo -e "\e[1m**********************************"
echo -e 'Hard : \e[33m'"$hdd"'%\e[291m\e[0m'
sleep 0.5
echo -e "\e[1m**********************************"
echo -e "\e[40;38;5;82mProcess : \e[30;48;5;82m ""$ProcessCnt\e[0m"
sleep 0.5
echo -e "\e[1m**********************************\e[0m"
echo -e "\e[92m     »» Launching Bot ««\e[0m"
sleep 2
./tg -s bot.lua
