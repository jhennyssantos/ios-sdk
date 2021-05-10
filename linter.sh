#!/usr/bin/env sh

current_dir=$(pwd)
script_dir=$(dirname $0)

if [ $script_dir = '.' ]
then
	script_dir="$current_dir"
fi

PROJECT_NAME=`basename $script_dir`

if ! which swiftlint > /dev/null
then
	echo "ERRO: swiftLint nao instalado. --> https://github.com/realm/SwiftLint"
	exit -1
fi

DATE=`date '+%Y-%m-%d_%H:%M:%S'`
BKP_FILE="/tmp/linter-$PROJECT_NAME-$DATE.tgz"

echo "AVISO: Gerando backup no arquivo $BKP_FILE"

CDIR=$PWD
cd $script_dir
tar czf $BKP_FILE .

if [ -f $BKP_FILE ]
then
	swiftlint autocorrect --format --config $PWD/.swiftlint.yml > /dev/null 2>&1
	cd $CDIR
else
	echo "ERRO: falha ao gerar arquivo de backup"
	cd $CDIR	
	exit 1
fi
