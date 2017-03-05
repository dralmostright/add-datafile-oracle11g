#/bin/bash
echo "##################################################################"
echo "## Author : Suman Adhikari                                      ##"
echo "## Date of Version : 24-02-2017                                 ##"
echo "## Description: The scripts Adds the datafile to the Name of    ##"
echo "## Tablespace provied by the user.                              ##"
echo "##################################################################"

_errorReport(){
       echo "########################################################"
       echo "Error during Running Scripts"
       echo "Error: $1 "
       echo "########################################################"
       exit 1
}


#printf "\t Enter the Oracle SID of the Database : "
#read -r ORA_SID
#ORACLE_SID=`echo $ORA_SID`

##
## Test if the respective environmental variables are set or not.
## 

if [[ "${ORACLE_HOME}" = "" ]]
then
 _errorReport "ORACLE_HOME Environmental variable not Set. Aborting...."
fi

if [ ! -d ${ORACLE_HOME} ]
then
 _errorReport "Directory \"${ORACLE_HOME}\" not Valid. Aborting...."
fi

if [ ! -x ${ORACLE_HOME}/bin/sqlplus ]
then
 echo "Executable \"${ORACLE_HOME}/bin/sqlplus\" not found; aborting..."
fi

if [[ "${ORACLE_SID}" = "" ]]
then
 _errorReport "ORACLE_SID Environmental variable not Set. Aborting...."
fi

#
# Function to report the error and exit the script.
#

#_errorReport(){
#       echo "########################################################"
#       echo "Error during Running Scripts"
#       echo "Error: $1 "
#       echo "########################################################"
#       exit 1
#}

## List the status of the overall tablespace status for the database.
## 
count=$(sqlplus -s /nolog <<END
set pagesize 0 feedback off verify off echo off;
connect / as sysdba    
set lines 222
column "Tablespace" format a25
column "Total Size in MB" format 999,999,999.99
column "Total Used in MB" format 999,999,999.99
column "Total free in MB" format 999,999,999.99
column "Used %" format a6
column "Free %" format a6

select tablespace_name "Tablespace",
round("Total in MB",2) "Total Size in MB",
round("Free in MB",2) "Total Free in MB",
round("Total in MB" - "Free in MB", 2) as "Total Used in MB",
round((("Total in MB" - "Free in MB")/"Total in MB")*100,2)||'%' as "Used %",
(round(100-(("Total in MB" - "Free in MB")/"Total in MB")*100,2))||'%' as "Free %"
from (select tablespace_name ,
sum( bytes /(1024*1024)) "Free in MB"  from dba_free_space
group by tablespace_name) ts join (select tablespace_name , sum( bytes/(1024*1024)) "Total in MB"
from dba_data_files group by tablespace_name) using ( tablespace_name) order by 4 desc;

exit;
END
)

bold=$(tput bold)
reset=$(tput sgr0)
bell=$(tput bel)
green=$(tput setaf 2)

##
## Dispaly the Tablespace Status
## 

echo ""

echo "##########################################################################################"
echo "Tablespace                Total Size in MB Total Free in MB Total Used in MB Used % Free %"
echo "------------------------- ---------------- ---------------- ---------------- ------ ------"
echo -e "${count}"
echo ""
echo "##########################################################################################"
echo ""
printf "Enter the Name of Tablespace to extend : "
read -r tablespace
totalcount=$(echo -e "${count}" | grep $tablespace | wc -l)
if [[ $totalcount == 1 ]]; 
then
  echo ""
  echo "> Selected Tablespace to add datafile : ${bold}$tablespace${reset}."
else
  echo ""
 _errorReport "Tablespace ${bell}${bold}$tablespace ${reset}name doesnot exists. Aborting...."
fi

directories=$(sqlplus -s /nolog <<END
set pagesize 0 feedback off verify off echo off;
connect / as sysdba    
set lines 222
select substr(file_name, 1, instr(file_name, '/',-1)) PATH from dba_data_files where tablespace_name='$tablespace';
exit;
END
)

directories=$(echo -e "${directories}" | sort | uniq)
echo ""
echo "> Directories containing Datafile for the specified tablespace: $tablespace"
echo -e "${directories}"

echo ""
directories=`echo -e "${directories}" | tail -1` 

datafileno=$(sqlplus -s /nolog <<END
set pagesize 0 feedback off verify off echo off;
connect / as sysdba    
set lines 222
select substr("Datafile", - instr(reverse("Datafile"),'.') -2,2) from(
select substr(df.name, - instr(reverse(df.name), '/') + 1) "Datafile" from v\$datafile df join v\$tablespace ts using (ts#) where ts.name='$tablespace' order by creation_time) tts;
exit;
END
)

#echo -e "${datafileno}"
datafileno=`echo -e "${datafileno}" | tail -1`
datafileno=$(expr "$datafileno" + 1)

regex='^[0-9]+$'
if ! [[ $datafileno =~ $regex ]] ;
then
 _errorReport "Datafile format not compatible i.e not numeric at end."
fi

if [ $datafileno -lt 10 ]; 
then
   datafileno=00`echo $datafileno`
elif [ $datafileno -lt 100 ]
then
   datafileno=0`echo $datafileno`
else
  datafileno=`echo $datafileno`
fi

#regex='^[0-9]+$'
#if ! [[ $datafileno =~ $regex ]] ; 
#then
# _errorReport "Datafile format not compatible i.e not numeric at end."
#fi

#echo ""
echo "> Datafile number to be added : $datafileno"

echo ""
echo "> Script to add datafile to tablespace: $tablespace"
dbfaddscript=$(sqlplus -s /nolog <<END
set pagesize 0 feedback off verify off echo off;
connect / as sysdba    
set lines 222
select 'ALTER TABLESPACE $tablespace ADD DATAFILE ' || '''$directories$tablespace$datafileno.dbf''' || ' SIZE 1M AUTOEXTEND ON next 200M MAXSIZE 10G;' from dual;
exit;
END
)

echo -e "${dbfaddscript}"

dbfaddstatus=$(sqlplus -s /nolog <<END
set pagesize 0 feedback off verify off echo off;
WHENEVER OSERROR EXIT 9;
WHENEVER SQLERROR EXIT SQL.SQLCODE;
connect / as sysdba
set lines 222
$dbfaddscript
exit;
END
)

echo -e "${dbfaddstatus}"

sql_return_code=$?

if [[ $sql_return_code -eq 0 ]];
then
   echo "> Datafile successfully add to tablespace: $tablespace."
else
   echo "Datafile was not successfully added."
fi


echo '
***************************
********* DONE ************
***************************
'
