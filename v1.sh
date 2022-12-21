#! /bin/bash
#MR extension stands for MohamedRaphael DBMS Developers :) 
# to start please un comment next line for a once then comment it again
#touch users.MR
declare name
declare passwd
create_user_account(){
    read -p "Please Enter Your Name:  " name
    if [ -z "$name" ];then
    echo "Can not give a empty name"
    menu_for_user
    fi
    if [[ $name =~ ['!@#$%^&*()_+'] ]]; then
    echo "name Can not contain special character"
    menu_for_user
    fi
    if [[ $name =~ [0-9] ]];then
    echo " name has number this is wrong"
    menu_for_user
    fi
    read -p "Please Enter Your Passwd:  " passwd
    if [ -z "$passwd" ];then
    echo "Can not give a empty passwd"
    menu_for_user
    fi
    echo "$name:$passwd" | tee -a users.MR
    menu_for_user
}
check_user_log_in_name(){
    name=$1
    if [ -z "$name" ];then
    echo "Can not give a empty name"
    menu_for_user
    fi
    if [[ $name =~ ['!@#$%^&*()_+'] ]]; then
    echo "name Can not contain special character"
    menu_for_user
    fi
    if [[ $name =~ [0-9] ]];then
    echo " name has number this is wrong"
    menu_for_user
    fi
    if [[ `grep $name users.MR` ]];then
    echo "User name is correct"
    else
    echo "User name is wrong"
    menu_for_user
    fi
}
check_user_log_in_passwd(){
    if [[ `grep $name users.MR | cut -d ":" -f 2` == $1 ]];then
    echo "passwd  is correct"
    else
    echo "passwd is wrong"
    menu_for_user
    fi
}
check_user_log_in(){
    read -p "Enter Name to check : " name_check
    read -p "Enter Passwd to check : " passwd_check
    check_user_log_in_name $name_check
    check_user_log_in_passwd $passwd_check
    return 1
}
create_database_with_user_name(){
    read -p "Please Enter DB Name : " DBName
    if [ -z "$DBName" ];then
    echo "Can not give a database empty name"
    database_menu
    fi
    if [[ $DBName =~ [0-9] ]];then
    echo "database name has number this is wrong"
    database_menu
    fi
    if [[ $DBName =~ ['!@#$%^&*()_+'] ]]; then
    echo "Can not contain special character"
    database_menu
    fi
    cd DBs/
    mkdir $DBName@$name
    cd ..
    return 1
}
list_database_for_specific_user(){
    cd DBs/ 2> errors.MR
    if [ `find . -type d -name "*@$name" | wc -l` = 0 ];then
    echo "No Database to list"
    database_menu
    fi
    find . -type d -name "*@$name" -printf '%f\n' 
    cd ..
    return 1
}
connect_to_db_for_certain_user_and_find_table(){
    read -p "Enter DB Name : " DBName
    if [ -z "$DBName" ];then
    echo "Can not give a database empty name"
    database_menu
    fi
    if [[ $DBName =~ [0-9] ]];then
    echo "database name has number this is wrong"
    database_menu
    fi
    if [[ $DBName =~ ['!@#$%^&*()_+'] ]]; then
    echo "Can not contain special character"
    database_menu
    fi
    cd DBs 
    #cd $DBName@$name 2> 
    path="$DBName@$name"
    cd $path 
    echo "connected to DB"
    count=`ls -1 | wc -l`
    if [[ count -le 0 ]];then
        echo "There is no tables exists "
        ls -1 | sed -e 's/\.table$//'
        else
        echo "There is exists tables : "
        ls -1 | sed -e 's/\.table$//'
    fi
    count=`ls -1 | wc -l`
    #./Tables.sh 2> .errors.MR
    TableMenu
    return 1
} 
Drop_db_for_specific_user(){
    read -p "Enter DB name to drop : " DBName
    if [ -z "$DBName" ];then
    echo "Can not give a database empty name"
    database_menu
    fi
    if [[ $DBName =~ [0-9] ]];then
    echo "database name has number this is wrong"
    database_menu
    fi
    if [[ $DBName =~ ['!@#$%^&*()_+'] ]]; then
    echo "Can not contain special character"
    database_menu
    fi
    cd DBs/ 2> errors.MR
    if [ -d DBName ];then
    rm -R $DBName@$name 2> errors.MR
    echo "Deleted"
    cd ..
    else
    echo "Data base not found"
    database_menu
    fi
    return 1
}
database_menu(){
    select i in "create DB" "List DB" "Connect To DB" "Drop DB"
    do
        case $i in 
            "create DB")
            create_database_with_user_name
            if [ $? != 1 ];
                then 
                database_menu
            fi
            ;;
            "List DB")
            list_database_for_specific_user
            if [ $? != 1 ];
                then 
                database_menu
            fi
            ;;
            "Connect To DB")
            connect_to_db_for_certain_user_and_find_table
            if [ $? != 1 ];
                then 
                database_menu
            fi
            ;;
            "Drop DB")
            Drop_db_for_specific_user
            if [ $? != 1 ];
                then 
                database_menu
            fi
            ;;
            *)
            echo "Bad choice"
            database_menu
        esac
    done
}
menu_for_user(){
    select i in "create new account" "login"
    do
        case $i in
        "create new account")
        create_user_account
        ;;
        "login")
        check_user_log_in
        if [ $? -eq 1 ];then
            database_menu
        fi
        ;;
        *)
        echo "bad input"
        menu_for_user
        ;;
        esac
    done
}
#This
#Is 
#Tables
#Section
#
#
#
#
#
menu(){
sleep 1
clear
echo 1-Create Table
echo 2-Delete table
echo 3-Select from Table
echo 4-Insert into table
echo 5-Delete from table
echo 6-Update table
echo 7-Quit
PS3='What Action on Tables will you do: '
}

