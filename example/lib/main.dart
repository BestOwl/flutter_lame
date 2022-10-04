import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_lame/flutter_lame.dart';
import 'package:wav/wav.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? inputPath;
  String outputName = "output.mp3";
  bool working = false;

  void selectInputFile() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        dialogTitle: "Select WAV file",
        allowedExtensions: ["wav"],
        allowMultiple: false);

    if (result == null) {
      return;
    }

    if (result.paths.isEmpty) {
      return;
    }

    setState(() {
      inputPath = result.paths[0];
    });
  }

  void encodeMp3() async {
    if (inputPath == null) {
      throw StateError("inputPath should not be null");
    }

    final outputDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: "Pick a directory to save output MP3 file");
    if (outputDir == null) {
      return;
    }

    setState(() {
      working = true;
    });

    LameMp3Encoder? encoder;
    IOSink? sink;
    try {
      final wav = await compute(Wav.readFile, inputPath!);

      final File f = File(path.join(outputDir, outputName));
      sink = f.openWrite();
      encoder = LameMp3Encoder(
          sampleRate: wav.samplesPerSecond, numChannels: wav.channels.length);

      final left = wav.channels[0];
      Float64List? right;
      if (wav.channels.length > 1) {
        right = wav.channels[1];
      }

      for (int i = 0; i < left.length; i += wav.samplesPerSecond) {
        final mp3Frame = await encoder.encodeDouble(
            leftChannel: left.sublist(i, i + wav.samplesPerSecond),
            rightChannel: right?.sublist(i, i + wav.samplesPerSecond));
        sink.add(mp3Frame);
      }
      sink.add(await encoder.flush());
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Error"),
                content: Text(e.toString()),
              ));
    } finally {
      encoder?.close();
      sink?.close();
      setState(() {
        working = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    const spacerLarge = SizedBox(height: 30);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter LAME Example'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'Call LAME API through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                const Divider(),
                spacerLarge,
                ElevatedButton(
                    onPressed: !working ? selectInputFile : null,
                    child: const Text(
                      "Select WAV file",
                      style: textStyle,
                    )),
                spacerSmall,
                RichText(
                  text: TextSpan(
                      style: const TextStyle(fontSize: 25, color: Colors.black),
                      children: [
                        const TextSpan(
                            text: "Input WAV file: ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: inputPath)
                      ]),
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                TextFormField(
                    onChanged: (v) => setState(() {
                          outputName = v;
                        }),
                    decoration:
                        const InputDecoration(labelText: "Output MP3 filename"),
                    initialValue: outputName),
                spacerSmall,
                ElevatedButton(
                    onPressed:
                        inputPath != null && outputName.isNotEmpty && !working
                            ? encodeMp3
                            : null,
                    child: const Text(
                      "Encode to MP3",
                      style: textStyle,
                    )),
                spacerSmall,
                if (working) const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
