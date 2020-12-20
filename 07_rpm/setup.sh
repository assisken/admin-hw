#!/bin/bash

curl -OL https://nginx.org/packages/centos/7/SRPMS/nginx-1.18.0-2.el7.ngx.src.rpm
rpm -i nginx-1.18.0-2.el7.ngx.src.rpm
curl -OL https://www.openssl.org/source/latest.tar.gz
tar -xvgf latest.tar.gz
yum-builddep -y rpmbuild/SPECS/nginx.spec
ls
pwd