containsElement() {
    local e
    for e in '$2'; do [[ '$e' == '$1' ]] && return 1; done
    return 0
}

create_table(){
PS3='Please enter your choice: '

echo "What's the Table Name:"
read tableName
while  test -f "$tableName.table" 
do
echo "Already Exists"
read tableName
done

echo "How many columns are there :"
read colsNum

col=1
while(($col<=$colsNum));
do
echo "what's Column Name :"
read colName
echo "what's it's type :"
select dtype in "int" "string"
do
case $dtype in
"int") dataType="int";break;;
"string") dataType="string";break;;
*) echo invalid type;;
esac
done

echo "will it be primary :"

select answer in "yes" "no"
do
case $answer in
"yes") PK="PK";break;;
"no") PK="";break;;
*) echo invalid answer;;
esac
done

metaData=$colName:$dataType:$PK
echo $metaData >> .$tableName.meta
columns=$columns:$colName

((col++))
done

#removing the first : and appending first two lines with column names and datatypes
echo $columns | sed 's/://' > $tableName.table
echo $tableName is created
menu
}



insert_data(){

ls *.table 
echo "which Table will you insert into"
read insert_table
if [ ! -f $insert_table.table ]
then
echo This Table Does not exist
else
colsNum=$(cat .$insert_table.meta |wc -l)
for ((col=1;col<=$colsNum;col++));
do
colName=$(awk 'BEGIN{FS=":"}{if(NR=='$col') print $1}' .$insert_table.meta)
colType=$(awk 'BEGIN{FS=":"}{if(NR=='$col') print $2}' .$insert_table.meta)
PK=$(awk 'BEGIN{FS=":"}{if(NR=='$col') print $3}' .$insert_table.meta)

echo value of $colName :
read value

intTest=0
pkTest=0
while (( $intTest*$pkTest==0 ));
do
if [[ $colType == "int" ]];
then
	if ! [[ $value =~ ^[0-9]*$ ]]; 
	then
        	echo  this is not an integer value
        	intTest=0
      	else
      		intTest=1
      	fi
else 
intTest=1
fi

if [[ $PK == "PK" ]];
then
	if  [[ $value =~ ^[`awk 'BEGIN{FS=":"}{if(NR != 1)print $(('$col'))}' $insert_table.table`] ]]; 
	then
        echo "This value isn't unique"
        pkTest=0
        else
        pkTest=1
        fi
else
        pkTest=1

fi

if (( $intTest*$pkTest==0 ));
then
read value
fi
done

data=$data:$value
done

echo $data | sed 's/://' >> $insert_table.table
fi
data=""
menu
}


