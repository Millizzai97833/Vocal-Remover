import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/dialogue_removal_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _video;
  VideoPlayerController? _player;
  bool _busy = false;
  String _message = 'Select a video up to 30 minutes long.';

  Future<void> _selectVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final player = VideoPlayerController.file(file);
    try {
      await player.initialize();
      final duration = player.value.duration;
      if (duration > const Duration(minutes: 30)) {
        await player.dispose();
        if (!mounted) return;
        setState(() => _message = 'This app currently accepts videos up to 30 minutes.');
        return;
      }
      await _player?.dispose();
      if (!mounted) {
        await player.dispose();
        return;
      }
      setState(() {
        _video = file;
        _player = player;
        _message = 'Video selected. Ready for the offline AI engine.';
      });
    } catch (e) {
      await player.dispose();
      if (!mounted) return;
      setState(() => _message = 'Unable to preview this video: $e');
    }
  }

  Future<void> _removeDialogue() async {
    final file = _video;
    if (file == null) {
      setState(() => _message = 'Select a video first.');
      return;
    }
    setState(() {
      _busy = true;
      _message = 'Checking offline processing engine...';
    });
    final result = await DialogueRemovalService().process(file);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = result.message;
    });
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = _player;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocal Remover', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(Icons.graphic_eq_rounded, color: Color(0xFFB69AFF)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF30234F), Color(0xFF171724)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0xFF514078)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.record_voice_over_rounded, size: 36, color: Color(0xFFC6AEFF)),
                  SizedBox(height: 18),
                  Text('Remove dialogue.\nKeep the scene alive.',
                    style: TextStyle(fontSize: 27, height: 1.15, fontWeight: FontWeight.w800)),
                  SizedBox(height: 10),
                  Text(
                    'Offline-first video dialogue removal. Preserve music, ambience '
                    'and sound effects as much as the AI model allows.',
                    style: TextStyle(color: Color(0xFFC6C2D2), height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select video', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    if (player != null && player.value.isInitialized)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AspectRatio(
                          aspectRatio: player.value.aspectRatio,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(player),
                              IconButton.filled(
                                onPressed: () => setState(() {
                                  player.value.isPlaying ? player.pause() : player.play();
                                }),
                                icon: Icon(player.value.isPlaying ? Icons.pause : Icons.play_arrow),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10101A),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_library_outlined, size: 42, color: Color(0xFF9B8BB8)),
                            SizedBox(height: 8),
                            Text('No video selected', style: TextStyle(color: Colors.white60)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _busy ? null : _selectVideo,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Choose from phone gallery'),
                      ),
                    ),
                    if (_video != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _video!.uri.pathSegments.isNotEmpty ? _video!.uri.pathSegments.last : 'Selected video',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (player != null && player.value.isInitialized)
                        Text('Duration: ${_formatDuration(player.value.duration)}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy || _video == null ? null : _removeDialogue,
              icon: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
              label: Text(_busy ? 'Preparing...' : 'Remove human dialogue'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFB69AFF)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_message, style: const TextStyle(height: 1.4))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: speech can overlap music and effects. Complete removal without '
              'changing any background sound cannot be guaranteed.',
              style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
