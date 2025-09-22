#Just prints
function printParams()
{
	echo FLASH=$FLASH
	echo TYPE=$TYPE
	echo BOARD=$BOARD
	echo CUSTOMER=$CUSTOMER
	echo SHA=$SHA
	return 0
}

#Returns 99 if something is wrong
function isValid()
{
		local toSearch="$1"
		shift
		local list=("$@")

		for item in "${list[@]}"; do
				if [[ "$item" == "$toSearch" ]]; then
						return 0
				fi
		done
		return 99
}

function isError()
{
	if [[ "$?" -ne 0 ]]; then
		echo "Error!!! code $1"
		exit
	fi
}
#Check if params are valid
function checkParams()
{

	isValid $FLASH "${FLASHLIST[@]}"
	isError $LINENO
	isValid $BOARD "${BOARDLIST[@]}"
	isError $LINENO
	isValid $CUSTOMER "${CUSTOMERLIST[@]}"
	isError $LINENO
	isValid $SECUREDBUILD "${SECURITYLIST[@]}"
	isError $LINENO
	isValid $LOGLEVEL "${LOGLEVELLIST[@]}"
	isError $LINENO
	isValid $CAPABILITY "${CAPABILITYLIST[@]}"
	isError $LINENO
		
}

function updateToken()
{
	cd $fullPath
	echo git remote set-url origin $GITHUBURL
	cd -
}

function removeExisting()
{
	rm -rf Platform
	sleep 2
	rm -rf HE3
}

function getCode()
{
	#check if code is present in the path or not
	local fullPath=$CHECKOUTPATH/$CHECKOUTPARENTFOLDER
	local branchname=""
	
	#uncomment below if token is updated
	updateToken
	
	if [ ! -d "$fullPath" ]; then
		echo "$fullPath doesn't exist, cloning..."
		git clone $GITHUBURL $fullPath
		isError $LINENO
		cd $fullPath
		git checkout $GITBRANCH
		isError $LINENO
	else
		echo "$fullPath exist, updating..."
		cd $fullPath
		git checkout $GITBRANCH
		isError $LINENO
		git reset --hard $SHA
		isError $LINENO
		git clean -fd
		isError $LINENO		
	fi
	
	branchname=$(git rev-parse --abbrev-ref HEAD)
	GITSHA=$(git rev-parse HEAD | cut -c1-8)
	
	echo "GIT BRANCHNAME=$branchname"
	echo "GIT SHA=$GITSHA"
	
	sleep 3
	
	cd $CHECKOUTPATH
}

function useFlashInfo()
{
	echo "Configuring for FLASH=$FLASH..."
	
	#remove ld file
	rm $FLASHLD
	
	#remove flashcfg file
	rm $FLASHCFG
	
	if [ "$FLASH" == 2 ]; then
	
		echo "Copying $FLASHCFG2 as $FLASHCFG"
		cp $FLASHCFG2 $FLASHCFG
		
		echo "Copying $FLASHLD2 as $FLASHLD"
		cp $FLASHLD2 $FLASHLD
		
	elif [ "$FLASH" == 4 ]; then
	
		echo "Copying $FLASHCFG4 as $FLASHCFG"
		cp $FLASHCFG4 $FLASHCFG
		
		echo "Copying $FLASHLD4 as $FLASHLD"
		cp $FLASHLD4 $FLASHLD
	fi
	
}

function useTypeInfo()
{
	echo "TODO"
	#if production
	#{
	#	disableUART
	#	disableLogs
	#}
	
	#if dev
	#{
	#	enableUART
	#	enableMaxLogLevel
	#}
	#
	
}

function useBoardInfo()
{
	echo "TODO"
	#if htap or evb or demo
	#{
	#	changeLEDGpios
	#	changeControlGpios
	#}
}

function useCustomerInfo()
{
	echo "TODO"
	#if bajaj or superfan 
	#{
	#	changeLEDGpios
	#	changeControlGpios
	#}
}

