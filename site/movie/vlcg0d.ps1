# ====== Self-Elevate to Administrator ======
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "กำลังขอสิทธิ์ Administrator..."
    $myInvocation = $MyInvocation.MyCommand.Definition
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$myInvocation`"" -Verb RunAs
    exit
}

# ====== Check VLC Path ======
$vlcExePath = "C:\Program Files\VideoLAN\VLC\vlc.exe"
$batPath = "C:\Program Files\VideoLAN\VLC\v.g0d.bat"
If (-not (Test-Path $vlcExePath)) {
    Write-Host "ไม่พบ VLC ที่ $vlcExePath"
    Write-Host "โปรดติดตั้ง VLC ก่อน!"
    exit 1
}

# ====== Write .bat File ======
$batContent = @"
@echo off
REM รับ argument แรก
set url=%1
REM ลบ 'vlcg0d:' ออก (แปลง vlcg0d:https://.... เป็น https://....)
set url=%url:vlcg0d:=%
REM เปิด VLC พร้อมลิงก์
start "" "C:\Program Files\VideoLAN\VLC\vlc.exe" "%url%"
"@

Try {
    $batContent | Set-Content -Encoding ASCII -Path $batPath -Force
    Write-Host "สร้างไฟล์ v.g0d.bat สำเร็จ"
} Catch {
    Write-Host "เกิดข้อผิดพลาดในการสร้างไฟล์ v.g0d.bat: $_" -ForegroundColor Red
    exit 1
}

# ====== Write .reg File ======
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
$regPath = "$env:TEMP\vlcg0d.reg"

Try {
    $regContent | Set-Content -Encoding UTF8 -Path $regPath
    Write-Host "สร้างไฟล์ vlcg0d.reg สำเร็จ"
} Catch {
    Write-Host "เกิดข้อผิดพลาดในการสร้างไฟล์ .reg: $_" -ForegroundColor Red
    exit 1
}

# ====== Import .reg File ======
Try {
    Start-Process regedit.exe -ArgumentList "/s `"$regPath`"" -Wait -ErrorAction Stop
    Write-Host "เพิ่ม registry สำเร็จ"
} Catch {
    Write-Host "เกิดข้อผิดพลาดในการเพิ่ม registry: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n--- ดำเนินการเสร็จสิ้น ---" -ForegroundColor Green
Write-Host "ทดสอบโดยพิมพ์ vlcg0d:https://... ใน Run หรือ Browser"
