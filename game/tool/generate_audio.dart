import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

void main() async {
  final directory = Directory('assets/audio');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final files = {
    'ui_click.wav': 440.0, // A4
    'build.wav': 523.25, // C5
    'error.wav': 150.0, // Low buzz
    'wave_start.wav': 880.0, // A5
    'game_over.wav': 100.0, // Deep
    'hit.wav': 200.0, // Thud
    'shoot.wav': 600.0, // Pew
  };

  for (final entry in files.entries) {
    final file = File('assets/audio/${entry.key}');
    print('Generating ${file.path}...');
    final bytes = _generateWav(entry.value, 0.2); // 0.2 seconds
    await file.writeAsBytes(bytes);
  }
  print('Audio generation complete.');
}

Uint8List _generateWav(double frequency, double duration) {
  const sampleRate = 44100;
  const numChannels = 1;
  const bitsPerSample = 16;
  final numSamples = (duration * sampleRate).toInt();
  final byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
  final blockAlign = numChannels * bitsPerSample ~/ 8;
  final dataSize = numSamples * numChannels * bitsPerSample ~/ 8;
  final fileSize = 36 + dataSize;

  final buffer = BytesBuilder();

  // RIFF header
  buffer.add(_stringToBytes('RIFF'));
  buffer.add(_int32ToBytes(fileSize));
  buffer.add(_stringToBytes('WAVE'));

  // fmt chunk
  buffer.add(_stringToBytes('fmt '));
  buffer.add(_int32ToBytes(16)); // Chunk size
  buffer.add(_int16ToBytes(1)); // Audio format (PCM)
  buffer.add(_int16ToBytes(numChannels));
  buffer.add(_int32ToBytes(sampleRate));
  buffer.add(_int32ToBytes(byteRate));
  buffer.add(_int16ToBytes(blockAlign));
  buffer.add(_int16ToBytes(bitsPerSample));

  // data chunk
  buffer.add(_stringToBytes('data'));
  buffer.add(_int32ToBytes(dataSize));

  // Samples
  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final sample = (sin(2 * pi * frequency * t) * 32767).toInt();
    buffer.add(_int16ToBytes(sample));
  }

  return buffer.toBytes();
}

List<int> _stringToBytes(String s) => s.codeUnits;

List<int> _int32ToBytes(int value) {
  final list = Uint8List(4);
  final view = ByteData.view(list.buffer);
  view.setInt32(0, value, Endian.little);
  return list;
}

List<int> _int16ToBytes(int value) {
  final list = Uint8List(2);
  final view = ByteData.view(list.buffer);
  view.setInt16(0, value, Endian.little);
  return list;
}
