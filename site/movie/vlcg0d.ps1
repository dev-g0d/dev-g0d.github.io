# กำหนดเนื้อหา .reg
$regContent = @"
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\vlcg0d]
@="URL:VLCg0d Protocol"
"URL Protocol"=""

[HKEY_CLASSES_ROOT\vlcg0d\DefaultIcon]
@="C:\\Program Files\\VideoLAN\\VLC\\vlc.exe,1"

[HKEY_CLASSES_ROOT\vlcg0d\shell]

[HKEY_CLASSES_ROOT\vlcg0d\shell\open]

[HKEY_CLASSES_ROOT\vlcg0d\shell\open\command]
@="\"C:\\Program Files\\VideoLAN\\VLC\\v.g0d.bat\" \"%1\""
"@

# สร้างไฟล์ .reg ในโฟลเดอร์ชั่วคราว
$regPath = "$env:TEMP\vlcg0d.reg"
$regContent | Set-Content -Encoding UTF8 -Path $regPath

# กำหนดเนื้อหา .bat
$batContent = @"
@echo off
REM รับ argument แรก
set url=%1
REM ลบ 'vlcg0d:' ออก (แปลง vlcg0d:https://.... เป็น https://....)
set url=%url:vlcg0d:=%
REM เปิด VLC พร้อมลิงก์
start "" "C:\Program Files\VideoLAN\VLC\vlc.exe" "%url%"
"@

# กำหนด path ไฟล์ .bat
$batPath = "C:\Program Files\VideoLAN\VLC\v.g0d.bat"

# Copy .bat ไปยังโฟลเดอร์ VLC (ต้องรัน PowerShell เป็น Administrator)
$batContent | Set-Content -Encoding ASCII -Path $batPath

# รันไฟล์ .reg เพื่อเพิ่ม protocol (ต้องรัน PowerShell เป็น Administrator)
Start-Process regedit.exe -ArgumentList "/s `"$regPath`"" -Wait

Write-Host "สร้างไฟล์ v.g0d.bat และเพิ่ม protocol สำเร็จแล้ว!"
Write-Host "ทดสอบโดยพิมพ์ vlcg0d:https://... ใน Run หรือ Browser"
