#!/bin/bash
cd "$(dirname "$0")"
# ============================================================
# HealthMaxxing — tes end-to-end semua endpoint
# Cara pakai (server harus jalan di :3000, MySQL nyala, schema sudah di-load):
#   bash test_all.sh
# ============================================================
BASE="http://localhost:3000/api"
DB="mysql -u root healthmaxxing -N -e"
PASS=0; FAIL=0

json() { python3 -c "import sys,json; d=json.load(sys.stdin); print($1)" 2>/dev/null; }

check() { # check "deskripsi" expected actual
  if [ "$2" == "$3" ]; then echo "  [PASS] $1"; PASS=$((PASS+1));
  else echo "  [FAIL] $1  (harusnya: $2, dapat: $3)"; FAIL=$((FAIL+1)); fi
}

req() { # req METHOD PATH TOKEN [BODY] -> cetak "STATUS|BODY"
  local m=$1 p=$2 t=$3 b=$4
  local args=(-s -w "|%{http_code}" -X "$m" "$BASE$p" -H "Content-Type: application/json")
  [ -n "$t" ] && args+=(-H "Authorization: Bearer $t")
  [ -n "$b" ] && args+=(-d "$b")
  curl "${args[@]}"
}
status() { echo "${1##*|}"; }
body()   { echo "${1%|*}"; }

register() { curl -s -X POST $BASE/auth/register -H "Content-Type: application/json" \
  -d "{\"name\":\"$1\",\"email\":\"$2\",\"username\":\"$3\",\"password\":\"password123\",\"role\":\"$4\"}" > /dev/null; }
login() { curl -s -X POST $BASE/auth/login -H "Content-Type: application/json" \
  -d "{\"username\":\"$1\",\"password\":\"password123\"}" | json "d['token']"; }

# --- Pemeriksaan: database harus BARU ---
# Skrip ini memasukkan data uji dengan ID tetap (PT = user 1, klien = client 1, dst.). Penghitung ID
# (AUTO_INCREMENT) tidak mundur walau datanya dihapus, jadi database yang pernah dipakai membuat ID
# tidak cocok dan puluhan tes gagal dengan pesan yang membingungkan. Lebih baik berhenti di sini.
if ! mysql -u root -e "USE healthmaxxing" 2>/dev/null; then
  echo "Tidak bisa terhubung ke database 'healthmaxxing' (MySQL menyala? schema sudah dimuat?)."
  exit 2
fi
next_id() {
  mysql -u root -N -e "SET SESSION information_schema_stats_expiry=0; SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA='healthmaxxing' AND TABLE_NAME='$1'" 2>/dev/null \
    || mysql -u root -N -e "SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA='healthmaxxing' AND TABLE_NAME='$1'" 2>/dev/null
}
for tbl in users client_profiles exercise_reference food_reference workout_plans workout_plan_items meal_plans meal_plan_items notifications ai_analysis_results; do
  n=$(next_id $tbl)
  if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -gt 1 ]; then
    echo "DATABASE BELUM BERSIH: tabel '$tbl' sudah pernah dipakai (ID berikutnya = $n)."
    echo "Skrip ini butuh database yang benar-benar baru. Langkah:"
    echo "  1. Hentikan server (Ctrl+C di terminal npm run dev)"
    echo "  2. mysql -u root -e \"DROP DATABASE IF EXISTS healthmaxxing;\""
    echo "  3. mysql -u root < healthmaxxing_schema.sql     (JANGAN muat healthmaxxing_seed.sql)"
    echo "  4. Nyalakan server lagi (npm run dev), lalu jalankan ulang: bash test_all.sh"
    exit 2
  fi
done

echo "== Setup: bikin 2 PT + 2 klien =="
register "PT Budi" budi@t.com ptbudi pt
register "PT Rina" rina@t.com ptrina pt
register "Klien Ani" ani@t.com klienani klien
register "Klien Sari" sari@t.com klien_sari klien
PT1=$(login ptbudi); PT2=$(login ptrina); KA=$(login klienani); KB=$(login klien_sari)

