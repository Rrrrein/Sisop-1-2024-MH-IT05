current_time=$(date +"%Y%m%d%H%M%S")

log_directory="/home/masgan/log"

mkdir -p "$log_directory"

chmod 700 "$log_directory"

log_file="${log_directory}/metrics_${current_time}.log"

mem_usage=$(free -m | awk 'NR==2{printf "%s,%s,%s,%s,%s,%s,%s,%s,%s\n", $2,$3,$4,$5,$6,$7,$2-$7,$5,$6}')

disk_usage=$(du -sh /home/masgan/log/ | awk '{print $1}')

echo "mem_total,mem_used,mem_free,mem_shared,mem_buff,mem_available,swap_total,swap_used,swap_free,path,path_size" > "$log_file"
echo "$mem_usage,/home/masgan/log/,$disk_usage" >> "$log_file"

chmod 600 "$log_file"

#* * * * * /home/masgan/log/minute_log.sh
