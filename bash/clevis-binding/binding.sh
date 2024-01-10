#!/bin/bash

function update() {
	packages="clevis clevis-luks clevis-dracut"
	echo "package update in progress..."
	yum update -y 
	echo "update complete"
	echo "Binding packages install in progress..."
	yum install $packages -y 
	echo "Binding packages installed"
}

function binder() {
	read -sp "Input luks password : " luks
	devices=("/dev/sda3" "/dev/sda4" "/dev/sda5")
	tang_url="http://127.0.0.1"
	tang_thp="68993ad4-d466-4911-a46f-46bcb06a6cd5"

	for device in "${devices[@]}"; do
		for slot in {2..7}; do
			luksmeta wipe -d "$device" -s "$slot" -f
		done
	done

	# Perform binding
	echo "$luks" > /tmp/luks

	
	for device in "${devices[@]}"; do
		echo "Binding Clevis to Tang for $device now..."
		for _ in {1..3}; do  # Repeat the binding process three times for each device
			clevis bind luks -f -k /tmp/LUKS -d "$device" tang '{"url":"'"$tang_url"'","thp":"'"$tang_thp"'"}'
		done
		echo "Clevis binding to $device complete."
	done
}


function draco() {
	read -r -p "Select your network type [static/dhcp] : " NETWORK
	case $NETWORK in
		static)
			echo "Static Selected"
			sleep 2
			read -p "Input your IP Address : " IP
			read -p "Input your netmask    : " MASK
			read -p "Input your gateway    : " GATEWAY
		    read -p "Input your DNS1       : " NAME1
		    read -p "Input your DNS2       : " NAME2
			dracut -f --regenerate-all --kernel-cmdline "ip=$IP netmask=$MASK gateway=$GATEWAY nameserver=$NAME1 nameserver=$NAME2"
			echo "Initramfs rebuilt with static ip parameters";;
		dhcp)
			echo "dhcp selected"
			sleep 2
			dracut -f --regenerate-all
			echo "Initramfs rebuilt with dhcp parameters";;
		*)
			echo "Wrong entry, try again"
			draco
			;;
	esac
}

function revup() {
	echo "Marking partitions as network devices..."
	sed -i -e '/^\s*\//s/\(\w*\s*\)\(\w*\s*\)/\1_netdev,\2/' \
           -e '/^\s*\/opt\/postgresql/s/\(\w*\s*\)\(\w*\s*\)/\1_netdev,\2/' \
           -e '/^\s*swap/s/\(\w*\s*\)\(\w*\s*\)/\1,_netdev\2/' /etc/fstab
		   
	sed -i 's/$/ _netdev/' /etc/crypttab
	echo "Partition marking complete."
	sleep 2
	systemctl enable clevis-luks-askpass.path
}

function grubedit() {
	#Marking a kernel as default that is known to be on the system at binding time as a kernel without binding will not boot.
	echo "Marking default kernel..."
	grub2-set-default 1
	grub2-mkconfig -o /boot/grub2/grub.cfg
	echo "Default kernel set."
}

function cleanup() {
	rm -f /root/anaconda*
	rm -f /root/original*
	rm -f /tmp/luks
	history -c
}

function main() {
update
binder
draco
revup
grubedit
cleanup
echo "Binding script process complete."
}

main

exit
