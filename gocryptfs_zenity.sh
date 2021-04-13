#!/bin/bash
cd "$(dirname "$0")"
pwd
echo "The scripts removes all signal rpms in the directory it runs"
echo Getting sudo && sudo echo "Got sudo privileage"
sudo rm -rf signal*.rpm
wget https://updates.signal.org/desktop/apt/pool/main/s/signal-desktop-beta/signal-desktop-beta_$1_amd64.deb -O signal.deb
sudo alien  -r -g -v -c signal.deb
thedir=$(find . -maxdepth 1 -type d -iname "signal*")
thereal=$(realpath $thedir)
cd $thedir
thespec=$(find . -maxdepth 1 -type f -iname "signal*" | sed "s/\.\///g")
sudo sed -i "s/^Summary:/Summary: Signal Desktop Beta Application /g" $thespec
sudo sed -i "/%dir \"\/opt\/\"/d" $thespec
sudo rpmbuild --buildroot="$thereal" -bb --target x86_64 "$thespec"
cd ..
sudo rm -rf $thedir
therpm=$(find . -maxdepth 1 -type f -iname "signal*.rpm" )
sudo dnf remove signal-desktop-beta
sudo rpm -i $therpm
echo "sudo rpm -i $therpm "
sudo rm signal-*.rpm
sudo rm signal.deb
~ ❯❯❯ cat ~/.script/secret
#!/bin/bash
if [ ! -d ~/.secret ]
then
        mkdir secret
fi
randof=$RANDOM
randod=$(uuidgen)
mounted=$(mount | grep -o "/home/navtey/.secret/secret[^ ]* ")
passwd=""
askfor (){
        passwd=$(zenity --entry --text="Enter $1 Password $2" --hide-text --width=400)
}
#cd "$(dirname "$0")"
names=""
for i in ~/.secret/*
do
  namefile=$(echo $i | sed "s/^.*\///g" )
        namefile2=$(echo $namefile | sed -E "s/^secret.+$//g")
        if [[ $namefile != $namefile2 ]];
        then
                continue
        fi
        if [ -d $i ] && [[ "$namefile" != "secret" ]];
        then
           echo Found $i
                 names+="$namefile|"
        fi
done
names=$(echo $names | sed "s/|$//g")

echo $names

userin=$(zenity --forms --add-entry="Create New" --text="Open or Create New" --add-combo="Folder Mount" --ok-label="Mount/Create" --combo-values="$names" --extra-button="Umount all" )
userin=$(echo $userin | sed "s/^|//g" )
userin=$(echo $userin | sed "s/|$//g" )
if [[ $userin = "|" ]];
then
        exit
fi
if [[ $userin == "Umount all" ]];
then
        umount $mounted
        if [[ $? == 0 ]];
        then
                rm -rf $mounted
                zenity --info --text="Unmounted" --width=400
        else
                zenity --info --text="Error Occured, Maybe Nothing is mounted" --width=400
        fi
        exit
fi

isdual=$(echo $userin | grep "|" )
if [[ $isdual == $userin ]];
then
        zenity --info --width=400 --text="Don't input 2 fields, Select one field for action"
        exit
fi

cd ~/.secret
if [[ $userin == "Open Mounted" ]];
then
        echo Opening file manager
elif [ -d "$userin" ];
then
        echo Directory exists
        thishome=$(readlink -f ~ )
        isloaded=$(mount | grep ~/.secret/$userin )
        if [[ $isloaded != "" ]];
        then
                echo "This is already mounted!!!"
    fileat=$(echo $isloaded | grep -o "/home/navtey/.secret/secret[^ ]* ")
                echo $fileat
                xdg-open $fileat
                exit
        fi
        askfor ""
        echo $passwd > $randof
        mkdir "secret$randod"
        gocryptfs --passfile=$randof $userin "secret$randod"
        if [[ $? != "0" ]];
        then
                zenity --info --text="Wrong Password, Forgot? Try restoring with masterkey" --width=400
                rm -r $randof
                exit
        fi
#       echo $randof
        rm -r $randof
        xdg-open secret$randod
else
        echo Making directory
        askfor "New"
        rt=$passwd
        askfor "" "Again"
        if [[ $passwd != $rt ]];
        then
     zenity --info --text="Passwords won't match! exiting" --width=400
                 exit
        fi
  mkdir $userin
        mkdir secret$randod
        echo $rt > $randof
        gocryptfs --passfile=$randof --init $userin
#       masstf=$(cat $masstf | grep "master key is" -A 3 )
#       rm -rf $masstf
#       echo "$masstf \n\nThis key is specific for folder $userin \nIn case you forgot password you would need key" | zenity --text-info --width=350 --height=500
        gocryptfs --passfile=$randof $userin "secret$randod"
        rm -f $randof
        xdg-open secret$randod
fi
#echo $userin
