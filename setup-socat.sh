#!/bin/bash

# تابع برای بررسی وضعیت اجرا
check_status() {
    if pgrep -x "socat" > /dev/null
    then
        echo -e "\033[0;32mRunning\033[0m"
    else
        echo -e "\033[0;31mNot Running\033[0m"
    fi
}

# تابع برای نصب اسکریپت
install_script() {
    echo "Enter the number of ports you want to use: "
    read num_ports

    ports=()
    ipv6_addresses=()

    for ((i=1; i<=num_ports; i++)); do
        echo "Enter port number $i: "
        read port
        ports+=("$port")
        echo "Enter the IPv6 address for port $port: "
        read ipv6
        ipv6_addresses+=("$ipv6")
    done

    # نصب socat در صورت عدم نصب
    sudo apt update
    sudo apt install -y socat

    # بازنویسی /etc/rc.local با افزودن #!/bin/bash به بالا
    echo "#!/bin/bash" | sudo tee /etc/rc.local > /dev/null

    # افزودن دستورات socat برای هر پورت و IPv6
    for index in "${!ports[@]}"; do
        port=${ports[$index]}
        ipv6=${ipv6_addresses[$index]}
        echo "socat TCP4-LISTEN:${port},fork TCP6:[${ipv6}]:${port},ipv6only=1 &" | sudo tee -a /etc/rc.local > /dev/null
    done

    echo "exit 0" | sudo tee -a /etc/rc.local > /dev/null

    # تنظیم مجوز اجرایی برای /etc/rc.local
    sudo chmod +x /etc/rc.local

    echo "Script installed successfully."
    exit 0
}

# تابع برای حذف اسکریپت
uninstall_script() {
    read -p "Are you sure you want to uninstall the script? (yes/no): " confirm
    if [[ "$confirm" == "yes" ]]; then
        # حذف خطوط socat از /etc/rc.local
        sudo sed -i '/socat TCP4-LISTEN/d' /etc/rc.local

        # حذف خط #!/bin/bash از ابتدای فایل اگر موجود باشد
        sudo sed -i '1d' /etc/rc.local

        echo "Script uninstalled successfully."
    else
        echo "Uninstallation canceled."
    fi
    exit 0
}

# تابع برای نمایش منو و پردازش ورودی
show_menu() {
    clear
    # طراحی ASCII Art سبز
    echo -e "\033[0;32m"
    echo "  _____               _____     _____   _____    _____    _____   _____   _______              _        _      "
    echo " |  __ \      /\     |  __ \   / ____| |  __ \  |_   _|  / ____| |_   _| |__   __|     /\     | |      | |     "
    echo " | |__) |    /  \    | |__) | | (___   | |  | |   | |   | |  __    | |      | |       /  \    | |      | |     "
    echo " |  ___/    / /\ \   |  _  /   \___ \  | |  | |   | |   | | |_ |   | |      | |      / /\ \   | |      | |     "
    echo " | |       / ____ \  | | \ \   ____) | | |__| |  _| |_  | |__| |  _| |_     | |     / ____ \  | |____  | |____ "
    echo " |_|      /_/    \_\ |_|  \_\ |_____/  |_____/  |_____|  \_____| |_____|    |_|    /_/    \_\ |______| |______|"
    echo "                                                                                                                "
    echo -e "\033[0m"  # بازگشت به رنگ پیش‌فرض

    # فاصله
    echo ""

    # طراحی ASCII Art آبی روشن
    echo -e "\033[1;34m"
    echo "  _______  ______  _       ______  _____  _____             __  __                __  __ __     __ ____   _    _  _______  _    _  ____  "
    echo " |__   __||  ____|| |     |  ____|/ ____||  __ \     /\    |  \/  |  _     ____  |  \/  |\ \   / // __ \ | |  | ||__   __|| |  | ||  _ \ "
    echo "    | |   | |__   | |     | |__  | |  __ | |__) |   /  \   | \  / | (_)   / __ \ | \  / | \ \_/ /| |  | || |  | |   | |   | |  | || |_) |"
    echo "    | |   |  __|  | |     |  __| | | |_ ||  _  /   / /\ \  | |\/| |      / / _\ || |\/| |  \   / | |  | || |  | |   | |   | |  | ||  _ / "
    echo "    | |   | |____ | |____ | |____| |__| || | \ \  / ____ \ | |  | |  _  | | (_| || |  | |   | |  | |__| || |__| |   | |   | |__| || |_) |"
    echo "    |_|   |______||______||______|\_____||_|  \_\/_/    \_\|_|  |_| (_)  \ \__,_||_|  |_|   |_|   \____/  \____/    |_|    \____/ |____/ "
    echo "                                                                          \____/                                                        "
    echo -e "\033[0m"  # بازگشت به رنگ پیش‌فرض

    echo "          ParsDigitall Script Management"
    echo "=========================================="
    echo -n "Status: "
    check_status  # اضافه کردن وضعیت سرویس
    echo "=========================================="
    echo "1) Install Script"
    echo "2) Uninstall Script"
    echo "3) Exit"
    echo "=========================================="
    echo -n "Please select an option [1-3]: "
}

# منو اصلی
show_menu
read choice
case $choice in
    1)
        install_script
        ;;
    2)
        uninstall_script
        ;;
    3)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option. Please select a valid option."
        exit 1
        ;;
esac