function genOTAHostingBuild()
{
	if [ "$PLATFORM" == "he3" ]; then
		echo "generating hosting build"
		python HE3_Flash_and_OTA_image_generation_script.py
		echo "generating hosting build success"
	elif [ "$FLASH" == "8MB" ]; then
		python hoagsOTAHostingImageGeneration_FW_8MB_Havells.py $CHECKOUTPARENTFOLDER/$SRCIMAGEPATH/OTA_All.bin $CHECKOUTPARENTFOLDER/$SRCIMAGEPATH/OTA_All_8MB.xz.bin
		sleep 2
		python Combine_BLder_Env_hoagsOTAHostingImageGeneration_8MB_Havells.py --inputFw $CHECKOUTPARENTFOLDER/$SRCIMAGEPATH/OTA_All.bin --inputEnv dummyEnv.bin --inputBootL $CHECKOUTPARENTFOLDER/$SRCIMAGEPATH/km4_boot_all.bin --outputImage $CHECKOUTPARENTFOLDER/$SRCIMAGEPATH/OTA_All_withBootloader_8MB.xz.bin
	else
		python hoagsOTAHostingImageGeneration.py $CHECKOUTPARENTFOLDER/$SRCIMAGEPATH/OTA_All.bin $CHECKOUTPARENTFOLDER/$SRCIMAGEPATH/OTA_All_4MB.xz.bin $1
		sleep 2
		python Combine_BLder_Env_hoagsOTAHostingImageGeneration.py --inputFw $CHECKOUTPARENTFOLDER/$SRCIMAGEPATH/OTA_All.bin --inputEnv dummyEnv.bin --inputBootL $CHECKOUTPARENTFOLDER/$SRCIMAGEPATH/km4_boot_all.bin --outputImage $CHECKOUTPARENTFOLDER/$SRCIMAGEPATH/OTA_All_withBootloader_4MB.xz.bin
	fi


	
}

