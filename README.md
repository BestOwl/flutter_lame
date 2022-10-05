# flutter_lame

Flutter native bindings to LAME (MP3 encoder), bundled with LAME source code.

Unlike [dart_lame](https://github.com/BestOwl/dart_lame), your don't need to provide
prebuilt libraries by yourself. The bundled LAME source code will be built as part of
the Flutter Runner build.

## Usage

```dart
final File f = File("output.mp3");
final IOSink sink = f.openWrite();
final LameMp3Encoder encoder = LameMp3Encoder(sampleRate: 44100, numChannels: 2);


Float64List leftChannelSamples;
Float64List rightChannelSamples;
// Get samples from file or from microphone.

final mp3Frame = await encoder.encode(
  leftChannel: leftChannelSamples,
  rightChannel: rightChannelSamples);
sink.add(mp3Frame);
// continue until all samples have been encoded

// finally, flush encoder buffer
final lastMp3Frame = await encoder.flush();
sink.add(lastMp3Frame);
```

For a complete example, please go to `/example` folder.