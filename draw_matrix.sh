#!/bin/bash
##############################################
if [ -z "$1" ]                             ###
then                                       ###
  echo "Type the name of your matrix file" ###
	read matrix_file                         ###
else                                       ###
  matrix_file="$1"                         ###
fi                                         ###
##############################################

##############################
if [ ! -e "$matrix_file" ] ###
then                       ###
	echo "Missing files"     ###
	exit 0                   ###
else                       ###
	echo "Files in order"    ###
fi                         ###
##############################

num_cols=$(wc -l < $matrix_file )
num_rows=$(head -n1 $matrix_file | perl -pe 's/\t/\n/g' | wc -l )

############################################
if [ "$num_cols" -ne "$num_rows" ]       ###
then                                     ###
	echo "Asymmetric matrix file, exiting" ###
	exit 0                                 ###
else                                     ###
	echo "Symmetric matrix"                ###
fi                                       ###
############################################

col_names=$(head -n1  "$matrix_file" | cut -f2- | perl -pe 's/\t/\n/g')
row_names=$(tail -n+2 "$matrix_file" | cut -f1)
name_diff=`diff <(echo "$col_names") <(echo "$row_names")`

#########################################
if [ -z "$name_diff" ]                ###
then                                  ###
	echo "Tax names ordered"            ###
else                                  ###
	echo "Tax names misplaced, exiting" ###
	exit 0                              ###
fi                                    ###
#########################################

