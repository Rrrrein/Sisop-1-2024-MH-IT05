#!/bin/bash

#Soal Shift Modul 1 - Sistem Operasi
#Kelompok IT05

# Langkah persiapan :
# a.Download file Sandbox.csv dari link yang disediakan
curl -L -o Sandbox.csv 'https://drive.google.com/uc?export=download&id=1cC6MYBI3wRwDgqlFQE1OQUN83JAreId0'
# b. Membuka file Sandbox.csv
open Sandbox.csv


# Langkah pengerjaan : 
# a. Mencari nama pembeli dengan sales tertinggi dari file Sandbox.csv
res_a=$(sort -t ',' -k 17 -nr Sandbox.csv | head -n 1 | cut -d ',' -f 6,17)

# b. Mencari customer segment dengan profit paling kecil dari file Sandbox.csv
res_b=$(sort -t ',' -k 20 -n Sandbox.csv | awk -F ',' 'NR==2{print $7, $20}')

# c. Mencari 3 kategori dengan profit paling tinggi dari file Sandbox.csv
res_c=$(awk -F ',' 'NR>1{print $14","$20}' Sandbox.csv | sort -t ',' -k 2 -nr | head -3)

# d. Mencari purchase date dan quantity dari pesanan milik adriaens
res_d=$(grep -i "adriaens" Sandbox.csv | cut -d ',' -f 2,18,6)

# Output hasilnya
echo -e "a. Pembeli dengan sales tertinggi dan total salesnya adalah:\n$res_a"
echo -e "b. Customer segment dengan profit paling kecil dan total profitnya adalah:\n$res_b "
echo -e "c. Tiga kategori yang memiliki profit tertinggi dan masing-masing profitnya adalah:\n$res_c"
echo -e "d. Purchase date dan amount dari pesanan milik adriaens adalah:\n$res_d"
