# BR PDF Reader V1.4.4 — Classic Transform + Thumbnail

V1.4.4 keeps the embedded FFGL thumbnail from V1.4.3, but restores the Transform behavior to the earlier stable version.

## Transform restored
- Zoom: 25%–400%
- Position X: -1.00 to +1.00
- Position Y: -1.00 to +1.00
- Same classic transform behavior as before the Dynamic Pan experiment

## Thumbnail retained
The BR PDF Reader artwork remains embedded directly inside the DLL as a 160x120 FFGL thumbnail.

No external PNG file is required after build.

## Other features retained
- BR PDF Reader
- static `by Belajar Resolume` branding
- Previous / Next
- NORMAL / FADE / SLIDE UP / DOWN / LEFT / RIGHT
- manual FAST / SLOW
- Auto Slide 1–60 sec
- Stop / Loop
- independent Auto Slide transition + speed
- FIT / FILL / STRETCH

## Build
Replace repository contents with this package and run the existing GitHub Action.

Output:
`BR_PDF_READER_FFGL.dll`

---

# macOS build (Apple Silicon + Intel)

The macOS port renders PDFs with Apple's CoreGraphics and uses a native file panel
for **Choose PDF**. All features and parameters are the same as on Windows.

## Build
Run the **Build BR PDF READER (macOS)** GitHub Action (Actions tab → Run workflow).
Output artifact: `BR-PDF-READER-macOS-universal` → `BR_PDF_READER_FFGL.bundle`.

## Install
1. Unzip, then copy `BR_PDF_READER_FFGL.bundle` to
   `~/Documents/Resolume Arena/Extra Effects`
2. The bundle is signed ad-hoc, not notarised, so macOS quarantines downloaded copies.
   Remove the flag in Terminal:
   `xattr -dr com.apple.quarantine ~/Documents/Resolume\ Arena/Extra\ Effects/BR_PDF_READER_FFGL.bundle`
3. Restart Resolume. **BR PDF Reader** appears under Sources.

Requires macOS 11+ and Resolume 7.11+ for Apple Silicon (universal bundle).

## Download
Download: [Plugin Resolume PDF Reader macOS v1.0](https://github.com/wsmcreative99/BR-PDF-READER/releases/download/macOS/BR-PDF-READER-mac-port.zip)
