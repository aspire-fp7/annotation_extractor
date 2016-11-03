#!/bin/bash

# Copyright (c) 2016 Fondazione Bruno Kessler www.fbk.eu
# Author Roberto Tiella

# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to 
# deal in the Software without restriction, including without limitation the 
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
# sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
# IN THE SOFTWARE.



# handle cntrl+C pressed by the user
trap 'echo interrupted by ^C; exit 1' SIGINT

#PATH=${PATH}:.
DIR=$(dirname $0)
DEBUGGING=0

ulimit -s unlimited

while getopts "hdapsx:" OPT $ARGS  
do
        case $OPT in
                "h")
                        echo "usage: $(basename $0) [-h] sourcefile.i destfile.json" >&2
                        exit 1
                        ;;
                "d")
                        echo "enabling debugging info" >&2
                        DEBUGGING=1
        esac

        shift

        if [ -n "$OPTARG" ]
        then
                shift
        fi
done


fin=${1?'specify an input preprocessed file'}
fout=${2?'specify an output json file'}
ftmp=/tmp/$$.i

echo "grep \"#pragma\\s*ASPIRE \|__attribute__\s*((\s*ASPIRE\s*(\" ${fin} >/dev/null"
grep "#pragma\s*ASPIRE \|__attribute__\s*((\s*ASPIRE\s*(" ${fin} >/dev/null
if [ $? -ne 0 ]
then
        echo "no annotations"
        echo "[]" > ${fout}
        exit 0;
fi


echo "${DIR}/convert_pragmas.py ${fin} ${ftmp}" >&2
${DIR}/convert_pragmas.py ${fin} ${ftmp}
err=$?

if [ $err -eq 0 ]
then
        if [ ${DEBUGGING} -eq 1 ] 
        then
                echo "${DIR}/readAnnot.x -o ${fout} ${ftmp} - -file_name ${fin}" >&2
        fi
        ${DIR}/readAnnot.x -o ${fout} ${ftmp} - -file_name ${fin}
	err2=$?
	if [ $err2 -eq 0 ]
	then
                if [ ${DEBUGGING} -eq 1 ] 
                then
		      echo "done" >&2
                fi
	else
		echo "ERROR translation aborted by errors: $err2" >&2
		exit $err2
	fi
	
else
        echo "ERROR translation aborted by errors: $err" >&2
	exit $err
fi

rm $ftmp
exit 0