PROFILE='{"birth_date":"2000-05-10","gender":"female","height_cm":160,"weight_current":65,"weight_target":58,"allergies":"-","activity_level":"moderate"}'
req POST /clients/me/profile $KA "$PROFILE" > /dev/null
req POST /clients/me/profile $KB "$PROFILE" > /dev/null

# user_id: ptbudi=1 ptrina=2 ani=3 sari=4 | client_id: ani=1 sari=2
$DB "
UPDATE client_profiles SET assigned_pt_id=1 WHERE client_id=1;
UPDATE client_profiles SET assigned_pt_id=2 WHERE client_id=2;
INSERT INTO exercise_reference (name,category,calories_per_unit) VALUES ('Push Up','strength',0.5);
INSERT INTO food_reference (name,calories,protein_g,carbs_g,fat_g) VALUES ('Nasi Merah',215,5,45,2);
INSERT INTO workout_plans (client_id,week_start_date) VALUES (1,'2026-10-12'),(2,'2026-10-12');
INSERT INTO workout_plan_items (plan_id,exercise_id,day_of_week,\`sets\`,reps) VALUES (1,1,'mon',3,10),(2,1,'mon',3,10);
INSERT INTO meal_plans (client_id,week_start_date) VALUES (1,'2026-10-12'),(2,'2026-10-12');
INSERT INTO meal_plan_items (plan_id,food_id,meal_type) VALUES (1,1,'lunch'),(2,1,'lunch');
INSERT INTO ai_analysis_results (client_id,week_start_date,ai_output) VALUES
  (1,'2026-10-12','{\"summary\":\"rencana A\"}'),(2,'2026-10-12','{\"summary\":\"rencana B\"}');
INSERT INTO notifications (user_id,type,title,message) VALUES (3,'ai_insight','Insight','Langkahmu naik!'),(4,'system','Halo','Untuk Sari');
"

echo; echo "== 1. Data master =="
R=$(req GET /exercises $KA); check "GET /exercises" 200 $(status "$R")
R=$(req GET /foods $KA);     check "GET /foods" 200 $(status "$R")
R=$(req GET /exercises "");  check "GET /exercises tanpa token ditolak" 401 $(status "$R")

echo; echo "== 2. Workout plan (klien Ani) =="
R=$(req GET /clients/me/workout-plans/current $KA)
check "GET workout plan" 200 $(status "$R")
check "  plan berisi 1 item + nama latihan" "Push Up" "$(body "$R" | json "d['items'][0]['exercise_name']")"
R=$(req PATCH /workout-plan-items/1 $KA '{"is_completed":true}')
check "Ani centang item miliknya" 200 $(status "$R")
check "  DB: is_completed jadi 1" 1 $($DB "SELECT is_completed FROM workout_plan_items WHERE item_id=1")
R=$(req PATCH /workout-plan-items/2 $KA '{"is_completed":true}')
check "Ani coba centang item MILIK SARI -> ditolak" 404 $(status "$R")
check "  DB: item Sari TIDAK berubah" 0 $($DB "SELECT is_completed FROM workout_plan_items WHERE item_id=2")
R=$(req PATCH /workout-plan-items/999 $KA '{"is_completed":true}'); check "ID tidak ada -> 404" 404 $(status "$R")
R=$(req PATCH /workout-plan-items/1 $KA '{"is_completed":"yes"}');  check "Input bukan boolean -> 400" 400 $(status "$R")

echo; echo "== 3. Meal plan (klien Ani) =="
R=$(req GET /clients/me/meal-plans/current $KA); check "GET meal plan" 200 $(status "$R")
R=$(req PATCH /meal-plan-items/1 $KA '{"is_completed":true}'); check "Ani centang makanan miliknya" 200 $(status "$R")
R=$(req PATCH /meal-plan-items/2 $KA '{"is_completed":true}'); check "Ani coba centang makanan MILIK SARI -> ditolak" 404 $(status "$R")
check "  DB: makanan Sari TIDAK berubah" 0 $($DB "SELECT is_completed FROM meal_plan_items WHERE item_id=2")

echo; echo "== 4. Notifikasi =="
R=$(req GET /users/me/notifications $KA)
check "GET notifikasi Ani (hanya miliknya)" 1 "$(body "$R" | json "len(d)")"
req PATCH /notifications/1/read $KA > /dev/null
check "  Ani tandai notif miliknya dibaca" 1 $($DB "SELECT is_read FROM notifications WHERE notification_id=1")
req PATCH /notifications/2/read $KA > /dev/null
check "  Ani TIDAK bisa tandai notif milik Sari" 0 $($DB "SELECT is_read FROM notifications WHERE notification_id=2")

echo; echo "== 5. Dashboard PT =="
R=$(req GET "/pt/clients?status=active" $PT1)
check "PT Budi lihat daftar klien aktif (hanya bimbingannya)" 1 "$(body "$R" | json "len(d)")"
R=$(req GET /pt/clients/1 $PT1); check "Budi lihat detail Ani (bimbingannya)" 200 $(status "$R")
R=$(req GET /pt/clients/2 $PT1); check "Budi lihat detail Sari (BUKAN bimbingannya) -> ditolak" 404 $(status "$R")
req PUT /clients/me/daily-logs/today $KA '{"steps":8000,"water_liters":1.5,"weight_kg":64.5}' > /dev/null
R=$(req GET /pt/clients/1/progress $PT1); check "Budi lihat progres Ani" 200 $(status "$R")
check "  data grafik berisi steps 8000" 8000 "$(body "$R" | json "d[0]['steps']")"
R=$(req GET /pt/clients/2/progress $PT1); check "Budi lihat progres Sari -> ditolak" 403 $(status "$R")
R=$(req GET /pt/clients/1 $KA);           check "Klien akses endpoint PT -> ditolak" 403 $(status "$R")

echo; echo "== 6. Review rencana AI (approve / override) =="
R=$(req GET /pt/clients/1/ai-analysis/current $PT1); check "Budi baca analisis AI Ani" 200 $(status "$R")
R=$(req GET /pt/clients/2/ai-analysis/current $PT1); check "Budi baca analisis AI Sari -> ditolak" 403 $(status "$R")
R=$(req PATCH /pt/ai-analysis/2/approve $PT1);       check "Budi approve analisis Sari -> ditolak" 403 $(status "$R")
check "  DB: analisis Sari tetap pending" pending $($DB "SELECT status FROM ai_analysis_results WHERE analysis_id=2")
R=$(req PATCH /pt/ai-analysis/1/approve $PT1);       check "Budi approve analisis Ani" 200 $(status "$R")
check "  DB: status approved" approved $($DB "SELECT status FROM ai_analysis_results WHERE analysis_id=1")
check "  DB: final_output terisi dari ai_output" 'rencana A' "$($DB "SELECT JSON_UNQUOTE(JSON_EXTRACT(final_output,'\$.summary')) FROM ai_analysis_results WHERE analysis_id=1")"
R=$(req PATCH /pt/ai-analysis/2/override $PT2 '{}');  check "Override tanpa final_output -> 400" 400 $(status "$R")
R=$(req PATCH /pt/ai-analysis/2/override $PT2 '{"final_output":{"summary":"Sari cedera, kurangi beban"}}')
check "Rina override analisis Sari (cedera)" 200 $(status "$R")
check "  DB: status overridden" overridden $($DB "SELECT status FROM ai_analysis_results WHERE analysis_id=2")
R=$(req PATCH /pt/ai-analysis/2/override $PT2 '{"final_output":"bukan objek"}'); check "Override dengan final_output bukan objek -> 400" 400 $(status "$R")

echo; echo "== 7. Daily log & target harian (Ani) =="
R=$(req GET /clients/me/daily-logs/today $KA)
check "GET log hari ini: steps 8000" 8000 "$(body "$R" | json "d['steps']")"
req PUT /clients/me/daily-logs/today $KA '{"steps":9500}' > /dev/null
check "Sync parsial (hanya steps): steps terupdate" 9500 "$($DB "SELECT steps FROM daily_logs WHERE client_id=1")"
check "  air TIDAK tertimpa (tetap 1.50)" "1.50" "$($DB "SELECT water_liters FROM daily_logs WHERE client_id=1")"
check "  berat TIDAK tertimpa (tetap 64.50)" "64.50" "$($DB "SELECT weight_kg FROM daily_logs WHERE client_id=1")"
R=$(req GET "/clients/me/daily-logs?from=2000-01-01&to=2999-12-31" $KA)
check "GET rentang tanggal (mencakup hari ini)" 1 "$(body "$R" | json "len(d)")"
R=$(req GET "/clients/me/daily-logs?from=2000-01-01&to=2000-12-31" $KA)
check "GET rentang tanggal (di luar hari ini)" 0 "$(body "$R" | json "len(d)")"
R=$(req PUT /clients/me/daily-logs/today $KA '{"steps":-5}');      check "steps negatif -> 400" 400 $(status "$R")
R=$(req PUT /clients/me/daily-logs/today $KA '{"steps":"abc"}');   check "steps bukan angka -> 400" 400 $(status "$R")
R=$(req PUT /clients/me/daily-logs/today $KA '{"water_liters":99}'); check "air tidak masuk akal -> 400" 400 $(status "$R")
check "  DB: steps tetap 9500 setelah input ditolak" 9500 "$($DB "SELECT steps FROM daily_logs WHERE client_id=1")"
R=$(req GET /clients/me/daily-logs/today $KB); check "Sari tidak melihat log Ani" null "$(body "$R")"
R=$(req GET /clients/me/targets/current $KA); check "Target belum ada -> 200 + null" "200|null" "$(status "$R")|$(body "$R")"
$DB "INSERT INTO targets (client_id,week_start_date,target_steps,target_water_liters,target_calories,source) VALUES (1,'2026-10-12',10000,2.5,2000,'ai');"
R=$(req GET /clients/me/targets/current $KA); check "GET target minggu ini: 10000 langkah" 10000 "$(body "$R" | json "d['target_steps']")"
R=$(req GET /clients/me/targets/current $KB); check "Sari tidak melihat target Ani" null "$(body "$R")"

echo; echo "== 8. Validasi Health Profile (klien baru: Dewi) =="
register "Klien Dewi" dewi@t.com klien_dewi klien
KD=$(login klien_dewi)
R=$(req POST /clients/me/profile $KD '{"gender":"abc","weight_current":60,"weight_target":55}'); check "gender tidak valid -> 400" 400 $(status "$R")
R=$(req POST /clients/me/profile $KD '{"weight_current":-5,"weight_target":55}');               check "berat negatif -> 400" 400 $(status "$R")
R=$(req POST /clients/me/profile $KD '{"weight_current":60}');                                  check "weight_target kosong -> 400" 400 $(status "$R")
R=$(req POST /clients/me/profile $KD '{"birth_date":"2999-01-01","weight_current":60,"weight_target":55}'); check "tanggal lahir di masa depan -> 400" 400 $(status "$R")
check "  DB: belum ada profil Dewi (semua ditolak)" 0 "$($DB "SELECT COUNT(*) FROM client_profiles WHERE user_id=5")"
R=$(req POST /clients/me/profile $KD '{"birth_date":"1999-03-02","gender":"female","height_cm":158,"weight_current":60,"weight_target":55,"allergies":"udang","activity_level":"light"}')
check "Profil valid -> 201" 201 $(status "$R")
R=$(req POST /clients/me/profile $KD '{"weight_current":60,"weight_target":55}'); check "Isi profil dua kali -> 409" 409 $(status "$R")
R=$(req PATCH /clients/me/profile $KD '{"gender":"zzz"}');           check "PATCH gender tidak valid -> 400" 400 $(status "$R")
R=$(req PATCH /clients/me/profile $KD '{"weight_current":63}');      check "PATCH berat valid -> 200" 200 $(status "$R")
check "  DB: berat jadi 63.00" "63.00" "$($DB "SELECT weight_current FROM client_profiles WHERE user_id=5")"
R=$(req PATCH /clients/me/profile $KD '{"assigned_pt_id":1}');       check "PATCH assigned_pt_id (mass assignment) -> 400" 400 $(status "$R")
check "  DB: assigned_pt_id tetap NULL" NULL "$($DB "SELECT IFNULL(assigned_pt_id,'NULL') FROM client_profiles WHERE user_id=5")"
LONG=$(python3 -c "print('a'*600)")
R=$(req PATCH /clients/me/profile $KD "{\"allergies\":\"$LONG\"}");  check "allergies terlalu panjang -> 400" 400 $(status "$R")

echo; echo "== 9. Klien memilih PT =="
R=$(req POST /clients/me/pt $KD '{"pt_username":"ptbudi"}');   check "Dewi pilih PT Budi" 200 $(status "$R")
check "  DB: assigned_pt_id = 1 (Budi)" 1 "$($DB "SELECT assigned_pt_id FROM client_profiles WHERE user_id=5")"
R=$(req POST /clients/me/pt $KD '{"pt_username":"ghost"}');    check "PT tidak ada -> 404" 404 $(status "$R")
R=$(req POST /clients/me/pt $KD '{"pt_username":"klienani"}'); check "Username milik klien (bukan PT) -> 404" 404 $(status "$R")
R=$(req POST /clients/me/pt $KD '{}');                         check "pt_username kosong -> 400" 400 $(status "$R")
R=$(req POST /clients/me/pt $PT1 '{"pt_username":"ptrina"}');  check "PT tidak boleh pakai endpoint ini -> 403" 403 $(status "$R")
register "Klien Eko" eko@t.com klien_eko klien
KE=$(login klien_eko)
R=$(req POST /clients/me/pt $KE '{"pt_username":"ptbudi"}');   check "Klien tanpa profil pilih PT -> 404" 404 $(status "$R")
R=$(req GET "/pt/clients?status=active" $PT1)
check "Dashboard Budi sekarang berisi Ani + Dewi" 2 "$(body "$R" | json "len(d)")"

echo; echo "== 10. Validasi auth & keamanan error =="
R=$(req POST /auth/logout $KA);                                       check "Logout" 200 $(status "$R")
R=$(req POST /auth/register "" '{"name":"X","email":"x@t.com","username":"xx","password":"abc","role":"klien"}');        check "Password < 6 karakter -> 400" 400 $(status "$R")
R=$(req POST /auth/register "" '{"name":"X","email":"bukan-email","username":"xx","password":"password123","role":"klien"}'); check "Email tidak valid -> 400" 400 $(status "$R")
R=$(req POST /auth/register "" '{"name":"X","email":"x@t.com","username":"klienani","password":"password123","role":"klien"}'); check "Username sudah dipakai -> 409" 409 $(status "$R")
R=$(req POST /auth/register "" '{"name":"X","email":"x@t.com","username":"xx","password":"password123","role":"admin"}');  check "Role 'admin' ditolak -> 400" 400 $(status "$R")
R=$(req POST /auth/login "" '{"username":"klienani","password":"salah"}'); check "Login password salah -> 401" 401 $(status "$R")
R=$(req POST /auth/login "" '{bukan json');                                check "Body JSON rusak -> 400" 400 $(status "$R")
LEAK=$(node -e "
const h=require('./src/middlewares/errorHandler');
const e=new Error(\"You have an error in your SQL syntax near 'secret_table'\");
let out; const res={status(c){out={code:c};return this},json(b){out.body=b}};
const log=console.error; console.error=()=>{}; h(e,{},res,()=>{}); console.error=log;
console.log(out.code+'|'+out.body.message)")
check "Error 500 tidak membocorkan detail SQL ke klien" "500|Terjadi kesalahan pada server." "$LEAK"

echo; echo "== 11. AI: endpoint internal (AI tiruan / mock) =="
envval() { grep -E "^$1=" .env 2>/dev/null | head -1 | cut -d= -f2-; }
IKEY=$(envval INTERNAL_API_KEY); PROV=$(envval AI_PROVIDER); PROV=${PROV:-mock}
if [ ${#IKEY} -lt 16 ] || [ "$PROV" != "mock" ]; then
  echo "  [SKIP] bagian ini butuh di .env: INTERNAL_API_KEY (min 16 karakter) dan AI_PROVIDER=mock."
  echo "         Saat ini AI_PROVIDER='$PROV', panjang INTERNAL_API_KEY=${#IKEY}. Ubah, restart server, jalankan ulang."
else
  ireq() { # ireq KEY BODY [JWT]
    local args=(-s -w "|%{http_code}" -X POST "$BASE/internal/ai/generate-weekly-plan" -H "Content-Type: application/json")
    [ -n "$1" ] && args+=(-H "x-internal-key: $1")
    [ -n "$3" ] && args+=(-H "Authorization: Bearer $3")
    curl "${args[@]}" -d "$2"
  }
  FAR=$(python3 -c "import datetime as d; t=d.date.today(); n=t+d.timedelta(days=7-t.weekday()); print(n+d.timedelta(weeks=10))")

  R=$(ireq "" '{"client_id":1}');                          check "Tanpa kunci internal -> 401" 401 $(status "$R")
  R=$(ireq "kunci-salah-sekali-pokoknya" '{"client_id":1}'); check "Kunci salah -> 401" 401 $(status "$R")
  R=$(ireq "" '{"client_id":1}' $PT1);                     check "JWT PT saja tidak cukup (butuh kunci internal) -> 401" 401 $(status "$R")
  R=$(ireq "" '{"client_id":1}' $KA);                      check "JWT klien tidak bisa memicu AI -> 401" 401 $(status "$R")
  R=$(ireq "$IKEY" '{}');                                  check "client_id kosong -> 400" 400 $(status "$R")
  R=$(ireq "$IKEY" '{"client_id":"1"}');                   check "client_id bukan angka -> 400" 400 $(status "$R")
  R=$(ireq "$IKEY" '{"client_id":1,"week_start_date":"2030-01-08"}'); check "week_start_date bukan Senin -> 400" 400 $(status "$R")
  R=$(ireq "$IKEY" '{"client_id":1,"week_start_date":"2020-01-06"}'); check "week_start_date di masa lalu -> 400" 400 $(status "$R")
  R=$(ireq "$IKEY" "{\"client_id\":1,\"week_start_date\":\"$FAR\"}"); check "week_start_date terlalu jauh -> 400" 400 $(status "$R")
  R=$(ireq "$IKEY" '{"client_id":999999}');                check "Klien tidak ada -> 404" 404 $(status "$R")

  R=$(ireq "$IKEY" '{"client_id":1}')
  check "Generate rencana untuk Ani -> 201" 201 $(status "$R")
  W=$(body "$R" | json "d['week_start_date']"); AID=$(body "$R" | json "d['analysis_id']")
  check "  status pending" pending "$(body "$R" | json "d['status']")"
  check "  provider mock" mock "$(body "$R" | json "d['provider']")"
  check "  minggu default = Senin berikutnya (setelah hari ini)" 1 "$(python3 -c "import datetime as d; x=d.date.fromisoformat('$W'); print(1 if x.weekday()==0 and x>d.date.today() else 0)")"
  check "  DB: 1 baris analisis, status pending" "1|pending" "$($DB "SELECT CONCAT(COUNT(*),'|',MIN(status)) FROM ai_analysis_results WHERE client_id=1 AND week_start_date='$W'")"
  check "  DB: ai_output.meta.provider = mock" mock "$($DB "SELECT JSON_UNQUOTE(JSON_EXTRACT(ai_output,'\$.meta.provider')) FROM ai_analysis_results WHERE analysis_id=$AID")"
  CAL=$($DB "SELECT JSON_UNQUOTE(JSON_EXTRACT(ai_output,'\$.targets.calories')) FROM ai_analysis_results WHERE analysis_id=$AID")
  check "  DB: target kalori >= batas aman 1200 (dapat $CAL)" 1 "$([ "$CAL" -ge 1200 ] && echo 1 || echo 0)"
  check "  DB: workout dan meals terisi" 1 "$($DB "SELECT (JSON_LENGTH(ai_output,'\$.workout')>0 AND JSON_LENGTH(ai_output,'\$.meals')>=21) FROM ai_analysis_results WHERE analysis_id=$AID")"
  check "  DB: audit log 'ai.generate_plan' tercatat" 1 "$($DB "SELECT COUNT(*) FROM audit_logs WHERE action='ai.generate_plan'")"
  check "  DB: PT Budi dapat notifikasi review" 1 "$($DB "SELECT COUNT(*) FROM notifications WHERE user_id=1 AND title='Rencana AI menunggu review'")"

  R=$(ireq "$IKEY" '{"client_id":1}')
  check "Generate ulang saat masih pending -> 200 (diperbarui)" 200 $(status "$R")
  check "  DB: tetap 1 baris (tidak menggandakan)" 1 "$($DB "SELECT COUNT(*) FROM ai_analysis_results WHERE client_id=1 AND week_start_date='$W'")"
  check "  DB: notifikasi tidak menggandakan" 1 "$($DB "SELECT COUNT(*) FROM notifications WHERE user_id=1 AND title='Rencana AI menunggu review'")"

  R=$(req GET /pt/clients/1/ai-analysis/current $PT1)
  check "PT melihat rencana AI terbaru di dashboard" 200 $(status "$R")
  check "  statusnya pending" pending "$(body "$R" | json "d['status']")"
  R=$(req PATCH /pt/ai-analysis/$AID/approve $PT1);        check "PT approve rencana" 200 $(status "$R")
  check "  DB: final_output terisi" 1 "$($DB "SELECT final_output IS NOT NULL FROM ai_analysis_results WHERE analysis_id=$AID")"
  R=$(ireq "$IKEY" '{"client_id":1}');                     check "Generate lagi setelah di-approve -> 409 (tidak menimpa keputusan PT)" 409 $(status "$R")
fi

echo; echo "== 12. Format data untuk Mobile & profil minimal =="
R=$(req GET /clients/me/profile $KA)
check "birth_date berupa tanggal polos (tidak bergeser zona waktu)" "2000-05-10" "$(body "$R" | json "d['birth_date']")"
check "height_cm dan weight_current berupa angka, bukan teks" "int-or-float" "$(body "$R" | json "'int-or-float' if all(isinstance(d[k],(int,float)) for k in ('height_cm','weight_current','weight_target')) else 'teks'")"
R=$(req GET /clients/me/workout-plans/current $KA)
check "week_start_date workout plan berupa tanggal polos" "2026-10-12" "$(body "$R" | json "d['week_start_date']")"
check "is_completed berupa boolean (true/false), bukan 1/0" bool "$(body "$R" | json "type(d['items'][0]['is_completed']).__name__")"
R=$(req GET /clients/me/daily-logs/today $KA)
check "water_liters berupa angka" "int-or-float" "$(body "$R" | json "'int-or-float' if isinstance(d['water_liters'],(int,float)) else 'teks'")"
R=$(req GET /users/me/notifications $KA)
check "is_read notifikasi berupa boolean" bool "$(body "$R" | json "type(d[0]['is_read']).__name__")"

register "Klien Fira" fira@t.com klien_fira klien
KF=$(login klien_fira)
R=$(req GET /clients/me/profile $KF);   check "Profil belum diisi -> 404 (sinyal untuk menampilkan form profil)" 404 $(status "$R")
R=$(req POST /clients/me/profile $KF '{"weight_current":60,"weight_target":55,"allergies":"kacang"}')
check "Profil MINIMAL (hanya berat, target, alergi) -> 201" 201 $(status "$R")
R=$(req GET /clients/me/profile $KF)
check "  field yang tidak diisi bernilai null (gender, birth_date, height_cm, activity_level)" "None|None|None|None" "$(body "$R" | json "'|'.join(str(d[k]) for k in ('gender','birth_date','height_cm','activity_level'))")"
R=$(req GET /clients/me/workout-plans/current $KF); check "Belum ada plan -> 404 (bukan array kosong)" 404 $(status "$R")

echo; echo "============================================"
echo " HASIL: $PASS lulus, $FAIL gagal"
echo "============================================"
[ $FAIL -eq 0 ]
