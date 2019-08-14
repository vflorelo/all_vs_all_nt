#!/bin/bash
#############################################
if [ ! -z "$1" ] && [ -e "$1" ]           ###
then                                      ###
  genome_order_file="$1"                  ###
elif [ -z "$1" ] && [ -e "genome_order" ] ###
then                                      ###
  genome_order_file="genome_order"        ###
else                                      ###
  echo "No genome order file provided"    ###
  exit 0                                  ###
fi                                        ###
#############################################
echo "Using $genome_order_file as genome order file"

####################
if [ -z "$2" ]   ###
then             ###
  break_len=120  ###
elif [ -n "$2" ] ###
then             ###
  break_len="$2" ###
fi               ###
####################
echo "Using break length of $break_len"

tmp_genome_order_datablock=$(grep -v \# $genome_order_file | grep -v ^$)
genome_order_datablock=$tmp_genome_order_datablock
num_sequences=$(echo "$tmp_genome_order_datablock" | wc -l)
acc_nums=""
for sequence_num in $(seq 1 $num_sequences)
do
  file_name=$(echo "$tmp_genome_order_datablock" | tail -n+$sequence_num | head -n1)
  if [ -e "$file_name" ]
  then
    echo "$file_name [OK]"
    acc_no=$(grep \> "$file_name" | cut -d\> -f2 | cut -d' ' -f1 )
    acc_nums=$(echo -e "$acc_nums\n$acc_no")
  else
    echo "$file_name [missing] removing from list"
    genome_order_datablock=$(echo "$genome_order_datablock" | grep -wv ^$file_name)
  fi
done

num_sequences=$(echo "$genome_order_datablock" | wc -l)
if [ "$num_sequences" -lt "3" ]
then
  echo "Less than 3 sequences left for analysis, exiting"
  exit 0
fi

echo -e "$acc_nums" > query_based_table.tsv
echo -e "$acc_nums" > subject_based_table.tsv
echo -e "$acc_nums" > shortest_based_table.tsv
echo -e "$acc_nums" > longest_based_table.tsv
echo -e "$acc_nums" > average_based_table.tsv

for sequence_num in $(seq 1 $num_sequences)
do
  query_file=$(echo "$genome_order_datablock" | tail -n+$sequence_num | head -n1 )
  query_len=$(grep -v \> "$query_file" | perl -pe 's/\n//g' | wc -c)
  query_name=$(grep \> "$query_file" | cut -d\> -f2 | cut -d' ' -f1 )
  missing_rows=$(perl -e "print(\"x\n\" x $sequence_num, \"\");")
  query_based_data=$(echo    -e "$query_name\n$missing_rows")
  subject_based_data=$(echo  -e "$query_name\n$missing_rows")
  shortest_based_data=$(echo -e "$query_name\n$missing_rows")
  longest_based_data=$(echo  -e "$query_name\n$missing_rows")
  average_based_data=$(echo  -e "$query_name\n$missing_rows")
  if [ "$sequence_num" -lt "$num_sequences" ]
  then
    subject_file_list=$(echo "$genome_order_datablock" | tail -n+$sequence_num | tail -n+2 )
    num_subjects=$(echo "$subject_file_list" | wc -l)
    for subject_num in $(seq 1 $num_subjects)
    do
      subject_file=$(echo "$subject_file_list" | tail -n+$subject_num | head -n1)
      subject_len=$(grep -v \> $subject_file | perl -pe 's/\n//g' | wc -c)
      nucmer -b $break_len $query_file $subject_file
      aln_datablock=$(show-coords out.delta | grep "|" | grep -v "\[" | awk 'BEGIN{SEP="\t"}{print $12 SEP $13 SEP $7 SEP $8 SEP $1 SEP $4 SEP $2 SEP $5 SEP $10}')
      shortest_len=$(echo -e "$query_len\t$subject_len" | awk 'BEGIN{FS="\t"}{if($2>=$1){print $1}else{print $2}}')
      longest_len=$(echo  -e "$query_len\t$subject_len" | awk 'BEGIN{FS="\t"}{if($2>=$1){print $2}else{print $1}}')
      average_len=$(echo  -e "$query_len\t$subject_len" | awk 'BEGIN{FS="\t"}{print ($1+$2)/2}')
      query_based_idy=$(echo    "$aln_datablock" | awk -v query_len="$query_len"       'BEGIN{FS="\t"}{avg_len=($3+$4)/2;sum+=avg_len*$9}END{print sum/query_len}')
      subject_based_idy=$(echo  "$aln_datablock" | awk -v subject_len="$subject_len"   'BEGIN{FS="\t"}{avg_len=($3+$4)/2;sum+=avg_len*$9}END{print sum/subject_len}')
      shortest_based_idy=$(echo "$aln_datablock" | awk -v shortest_len="$shortest_len" 'BEGIN{FS="\t"}{avg_len=($3+$4)/2;sum+=avg_len*$9}END{print sum/shortest_len}')
      longest_based_idy=$(echo  "$aln_datablock" | awk -v longest_len="$longest_len"   'BEGIN{FS="\t"}{avg_len=($3+$4)/2;sum+=avg_len*$9}END{print sum/longest_len}')
      average_based_idy=$(echo  "$aln_datablock" | awk -v average_len="$average_len"   'BEGIN{FS="\t"}{avg_len=($3+$4)/2;sum+=avg_len*$9}END{print sum/average_len}')
      query_based_data=$(echo    -e "$query_based_data\n$query_based_idy")
      subject_based_data=$(echo  -e "$subject_based_data\n$subject_based_idy")
      shortest_based_data=$(echo -e "$shortest_based_data\n$shortest_based_idy")
      longest_based_data=$(echo  -e "$longest_based_data\n$longest_based_idy")
      average_based_data=$(echo  -e "$average_based_data\n$average_based_idy")
      rm -f out.delta
    done
  fi
  echo "$query_based_data"    > query.tsv
  echo "$subject_based_data"  > subject.tsv
  echo "$shortest_based_data" > shortest.tsv
  echo "$longest_based_data"  > longest.tsv
  echo "$average_based_data"  > average.tsv
  echo "$(paste query_based_table.tsv query.tsv)"       > query_based_table.tsv
  echo "$(paste subject_based_table.tsv subject.tsv)"   > subject_based_table.tsv
  echo "$(paste shortest_based_table.tsv shortest.tsv)" > shortest_based_table.tsv
  echo "$(paste longest_based_table.tsv longest.tsv)"   > longest_based_table.tsv
  echo "$(paste average_based_table.tsv average.tsv)"   > average_based_table.tsv
  rm -f query.tsv subject.tsv shortest.tsv longest.tsv average.tsv
done
