#!/bin/bash

# Script to call MATLAB
# Uses the environment variable FSL_FIX_MATLAB_MODE to control whether compiled, un-compiled or Octave versions are used

function usage {
	echo \
"$0 [-z <mode>] [-o <options>] [-p <path>] [-h <fix path>] 
	[-c <mcr path>] [-b <binaries path>] [-l <logfile>] 
	{-r <\"MATLAB code\">|-m <script>|-f <function> [arguments...]}

	-z <mode>:	This overrides the environment variable 
		FSL_FIX_MATLAB_MODE which would	otherwise control this.
			0 = Use compiled MATLAB function specified by 
				-m <function name>
			1 = Use MATLAB - requires -r or -m option
			2 = Use Octave - requires -r or -m option
	-r <\"MATLAB code\">: Evaluate the double-quoted MATLAB/Octave
		code. Equivalent to 'matlab -r \"MATLAB code\"' or
		'octave --eval \"MATLAB code\"'
		Ensure that any double quotes in this string are escaped
		with '\\'.
	-m <script>:
		-z = 0 or not provided, run as -z = 1 
		-z = 1|2 - Run <script> in MATLAB/Octave
			Equivalent to 'matlab \< <script>.m' or 'octave <script>.m'
	-f <function> [arguments]:
		-z = 0 - Call compiled MATLAB <function>
			Arguments to be passed are given in the remainder of the
			command line.
		-z = 1|2 - Run <function> script in MATLAB/Octave
			Equivalent to 'matlab -r \"<function>([arguments])\"' or
			'octave --eval \"<function>([arguments])\"'
			Arguments to be passed are given in the remainder of the 
			command line.
	-o <options>: Double quoted list of MATLAB/Octave command line
		options. Defaults to \${FSL_FIX_MLOPTS} or \${FSL_FIX_OCOPTS}
		respectively
	-p <path>: Path to MATLAB/Octave startup script/binary.
		Defaults to: \${FSL_FIX_MATLAB} or \${FSL_FIX_OCTAVE}
		respectively
	-h <path>: Path to folder containing the Fix programs
	-w <path>: Path to FSL MATLAB helper functions, defaults to
			${FSLDIR}/etc/matlab
	-c <mcr path>: Path to MATLAB Compiler Runtime for the version
		of MATLAB Fix was compiled under. Defaults to \${FSL_FIX_MCRROOT}
	-b <compiled path>: Path to the folder containing the compiled MATLAB
		functions. Defaults to \${FSL_FIX_MLCDIR}
	-l <logfile>: Append console and error output to <logfile>\n" >&2
	exit 2
}

if [ -z "${FSL_FIXDIR}" ]; then
	FSL_FIXDIR=$( cd $(dirname $0) ; pwd)
	export FSL_FIXDIR
fi
. ${FSL_FIXDIR}/settings.sh
opt_str=":z:o:p:h:c:b:l:r:m:f:d"
NO_EXT=0
DEBUG=0

while getopts ${opt_str} opt
do
	case $opt in
	z)
		if [ -z "${fmm}" ]; then
			case ${OPTARG} in
				''|*[!0-9*])
					usage
					;;
				*)
				fmm=${OPTARG}
				;;
			esac
		else
			echo "More than one mode passed." >&2
			usage
		fi
		;;
	o)
		if [ -z "${DMOPTS}" ]; then
			DMOPTS=${OPTARG}
		else
			echo "More than one MATLAB/Octave option string passed." >&2
			usage
		fi
		;;
	p)
		if [ -z "${BIN_PATH}" ]; then
			BIN_PATH=${OPTARG}
		else
			echo "More than one MATLAB/Octave binary path passed." >&2
			usage
		fi
		;;
	h)
		if [ -z "${FIX_PATH}" ]; then
			FIX_PATH=${OPTARG}
		else
			echo "More than one FIX path passed." >&2
			usage
		fi
		;;
	w)
		if [ -z "${FSL_MATLAB_PATH}" ]; then
			FSL_MATLAB_PATH=${OPTARG}
		else
			echo "More than one FSL MATLAB path passed." >&2
			usage
		fi
		;;
	c)
		if [ -z "${MCR}" ]; then
			MCR=${OPTARG}
		else
			echo "More then one MATLAB runtime path passed." >&2
			usage
		fi
		;;
	b)
		if [ -z "${CSUBDIR}" ]; then
			CSUBDIR=${OPTARG}
		else
			echo "More than one compiled MATLAB executable path passed." >&2
			usage
		fi
		;;
	l)
		if [ -z "${LOGF}" ]; then
			LOGF=${OPTARG}
		else
			echo "More than one log file passed." >&2
			usage
		fi
		;;
	r)
		if [ -z "${EVAL}" ]; then
			EVAL=${OPTARG}
		else
			echo "More than one set of MATLAB/Octave commands passed." >&2
			usage
		fi
		;;
	f)
		if [ -z "${FUNC}" ]; then
			FUNC=${OPTARG}
		else
			echo "More than one function passed." >&2
			usage
		fi
		;;
	m)
		if [ -z "${MFILE}" ]; then
			MFILE=${OPTARG}
		else
			echo "More than one file name passed." >&2
			usage
		fi
		;;
	d)
		DEBUG=1
		set -x
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		usage
		;;
	:)
		echo "Option -$OPTARG requires an argument." >&2
		usage
		;;
	esac
