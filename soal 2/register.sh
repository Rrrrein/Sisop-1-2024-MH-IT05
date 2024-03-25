#!/bin/bash

# Function buat mastiin kalau email yang dipakai unik
function check_email() {
    local email="$1" # bikin variabel "email"
    if grep -q "^$email:" users.txt; then
        return 0 # Email udah dipake
    else
        return 1 # Email belum dipake
    fi
}

# Function baut enkripsi password
function encrypt_password() {
    local password="$1"
    local encrypted_password=$(echo -n "$password" | base64)
    echo "$encrypted_password"
}

# Function buat bikin akun baru
function register() {
    local email="$1"
    local username="$2"
    local security_question="$3"
    local security_answer="$4"
    local password="$5"

    # Cek apakah email udah dipake pake func tadi
    if check_email "$email"; then
        echo "Email sudah terpakai."
        exit 1
    fi

    # Apakah password tidak memenuhi kriteria
    while true; do
        read -s -p "Enter password: " password
        echo

        # Kalau ngga, suruh ulang
        if [[ "$password" =~ [[:upper:]] && "$password" =~ [[:lower:]] && "$password" =~ [[:digit:]] && ${#password} -ge 8 ]]; then
            break  # Break out of the loop if password meets criteria
        else
            echo "Password must contain at least 1 uppercase letter, 1 lowercase letter, 1 digit, and be at least 8 characters long."
            echo "Please try again."
        fi
    done

    # Enkripsi pass paeke func tadi 
    local encrypted_password=$(encrypt_password "$password")

    # Cek apakah email ini ber-"admin"
    if [[ "$email" == *"admin"* ]]; then
        user_type="admin"
    else
        user_type="user"
    fi

    # Tambah informasi user ke file users.txt
    echo "$email:$username:$security_question:$security_answer:$encrypted_password:$user_type" >>/Users/rrrreins/sisop/mod1-soal2/users.txt
    echo "Registration successful."
    # Masukkan info user ke file auth.log buat penyimpanan data si Oppie
    echo "$(date '+[%d/%m/%y %H:%M:%S]') [REGISTER SUCCESS] Registrasi user $username berhasil." >>/Users/rrrreins/sisop/mod1-soal2//auth.log
}

# Main script starts here
# Prompt user for registration details
echo "Welcome to Registration System"
read -p "Enter email: " email
read -p "Enter username: " username
read -p "Enter security question: " security_question
read -p "Enter security answer: " security_answer
echo

# Pake func register buat regist
register "$email" "$username" "$security_question" "$security_answer" "$password"

