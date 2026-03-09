# Payroll Attendance

Project Mini Payroll & Time Attendance (Ruby on Rails + PostgreSQL)

## เทคโนโลยีที่ใช้

- Ruby on Rails 8
- PostgreSQL 16 (via Docker Compose)
- Tailwind CSS
- Minitest

## สิ่งที่ต้องมีในเครื่อง

- Ruby `3.4.8`
- Bundler
- Docker + Docker Compose

## วิธีติดตั้งและรัน

1. ติดตั้ง dependencies
```bash
bundle install
```

2. สร้างไฟล์ `.env`
```bash
cat > .env <<'EOF'
DB_HOST=127.0.0.1
DB_PORT=5432
DB_USER=payroll
DB_PASSWORD=payroll123
EOF
```

3. โหลด environment variables
```bash
set -a; source .env; set +a
```

4. เปิดใช้งาน PostgreSQL ด้วย Docker
```bash
docker compose up -d
```

5. สร้างและ migrate ฐานข้อมูล
```bash
bin/rails db:prepare
```

6. รันแอปพลิเคชัน
```bash
bin/dev
```

เข้าใช้งานได้ที่ [http://localhost:3000](http://localhost:3000)

## วิธีรันเทสต์

1. ให้แน่ใจว่า PostgreSQL กำลังทำงาน
```bash
docker compose up -d db
```

2. โหลด environment variables
```bash
set -a; source .env; set +a
```

3. เตรียมฐานข้อมูล test
```bash
RAILS_ENV=test bin/rails db:prepare
```

4. รันเทสต์
```bash
bin/rails test
```


## ขอบเขตที่ทำเพิ่มจาก requirement

- เลือกเดือนเพื่อดู payroll รายเดือนบนหน้า Employee Show
- แก้ไข/ลบ Attendance ได้จากหน้า Employee Show
- เพิ่ม validation และ test coverage สำหรับกฎ attendance และการคำนวณ payroll

### รายละเอียด validation และ test coverage ที่เพิ่ม

1. Validation ฝั่ง Attendance
- บังคับมี `work_date`, `check_in_at`, `check_out_at`
- ห้ามมี attendance ซ้ำวันเดิมใน employee เดียวกัน
- บังคับ `check_out_at` ต้องหลัง `check_in_at`
- บังคับ `work_date` ต้องตรงกับวันของ `check_in_at`
- ถ้าไม่ส่ง `work_date` จะเติมจาก `check_in_at` อัตโนมัติ

2. Validation ฝั่ง Employee
- บังคับมี `name`, `position`
- `base_salary` ต้องมากกว่า 0

3. Test Coverage ที่เพิ่ม
- Attendance model: เคสเวลาออกก่อนเข้า, ซ้ำวัน, OT > 8 ชม./<= 8 ชม., วันไม่ตรง check-in, auto-set `work_date`
- Employee/payroll: เคสคำนวณ OT pay, gross/net, ภาษีแบบขั้นบันได, boundary 30k/50k, OT ดันข้าม bracket, filter ตามเดือน
- Integration ฝั่ง Attendance controller: create/update/destroy + เคส invalid (ซ้ำวัน, เวลาไม่ถูกต้อง)

## การใช้ AI

- Claude
  - ศึกษาการติดตั้งและใช้งานของ Ruby on Rails
- OpenAI ChatGPT (Codex agent)
  - วางแผนงาน, ช่วยเขียน/ปรับโค้ด, และช่วยออกแบบ test scenario
- Antigravity: Gemini
  - ปรับปรุง UI
- Nano Banana 2 
  - ทำ logo app
- Stitch
  - ออกแบบ prototype