svg_name=$(echo "$matrix_file" | awk 'BEGIN{FS="."}{print $1 FS "svg"}')
matrix_datablock=$(tail -n+2 "$matrix_file")
tax_names=$(echo "$matrix_datablock" | cut -f1)
matrix_size=$(echo "$matrix_datablock" | wc -l)
longest_name=$(echo "$matrix_datablock" | awk 'BEGIN{FS="\t"}{print length($1)}' | sort -nr | head -n1)
block_size="20"
matrix_separator="10"
canvas_size=$(echo -e "$matrix_size\t$longest_name\t$block_size\t$matrix_separator" | awk 'BEGIN{FS="\t"}{print (($2*8.1)+(($2-1)*0.75))+($1*$3)+$4}')
block_style=$(echo "style=\"opacity:1;fill:@color@;fill-opacity:1;stroke:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1\"")
text_style=$(echo "font-family=\"Source Code Pro\" font-size=\"12\" fill=\"#000000\" font-weight=\"bold\" font-style=\"normal\" ")
label_style=$(echo "font-family=\"Source Code Pro\" font-size=\"10\" fill=\"#000000\" font-weight=\"bold\" font-style=\"normal\" ")
matrix_padding=$(echo "$longest_name" | awk '{print (($1*8.1)+(($1-1)*0.75))}')
matrix_datablock=$(echo "$matrix_datablock" | cut -f1 --complement)
echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>" > "$svg_name"
echo "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"$canvas_size""px\" height=\"$canvas_size""px\" viewBox=\"0 0 $canvas_size $canvas_size\" id=\"matrix\">"  >> "$svg_name"
for i in $(seq 1 $matrix_size)
do
  text_y_padding=$(echo -e "$i\t$block_size" | awk 'BEGIN{FS="\t"}{print ((($1-1)*$2)+12.5)}')
  tax_name=$(echo "$tax_names" | tail -n+$i | head -n1)
  tax_width=$(echo "$tax_name" | awk '{print (length($AF)*8.1)+ ((length($AF)-1)*0.75) }')
  text_x_padding=$(echo -e "$tax_width\t$matrix_padding" | awk 'BEGIN{FS="\t"}{print $2 - $1}')
  echo "<text $text_style id=\"Tax_$i\" y=\"$text_y_padding\" x=\"$text_x_padding\">$tax_name</text>" >> "$svg_name"
  text_vert_x_padding=$(echo -e "$matrix_padding\t$i\t$block_size" | awk 'BEGIN{FS="\t"}{print $1 + 24 + (($2-1)*$3)}')
  text_vert_y_padding=$(echo -e "$canvas_size\t$matrix_padding\t$tax_width" | awk 'BEGIN{FS="\t"}{print ($1-($2-$3))}')
  echo "<text $text_style id=\"Tax_$i""_vert\" y=\"0\" x=\"0\" transform=\"matrix(0,-1,1,0,$text_vert_x_padding,$text_vert_y_padding)\" >$tax_name</text>" >> "$svg_name"
  sub_start=$(echo "$i" | awk '{print $1+1}')
  block_x_padding=$(echo -e "$matrix_padding\t$matrix_separator\t$i\t$block_size" | awk 'BEGIN{FS="\t"}{print $1+$2+(($3-1)*$4)}')
  block_y_padding=$(echo -e "$i\t$block_size" | awk 'BEGIN{FS="\t"}{print (($1-1)*$2)}')
  block_color="#00FF00"
  block_id=$(echo "T""$i""xT""$i")
  echo "<rect $block_style id=\"$block_id\" width=\"$block_size\" height=\"$block_size\" x=\"$block_x_padding\" y=\"$block_y_padding\" />" | perl -pe "s/\@color\@/$block_color/" >> "$svg_name"
  btext_y_padding=$(echo -e "$i\t$block_size" | awk 'BEGIN{FS="\t"}{print ((($1-1)*$2)+13.1)}')
  btext_x_padding=$(echo -e "$matrix_padding\t$matrix_separator\t$i\t$block_size\t16.8\t100" | awk 'BEGIN{FS="\t"}{print $1 + $2 + (($3-1)*$4) + (($4 - $5)/3.2) + ( ( 3 - length( $6 ) ) * 1.2 )}')
  echo "<text $label_style id=\"label_$block_id\" y=\"$btext_y_padding\" x=\"$btext_x_padding\" >100</text>" >> "$svg_name"
  for j in $(seq $sub_start $matrix_size)
  do
    block_value=$(echo "$matrix_datablock" | cut -f$i | tail -n+$j | head -n1 | awk '{print int($1)}')
    block_value_width=$(echo "$block_value" | awk '{print (length($AF)*4.8)+((length($AF)-1)*1.2)}')
    if [ "$block_value" == "x" ]
    then
      unset block_value
    fi
    if [ ! -z "$block_value" ]
    then
      if [ "$block_value" -le "50" ]
      then
        red_hex="FF"
        green_dec=$(echo "$block_value 50" | awk '{print int(($1/$2)*255)}')
        green_hex=$(echo "obase=16;$green_dec" | bc | awk '{if(length($1)==1){print "0"$AF}else{print $AF}}')
      elif [ "$block_value" -gt "50" ]
      then
        red_dec=$(echo "$block_value 100" | awk '{print int( ( ($2-$1) / ($2/2 ) ) * 255 )}')
        red_hex=$(echo "obase=16;$red_dec" | bc | awk '{if(length($1)==1){print "0"$AF}else{print $AF}}')
        green_hex="FF"
      fi
      block_color=$(echo "#""$red_hex""$green_hex""00")
      block_y_padding=$(echo "$j $block_size" | awk '{print (($1-1)*$2)}')
      block_id=$(echo "T""$i""xT""$j")
      echo "<rect $block_style id=\"$block_id\" width=\"$block_size\" height=\"$block_size\" x=\"$block_x_padding\" y=\"$block_y_padding\" />" | perl -pe "s/\@color\@/$block_color/" >> "$svg_name"
      btext_y_padding=$(echo -e "$j\t$block_size" | awk 'BEGIN{FS="\t"}{print ((($1-1)*$2)+13.1)}')
      btext_x_padding=$(echo -e "$matrix_padding\t$matrix_separator\t$i\t$block_size\t$block_value_width\t$block_value" | awk 'BEGIN{FS="\t"}{print $1 + $2 + (($3-1)*$4) + (($4 - $5)/3.2) + ((3-length($6))*1.2)}')
      echo "<text $label_style id=\"label_$block_id\" y=\"$btext_y_padding\" x=\"$btext_x_padding\" >$block_value</text>" >> "$svg_name"
    fi
    unset block_color block_y_padding btext_x_padding btext_y_padding block_id block_value block_value_width
  done
  unset block_x_padding
done
echo "</svg>" >> "$svg_name"
