#!/usr/bin/bash

# http://erlang.org/download/otp_src_18.3.tar.gz
OTP_VERSION=18.3
OTP_SRC_DIR=otp_src_${OTP_VERSION}
OTP_PKGNAME=${OTP_SRC_DIR}.tar.gz

PWD=$(pwd)

TMPDIR=/tmp/src
OTP_INSTALL_PATH=/opt/otp/${OTP_VERSION}
if [ ${USER} != "root" ]; then
  TMPDIR=$(pwd)/tmp
  OTP_INSTALL_PATH=$(pwd)/otp/${OTP_VERSION}
  echo "You are not root, install path is changed to ${OTP_INSTALL_PATH}"
  echo "Temporary build path is ${TMPDIR}"
fi

TMPFILE=${TMPDIR}/${OTP_PKGNAME}
BASE_URL=http://erlang.org/download/${OTP_PKGNAME}


if [ ! -d ${TMPDIR} ]; then
  mkdir -p ${TMPDIR}
fi

if [ ! -d ${OTP_INSTALL_PATH} ]; then
  mkdir -p ${OTP_INSTALL_PATH}
fi

if [ ! -e ${TMPFILE} ]; then
  $(curl ${BASE_URL} > ${TMPFILE})
fi

if [ ! -d ${TMPDIR}/${OTP_SRC_DIR} ]; then
  cd ${TMPDIR} && tar xvzf ${OTP_PKGNAME}
fi

cd ${TMPDIR}/${OTP_SRC_DIR} && ./configure --prefix ${OTP_INSTALL_PATH}

if [ ! -e ${TMPDIR}/${OTP_SRC_DIR}/Makefile ]; then
  echo "Aborting install, no makefile created through configure"
  exit
fi

make && make install

PATH=$PATH:${OTP_INSTALL_PATH}/bin
REBAR_URL=https://github.com/rebar/rebar
cd ${TMPDIR} && $(git clone ${REBAR_URL}) && cd rebar && ./bootstrap

if [ -e "rebar" ]; then
  cp rebar ${PWD}/rebar
fi
