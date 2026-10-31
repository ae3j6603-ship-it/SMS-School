# School OS — โรงเรียนสามัคคีศรีวิชัย

เว็บภาษาไทย โทนเขียว–เหลือง ใช้ Supabase Auth + PostgreSQL + Row Level Security และเผยแพร่เป็น static web ได้ โดยไม่ต้องมี service_role key ในเบราว์เซอร์

## สิ่งที่ใช้งานได้

- 49 หมวดข้อมูลตามระบบเดิม: ทะเบียนนักเรียน / ครู / ห้องเรียน, วิชาการ, แบบประเมิน, บุคลากร, งบประมาณ, พัสดุ, สารบรรณ, ห้องสมุด
- เพิ่ม แก้ไข ค้นหา กรอง แบ่งหน้า พิมพ์ นำเข้า / ส่งออก CSV
- เช็กชื่อรายห้องรายวันและสรุปมา สาย ลา ขาด
- บันทึกคะแนน 0–100 และคำนวณเกรด 0–4
- โครงการ: ร่าง → เสนอ ผอ. → อนุมัติ → เสร็จสิ้น
- ขอเบิก: ยื่นแล้ว → เสนอ ผอ. → อนุมัติ / ปฏิเสธ → จ่ายแล้ว
- ตัดงบจริง เงินออม รับจ่ายวัสดุ FIFO และยืมคืนหนังสือ / ครุภัณฑ์ผ่าน PostgreSQL functions พร้อม row locks
- ผู้ใช้ใหม่ไม่มีสิทธิ์ข้อมูลจนผู้ดูแลกำหนดบทบาท; ประวัติการเปลี่ยนข้อมูลที่ฐานข้อมูล
- ข้อมูลสาธิตอยู่ในหน่วยความจำแยกจากข้อมูลจริง

## ติดตั้งฐานข้อมูล

1. ใช้โปรเจกต์ Supabase ที่เลือกสำหรับโรงเรียน ตรวจสอบตารางเดิมก่อนติดตั้ง
2. รัน `supabase/migrations/202610310001_school.sql` ใน SQL Editor ครั้งเดียว (หรือใช้ migration workflow)
3. ใส่ Project URL และ Publishable key ใน `dist/config.js` คีย์นี้ออกแบบให้เผยแพร่ได้ ห้ามใส่ secret / service_role
4. สร้างผู้ใช้ผ่าน Authentication > Users หรือผ่านหน้าขอเปิดบัญชีและยืนยันอีเมล
5. เจ้าของฐานข้อมูลกำหนดผู้ดูแลคนแรกด้วยคำสั่งที่ระบุอีเมลจริง:

```sql
update public.school_profiles
set role='admin', display_name='ผู้ดูแลระบบโรงเรียน'
where id=(select id from auth.users where email='YOUR_VERIFIED_ADMIN_EMAIL');
```

ไม่ควรตั้ง admin อัตโนมัติให้บัญชีแรกที่สมัครผ่านเว็บสาธารณะ ผู้ดูแลที่มีสิทธิ์แล้วกำหนดบทบาทคนอื่นในหน้า “ผู้ใช้และสิทธิ์” ได้

## ใช้งานและเผยแพร่

`dist/` คือเว็บที่พร้อมเผยแพร่ เปิดผ่าน HTTP server หรือ host static directory นี้ ใช้ `npm test` และ `npm run check` ตรวจโค้ด ไม่ต้องติดตั้ง dependency สำหรับหน้าเว็บ

มี `.github/workflows/pages.yml` สำหรับ GitHub Pages โดยผู้ดูแล repository เปิด Settings > Pages > Source: GitHub Actions ก่อน การเผยแพร่ผ่าน Sites ใช้ `.openai/hosting.json` และ source helper ตามระบบ Sites

การแก้ source บน GitHub ไม่ส่งมาที่ Sites โดยอัตโนมัติ GitHub Pages workflow เป็นเส้นทางเผยแพร่แยกจาก Sites

## โครงสร้าง

- `dist/index.html`, `styles.css` — โครงหน้าและธีม
- `dist/app.js` — เมนู แบบฟอร์มและขั้นตอนทำงาน
- `dist/data.js` — Supabase REST/Auth, refresh token, optimistic concurrency, demo adapter
- `dist/core.js` — validation, CSV, เกรด, HTML escaping
- `dist/modules.js` — ฟิลด์ 49 หมวดจาก schema เดิม
- `supabase/migrations/` — ตาราง policies triggers และ transaction functions
- `tests/` — ทดสอบ logic ที่กระทบข้อมูล

## สิทธิ์

admin / director ดูภาพรวม; teacher จำกัดข้อมูลนักเรียนตามห้องประจำชั้น; academic_head จัดการวิชาการ; plan_head จัดการโครงการและเสนอคำขอ; finance บันทึกการจ่าย; admin_sec ดูแลงานธุรการและพัสดุ สิทธิ์ทั้งหมดตรวจจาก school_profiles ในฐานข้อมูล ไม่รับ role จาก browser

ข้อมูล health / แบบประเมินมีสิทธิ์เช่นเดียวกับข้อมูลนักเรียน ไม่มี public endpoint เปิดเผยข้อมูลส่วนบุคคล

## ขอบเขตที่ยังไม่เทียบเท่าระบบเดิม

SDQ, LD, EQ, Fitness, SAR, จัดซื้อ และ PLC มีแบบฟอร์มบันทึกและรายงานตาราง แต่ยังไม่มี scoring engine หรือวงจรอนุมัติเฉพาะทุกแบบ รายงานผลการเรียนยังไม่ใช่แบบ ปพ.5 / ปพ.6 ราชการฉบับตรวจรับ ไม่มี student portal, auto timetable, promotion wizard, การอัปโหลดไฟล์ (เก็บ URL ได้), นำเข้า XLSX หรือรายงาน PDF แม่แบบเฉพาะ ผู้ดูแลต้องตรวจชุดเกณฑ์ แบบฟอร์ม และการใช้งานกับสถานการณ์จริงของโรงเรียนก่อนรับรองส่วนเหล่านี้

เปิดใช้ backup ตามแผน Supabase ที่โรงเรียนเลือก โค้ดนี้ไม่เพิ่ม subscription, SMTP, domain หรือบริการแบบมีค่าใช้จ่ายอัตโนมัติ
