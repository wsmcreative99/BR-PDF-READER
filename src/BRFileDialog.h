#pragma once
#include <functional>
#include <string>

#ifdef __APPLE__
// Shows the macOS "open file" panel for PDFs on the main thread (asynchronously,
// so the host's render thread is never blocked). The callback receives the chosen
// UTF-8 path, or is not called at all if the user cancels.
void BRChoosePdfAsync(std::function<void(const std::string&)> onChosen);
#endif
