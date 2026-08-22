# SALDOKU - Versi Godot 4

Port game SALDOKU dari Unity ke **Godot 4 (GDScript)**. Dibuat agar bisa
dikerjakan penuh lewat GitHub + build APK otomatis **tanpa PC**.

## Cara ambil APK (dari Android, tanpa PC)

1. Setiap kali ada perubahan di-push ke branch `main`, GitHub akan otomatis
   membuat APK.
2. Buka repo ini di browser HP > tab **Actions**.
3. Pilih run paling atas (yang ada tanda centang hijau).
4. Scroll ke bawah ke bagian **Artifacts** > unduh **SALDOKU-Android-APK**.
5. Ekstrak ZIP-nya, lalu pasang file `.apk` (izinkan "install dari sumber tak dikenal").

> Catatan: APK ini **debug build** (untuk uji coba). Untuk rilis Play Store
> nanti kita siapkan release build + keystore sendiri.

## Struktur

- `project.godot` - konfigurasi project (portrait, mobile renderer)
- `scenes/Main.tscn` - scene utama (saat ini: demo gerak)
- `scripts/` - kode GDScript
- `export_presets.cfg` - preset export Android
- `.github/workflows/android.yml` - auto-build APK

## Status porting

- [x] Pondasi project + auto-build APK
- [x] Player gerak (uji sentuh)
- [ ] Tembak otomatis + peluru
- [ ] Musuh + spawn
- [ ] Skill & senjata (orbit, aura, roket)
- [ ] Item (magnet, bom, peti)
- [ ] Menu, skor, level, pause
- [ ] Pilih karakter
