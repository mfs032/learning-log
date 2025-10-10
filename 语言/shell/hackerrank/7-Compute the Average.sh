read n
for i in $(seq 1 $n); do
sum=0
    read num
    sum=$(( $sum + $num ))
done
result=$(awk "BEGIN{printf \"%.3f\n\", $sum/$n}")
echo $result