done

if [ -z "${FSLDIR}" ]; then
	echo "FSLDIR environment variable not set!" >&2
	usage
fi

if [ ! -z "${EVAL}" -a ! -z "${MFILE}" -a ! -z "${FUNC}" ]; then
	echo "Cannot evaluate commands and a function/compiled command." >&2
	usage
fi

if [ -z "${fmm}" ]; then
	if [ -z "${FSL_FIX_MATLAB_MODE}" ]; then
		fmm=0
	else
		fmm=${FSL_FIX_MATLAB_MODE}
	fi
fi	

shift $(($OPTIND - 1))

if [ ! -z "${EVAL}" -a $fmm -eq 0 ]; then
	# Default to running MATLAB if evaluation has been specified without a -z mode
	fmm=1
fi
if [ ! -z "${MFILE}" -a $fmm -eq 0 ]; then
	# Default to running MATLAB if script has been specified without a -z mode
	fmm=1
fi
# Capture the passed arguments if we are running a function
if [ ! -z "${FUNC}" ]; then
	F_ARGS=''
	for arg in "$@";do
		if echo "${arg}" | egrep '^[-+]?([0-9]+\.?|[0-9]*\.[0-9]+)$' >/dev/null
		then
			F_ARGS="${F_ARGS} ${arg}"
		else
			F_ARGS="${F_ARGS} '${arg//\"/\\\"}'"
	fi
	done;
fi 

# Set some defaults
if [ -z "${MATLAB_BIN}" ]; then
	MATLAB_BIN=${FSL_FIX_MATLAB}
fi
if [ -z "${OCTAVE_BIN}" ]; then
	OCTAVE_BIN=${FSL_FIX_OCTAVE}
fi
if [ -z "${CSUBDIR}" ]; then
	CSUBDIR=${FSL_FIX_MLCDIR}
fi
if [ -z "${MCR}" ]; then
	MCR=${FSL_FIX_MCR}
fi
if [ ! -z "${LOGF}" ]; then
	LOGGING=" >> ${LOGF} 2>&1 "
fi

case ${fmm} in
    ''|*[!0-9]*) echo "MATLAB Mode must be a number" >&2
    usage
    ;;
    *) : ;;
esac

