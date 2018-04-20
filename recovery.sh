#!/bin/bash
# description: readycloud private home share recovery
# NETGEAR Proprietary
# email: readynassupport@netgear.com
# usage: ./scriptname <dev> <dst> <email>
# example: ./recovery.sh /dev/md127 /mnt/ readynassupport@netgear.com

#set variables
dev=$1
dst=$2
cc=$3
blocks=/root/blocks
users=/root/users
refs=/root/refs
bfr="btrfs-find-root"
btrfs="btrfs"
skipblocks=1
skipusers=1
skiprefs=1
spin='-\|/'
lastmod=$(stat -c %y "$0")
mounted=$(mount | grep -c "$1")
restart_start_time=0

#Notifications
email_to="readynassupport@netgear.com"
email_conf_file=/root/msmtp_recovery.conf
email_config="defaults
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account default 
host smtp.gmail.com
port 587
protocol smtp
auth on
from ngkberthelette@netgear.com
user ngkberthelette
password vlhdwbkvvsevulfv
"

#email config creation
echo "${email_config}" > "${email_conf_file}"



# script announcement
printf "\nReadyCLOUD Private Home Share Recovery script\nThis script is used to recover ReadyCLOUD home folders that were mistakenly deleted.\n"
printf "Last Modified: %s\n\n" "$lastmod"

# quick little usage dialog
script_help()
{
echo "Usage:"
printf "      %s <dev> <dst> <email>\n\n" "$0"
}
if [[ -z $dev ]] || [[ -z $dst ]]
then
echo "Missing device or destination. Check syntax and try again."
script_help
exit 1
fi
if [[ $mounted -ne 0 ]]
then
printf "\nThis script can only be run against unmounted <dev>...\n"
printf "We found that %s was mounted; please unmount and try again.\n" "$dev"
script_help
exit 2
fi

#make sure destination is really there
mkdir -p "$dst" >/dev/null 2>&1 ||:

# don't rotate the files unless approved
if [[ -e $blocks ]] && [[ -s $blocks ]]
then
read -p "-- $blocks is not empty. Do you want to remove and rebuild the list (y) or reuse the existing list (n)? " -n 1 -t 60 -e input
if [[ $input == "y"  ]] || [[ $input == "Y" ]]
then
mv $blocks $blocks."$(date +%s)" >/dev/null 2>&1 ||:
skipblocks=1
elif [[ $input == "n" ]] || [[ $input == "N" ]]
then
skipblocks=0
fi
fi
if [[ -e $refs ]] && [[ -s $refs ]] && ! grep -q ROOT_REF $refs
then
        read -p "-- $refs is not empty. Do you want to remove and rebuild the list (y) or reuse the existing list (n)? " -n 1 -t 60 -e input
        if [[ $input == "y"  ]] || [[ $input == "Y" ]]
        then
                mv $refs $refs."$(date +%s)" >/dev/null 2>&1 ||:
skiprefs=1
        elif [[ $input == "n" ]] || [[ $input == "N" ]]
        then
                skiprefs=0
        fi

fi
if [[ -e $users ]] && [[ -s $users ]]
then
        read -p "-- $users is not empty. Do you want to remove and rebuild the list (y) or reuse the existing list (n)? " -n 1 -t 60 -e input
        if [[ $input == "y"  ]] || [[ $input == "Y" ]]
        then
                mv $users $users."$(date +%s)" >/dev/null 2>&1 ||:
skipusers=1
        elif [[ $input == "n" ]] || [[ $input == "N" ]]
        then
                skipusers=0
        fi

fi
touch $refs $users $blocks

#establish architecuture
printf "Checking CPU architecture.\n"
if [[ $(lscpu | grep Architecture) == *"x86"* ]]; then
        arch="x86"
else
        arch="arm"
fi

#find deleted user email addresses if empty
if [[ $skipusers -eq 1 ]]
then
grep -a DELETE_USER /var/log/frontview/status.log | awk '{print $6}' | sed "s/'//g;s/)//g"| sort -r | uniq > $users
else
printf "Reusing users from %s." $users
fi

