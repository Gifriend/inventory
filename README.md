# Inventory App

Flutter app for inventory and loan workflow.

## Environment

Create `.env` in project root:

```env
BASE_URL=https://your-backend-domain
```

The app will normalize `BASE_URL` and automatically use `/api` prefix when needed.

## Android Release Build

### Why release APK can be large

For this project, biggest contributors are native libraries:

- Flutter engine (`libflutter.so`) for multiple ABIs.
- App native snapshot (`libapp.so`) for multiple ABIs.
- `mobile_scanner` ML Kit barcode native libs (`libbarhopper_v3.so`).

If you build universal APK (`flutter build apk --release`), all ABI binaries are bundled into one file, so size is much larger.

### Build stability on low-RAM machine

If Gradle daemon crashes with out-of-memory on Windows laptop, use smaller Gradle memory config (already set in `android/gradle.properties`):

- `org.gradle.jvmargs=-Xmx2G ...`
- `org.gradle.workers.max=2`
- `org.gradle.parallel=false`

If needed, stop stale daemon before build:

- `cd android`
- `./gradlew --stop`

### Recommended commands

- Smaller APK per architecture:
	- `flutter build apk --release --split-per-abi`
- Single architecture APK (smallest for modern phones):
	- `flutter build apk --release --target-platform android-arm64`
- Recommended for Play Store:
	- `flutter build appbundle --release`

### Derry scripts

You can also use:

- `derry release-apk` (default kecil, split per ABI)
- `derry release-apk-split`
- `derry release-apk-arm64`
- `derry release-apk-universal` (lebih besar, semua ABI jadi satu APK)
- `derry release-aab`
