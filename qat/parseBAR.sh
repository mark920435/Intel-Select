export BUSYBOX=/root/Downloads/busybox-1.31.1
export CURRENT=$(pwd)
declare -a DESC=(RICPPINTCTL ERRSOU0 ERRSOU1 ERRSOU2 ERRSOU3 ERRSOU4 ERRSOU5 ERRMSK0 ERRMSK1 ERRMSK2 ERRMSK3 EPERRLOG \
                 RIMISCCTL ERRSOU4 ERRMSK4 RICPPINTSTS RIERRPUSHID RIERRPULLID \
                 INTSTATSSM[0] INTSTATSSM[1] INTSTATSSM[2] INTSTATSSM[3] INTSTATSSM[4] \
                 PPERR[0] PPERR[1] PPERR[2] PPERR[3] PPERR[4] \
                 PPERRID[0] PPERRID[1] PPERRID[2] PPERRID[3] PPERRID[4] \
                 CERRSSMSH[0] CERRSSMSH[1] CERRSSMSH[2] CERRSSMSH[3] CERRSSMSH[4] \
                 CERSSMSHAD[0] CERSSMSHAD[1] CERSSMSHAD[2] CERSSMSHAD[3] CERSSMSHAD[4] \
                 UERRSSMSH[0] UERRSSMSH[1] UERRSSMSH[2] UERRSSMSH[3] UERRSSMSH[4] \
                 UERRSSMSHAD[0] UERRSSMSHAD[1] UERRSSMSHAD[2] UERRSSMSHAD[3] UERRSSMSHAD[4] \
                 CERRSSMMMP0[0] CERRSSMMMP0[1] CERRSSMMMP0[2] CERRSSMMMP0[3] CERRSSMMMP0[4] \
                 CERRSSMMMP0AD[0] CERRSSMMMP0AD[1] CERRSSMMMP0AD[2] CERRSSMMMP0AD[3] CERRSSMMMP0AD[4] \
                 UERRSSMMMP0[0] UERRSSMMMP0[1] UERRSSMMMP0[2] UERRSSMMMP0[3] UERRSSMMMP0[4]
                 UERRSSMMMP0AD[0] UERRSSMMMP0AD[1] UERRSSMMMP0AD[2] UERRSSMMMP0AD[3] UERRSSMMMP0AD[4] \
                 CERRSSMMMP1[0] CERRSSMMMP1[1] CERRSSMMMP1[2] CERRSSMMMP1[3] CERRSSMMMP1[4] \
                 CERRSSMMMP1AD[0] CERRSSMMMP1AD[1] CERRSSMMMP1AD[2] CERRSSMMMP1AD[3] CERRSSMMMP1AD[4] \
                 UERRSSMMMP1[0] UERRSSMMMP1[1] UERRSSMMMP1[2] UERRSSMMMP1[3] UERRSSMMMP1[4] \
                 UERRSSMMMP1AD[0] UERRSSMMMP1AD[1] UERRSSMMMP1AD[2] UERRSSMMMP1AD[3] UERRSSMMMP1AD[4] \
                 CERRSSMMMP2[0] CERRSSMMMP2[1] CERRSSMMMP2[2] CERRSSMMMP2[3] CERRSSMMMP2[4] \
                 CERRSSMMMP2AD[0] CERRSSMMMP2AD[1] CERRSSMMMP2AD[2] CERRSSMMMP2AD[3] CERRSSMMMP2AD[4] \
                 UERRSSMMMP2[0] UERRSSMMMP2[1] UERRSSMMMP2[2] UERRSSMMMP2[3] UERRSSMMMP2[4] \
                 UERRSSMMMP2AD[0] UERRSSMMMP2AD[1] UERRSSMMMP2AD[2] UERRSSMMMP2AD[3] UERRSSMMMP2AD[4] \
                 CERRSSMMMP3[0] CERRSSMMMP3[1] CERRSSMMMP3[2] CERRSSMMMP3[3] CERRSSMMMP3[4] \
                 CERRSSMMMP3AD[0] CERRSSMMMP3AD[1] CERRSSMMMP3AD[2] CERRSSMMMP3AD[3] CERRSSMMMP3AD[4] \
                 UERRSSMMMP3[0] UERRSSMMMP3[1] UERRSSMMMP3[2] UERRSSMMMP3[3] UERRSSMMMP3[4] \
                 UERRSSMMMP3AD[0] UERRSSMMMP3AD[1] UERRSSMMMP3AD[2] UERRSSMMMP3AD[3] UERRSSMMMP3AD[4] \
                 CERRSSMMMP4[0] CERRSSMMMP4[1] CERRSSMMMP4[2] CERRSSMMMP4[3] CERRSSMMMP4[4] \
                 CERRSSMMMP4AD[0] CERRSSMMMP4AD[1] CERRSSMMMP4AD[2] CERRSSMMMP4AD[3] CERRSSMMMP4AD[4] \
                 UERRSSMMMP4[0] UERRSSMMMP4[1] UERRSSMMMP4[2] UERRSSMMMP4[3] UERRSSMMMP4[4] \
                 UERRSSMMMP4AD[0] UERRSSMMMP4AD[1] UERRSSMMMP4AD[2] UERRSSMMMP4AD[3] UERRSSMMMP4AD[4] \
                 SecRAMCERR SecRAMUERR SecRAMCERRAD SecRAMUERRAD CPPMEMTGTERR \
                 TICPPINTSTS TIERRPUSHID TIERRPULLID TIMISCCTL TIMISCSTS \
                 SLICEHANGSTATUS METHDSTS0 METHDSTS1 METHDSTS2 \
                 CPP_CFC_ERR_STATUS CPP_CFC_ERR_PPID DRAM_ADDR_HI DRAM_ADDR_LO RAMBASEADDRHI RAMBASEADDRLO)
