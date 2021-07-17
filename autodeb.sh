#!/bin/sh
red="\e[1m\e[31m"
green="\e[1m\e[32m"
yellow="\e[1m\e[33m"
white="\e[1m\e[39m"
mess=$(echo -e ""$white"Press [Enter] key to continue... ")
##################################################################
banner(){
clear
echo -e "$green █████╗ ██╗   ██╗████████╗ ██████╗ ██████╗ ███████╗██████╗
██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝██╔══██╗
███████║██║   ██║   ██║   ██║   ██║██║  ██║█████╗  ██████╔╝
██╔══██║██║   ██║   ██║   ██║   ██║██║  ██║██╔══╝  ██╔══██╗
██║  ██║╚██████╔╝   ██║   ╚██████╔╝██████╔╝███████╗██████╔╝
╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═════╝ ╚══════╝╚═════╝  v1.2 \n$white"
}
line(){
for (( i = 0; i < 64; i++ )); do
printf %b "$green=$white"
done
echo -e "\n"
}
menu(){
echo -e "$white[1] Config IP   [3] Web Service  [5] System Info  [0] Exit
[2] Update Repo [4] Web Page     [6] Other Menu$white\n"
}
pause(){
  read -p "$*"
  echo 'click'
}
##################################################################
ipStatic(){
read -p "IP Address : " ipaddress
read -p "Netmask    : " netmask
read -p "Gateway    : " gateway
read -p "DNS        : " dns
echo "auto eth0
iface eth0 inet static
address $ipaddress
netmask $netmask
gateway $gateway
dns-nameservers $dns" > /etc/network/interfaces
echo "nameserver $dns" > /etc/resolv.conf
sleep 2
/etc/init.d/networking restart
}

ipDHCP(){
read -p "DNS : " dns
echo "# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet dhcp" > /etc/network/interfaces
echo "nameserver $dns" > /etc/resolv.conf
sleep 2
/etc/init.d/networking restart
}
##################################################################
repoSimple(){
echo -e "deb http://deb.debian.org/debian buster main
deb-src http://deb.debian.org/debian buster main" > /etc/apt/sources.list
apt update -y --force-yes
}

repoFull(){
echo -e "deb http://deb.debian.org/debian buster main
deb-src http://deb.debian.org/debian buster main

deb http://deb.debian.org/debian-security/ buster/updates main
deb-src http://deb.debian.org/debian-security/ buster/updates main

deb http://deb.debian.org/debian buster-updates main
deb-src http://deb.debian.org/debian buster-updates main

deb http://deb.debian.org/debian buster main contrib non-free
deb-src http://deb.debian.org/debian buster main contrib non-free

deb http://deb.debian.org/debian-security/ buster/updates main contrib non-free
deb-src http://deb.debian.org/debian-security/ buster/updates main contrib non-free

deb http://deb.debian.org/debian buster-updates main contrib non-free
deb-src http://deb.debian.org/debian buster-updates main contrib non-free" > /etc/apt/sources.list
apt update -y --force-yes
}

repoCdrom(){
apt-cdrom add
apt update -y --force-yes
}
##################################################################
installApache(){
  apt install apache2 -y --force-yes
}
##################################################################
webPage(){
read -p 'Nama Lengkap : ' nama
read -p 'Kelas : ' kelas
read -p 'Sekolah : ' sekolah
read -p 'Hobi : ' hobi
echo -e "
<!DOCTYPE HTML>
<html>
  <head>
    <title>BIODATA DIRI</title>
    <style>
   body {
margin:0 auto;
color:;}
#konten {
margin:10px auto;
padding:20px;
width:800px;
border:1px solid ;
}
</style>
  </head>

  <body>
  <font color="black" size="5">
  <center>
    <caption>BIODATA</caption>
  <table border="1">
    <td>
      <table border="0">
        <div>
        <p class="satu">
        <tr><td>Nama Lengkap</td><td>:</td><td>$nama</td>
        <tr><td>Kelas</td><td>:</td><td>$kelas</td>
        <tr><td>Sekolah</td><td>:</td><td>$sekolah</td>
        <tr><td>Hobi</td><td>:</td><td>$hobi</td>
        </div>
      </table>
    </td>
    </center>
  </body>
</html>" > /var/www/html/index.html
}
##################################################################
sysinfo(){
  os=$(cat /etc/os-release | awk -F= '$1=="PRETTY_NAME" { print $2 ;}' | sed 's/"//g')
  kernel=$(uname -r)
  upTime=$(uptime -p | sed 's/up //')
  cpu=$(lscpu | sed -nr '/Model name/ s/.*:\s*(.*)/\1/p')
  memUsed=$(free -m | grep Mem | awk '{print $3}')
  memTotal=$(free -m | grep Mem | awk '{print $2}')
  memPersen=$(python -c "print(int($memUsed / $memTotal * 100))")
  memory="$memUsed MiB / $memTotal MiB ($memPersen%)"
  ip=$(hostname -I)
  user="$USER@$(hostname)"
  count=$(echo $(expr length $user))
  row=$(for (( i = 0; i < $count; i++ )); do
    printf %b "$white-"
  done
  echo "")
  echo -e "$user
$row $green
OS     $white: $os $green
Kernel $white: $kernel $green
Uptime $white: $upTime $green
CPU    $white: $cpu $green
Memory $white: $memory $green
IP     $white: $ip
"
}
##################################################################
otherMenu(){
  echo -e "[1] Calculator "
  read -p ">> " choose
}
calculator(){
  while true; do
  banner
  line
  echo -e "Contoh penggunaan :
  # 1+1 (untuk penjumlahan)
  # 2-1 (untuk pengurangan)
  # 2*8 (untuk perkalian)
  # 8/2 (untuk pembagian)
  # (10+5)*20/5
  # q   (untuk exit)
  "
  read -p "   >> " cal
  if [[ $cal = "q" ]]; then
    exit
  else
    echo -e "Hasil : $(python -c "print(int("$cal"))")\n"
    pause $mess
  fi
  done
}
while true; do
  banner && line && menu
  read -p ">> " choose
    case $choose in
    1 )
    banner && line
    echo -e "[1] IP Static  [2] IP DHCP"
    read -p ">> " choose
      case $choose in
      1 )
        clear && ipStatic
      ;;
      2 )
        clear && ipDHCP
      esac
    ;;
    2 )
    banner && line
    echo -e "[1] Simple  [2] Full  [3] CD Rom"
    read -p ">> " choose
      case $choose in
      1 )
        clear && repoSimple
      ;;
      2 )
        clear && repoFull
      ;;
      3 )
        clear && repoCdrom
      esac
    ;;
    3 )
    clear && installApache
    ;;
    4 )
    clear && webPage
    ;;
    5 )
    clear && banner && line && sysinfo
    pause $mess
    ;;
    6 )
    clear && banner && line && otherMenu
    case $choose in
      1 )
      calculator
        ;;
    esac
    ;;
    0 )
    exit;
    esac
done
