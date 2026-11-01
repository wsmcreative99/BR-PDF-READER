// macOS PDF renderer for BR PDF Reader, built on CoreGraphics (CGPDFDocument).
#ifdef __APPLE__

#include "PdfRenderer.h"

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#include <algorithm>

struct PdfRenderer::Impl {
  CGPDFDocumentRef document = nullptr;
};

PdfRenderer::PdfRenderer() : impl_(new Impl) {}

PdfRenderer::~PdfRenderer() {
  Close();
  delete impl_;
}

bool PdfRenderer::Open(const std::string& utf8Path) {
  Close();
  if (utf8Path.empty()) return false;

  @autoreleasepool {
    NSString* nsPath = [NSString stringWithUTF8String:utf8Path.c_str()];
    if (!nsPath) return false;

    NSURL* url = [NSURL fileURLWithPath:nsPath];
    CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    if (!doc) return false;

    // Some PDFs are password-protected; an empty password unlocks "view only" files.
    if (CGPDFDocumentIsEncrypted(doc) && !CGPDFDocumentIsUnlocked(doc)) {
      CGPDFDocumentUnlockWithPassword(doc, "");
      if (!CGPDFDocumentIsUnlocked(doc)) {
        CGPDFDocumentRelease(doc);
        return false;
      }
    }

    const size_t count = CGPDFDocumentGetNumberOfPages(doc);
    if (count == 0) {
      CGPDFDocumentRelease(doc);
      return false;
    }

    impl_->document = doc;
    path_ = utf8Path;
    pageCount_ = static_cast<unsigned>(count);
    return true;
  }
}

void PdfRenderer::Close() {
  if (impl_ && impl_->document) {
    CGPDFDocumentRelease(impl_->document);
    impl_->document = nullptr;
  }
  path_.clear();
  pageCount_ = 0;
}

bool PdfRenderer::IsOpen() const {
  return impl_ && impl_->document && pageCount_ > 0;
}

unsigned PdfRenderer::PageCount() const {
  return pageCount_;
}

const std::string& PdfRenderer::Path() const {
  return path_;
}

bool PdfRenderer::RenderPage(unsigned pageIndex,
                             unsigned targetHeight,
                             std::vector<std::uint8_t>& bgra,
                             int& width,
                             int& height) {
  if (!IsOpen() || pageIndex >= pageCount_) return false;

  // CGPDF pages are 1-based.
  CGPDFPageRef page = CGPDFDocumentGetPage(impl_->document, pageIndex + 1);
  if (!page) return false;

  const CGRect box = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
  const int rotation = CGPDFPageGetRotationAngle(page);
  const bool swapped = (rotation % 180) != 0;

  const double nativeW = swapped ? box.size.height : box.size.width;
  const double nativeH = swapped ? box.size.width : box.size.height;
  if (nativeW <= 0.0 || nativeH <= 0.0) return false;

  const unsigned outH = std::max(64u, targetHeight);
  const unsigned outW = std::max(
    64u, static_cast<unsigned>(nativeW * (static_cast<double>(outH) / nativeH)));

  const size_t stride = static_cast<size_t>(outW) * 4;
  bgra.assign(stride * outH, 0);

  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
  // BGRA, premultiplied alpha: matches the GL_BGRA upload used on Windows.
  CGContextRef ctx = CGBitmapContextCreate(
    bgra.data(), outW, outH, 8, stride, space,
    kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
  CGColorSpaceRelease(space);
  if (!ctx) return false;

  const CGRect dest = CGRectMake(0, 0, outW, outH);

  // PDF pages are transparent by default; paint white like a normal viewer.
  CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
  CGContextFillRect(ctx, dest);

  CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
  CGContextSetShouldAntialias(ctx, true);

  const CGAffineTransform t =
    CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, dest, 0, true);
  CGContextConcatCTM(ctx, t);
  CGContextClipToRect(ctx, box);
  CGContextDrawPDFPage(ctx, page);

  CGContextRelease(ctx);

  width = static_cast<int>(outW);
  height = static_cast<int>(outH);
  return true;
}

#endif  // __APPLE__