delete_table(){
ls *.table 
echo "which Table will you delete"
read delete_table
if [ ! -f $delete_table ]
then
echo This Table Does not exist
else
rm $delete_table.table .$delete_table.meta 
fi
menu
}


delete_data(){
ls *.table 
echo "which Table will you delete from"
read delete_data_table
if [ ! -f $delete_data_table.table ]
then
echo This Table Does not exist
else
echo which column will you delete upon
cat .$delete_data_table.meta | cut -f1 -d:
read col
search="`awk 'BEGIN{FS=":"}{if($1=="'$col'")print NR}' .$delete_data_table.meta`"
	while  [[ $search == "" ]]; 
	do
        echo "This column doesn't exist"
        read col
	search="`awk 'BEGIN{FS=":"}{if($1=="'$col'")print NR}' .$delete_data_table.meta`"
	done
colNum=$(awk 'BEGIN{FS=":"}{if($1=="'$col'") print NR}' .$delete_data_table.meta)
echo "What is it's value :"
read value
rowNum=$(awk 'BEGIN{FS=":"}{if($'$colNum'=="'$value'") print NR}' $delete_data_table.table)
if ! [[ $rowNum == "" ]];
then
sed -i ''$rowNum'd' $delete_data_table.table
echo succesfully deleted
else
echo this value does not exist
fi
fi
menu
}

select_data(){
PS3="Select Option:"
ls *.table 
echo "which Table will you select"
read select_table
if [ ! -f $select_table.table ]
then
echo This Table Does not exist
else
echo is there a condition?
	select var in "yes" "no"
	do
	case $var in
	"no")break;;
	"yes")
	echo which column will you select upon
	cat .$select_table.meta | cut -f1 -d:
	read condColumn
	search="`awk 'BEGIN{FS=":"}{if($1=="'$condColumn'")print NR}' .$select_table.meta`"
	while  [[ $search == "" ]]; 
	do
        echo "This column doesn't exist"
        read condColumn
	search="`awk 'BEGIN{FS=":"}{if($1=="'$condColumn'")print NR}' .$select_table.meta`"
	done
	condColNum=$(awk 'BEGIN{FS=":"}{if($1=="'$condColumn'") print NR}' .$select_table.meta)
	echo where $condColumn = 
	read cond
	break;;
	esac
	done
	
echo What do you want to select :
select opt in "All Columns" "Single Column"
do
case $opt in
"All Columns")
clear
if [[ $var == "yes" ]];
then
head -n1 $select_table.table
awk 'BEGIN{FS=":"; OFS=":"}{if($'$condColNum'=="'$cond'")print $0}' $select_table.table
else
cat  $select_table.table
fi
break;;
"Single Column")
echo which column will you select
cat .$select_table.meta | cut -f1 -d:
read column
search="`awk 'BEGIN{FS=":"}{if($1=="'$column'")print NR}' .$select_table.meta`"
while  [[ $search == "" ]]; 
do
        echo "This column doesn't exist"
        read column
	search="`awk 'BEGIN{FS=":"}{if($1=="'$column'")print NR}' .$select_table.meta`"
done
clear
colNum=$(awk 'BEGIN{FS=":"}{if($1=="'$column'") print NR}' .$select_table.meta)

