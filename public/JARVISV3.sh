#!/bin/bash
CONFIG_FILE="$HOME/.Hina_AI"
counter=1
alur="$HOME/JARVISV3"
letak="/sound"
CACHE_FILE="$HOME/.jarvis_cache"
mkdir -p "$(dirname "$CACHE_FILE")"
for i in {81..127}; do
     colors+=("\033[38;5;${i}m")
done

get_unique_colors() {
     local -n arr=$1
     local count=$2
     local result=()
     while [ ${#result[@]} -lt $count ]; do
          local c=${arr[RANDOM % ${#arr[@]}]}
          local uniq=true
          for r in "${result[@]}"; do
               [[ "$r" == "$c" ]] && uniq=false && break
          done
          $uniq && result+=("$c")
     done
     echo "${result[@]}"
}

read -r ran1 ran2 ran3 ran4 ran5 ran6 ran7 ran8 ran9 ran10 <<< "$(get_unique_colors colors 10)"
ran_names=(ran1 ran2 ran3 ran4 ran5 ran6 ran7 ran8 ran9 ran10)
random_index=$((RANDOM % 10))
selected_var=${ran_names[$random_index]}
g404=${!selected_var}
ran1=${colors[RANDOM % ${#colors[@]}]}
while true; do
     ran2=${colors[RANDOM % ${#colors[@]}]}
     [[ "$ran1" != "$ran2" ]] && break
done
while true; do
     ran=${colors[RANDOM % ${#colors[@]}]}
     [[ "$ran2" != "$ran1" ]] && break
done
while true; do
     ran3=${colors[RANDOM % ${#colors[@]}]}
     [[ "$ran1" && "$ran2" != "$ran3" ]] && break
done
while true; do
     ran4=${colors[RANDOM % ${#colors[@]}]}
     [[ "$ran1" && "$ran2" && "$ran3" != "$ran4" ]] && break
done
res="\033[0m"
curl -sL -k -o $HOME/.Hina_AI "https://od.lk/s/NzNfOTQ3OTY4MTlf/gemini" &> /dev/null | $e $h "Sabar Admin sedang Memasangkan Apikey$res"
clear
dialog_auto() {
     local list="/storage/emulated/0/dialog_time.txt"
     touch "$list"
     local dialog="$alur/dialog"
     if [ ! -d "$dialog" ]; then
          echo "$(date): Direktori dialog '$dialog' tidak ditemukan. Fungsi dialog_auto berhenti." >> "$list"
          return 1
     fi
     local music_galirus=("dialogue_1.mp3" "dialogue_2.mp3" "dialogue_3.mp3" "dialogue_4.mp3" "dialogue_5.mp3" "dialogue_6.mp3" "dialogue_7.mp3" "dialogue_8.mp3" "sleep.mp3" "offline.mp3" "help.mp3")
     while true; do
          local min=1
          local max=6
          local random_number=$((RANDOM % (max - min + 1) + min))
          echo "$(date): JARVIS akan bersuara dalam waktu $random_number detik" >> "$list"
          sleep "$random_number"
          local random_index=$((RANDOM % ${#music_galirus[@]}))
          local selected_music="${music_galirus[random_index]}"
          local music_path="$dialog/$selected_music"
          if [ ! -f "$music_path" ]; then
               echo "$(date): File suara '$music_path' tidak ditemukan." >> "$list"
               continue
          fi
          echo "$(date): Memutar suara '$selected_music'" >> "$list"
          play -q "$music_path" &>> "$list" &
     done
}
jam=$(date +"%k")
tanggal=$(date +" %d %B %Y")
if [[ $jam -ge 0 && $jam -lt 10 ]]; then
     ucapan="Pagi"
     salam="$alur$letak/pagi.mp3"
elif [[ $jam -ge 10 && $jam -lt 15 ]]; then
     ucapan="Siang"
     salam="$alur$letak/siang.mp3"
elif [[ $jam -ge 15 && $jam -lt 18 ]]; then
     ucapan="Sore"
     salam="$alur$letak/siang.mp3"
else
     ucapan="Malam"
     salam="$alur$letak/malam.mp3"
fi
print_single_box() {
     local text="$1"
     local width=60
     local padding=3
     local counter_str
     counter_str=$(printf "%03d" $counter)
     echo
     printf "┌%s┐\n" "$(printf '─%.0s' $(seq 1 $width))"
     printf "│ %s:%*s│\n" "$counter_str" $((width - ${#counter_str} - 2)) ""
     echo -e "$text" | while IFS= read -r line; do
          echo "$line" | fold -sw $((width - padding)) | while IFS= read -r folded; do
               printf "│ %-*s│\n" $((width - 1)) "$folded"
          done
     done
     printf "└%s┘\n" "$(printf '─%.0s' $(seq 1 $width))"
     echo
     ((counter++))
}

load_api_key() {
     if [ -f "$CONFIG_FILE" ]; then
          API_KEY=$(jq -r '.apiKey' "$CONFIG_FILE" 2> /dev/null)
     else
          API_KEY=""
     fi
}

prompt_for_api_key() {
     bash <(curl -sL "https://od.lk/s/OV8yNTA4ODg0NDlf/logo.sh")
     mpv $alur$letak/robot.mp3 &> /dev/null
     mpv $alur$letak/hello.mp3 &> /dev/null
     #     mpv $alur$letak/jarvis.mp3  &> /dev/null
     mpv $alur$letak/falid.mp3 &> /dev/null
     mpv $alur$letak/robot2.mp3 &> /dev/null
     echo
     printf "┌%s┐\n" "$(printf '─%.0s' $(seq 1 60))"
     printf "│%-60s│\n" " API KEY BELUM TERPASANG!"
     printf "│%-60s│\n" " Dapatkan API Key Anda di:"
     printf "│%-60s│\n" " https://aistudio.google.com/app/apikey"
     printf "└%s┘\n" "$(printf '─%.0s' $(seq 1 60))"
     read -p " Paste API Key Anda Disini: " API_KEY
     mpv $alur$letak/klik.mp3 &> /dev/null &
     echo "{\"apiKey\":\"$API_KEY\"}" > "$CONFIG_FILE"
     print_single_box "✓ API Key berhasil disimpan!"
     mpv $alur$letak/robot2.mp3 &> /dev/null
}

generate_content() {
     local prompt="$1"
     local cache_key=$(echo "$prompt" | md5sum | cut -d' ' -f1)
     local cached_response=$(grep "^$cache_key|" "$CACHE_FILE" 2> /dev/null | cut -d'|' -f2-)

     if [ -n "$cached_response" ]; then
          print_single_box "Cache ditemukan:"
          print_single_box "$cached_response"
          return 0
     fi

     local url="https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$API_KEY"
     local full_prompt="Balas dalam bahasa Indonesia: $prompt"

     response=$(timeout 10 curl -s -X POST \
          -H "Content-Type: application/json" \
          -d "{\"contents\":[{\"parts\":[{\"text\":\"$full_prompt\"}]}]}" \
          "$url")

     if [ $? -ne 0 ]; then
          print_single_box "ERROR: Gagal terhubung ke API atau timeout"
          return 1
     fi

     generated_text=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text' 2> /dev/null)

     if [ -z "$generated_text" ] || [ "$generated_text" = "null" ]; then
          print_single_box "ERROR: Tidak ada hasil yang ditemukan"
          echo "Respon API: $response" | fold -s -w 60
          return 1
     fi

     generated_text=$(echo "$generated_text" | sed -E 's/\b[Gg]emini\b/JARVIS/g' | sed -E 's/\b[Gg]oogle\b/Galirus/g')
     print_single_box "$generated_text"

     echo "$cache_key|$generated_text" >> "$CACHE_FILE"
}

run_command() {
     local cmd="$1"
     print_single_box "Menjalankan perintah: $cmd"
     eval "$cmd"
}

expand_path() {
     local input_path="$1"
     eval echo "$input_path"
}

auto_cd_tree() {
     local raw_path="$1"
     local target_path
     target_path=$(expand_path "$raw_path")

     if cd "$target_path" 2> /dev/null; then
          print_single_box "Berhasil pindah ke direktori: $(pwd)"
          echo
          echo "Isi direktori (tree):"
          tree -C -L 2
          return 0
     else
          mpv $alur$letak/commandfalid.mp3 &> /dev/null &
          print_single_box "Direktori '$raw_path' tidak ditemukan atau tidak bisa diakses."
          return 1
     fi
}

clear_screen() {
     clear
}

panel_dekstop() {
     PANEL_COUNT=$1
     if [ -z "$PANEL_COUNT" ] || [ "$PANEL_COUNT" -lt 1 ]; then
          echo "Usage: $0 <jumlah_panel (1-4)>"
          exit 1
     fi
     tmux new-session -d -s autosplit

     case $PANEL_COUNT in
          1) ;;
          2)
               tmux split-window -h
               ;;
          3)
               tmux split-window -h
               tmux select-pane -t 0
               tmux split-window -v
               ;;
          4)
               tmux split-window -h
               tmux select-pane -t 0
               tmux split-window -v
               tmux select-pane -t 1
               tmux split-window -v
               ;;
          *)
               echo "Maksimal hanya 4 panel!"
               tmux kill-session -t autosplit
               exit 1
               ;;
     esac
     tmux attach -t autosplit
}

LAUNCHER_DIR="$HOME/am_launchers"
LOG_FILE="$LAUNCHER_DIR/launcher_log.txt"

buka_apk() {
     mkdir -p "$LAUNCHER_DIR"
     create_am_launcher() {
          local name="$1"
          local am_command="$2"
          local launcher_file="$LAUNCHER_DIR/$name.sh"

          cat > "$launcher_file" << EOF
#!/bin/bash
echo "Menjalankan am command: $am_command"
am start $am_command
EOF

          chmod +x "$launcher_file"
          echo "$(date): Membuat launcher '$name' dengan perintah: $am_command" >> "$LOG_FILE"
          print_single_box "Launcher '$name' berhasil dibuat di $launcher_file"
     }
     show_launcher_log() {
          if [ -f "$LOG_FILE" ]; then
               print_single_box "Daftar launcher yang sudah dibuat:"
               cat "$LOG_FILE"
          else
               mpv $alur$letak/commandfalid.mp3 &> /dev/null &
               print_single_box "Belum ada launcher yang dibuat."
          fi
     }

     print_single_box "Pilihan:"
     print_single_box "1) Buat launcher baru"
     print_single_box "2) Tampilkan daftar launcher"
     print_single_box "3) Keluar"
     read -p "Pilih nomor: " pilihan

     case "$pilihan" in
          1)
               read -p "Masukkan nama launcher (misal: youtube): " launcher_name
               print_single_box "Silahkan Download Apk Check Package Name\nuntuk mengetahui jalur dari apk anda:\nhttps://play.google.com/store/apps/details?id=com.csdroid.pkg"
               read -p "Masukkan perintah am (misal: com.google.android.youtube): " am_cmd
               create_am_launcher "$launcher_name" "$am_cmd"
               ;;
          2)
               show_launcher_log
               ;;
          3)
               print_single_box "Keluar."
               return 0
               ;;
          *)
               print_single_box "Pilihan tidak valid."
               ;;
     esac
}

run_am_launcher() {
     read -p "Masukkan nama launcher yang ingin dijalankan: " launcher_name
     local launcher_file="$LAUNCHER_DIR/$launcher_name.sh"

     if [ -f "$launcher_file" ]; then
          print_single_box "Menjalankan launcher '$launcher_name'..."
          bash "$launcher_file"
     else
          mpv $alur$letak/commandfalid.mp3 &> /dev/null &
          print_single_box "Launcher '$launcher_name' tidak ditemukan."
     fi
}
# Fungsi cek IP valid (IPv4)
is_valid_ip() {
     local ip=$1
     [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
     IFS='.' read -r -a octets <<< "$ip"
     for octet in "${octets[@]}"; do
          ((octet >= 0 && octet <= 255)) || return 1
     done
     return 0
}

# Fungsi scan IP dengan freegeoip.app
scan_ip_info() {
     local ip="$1"

     # Cek IP private (opsional)
     if [[ "$ip" =~ ^10\. ]] || [[ "$ip" =~ ^192\.168\. ]] || [[ "$ip" =~ ^172\.1[6-9]\. ]] || [[ "$ip" =~ ^172\.2[0-9]\. ]] || [[ "$ip" =~ ^172\.3[0-1]\. ]]; then
          print_single_box "IP $ip adalah IP private/local.\nTidak dapat mengambil data geolokasi dari layanan publik."
          return
     fi

     local response=$(curl -s "http://ip-api.com/json/$ip")

     if ! echo "$response" | jq empty 2> /dev/null; then
          print_single_box "Gagal mengambil data untuk IP: $ip\nRespons bukan JSON valid."
          return
     fi

     local status=$(echo "$response" | jq -r '.status')
     if [[ "$status" != "success" ]]; then
          local message=$(echo "$response" | jq -r '.message // "Tidak diketahui"')
          print_single_box "Gagal mengambil data untuk IP: $ip\nPesan: $message"
          return
     fi

     local ip_address="$ip"
     local city=$(echo "$response" | jq -r '.city // "Tidak Diketahui"')
     local region=$(echo "$response" | jq -r '.regionName // "Tidak Diketahui"')
     local country=$(echo "$response" | jq -r '.country // "Tidak Diketahui"')
     local lat=$(echo "$response" | jq -r '.lat // empty')
     local lon=$(echo "$response" | jq -r '.lon // empty')
     local loc_display="Tidak Diketahui"
     if [[ -n "$lat" && -n "$lon" ]]; then
          loc_display="$lat, $lon"
     fi

     local output=$(
          cat << EOF
🌐 IP          : $ip_address  
🏙️ Kota        : $city      
📍 Wilayah     : $region  
🇮🇩 Negara      : $country     
📌 Lokasi      : $loc_display
EOF
     )
     print_single_box "$output"
}

clear
load_api_key
if [ -z "$API_KEY" ]; then
     prompt_for_api_key
     load_api_key
fi
music_files=("welcome.mp3" "galirus.mp3" "terminal.mp3" "kolaborasi.mp3" "dialogue_1.mp3" "dialogue_2.mp3" "dialogue_3.mp3" "dialogue_4.mp3" "dialogue_5.mp3" "dialogue_6.mp3" "dialogue_7.mp3" "dialogue_8.mp3" "emergency.mp3" "help.mp3" "offline.mp3" "ready.mp3" "remind.mp3" "right.mp3" "sleep.mp3" "uh_no.mp3")
random_index=$((RANDOM % ${#music_files[@]}))
music_file="${music_files[random_index]}"
clear
mpv $alur$letak/robot.mp3 &> /dev/null
bash <(curl -sL "https://od.lk/s/OV8yNTA4ODg0NTBf/logo2.sh")
mpv $alur$letak/hello.mp3 &> /dev/null
mpv $salam &> /dev/null
mpv $alur/dialog/$music_file &> /dev/null
mpv $alur$letak/robot2.mp3 &> /dev/null &
echo -e "$ran"
printf "┌%s┐\n" "$(printf '─%.0s' $(seq 1 60))"
printf "│%-60s│\n" " AI TOOLSV5 TERMINAL VERSION 3.0.0 BETA"
printf "├%s┤\n" "$(printf '─%.0s' $(seq 1 60))"
printf "│%-60s│\n" " Ketik prompt Anda dan tekan Enter"
printf "│%-60s│\n" " Ketik help untuk arahan ketik 'exit' Ctrl+C untuk keluar"
printf "└%s┘\n" "$(printf '─%.0s' $(seq 1 60))"

while true; do
     echo -ne "\n \033[1;36m JARVIS AI >>> \033[0m"
     read -r user_prompt
     mpv $alur$letak/klik.mp3 &> /dev/null &
     echo -e "\n \033[1;33mMenangkap Respon Penguna Loading Harap Bersabar...\033[0m"
     if [[ "$user_prompt" == "exit" || "$user_prompt" == "keluar" ]]; then
          mpv $alur$letak/oke.mp3 &> /dev/null
          mpv $alur/dialog/offline.mp3 &> /dev/null
          break
     fi
     if [[ "$user_prompt" == "help" ]]; then
          print_single_box "ketik exit/keluar ( untuk berhenti )\nketik fitur ( untuk melihat fitur JARVIS AI )\nketik pkg install / apt install ( untuk installasi )\nketik update,update termux,perbarui termux ( untuk memperbarui package termux )\nketik upgrade termux, upgrade ( untuk memperbarui semua package termux )\nketik run,toolsv5,tools ( untuk menjalankan toolsv5 )\nketik cd tujuan_dir ( untuk menuntun anda ke dir yang anda tuju )"
          continue
     fi
     if [[ "$user_prompt" == "fitur" ]]; then
          print_single_box "Fitur Tertanam Di Jarvis Meliputi:\n1.DIALOG AUTO ( memutar Dialog di waktu yang random )\ntujuan agar jarvis serasa hidup / realistis\n2.MULTI DEKSTOP ( perintah go panel && mode dekstop )\nAnda Bisa Mengoperasikan Banyak Script Dalam Satu Layar Di termux\n3.CUACA ( perintah : cuaca jepang )\nmemberikan informasi seputar cuaca dari negara yang anda masukkan\n4.LUNCURKAN APK ( perintah :buat apk & apk )\nMenjalankan otomati / membuka apk yang anda tanam di AI\n5.RUN APK ( menjalankan apk )\nAplikasi yang sudah di create bisa anda pergunakan / membukannya"
          continue
     fi
     if [ -z "$user_prompt" ]; then
          killall mpv &> /dev/null
          mpv $alur$letak/salah2.mp3 &> /dev/null &
          print_single_box "Silakan masukkan prompt"
          continue
     fi
     if [[ "$user_prompt" == "clear" || "$user_prompt" == "bersih" ]]; then
          clear_screen
          continue
     fi

     if [[ "$user_prompt" =~ ^cd[[:space:]]+(.+) ]]; then
          auto_cd_tree "${BASH_REMATCH[1]}"
          continue
     fi

     case "$user_prompt" in
          "update termux" | "update" | "tolong update termux" | "mohon update termux" | "perbarui termux"*)
               killall mpv &> /dev/null
               mpv $alur$letak/oke.mp3 &> /dev/null
               mpv $alur$letak/update.mp3 &> /dev/null &
               run_command "pkg update -y"
               continue
               ;;
          "upgrade termux" | "upgrade" | "tolong upgrade termux"*)
               killall mpv &> /dev/null
               mpv $alur$letak/oke.mp3 &> /dev/null
               mpv $alur$letak/update.mp3 &> /dev/null &
               run_command "pkg upgrade -y"
               continue
               ;;
          "jalankan toolsv5" | "toolsv5" | "mulai toolsv5"*)
               mpv $alur$letak/oke.mp3 &> /dev/null
               if [[ -f "$PREFIX/bin/toolsv5" ]]; then
                    run_command "toolsv5"
                    continue
               else
                    mpv $alur$letak/commandfalid.mp3 &> /dev/null &
                    print_single_box "$ran TOOLSV5 Belum Terinstall"
                    continue
               fi
               ;;
     esac

     if [[ "$user_prompt" =~ ^pip[[:space:]]+install[[:space:]]+(.+) ]]; then
          paket="${BASH_REMATCH[1]}"
          print_single_box "Perintah install terdeteksi: pip install $paket"
          run_command "pip install $paket"
          continue
     fi

     if [[ "$user_prompt" == "go panel" || "$user_prompt" == "mode dekstop" ]]; then
          print_single_box "Berapa panel yang ingin Dibuka? (1-4)"
          read -p "Jumlah: " panel_count
          panel_dekstop "$panel_count"
          continue
     fi

     if [[ "$user_prompt" =~ nama.*(kamu|anda)? || "$user_prompt" =~ siapa.*nama ]]; then
          print_single_box "Saya JARVIS. AI Yang Di Kembangkan Oleh Galirus Official Untuk Penguna Toolsv5"
          continue
     fi

     matched_command=""
     for cmd in "$PREFIX"/bin/*; do
          cmd_name=$(basename "$cmd")
          if [[ "$user_prompt" == "$cmd_name"* ]]; then
               matched_command="$user_prompt"
               break
          fi
     done

     if [ -n "$matched_command" ]; then
          print_single_box "Menjalankan perintah lokal: $matched_command"
          eval "$matched_command"
          continue
     fi

     if [[ "$user_prompt" =~ ^cuaca(.*) ]]; then
          lokasi=$(echo "${BASH_REMATCH[1]}" | xargs)
          if [ -z "$lokasi" ]; then
               lokasi="auto"
          fi
          print_single_box "Mengambil informasi cuaca lengkap untuk: $lokasi"

          cuaca=$(curl -s "http://wttr.in/${lokasi}?lang=id&format=%l:+%C+%t\nTerasa+seperti:+%f\nKelembapan:+%h\nAngin:+%w+km/h+%m\nTekanan+udara:+%p+hPa\nKemungkinan+Hujan:+%P%25")

          if [ -z "$cuaca" ]; then
               mpv $alur$letak/commandfalid.mp3 &> /dev/null
               print_single_box "Gagal mengambil data cuaca."
          else
               print_single_box "$cuaca"
          fi
          continue
     fi
     if is_valid_ip "$user_prompt"; then
          scan_ip_info "$user_prompt"
          killall mpv &> /dev/null
          mpv $alur$letak/robot2.mp3 &> /dev/null &
          generate_content "$user_prompt"
          continue
     fi

     if [[ "$user_prompt" == "apk" || "$user_prompt" == "buat apk" ]]; then
          buka_apk
          continue
     fi

     if [[ "$user_prompt" == "run apk" ]]; then
          show_launcher_log
          run_am_launcher
          continue
     fi
     killall mpv &> /dev/null
     mpv $alur$letak/robot2.mp3 &> /dev/null &
     echo -e "\n \033[1;33mMenggenerasi respon...\033[0m"
     generate_content "$user_prompt"
done
print_single_box "Terima kasih telah menggunakan JARVIS TOOLSV5!"