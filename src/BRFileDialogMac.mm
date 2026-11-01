#ifdef __APPLE__

#include "BRFileDialog.h"

#import <Cocoa/Cocoa.h>

void BRChoosePdfAsync(std::function<void(const std::string&)> onChosen) {
  dispatch_async(dispatch_get_main_queue(), ^{
    @autoreleasepool {
      NSOpenPanel* panel = [NSOpenPanel openPanel];
      panel.title = @"BR PDF Reader - Choose PDF";
      panel.canChooseFiles = YES;
      panel.canChooseDirectories = NO;
      panel.allowsMultipleSelection = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
      panel.allowedFileTypes = @[ @"pdf" ];
#pragma clang diagnostic pop

      if ([panel runModal] == NSModalResponseOK && panel.URL != nil) {
        const char* p = panel.URL.path.UTF8String;
        if (p) onChosen(std::string(p));
      }
    }
  });
}

#endif  // __APPLE__