awk 'BEGIN{FS=":"; OFS=":"}{if(NR==1)print $'$colNum'}' $select_table.table
if [[ $var == "yes" ]];
then
awk 'BEGIN{FS=":"; OFS=":"}{if($'$condColNum'=="'$cond'")print $'$colNum'}' $select_table.table
else
awk 'BEGIN{FS=":"; OFS=":"}{print $'$colNum'}' $select_table.table
fi
	
break;;
esac
done
 fi
 sleep 3
 menu

}


update_data(){
ls *.table 
echo "which Table will you update"
read update_data_table
if [ ! -f $update_data_table.table ]
then
echo This Table Does not exist
else
echo which column will you update upon
cat .$update_data_table.meta | cut -f1 -d:
read column
search="`awk 'BEGIN{FS=":"}{if($1=="'$column'")print NR}' .$update_data_table.meta`"
while  [[ $search == "" ]]; 
do
        echo "This column doesn't exist"
        read column
	search="`awk 'BEGIN{FS=":"}{if($1=="'$column'")print NR}' .$update_data_table.meta`"
done
colNum=$(awk 'BEGIN{FS=":"}{if($1=="'$column'") print NR}' .$update_data_table.meta)
echo "What is it's value :"
read Uvalue

if ! [[ $Uvalue =~ ^[`awk 'BEGIN{FS=":"}{if(NR != 1)print $'$colNum'}' $update_data_table.table`] ]]; 
then
echo there is no such value
return
fi
tempValue=$Uvalue
colsNum=$(cat .$update_data_table.meta |wc -l)
for ((col=1;col<=$colsNum;col++));
do
colName=$(awk 'BEGIN{FS=":"}{if(NR=='$col') print $1}' .$update_data_table.meta)
colType=$(awk 'BEGIN{FS=":"}{if(NR=='$col') print $2}' .$update_data_table.meta)
PK=$(awk 'BEGIN{FS=":"}{if(NR=='$col') print $3}' .$update_data_table.meta)

echo "value of $colName (if no change just press enter)":
read value

if  [[ $value != "" ]];
then
intTest=0
pkTest=0
while (( $intTest*$pkTest==0 ));
do
if [[ $colType == "int" ]];
then
	if ! [[ $value =~ ^[0-9]*$ ]]; 
	then
        	echo  this is not an integer value
        	intTest=0
      	else
      		intTest=1
      	fi
else 
intTest=1
fi

if [[ $PK == "PK" ]];
then
	if  [[ $value =~ ^[`awk 'BEGIN{FS=":"}{if(NR != 1)print $(('$col'))}' $update_data_table.table`] ]]; 
	then
        echo "This value isn't unique"
        pkTest=0
        else
        pkTest=1
        fi
else
        pkTest=1

fi

if (( $intTest*$pkTest==0 ));
then
read value
fi
done

if  [[ $value == "" ]];
   then
   continue
fi


awk 'BEGIN{FS=":"; OFS=":"}{if(NR!=1) $'$col'=($'$colNum'=="'$tempValue'")?"'$value'":$'$col';print $0}' $update_data_table.table > temp
cp temp $update_data_table.table
rm temp
if [[ $col == $colNum ]];
then
tempValue=$value
fi 
fi
done

fi

menu

}


TableMenu(){
PS3='What Action on Tables will you do: '
options=("Create Table" "Delete Table" "Select Data" "Insert Data" "Delete Data" "Update Data" "Disconnect")
select opt in "${options[@]}"
do
    case $opt in
        "Create Table")
            	create_table 
            ;;
        "Delete Table")
        	delete_table
   		;;
        "Select Data")
            select_data
            
            ;;
        "Insert Data")
            insert_data
            ;;
        "Delete Data")
            delete_data
            ;;
         "Update Data")
            update_data
            ;;
        "Disconnect")
        PS3="Pick an option"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
        database_menu
}

menu_for_user