function generateSecuredKeys()
{
	if [ "$SECUREDBUILD" == "1" ]; then
		if [ "$CUSTOMERNAME" == "HAVELLS_HANDTUNED" ] || [ "$CUSTOMERNAME" == "HAVELLS_AC" ]; then
			#echo 'hello world'
			cp -rf $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/$SECURITYHAVELLSFOLDER/* $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/../
	
		elif [ "$CUSTOMERNAME" == "VIRTUALFOREST_AC" ]; then
		
			cp -rf $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/$SECURITYVIRTUALFORESTFOLDER/* $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/../
			
		elif [ "$CUSTOMERNAME" == "VERSADEVICES_SUPERFAN_IOT" ]; then
			
			cp -rf $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/$SECURITYVERSADEVICESFOLDER/* $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/../
			
		elif [ "$CUSTOMERNAME" == "LIVPURE_CHIMNEY" ] || [ "$CUSTOMERNAME" == "LIVPURE_CHIMNEY_SMOKE" ]; then
			
			#echo "Here"
			cp -rf $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/$SECURITYLIVPUREFOLDER/* $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/../
			
		elif [ "$CUSTOMERNAME" == "POLYCAB_FAN" ]; then
			
			cp -rf $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/$SECURITYPOLYCABFOLDER/* $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/../
		
		elif [ "$CUSTOMERNAME" == "AMBER_AIRCOOLER" ]; then
			
			cp -rf $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/$SECURITYAMBERFOLDER/* $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/../
		
		elif [ "$CUSTOMERNAME" == "UNISEMI" ] || [ "$CUSTOMERNAME" == "RR_KABLES" ] || [ "$CUSTOMERNAME" == "ATOMBERG_FAN" ] || [ "$CUSTOMERNAME" == "MOBILISE_FMHUB" ] || [ "$CUSTOMERNAME" == "AMBER_AC" ] || [ "$CUSTOMERNAME" == "VGUARD_NEW_FAN" ] || [ "$CUSTOMERNAME" == "OMNI_AC" ] || [ "$CUSTOMERNAME" == "INDCOOL_AC" ] || [ "$CUSTOMERNAME" == "HOAGS_DEMO_LIGHT" ] || 
[ "$CUSTOMERNAME" == "LIVPURE_PURIFIER" ] || [ "$CUSTOMERNAME" == "SYMPHONY_AIRCOOLER" ] || [ "$CUSTOMERNAME" == "CRUISE_AC" ] || [ "$CUSTOMERNAME" == "ORIENT" ]; then
			
			#cp -rf $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/$SECURITYLIVPUREFOLDER/* $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/../
			echo "Using POC keys"
			cp -rf $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/$SECURITYPOCFOLDER/* $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SECUREDPATH/../

		else
		
			echo "Security keys not yet generated for $CUSTOMERNAME, aborting build!!!"
			exit

		fi
	fi	
	
}

function build()
{
		
	
	local makePath=$CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$MAKEPATH

	cd $makePath
	make clean
	sleep 2
	make
	if [[ $? -ne 0 ]]; then
		echo "Build Error!!!, aborting..."
		exit
	fi
	cd $CHECKOUTPATH
}

function versioning()
{
	
	local version=$PLATFORM.$TYPE
	local minor=""

	if [ "$TYPE" == "prod" ]; then
	
		minor=$(<$PRODVERSIONFILE)
		jq ".IMG_VER_MAJOR = $MAJORPROD" $MANIFESTFILEPATH > .output.json && mv .output.json $MANIFESTFILEPATH
		jq ".IMG_VER_MINOR = $minor" $MANIFESTFILEPATH > .output.json && mv .output.json $MANIFESTFILEPATH
		version=$version.$minor
		
	elif [ "$TYPE" == "dev" ]; then
		echo SHIT1
		if [ "$PLATFORM" == "he3" ]; then
			minor=$(<$DEVVERSIONFILE)
			
			#Handle versioning for HE3
			jq ".FWHS.header.serial = $minor" $MANIFESTFILEPATH > .output.json && mv .output.json $MANIFESTFILEPATH
			stt="#define VERSION_MINOR $minor"
			echo Current Path $PWD
			echo $VERSION_HEADER_FILE
			sed -i "2c\\$stt" $VERSION_HEADER_FILE
			version=$version.$minor
			
			#Handle security for HE3
			if [ "$SECURESOC" == "1" ]; then
				jq ".PARTAB.header.enc = true" $MANIFESTFILEPATH_BOOTLOADER > .output.json && mv .output.json  $MANIFESTFILEPATH_BOOTLOADER
				jq ".BOOT.header.enc = true" $MANIFESTFILEPATH_BOOTLOADER > .output.json && mv .output.json  $MANIFESTFILEPATH_BOOTLOADER
				sed -i 's/BOOTLOADER secure_bit=0/BOOTLOADER secure_bit=1/g' $MAKEFILE_PATH
				sed -i 's/PARTITIONTABLE secure_bit=0/PARTITIONTABLE secure_bit=1/g' $MAKEFILE_PATH
				sed -i 's/FIRMWARE secure_bit=0/FIRMWARE secure_bit=1/g' $MAKEFILE_PATH
				
			fi
			

		else
			minor=$(<$DEVVERSIONFILE)
			jq ".IMG_VER_MAJOR = $MAJORDEV" $MANIFESTFILEPATH > .output.json && mv .output.json $MANIFESTFILEPATH
			jq ".IMG_VER_MINOR = $minor" $MANIFESTFILEPATH > .output.json && mv .output.json $MANIFESTFILEPATH
			version=$version.$minor
		fi
		
	elif [ "$TYPE" == "test" ]; then
		if [ "$PLATFORM" == "he3" ]; then
			echo SHIT5
			minor=$(<$TESTVERSIONFILE)
			jq ".FWHS.header.serial = $minor" $MANIFESTFILEPATH > .output.json && mv .output.json $MANIFESTFILEPATH
			stt="#define VERSION_MINOR $minor"
			echo Current Path $PWD
			echo $VERSION_HEADER_FILE
			sed -i "2c\\$stt" $VERSION_HEADER_FILE
			version=$version.$minor
			
			#Handle security for he3
			if [ "$SECURESOC" == "1" ]; then
				jq ".PARTAB.header.enc = true" $MANIFESTFILEPATH_BOOTLOADER > .output.json && mv .output.json  $MANIFESTFILEPATH_BOOTLOADER
				jq ".BOOT.header.enc = true" $MANIFESTFILEPATH_BOOTLOADER > .output.json && mv .output.json  $MANIFESTFILEPATH_BOOTLOADER
				sed -i 's/BOOTLOADER secure_bit=0/BOOTLOADER secure_bit=1/g' $MAKEFILE_PATH
				sed -i 's/PARTITIONTABLE secure_bit=0/PARTITIONTABLE secure_bit=1/g' $MAKEFILE_PATH
				sed -i 's/FIRMWARE secure_bit=0/FIRMWARE secure_bit=1/g' $MAKEFILE_PATH
				echo "going here"
				
			fi
		else
			minor=$(<$TESTVERSIONFILE)
			jq ".IMG_VER_MAJOR = $MAJORTEST" $MANIFESTFILEPATH > .output.json && mv .output.json $MANIFESTFILEPATH
			jq ".IMG_VER_MINOR = $minor" $MANIFESTFILEPATH > .output.json && mv .output.json $MANIFESTFILEPATH
			version=$version.$minor
		fi
		
	elif [ "$TYPE" == "test-ota" ]; then
		minor=9999
		if [ "$PLATFORM" == "he3" ]; then
			jq ".FWHS.header.serial = $minor" $MANIFESTFILEPATH > .output.json && mv .output.json $MANIFESTFILEPATH
			stt="#define VERSION_MINOR $minor"
			echo Current Path $PWD
			echo $VERSION_HEADER_FILE
			sed -i "2c\\$stt" $VERSION_HEADER_FILE
			version=$version.$minor
			
		else
		
			jq ".IMG_VER_MAJOR = $MAJORTEST" $MANIFESTFILEPATH > .output.json && mv .output.json $MANIFESTFILEPATH
			jq ".IMG_VER_MINOR = $minor" $MANIFESTFILEPATH > .output.json && mv .output.json $MANIFESTFILEPATH
			version=$version.$minor
		fi
		
	fi
	
	VERSION=$version
	
	echo "Build Version=$version"
	
}

function copyBuild()
{

	local epoch=$(date +"%s")
	cd $CHECKOUTPATH/$CHECKOUTPARENTFOLDER && GITSHA=$(git rev-parse HEAD | cut -c1-8)
	BUILDNAME=$VERSION-$GITSHA-$epoch.zip
	if [ "$PLATFORM" == "he2" ]; then
		cd $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SRCIMAGEPATH && cd ../ && zip -r $TARGETIMAGEPATH/$BUILDNAME bin
			
	elif [ "$PLATFORM" == "he3" ]; then
		cd $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SRCIMAGEPATH && cd ../ && zip -r $TARGETIMAGEPATH/$BUILDNAME application_is
		
	else
		cd $CHECKOUTPATH/$CHECKOUTPARENTFOLDER/$SRCIMAGEPATH && cd ../ && zip -r $TARGETIMAGEPATH/$BUILDNAME image
	fi
    	 
	cd $CHECKOUTPATH
}

function copyToolChain()
{
	cp -rf /home/build/build-scripts/patches/vsdk /home/build/build-scripts/Platform/Entry/HE1/RTL872xEA_v10.1c_beta/project/realtek_amebaLite_va0_example/GCC-RELEASE/project_kr4/toolchain/
	cp -rf /home/build/build-scripts/patches/asdk /home/build/build-scripts/Platform/Entry/HE1/RTL872xEA_v10.1c_beta/project/realtek_amebaLite_va0_example/GCC-RELEASE/project_km4/toolchain/
}

function incrementVersionFile()
{
	if [ "$TYPE" == "prod" ]; then
	
		number=$(<$PRODVERSIONFILE)
		number=$(($number+1))
		echo $number > $PRODVERSIONFILE
		
	elif [ "$TYPE" == "dev" ]; then
	
		number=$(<$DEVVERSIONFILE)
		number=$(($number+1))
		echo $number > $DEVVERSIONFILE
		
	elif [ "$TYPE" == "test" ]; then
	
		number=$(<$TESTVERSIONFILE)
		number=$(($number+1))
		echo $number > $TESTVERSIONFILE
	fi
}

function postBuild()
{
	echo "Post Build operation here"
}

function sendMail()
{	
	
	IP_ADDRESS=$(hostname -I | awk '{print $1}')
	cd $CHECKOUTPARENTFOLDER
	BRANCHNAME=$(git rev-parse --abbrev-ref HEAD)
	echo $BRANCHNAME $(pwd)
	cd $CHECKOUTPATH 
	echo $(pwd)

	local buildLink="http://$IP_ADDRESS/builds/local/he1/$BUILDNAME"
	echo "Build $VERSION generated" > $SUBJFILE
	echo -e "Hi all,\n" > $BODYFILE
	echo -e "Please find the build details below:\n" >> $BODYFILE
	echo -e "Version=$VERSION" >> $BODYFILE
	echo -e "Flash=$FLASH" >> $BODYFILE
	echo -e "Type=$TYPE" >> $BODYFILE
	echo -e "Board=$BOARD" >> $BODYFILE
	echo -e "Customer=$CUSTOMER" >> $BODYFILE
	echo -e "Loglevel=$LOGLEVEL" >> $BODYFILE
	echo -e "Capability=$CAPABILITY" >> $BODYFILE
	echo -e "SecurityBuild=$SECUREDBUILD" >> $BODYFILE
	echo -e "SecuritySoc=$SECUREDSOC" >> $BODYFILE
	echo -e "uartLogDisable=$UARTLOGDISABLE" >> $BODYFILE
	echo -e "ModelNumber=$MODEL" >> $BODYFILE
	echo -e "BranchName=$BRANCHNAME" >> $BODYFILE
	echo -e "Note:=" $NOTE >> $BODYFILE
	echo -e "Buildlink=$buildLink" >> $BODYFILE
	echo -e "\nRegards,\nBuildServer" >> $BODYFILE

	python mailer.py
	
	incrementVersionFile
	
	echo "BuildLink=$buildLink"
	
	rm -rf $SUBJFILE $BODYFILE
	
}




