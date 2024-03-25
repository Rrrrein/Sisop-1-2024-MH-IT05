log_directory="/home/masgan/log"
current_hour=$(date +"%Y%m%d%H")
aggregated_log_file="${log_directory}/metrics_agg_${current_hour}.log"

# Fungsi untuk mengkonversi nilai ke MB
convert_to_mb() {
    size=$1
    # Cek apakah size mengandung 'M' atau 'K' dan konversi jika perlu
    if [[ $size == *M ]]; then
        echo $size | sed 's/M//'
    elif [[ $size == *K ]]; then
        echo $size | awk '{printf "%.2f\n", $1 / 1024}' | sed 's/$/M/'
    else
        echo $size
    fi
}

echo "type,mem_total,mem_used,mem_free,mem_shared,mem_buff,mem_available,swap_total,swap_used,swap_free,path,path_size" > "$aggregated_log_file"

min_path_size=$(du -sh "${log_directory}" | cut -f1)
max_path_size=$min_path_size
min_path_size=$(convert_to_mb "$min_path_size")
max_path_size=$(convert_to_mb "$max_path_size")

declare -A min max avg
metrics=(mem_total mem_used mem_free mem_shared mem_buff mem_available swap_total swap_used swap_free)
for metric in "${metrics[@]}"; do
    min["$metric"]=999999
    max["$metric"]=0
done

for file in "${log_directory}"/metrics_"${current_hour}"*.log; do
    if [[ -r "$file" && -s "$file" ]]; then
        while IFS=',' read -r "${metrics[@]}" _ path_size; do
            [[ $mem_total == "mem_total" ]] && continue

            for metric in "${metrics[@]}"; do
                (( ${!metric} < min["$metric"] )) && min["$metric"]=${!metric}
                (( ${!metric} > max["$metric"] )) && max["$metric"]=${!metric}
            done

            path_size=$(convert_to_mb "$path_size")
            [[ "$path_size" < "$min_path_size" ]] && min_path_size=$path_size
            [[ "$path_size" > "$max_path_size" ]] && max_path_size=$path_size
        done < "$file"
    fi
done

for metric in "${metrics[@]}"; do
    avg["$metric"]=$(echo "scale=2; (${min["$metric"]} + ${max["$metric"]}) / 2" | bc)
done
average_path_size=$(echo "$min_path_size + $max_path_size" | sed 's/M//g' | awk '{printf "%.2fM\n", ($1 + $2)/2}')

{
    echo -n "minimum,"
    for metric in "${metrics[@]}"; do echo -n "${min[$metric]},"; done
    echo "${log_directory},${min_path_size}"
    
    echo -n "maximum,"
    for metric in "${metrics[@]}"; do echo -n "${max[$metric]},"; done
    echo "${log_directory},${max_path_size}"
    
    echo -n "average,"
    for metric in "${metrics[@]}"; do echo -n "${avg[$metric]},"; done
    echo "${log_directory},${average_path_size}"
} >> "$aggregated_log_file"

# Set permissions
chmod 600 "$aggregated_log_file"

#59 * * * * /home/masgan/log/aggregate_minutes_to_hourly_log.sh