declare -a OFFSET=(0x3A110 0x3A000 0x3A004 0x3A008 0x3A00C 0x3A0D0 0x3A0D8 0x3A010 0x3A014 0x3A018 0x3A01C 0x3A020 \
                 0x3A0C4 0x3A0D0 0x3A0D4 0x3A114 0x3A118 0x3A11C \
                 0x0004 0x4004 0x8004 0xC004 0x10004 \
                 0x0008 0x4008 0x8008 0xC008 0x10008 \
                 0x000C 0x400C 0x800C 0xC00C 0x1000C \
                 0x0010 0x4010 0x8010 0xC010 0x10010 \
                 0x0014 0x4014 0x8014 0xC014 0x10010 \
                 0x0018 0x4018 0x8018 0xC018 0x10018 \
                 0x001C 0x401C 0x801C 0xC01C 0x1001C \
                 0x0380 0x4380 0x8380 0xC380 0x10380 \
                 0x0384 0x4384 0x8384 0xC384 0x10384 \
                 0x0388 0x4388 0x8388 0xC388 0x10388 \
                 0x038C 0x438C 0x838C 0xC38C 0x1038C \
                 0x1380 0x5380 0x9380 0xD380 0x11380 \
                 0x1384 0x5384 0x9384 0xD384 0x11384 \
                 0x1388 0x5388 0x9388 0xD388 0x11388 \
                 0x138C 0x538C 0x938C 0xD38C 0x1138C \
                 0x2380 0x6380 0xA380 0xE380 0x12380 \
                 0x2384 0x6384 0xA384 0xE384 0x12384 \
                 0x2388 0x6388 0xA388 0xE388 0x12388 \
                 0x238C 0x638C 0xA38C 0xE38C 0x1238C \
                 0x3380 0x7380 0xB380 0xF380 0x13380 \
                 0x3384 0x7384 0xB384 0xF384 0x13384 \
                 0x3388 0x7388 0xB388 0xF388 0x13388 \
                 0x338C 0x738C 0xB38C 0xF38C 0x1338C \
                 0x0B80 0x4B80 0x8B80 0xCB80 0x10B80 \
                 0x0B84 0x4B84 0x8B84 0xCB84 0x10B84 \
                 0x0B88 0x4B88 0x8B88 0xCB88 0x10B88 \
                 0x0B8C 0x4B8C 0x8B8C 0xCB8C 0x10B8C \
                 0x3AC00 0x3AC04 0x3AC08 0x3AC0C 0x3AC10 \
                 0x3A53C 0x3A540 0x3A544 0x3A548 0x3A54C \
                 0x404C 0x3A76C 0x3A770 0x3A774 \
                 0x30C04 0x30C0C 0x308D0 0x308CC 0x308D4 0x308D8)
