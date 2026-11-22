import 'dart:io';

class ProcessingResult {
  const ProcessingResult(this.success, this.message);
  final bool success;
  final String message;
}

class DialogueRemovalService {
  /// Deliberately does not pretend to remove dialogue yet.
  ///
  /// The actual offline separation model and native ONNX/FFmpeg pipeline
  /// must be integrated before this method can process audio. This safe
  /// placeholder prevents the app from exporting an unchanged video while
  /// claiming that speech was removed.
  Future<ProcessingResult> process(File input) async {
    if (!await input.exists()) {
      return const ProcessingResult(false, 'The selected video could not be found.');
    }
    return const ProcessingResult(
      false,
      'The video is ready, but the offline AI speech-separation engine '
      'has not been integrated yet. No audio has been changed.',
    );
  }
}