if [ ${fmm} -eq 0 ]; then
	# Compiled MATLAB - the default
	if [ -z "${FUNC}" ]; then
		echo "No compiled function name passed." >&2
		usage
	fi
	# Test for MCR setup
	if [ ! -d "${FSL_FIX_MCR}" ]; then
		echo "Unable to find MATLAB Compiler Runtime" >&2
		usage
	fi
	if [ -z "${FSL_FIX_MCRV}" ]; then
		echo "Cannot locate MATLAB Compiler Runtime version file (MCR.version)" >&2
		usage
	fi

	EXE=${CSUBDIR}/run_${FUNC}.sh
	if [ ! -x "${EXE}" ]; then
		if [ "${DEBUG}" -eq 1 ]; then
			echo "Cannot find executable for compiled function (looking for ${EXE}) - reverting to running MATLAB."
		fi
		if [ -x "${MATLAB_BIN}" ]; then
			fmm=1
		elif [ -x "${OCTAVE_BIN}" ]; then
			fmm=2
		else
			echo "Unable to find compiled functions or MATLAB/OCTAVE" >&2
			exit 2
		fi	
	else
		cmd="${EXE} ${MCR} ${F_ARGS} ${LOGGING}"
		echo "$cmd" | sh
		exit $?
	fi
fi

if [ -z "${DOPTS}" ]; then
	if [ "${fmm}" -eq 1 ]; then
		DOPTS=${FSL_FIX_MLOPTS}
	else
		DOPTS=${FSL_FIX_OCOPTS}
	fi
fi

if [ "${fmm}" -eq 1 ]
then
	RUNTIME="${MATLAB_BIN}"
	EVAL_CMD=${FSL_FIX_MLEVAL}
	FILE_CMD=${FSL_FIX_MLFILE}
	if [ ! -x "${RUNTIME}" ]; then
echo "${RUNTIME} not found!" >&2
		usage
	fi
elif [ "${fmm}" -eq 2 ]; then
	RUNTIME="${OCTAVE_BIN}"
	EVAL_CMD=${FSL_FIX_OCEVAL}
	FILE_CMD=${FSL_FIX_OCFILE}
	if [ ! -x "${RUNTIME}" ]; then
echo "${RUNTIME} not found!" >&2
		usage
	fi
fi

if [ -z "${FSL_MATLAB_PATH}" ]; then
	FSL_MATLAB_PATH=${FSL_FIX_FSLMATLAB}
fi

ML_PATHS="addpath('${FSL_FIXDIR}'); addpath('${FSL_MATLAB_PATH}');"


if [ ${fmm} -gt 0 -a ${fmm} -lt 3 ]; then
	# Uncompiled MATLAB/Octave
	if [ ! -z "${EVAL}" ]; then
		# We were passed some MATLAB/Octave commands in a string
		cmd="${RUNTIME} ${DOPTS} ${EVAL_CMD} \"${ML_PATHS} ${EVAL}\" ${LOGGING}"
		echo "$cmd" | sh
		exit $?
	elif [ ! -z "${FUNC}" ]; then
		for arg in ${F_ARGS}; do
			arg=`echo $arg | sed -e 's/^\(.* \)$/\"\1\"/'`
			FUNC_ARGS="${FUNC_ARGS},${arg}"
		done
		FUNC_ARGS=`echo ${FUNC_ARGS} | sed -e 's/^.\(.*\)$/\1/'`
		cmd="${RUNTIME} ${DOPTS} ${EVAL_CMD} \"${ML_PATHS} ${FUNC}(${FUNC_ARGS})\" ${LOGGING}"
		echo "$cmd" | sh
		exit $?
	elif [ ! -z "${MFILE}" ]; then
		# We were passed a MATLAB script to run
		cmd="${RUNTIME} ${DOPTS} ${FILE_CMD} ${MFILE} ${LOGGING}"
		echo "$cmd" | sh
		exit $?
	else
		echo "Missing MATLAB/Octave function to run" >&2
		usage
	fi
else
		echo "Unrecognised run mode." >&2
		usage
fi
