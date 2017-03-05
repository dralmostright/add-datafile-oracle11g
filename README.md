# Add datafile to Oracle Database running on Unix

The script is designed to add datafile to a selected tablespace for oracle database version (10g and 11g). The script automatically generates the script and executes when all prerequisites are meet.

E.g Of successful run of script:

```
[oracle@dralmostright scripts]$ ./tablespaceadd.sh 
##################################################################
## Author : Suman Adhikari                                      ##
## Date of Version : 24-02-2017                                 ##
## Description: The scripts Adds the datafile to the Name of    ##
## Tablespace provied by the user.                              ##
##################################################################

##########################################################################################
Tablespace                Total Size in MB Total Free in MB Total Used in MB Used % Free %
------------------------- ---------------- ---------------- ---------------- ------ ------
SYSTEM                              740.00             2.69           737.31 99.64% .36%
SYSAUX                              780.00            43.25           736.75 94.46% 5.54%
UNDOTBS1                             45.00            33.38            11.63 25.83% 74.17%
USERS                                 5.00             3.69             1.31 26.25% 73.75%
TS_SOMETHING                          2.00             1.88              .13 6.25%  93.75%

##########################################################################################

Enter the Name of Tablespace to extend : TS_SOMETHING

> Selected Tablespace to add datafile : TS_SOMETHING.

> Directories containing Datafile for the specified tablespace: TS_SOMETHING
/oradata/smart_dc/

> Datafile number to be added : 003

> Script to add datafile to tablespace: TS_SOMETHING
ALTER TABLESPACE TS_SOMETHING ADD DATAFILE '/oradata/smart_dc/TS_SOMETHING003.dbf' SIZE 1M AUTOEXTEND ON next 200M MAXSIZE 10G;

> Datafile successfully add to tablespace: TS_SOMETHING.

***************************
********* DONE ************
***************************

[oracle@dralmostright scripts]$ 

```

E.g of unsuccesful execution of script:

```
[oracle@dralmostright scripts]$ ./tablespaceadd.sh 
##################################################################
## Author : Suman Adhikari                                      ##
## Date of Version : 24-02-2017                                 ##
## Description: The scripts Adds the datafile to the Name of    ##
## Tablespace provied by the user.                              ##
##################################################################

##########################################################################################
Tablespace                Total Size in MB Total Free in MB Total Used in MB Used % Free %
------------------------- ---------------- ---------------- ---------------- ------ ------
SYSTEM                              740.00             2.69           737.31 99.64% .36%
SYSAUX                              780.00            43.25           736.75 94.46% 5.54%
UNDOTBS1                             45.00            33.38            11.63 25.83% 74.17%
USERS                                 5.00             3.69             1.31 26.25% 73.75%
TS_SOMETHING                          3.00             2.81              .19 6.25%  93.75%

##########################################################################################

Enter the Name of Tablespace to extend : system

########################################################
Error during Running Scripts
Error: Tablespace system name doesnot exists. Aborting.... 
########################################################
[oracle@dralmostright scripts]$ 

```