# download the appropriate tools
printf "\nDownloading the %s toolset.\n" $arch
wget http://www.readynas.com/download/support/btrfs-find-root.$arch -qN --show-progress -O $bfr
wget http://www.readynas.com/download/support/btrfs.$arch -qN --show-progress -O $btrfs

#set execute permissions on new binaries
chmod +x $bfr $btrfs

# before we start working on recovery, run btrfs device scan, just in case
./$btrfs device scan

#search for all the blocks, unless reusing blocks...
if [[ $skipblocks -eq 1 ]]
then
printf "\nSearching roots...\nthis may take a while...\n"
./$bfr -a "$dev" > $blocks 2>&1 &
pid=$!
spinner=0
while kill -0 "$pid" 2>/dev/null
do
  spinner=$(( (spinner+1) %4 ))
  printf "\r%s" ${spin:$spinner:1}
  sleep .1
done
else
printf "Reusing blocks from %s." $blocks
fi
printf " Done...\n"

#search for all the refs
total=$(grep -ac Well $blocks)
if [[ $skiprefs -eq 1 ]]
then
printf "Looking for root refs... This may take a while. "
pattern=$(cat $users | xargs echo | sed 's/ /|/g')
printf "(%-11.11s)" "0/$total"
n=1
for i in $(grep -a Well $blocks | sed -r -e 's/Well block ([0-9]+).*/\1/')
do
printf "\b\b\b\b\b\b\b\b\b\b\b\b%-12.12s" "$n/$total)"
./$btrfs restore -l -t "$i" "$dev" 2> /dev/null | egrep "$pattern" | awk -v b="$i" -F'[ ()]' '{ print b" "$5" "$7" "$10 }' >> $refs
n=$((n+1))
done
else
printf "Reusing refs from %s." $refs
fi

#attempting to restore the things
restart_start_time=$(date +%x" "%R%Z)
echo "To: ${email_to}
Cc: ${cc}
Subject: Starting recovery for Serial# $(grep serial /proc/sys/dev/boot/info | awk '{print $2}') on Port # $(remote_access -p)

Starting recovery.
Start Time: ${restart_start_time}
Model: $(grep model /proc/sys/dev/boot/info | awk '{print $2" "$3}')
Serial# $(grep serial /proc/sys/dev/boot/info | awk '{print $2}')
" | msmtp -C "${email_conf_file}" "${email_to}"
printf " Done...\nStarting restore... This will take a while depending on roots, refs and data! (%-11.11s)" "0/$total"
while read user
do
        mkdir -p "$dst"/"$user"
done < $users
n=1
for i in $(grep Well $blocks | sed -r -e 's/Well block ([0-9]+).*/\1/')
do
printf "\b\b\b\b\b\b\b\b\b\b\b\b%-12.12s" "$n/$total)"
awk '{print $3" "$4}' $refs | sort | uniq | \
while read x user_folder
do
 ./$btrfs restore -FXvi -t "$i" -r "$x" "$dev" "$dst"/"$user_folder" > /dev/null 2>&1
done
n=$((n+1))
done

#everything we could do was done, return completion
echo "To: ${email_to}
Cc: ${cc}
Subject: Recovery completed for Serial# $(grep serial /proc/sys/dev/boot/info | awk '{print $2}') on Port # $(remote_access -p)

Recovery started: ${restart_start_time} 
Recovery finished: $(date +%x" "%R%Z) 
Model: $(grep model /proc/sys/dev/boot/info | awk '{print $2" "$3}') 
Serial# $(grep serial /proc/sys/dev/boot/info | awk '{print $2}')

We were able to recover $(du -sh | awk '{print $1}') of data and $(find "${dst}" | wc -l) files.

Blocks: $(wc -l ${blocks})
Refs: $(wc -l ${refs})

We attempted to recover the following users:
$(cat ${users})
" | msmtp -C "${email_conf_file}" "${email_to}"
printf "\nDone! Check %s!\n\n" "$2"
exit 0

