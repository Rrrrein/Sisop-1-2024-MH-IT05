#!/bin/bash

# Function buat cek apakah user sudah ada atau belum
function authenticate_user() {
    local email="$1"
    local password="$2"

    # Cari user di users.txt
    local user_info=$(grep "^$email:" /Users/rrrreins/sisop/mod1-soal2/users.txt)

		# kalau ga nemu, kembali ke menu awal
    if [ -z "$user_info" ]; then
        echo "User with email $email not found."
        exit 1
    fi

    # Ambil info password dari enkripsi
    local encrypted_password=$(echo "$user_info" | cut -d: -f5)

    # Lalu di dekripsi pake base64
    local decrypted_password=$(echo "$encrypted_password" | base64 -d)

    # Cek apakah pass yang dimasukkan sesuai dengan data
    if [ "$password" != "$decrypted_password" ]; then
        echo "Incorrect password."
        exit 1
    fi
    
    # Check apakah user adalah admin, kalau bukan
    local user_type=$(echo "$user_info" | cut -d: -f6)
    if [ "$user_type" != "admin" ]; then
        echo "User $email berhasil login!"
        exit 1
    fi
	  
    echo "Login successful!"
    echo "$(date '+[%d/%m/%y %H:%M:%S]') [LOGIN SUCCESS] User $email berhasil log in." >> /Users/rrrreins/sisop/mod1-soal2/auth.log
		
		admin_menu "$email"
		
		return 0
		
		
}

	# Kalau abah2 lupa password
function forgot_password() {
    local email="$1"

    # Cari usernya di users.txt
    local user_info=$(grep "^$email:" /Users/rrrreins/sisop/mod1-soal2/users.txt)

    # Kalau ga ketemu balik ke menu awal
    if [ -z "$user_info" ]; then
        echo "User with email $email not found."
        return 1
    fi

    # Ambil info security question dari data
    local security_question=$(echo "$user_info" | cut -d: -f3)
    
    # Prompt user buat menjawab security question
    read -p "Security Question: $security_question " provided_security_answer

    # Ambil info security answer dari data
    local stored_security_answer=$(echo "$user_info" | cut -d: -f4)

    # Check apakah jawaban sama dengan security answer
    if [ "$provided_security_answer" != "$stored_security_answer" ]; then
        echo "Incorrect answer."
        return 1
    fi
    
    # Ambil dan tampilin password user
    local encrypted_password=$(echo "$user_info" | cut -d: -f5)
    local decrypted_password=$(echo "$encrypted_password" | base64 -d)
    echo "Your password is: $decrypted_password"
    return 0
}

# Function2 buat admin
function admin_menu() {
    local email="$1"
    while true; do
        # Tampilan menu admin
        echo "Admin Menu"
        echo "1. Add User"
        echo "2. Edit User"
        echo "3. Remove User"
        echo "4. Logout"
        read -p "Choose an option: " admin_option

        case $admin_option in
            1)
                add_user
                ;;
            2)
                read -p "Enter user's email to edit: " edit_email
                edit_user "$edit_email"
                ;;
            3)
                read -p "Enter user's email to remove: " remove_email
                remove_user "$remove_email"
                ;;
            4)
                echo "Logging out..."
                exit 0
                ;;
            *)
                echo "Invalid option. Please choose again."
                ;;
        esac
    done
}

# Function buat new user
function add_user() {
    # Pindah ke page registration
   /Users/rrrreins/sisop/mod1-soal2/register.sh
}

# Function buat edit informasi user
function edit_user() {
    local email="$1"

    # Check if the user exists
    if grep -q "^$email:" /Users/rrrreins/sisop/mod1-soal2/data/users.txt; then
        read -p "Enter new username (leave blank to keep current): " new_username
        read -s -p "Enter new password (leave blank to keep current): " new_password
        echo # Move to a new line after entering password
        
        # Update username if provided
        if [ -n "$new_username" ]; then
            sed -i "s/^$email:[^:]*:/&$new_username:/" /Users/rrrreins/sisop/mod1-soal2/data/users.txt
            echo "Username updated successfully for $email."
        fi

        # Update password if provided
        if [ -n "$new_password" ]; then
            # Encrypt the new password
            local encrypted_password=$(encrypt_password "$new_password")
            # Update the password in the file
            sed -i "s/^$email:[^:]*:[^:]*:/&$encrypted_password:/" /Users/rrrreins/sisop/mod1-soal2/data/users.txt
            echo "Password updated successfully for $email."
        fi
    else
        echo "User with email $email not found."
    fi
}

# Function buat hapus user
function remove_user() {
    local email="$1"
    
    # Check if the user exists
    if grep -q "^$email:" /Users/rrrreins/sisop/mod1-soal2/data/users.txt; then
        # Remove user from users.txt
        sed -i "/^$email:/d" /Users/rrrreins/sisop/mod1-soal2/data/users.txt
        echo "User with email $email removed successfully."
    else
        echo "User with email $email not found."
    fi
}


# Main script starts here
# Prompt user for login details
echo "Welcome to Login System"
echo "1. Login"
echo "2. Forgot Password"
read -p "Enter your choice: " choice

case $choice in
    1)
        # Login option selected
        read -p "Enter email: " email
        read -s -p "Enter password: " password
        echo
        authenticate_user "$email" "$password"
        ;;
    2)
        # Forgot Password option selected
        read -p "Enter email: " email
        forgot_password "$email" 
        ;;
    *)
        echo "Invalid choice. Please select 1 or 2."
        ;;
	esac
