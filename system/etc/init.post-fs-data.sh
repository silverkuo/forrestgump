#!/system/bin/sh
# copy cntv ini files
export PATH=/system/bin:/system/xbin
flag="data/duokancache/cntv/copied"
datapath="/data/duokancache/cntv"
inipath="/system/etc/cntv/ini"
datacachepath="/data/duokancache"

mkdir -p $datapath/ini

for file in `ls $datapath/ini`;
do
   if [ ! $file == "DeviceID.ini" ]; then
     rm $datapath/ini/$file
   fi
done

cp $inipath/* $datapath/ini

chmod 777 $datacachepath
chown nobody.nobody $datapath
find $datapath |xargs chown nobody.nobody
sync

ls /data/log/ -l | grep root
if [ "$?" == "0" ]; then
        chown log.log /data/log
        chown log.log /data/log/*
fi

ls /data/anr/ -l | grep root
if [ "$?" == "0" ]; then
        chown log.log /data/anr
        chown log.log /data/anr/*
fi

DATE=`date "+%Y-%m-%d-%H%M%S"`
if [ -e /proc/emmc_ipanic_console ]; then
	cp /proc/emmc_ipanic_console /data/log/kpanic_${DATE}
	cp /proc/emmc_ipanic_threads /data/log/kpanic_${DATE}_threads
	echo 1 > /proc/emmc_ipanic_console
fi

mkdir /data/diagnosis
chown system.system /data/diagnosis
chmod 775 /data/diagnosis
mkdir /data/diagnosis/upload
chown system.system /data/diagnosis/upload
chmod 775 /data/diagnosis/upload

# copy logo_retriever config and model files.
src="/system/logo_retriever"
dst="/data/logo_retriever"
if [ ! -d "$dst" ]; then
    mkdir $dst
fi
cp $src/* $dst
