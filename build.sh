#!/bin/bash
#source varsFM.sh
#source vars.sh
#source varsHM1.sh
source varsHE3.sh
source funcs.sh
 
#Sample command
#bash build.sh --flashsize 4MB --type test --customer HAVELLS_AC --board htap --sha tip --loglevel 1 --capability 1 --securedImg 1 --securedSoc 1 --branch Havells --uartLogDisable 0
 
#HVLS0020010EPCPX => Havells EPIC Fan Production
#HVLS0010002WAVPX => Havells WAVE Ac Production
LVPR0010001PURPX #=> Livpure Lotier
 
NOTE="Testing"
MODEL="LVPR0010001PURPX"

echo "Note: $NOTE"
echo "Model Number: $MODEL"
 
 
while :
do
	case "$1" in
	-f | --flashsize )
		FLASH="$2"
		shift 2
	;;
	-r | --branch )
		GITBRANCH="$2"
		shift 2
	;;
	-t | --type )
		TYPE="$2"
		shift 2
	;;
	-b | --board)
		BOARD="$2"
		shift 2
	;;
	-c | --customer)
		CUSTOMER="$2"
		shift 2
	;;
	-s | --sha )
		SHA="$2"
		shift 2
	;;
	-a | --capability )
		CAPLEVEL="$2"
		shift 2
	;;
	-l | --loglevel)
		LOGLVL="$2"
		shift 2
	;;
	-m | --securedImg )
		SECUREDBUILD="$2"
		shift 2
	;;
	-n | --securedSoc )
		SECUREDSOC="$2"
		shift 2
	;;
	-u | --uartLogDisable )
		UARTLOGDISABLE="$2"
		shift 2
	;;
	-f | --filterSetting )
		FILTERSETTING="$2"
		shift 2
	;;
	*)
	break
	;;
	esac
done
 
export CUSTOMERNAME=$CUSTOMER
export LOGLEVEL=$LOGLVL
export CAPABILITY=$CAPLEVEL
export SECURESOC=$SECUREDSOC
export UART_LOG_DISABLE=$UARTLOGDISABLE
export FILTER_SETTING=$FILTERSETTING
export MODEL_NUMBER=$MODEL
export FLASH_SIZE="${FLASH%MB}"
 
echo "branch" $GITBRANCH
echo "loglevel" $LOGLEVEL
echo "customername" $CUSTOMERNAME
echo "capability" $CAPABILITY
echo "securedBuild"	$SECUREDBUILD
echo "securedSoc"	$SECURESOC
echo "uartLogDisable" $UART_LOG_DISABLE
echo "filterSetting" $FILTERSETTING
echo "model" $MODEL
echo "Flash" $FLASH_SIZE
 
sleep 5
printParams
checkParams
removeExisting
getCode
#exit
useTypeInfo
useBoardInfo
useCustomerInfo
generateSecuredKeys
versioning
build
genOTAHostingBuild $MODEL
#copyBuild
#sendMail
