cmake_minimum_required(VERSION 3.20)

if(APPLE)
  project(BR_PDF_READER VERSION 1.4.4 LANGUAGES CXX OBJCXX)
else()
  project(BR_PDF_READER VERSION 1.4.4 LANGUAGES CXX)
endif()

if(NOT WIN32 AND NOT APPLE)
  message(FATAL_ERROR "BR PDF READER targets Windows 10/11 x64 and macOS (Apple Silicon + Intel).")
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/external/ffgl/CMakeLists.txt")
  message(FATAL_ERROR "Missing external/ffgl/CMakeLists.txt. GitHub Actions should clone Resolume FFGL before Configure.")
endif()

set(FFGL_BUILD_EXAMPLE_PLUGINS OFF CACHE BOOL "" FORCE)
add_subdirectory(external/ffgl ffgl-build EXCLUDE_FROM_ALL)

set(BR_COMMON_SOURCES
  src/BRPdfReader.cpp
  src/BRPdfReader.h
  src/BRThumbnail.h
  src/BRFileDialog.h
  src/PdfRenderer.h
)

if(WIN32)
  find_package(GLEW REQUIRED)

  add_library(BR_PDF_READER MODULE ${BR_COMMON_SOURCES} src/PdfRenderer.cpp)

  target_compile_definitions(BR_PDF_READER PRIVATE
    WIN32_LEAN_AND_MEAN
    NOMINMAX
    _WIN32_WINNT=0x0A00
    WINVER=0x0A00
    GLEW_STATIC
    BR_PDF_READER_VERSION="1.4.4"
  )

  target_link_libraries(BR_PDF_READER PRIVATE
    ffgl::sdk
    GLEW::GLEW
    windowsapp
    runtimeobject
    ole32
    shell32
    windowscodecs
    opengl32
  )

  if(MSVC)
    target_compile_options(BR_PDF_READER PRIVATE /W4 /EHsc /permissive-)
  endif()

  set_target_properties(BR_PDF_READER PROPERTIES
    PREFIX ""
    OUTPUT_NAME "BR_PDF_READER_FFGL"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
  )
endif()

if(APPLE)
  set(BR_MAC_SOURCES
    src/PdfRendererMac.mm
    src/BRFileDialogMac.mm
  )
  set_source_files_properties(${BR_MAC_SOURCES} PROPERTIES COMPILE_FLAGS "-fobjc-arc")

  add_library(BR_PDF_READER MODULE ${BR_COMMON_SOURCES} ${BR_MAC_SOURCES})

  target_compile_definitions(BR_PDF_READER PRIVATE
    GL_SILENCE_DEPRECATION
    BR_PDF_READER_VERSION="1.4.4"
  )

  target_link_libraries(BR_PDF_READER PRIVATE
    ffgl::sdk
    "-framework Cocoa"
    "-framework Foundation"
    "-framework CoreGraphics"
    "-framework OpenGL"
  )

  # Resolume loads FFGL plugins on macOS as .bundle packages.
  set_target_properties(BR_PDF_READER PROPERTIES
    BUNDLE TRUE
    BUNDLE_EXTENSION "bundle"
    PREFIX ""
    OUTPUT_NAME "BR_PDF_READER_FFGL"
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.belajarresolume.brpdfreader"
    MACOSX_BUNDLE_BUNDLE_NAME "BR PDF Reader"
    MACOSX_BUNDLE_BUNDLE_VERSION "1.4.4"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "1.4.4"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
  )
endif()