declare -a PLATFORM_ID=(0435 0443 37c8 19e2)
declare -a PLATFORM=("Coleto (DH895XCC)" "Coleto VF (DH895XCCIOV)" "Lewisburg (C62X)" "Denverton (C3XXX)")
#declare -a PLATFORM=(DH895XCC DH895XCCIOV C62X C3XXX)

PMISCBAR=""
VALUE=""
BUS=""


GetPMISCBAR(){
    rm -f $CURRENT/FormatReg.txt
    platform_id_len=${#PLATFORM_ID[@]}
    for (( i=0; i<$platform_id_len;i++ ))
    do
        platform_id="PLATFORM_ID[i]"
        platform="PLATFORM[i]"
        #echo ${!platform_id}
        if [ ! -z "$(lspci -vnd "8086:${!platform_id}")" ]
        then
        BUS=$(lspci -vnd "8086:${!platform_id}" | grep ${!platform_id} | cut -d ' ' -f 1 | sed ':a;N;$!ba;s/\n/ /g')
        PMISCBAR=$(lspci -vnd "8086:${!platform_id}" | grep "non-prefetchable" | awk 'NR % 2 == 1'  | cut -d ' ' -f 3 | sed ':a;N;$!ba;s/\n/ /g')
        fi
        echo "========================================"
        echo "            ${!platform}                "
        echo "========================================"
        PrintErrorReg
        FormatErrorReg
        PMISCBAR=""
    done
    #echo "PMISCBAR $PMISCBAR"
    #echo $BUS
}


GetValue(){
    base=$1
    offset=$2
    temp=$(( $base + $offset ))
    addr=`printf "0x%X\n" $temp`
    VALUE=$($BUSYBOX/busybox devmem $addr)
}

PrintErrorReg(){
    for address in $PMISCBAR
    do
        echo "----------------------------------------"
        echo "PMISCBAR 0x$address"
        
        echo "----------------------------------------"
        echo "DESCRIPTION          OFFSET          VALUE"
    
        desc_len=${#DESC[@]}
        for (( j=0; j<$desc_len;j++ ))
        do
            desc="DESC[j]"
            offset="OFFSET[j]"
            GetValue "0x$address" $offset
            printf "%-20s %-15s %-15s\n" ${!desc} ${!offset} $VALUE
        done
     done
}

FormatErrorReg(){
    touch $CURRENT/FormatReg.txt
    array_index=0
    for address in $PMISCBAR
    do
        array_index=`expr $array_index + 1`
        desc_len=${#DESC[@]}
        for (( j=0; j<$desc_len;j++ ))
        do
            if(( $j % 5 == 0 ))
            then
                echo "" >> $CURRENT/FormatReg.txt
                echo -n "[-----.------] c6xx 0000:$(echo $BUS | cut -d ' ' -f $array_index): " >> $CURRENT/FormatReg.txt
            fi
            desc="DESC[j]"
            offset="OFFSET[j]"
            GetValue "0x$address" $offset
            if [[ "${!desc}" == *"]"* ]]
            then
                printf "%s,%s," ${!desc} ${VALUE:2:8} >> $CURRENT/FormatReg.txt
            else
                printf "%s[0],%s," ${!desc} ${VALUE:2:8} >> $CURRENT/FormatReg.txt
            fi
        done
        echo "" >> $CURRENT/FormatReg.txt
     done
    #echo "" >> $CURRENT/FormatReg.txt
}

GetPMISCBAR
