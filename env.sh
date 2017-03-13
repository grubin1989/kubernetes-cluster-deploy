#!/bin/bash
mkdir -p /opt/kubernetes/{cfg,bin}
echo $PATH | grep kubernetes
rs=`echo $?`
if [[ $rs -eq 1 ]];  then
  echo 'PATH=$PATH:/opt/kubernetes/bin' >> /etc/profile 
  . /etc/profile
fi

#copy all bin files to /opt/kubernetes/bin
alias cp='cp'
chmod -R +x ./bin/*
cp -f ./bin/* /opt/kubernetes/bin/

pushd `pwd`
#go to /opt/kubernetes/bin dir and exec hyperkube 
pushd /opt/kubernetes/bin
if ! [ -h /opt/kubernetes/bin/apiserver ]; then
./hyperkube --make-symlinks
fi
popd
