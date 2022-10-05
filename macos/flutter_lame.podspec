#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_lame.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_lame'
  s.version          = '1.0.0'
  s.summary          = 'Flutter native bindlings to LAME (MP3 encoder).'
  s.homepage         = 'https://github.com/BestOwl/flutter_lame'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'NightOwl' => 'midnightow1@outlook.com' }

  s.prepare_command = <<-CMD
    rsync -a --delete ../src/lame/ Classes
  CMD

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.source_files     = [
    'Classes/libmp3lame/*.c',
    'Classes/libmp3lame/vector/*.c',
    'Classes/mpglib/*.c'
  ]
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES',
    'HEADER_SEARCH_PATHS' => [
      '"${PODS_TARGET_SRCROOT}/Classes/include"',
      '"${PODS_TARGET_SRCROOT}/Classes/"',
      '"${PODS_TARGET_SRCROOT}/Classes/libmp3lame"',
      '"${PODS_TARGET_SRCROOT}/Classes/mpglib"'
    ],
    'GCC_PREPROCESSOR_DEFINITIONS' => [
      'HAVE_STDINT_H',
      'HAVE_MPGLIB',
      'DECODE_ON_THE_FLY',
      'USE_FAST_LOG',
      'TAKEHIRO_IEEE754_HACK',
      'STDC_HEADERS',
      'ieee754_float32_t=float'
    ]
  }
  s.swift_version = '5.0'
end
