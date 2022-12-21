#! /bin/bash


menu(){
sleep 2
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
echo $metaData >> $PWD/$tableName.meta
columns=$columns:$colName

((col++))
done

#removing the first : and appending first two lines with column names and datatypes
echo $columns | sed 's/://' > $PWD/$tableName.table
echo $tableName is created
menu
return 1
}



insert(){

ls *.table 
echo "which Table will you insert into"
read insert_table
if [ ! -f $insert_table.table ]
then
echo This Table Does not exist
else
colsNum=$(cat $insert_table.meta |wc -l)
for ((col=1;col<=$colsNum;col++));
do
colName=$(awk 'BEGIN{FS=":"}{if(NR=='$col') print $1}' $insert_table.meta)
colType=$(awk 'BEGIN{FS=":"}{if(NR=='$col') print $2}' $insert_table.meta)
PK=$(awk 'BEGIN{FS=":"}{if(NR=='$col') print $3}' $insert_table.meta)

echo value of $colName :
read value

if [[ $colType == "int" ]];
then
	while ! [[ $value =~ ^[0-9]*$ ]]; 
	do
        	echo  this is not an integer value
        	read value
      	done
fi

if [[ $PK == "PK" ]];
then
while  [[ $value =~ ^[`awk 'BEGIN{FS=":"}{if(NR != 1)print $(('$col'))}' $insert_table.table`] ]]; 
do
        echo "This value isn't unique"
        read value
done

fi
data=$data:$value
done

echo $data | sed 's/://' >> $insert_table.table
fi
menu
return 1
}


delete_table(){
ls *.table 
echo "which Table will you delete"
read delete_table
if [ ! -f $delete_table ]
then
echo This Table Does not exist
else
rm $delete_table.table $delete_table.meta 
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
cat $delete_data_table.meta | cut -f1 -d:
read col
while ! [[ $col =~ ^[`awk 'BEGIN{FS=":"}{print $1}' $delete_data_table.meta`] ]]; 
do
        echo "This column doesn't exist"
        read col
done
colNum=$(awk 'BEGIN{FS=":"}{if($1=="'$col'") print NR}' $delete_data_table.meta)
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

#select

update(){
ls *.table 
echo "which Table will you update"
read update_data_table
if [ ! -f $update_data_table.table ]
then
echo This Table Does not exist
else
echo which column will you update upon
cat $update_data_table.meta | cut -f1 -d:
read column
while ! [[ $column =~ ^[`awk 'BEGIN{FS=":"}{print $1}' $update_data_table.meta`] ]]; 
do
        echo "This column doesn't exist"
        read column
done
colNum=$(awk 'BEGIN{FS=":"}{if($1=="'$column'") print NR}' $update_data_table.meta)
echo "What is it's value :"
read Uvalue

colsNum=$(cat $update_data_table.meta |wc -l)
for ((col=1;col<=$colsNum;col++));
do
colName=$(awk 'BEGIN{FS=":"}{if(NR=='$col') print $1}' $update_data_table.meta)
colType=$(awk 'BEGIN{FS=":"}{if(NR=='$col') print $2}' $update_data_table.meta)
PK=$(awk 'BEGIN{FS=":"}{if(NR=='$col') print $3}' $update_data_table.meta)

echo "value of $colName (if no change just press enter)":
read value

if  [[ $value != "" ]];
then
if [[ $colType == "int" ]];
then
	while ! [[ $value =~ ^[0-9]*$ ]]; 
	do
        	echo  this is not an integer value
        	read value
      	done
fi

if [[ $PK == "PK" ]];
then
while  [[ $value =~ ^[`awk 'BEGIN{FS=":"}{if(NR != 1)print $'$col'}' $update_data_table.table`] ]]; 
do
        echo "This value isn't unique"
        read value
done

fi
awk 'BEGIN{FS=":"}{if($'$colNum'=="'$Uvalue'") $'$col'="'$value'";}' $update_data_table.table
fi
done

fi

}


PS3='What Action on Tables will you do: '
options=("Create Table" "Delete Table" "Select" "Insert" "Delete" "Update" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Create Table")
            	create_table 
            ;;
        "Delete Table")
        	delete_table
   		;;
        "Select")
            ls *.table
            
            ;;
        "Insert")
            insert
            ;;
        "Delete")
            delete_data
            ;;
         "Update")
            update
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
