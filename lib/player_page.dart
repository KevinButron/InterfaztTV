import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PlayerPage extends StatefulWidget {
  final String videoUrl;
  final String canalName;

  const PlayerPage({Key? key, required this.videoUrl, required this.canalName}) : super(key: key);

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
      await _videoPlayerController.initialize();

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        showControls: true,
        allowFullScreen: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade400,
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
      );

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      _handleError('Error: $e');
    }
  }

  void _handleError(String error) {
    if (!mounted) return;
    setState(() {
      _hasError = true;
      _isLoading = false;
      _errorMessage = error;
    });
  }

  void _retryPlayback() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 20),
            Text('Cargando...', style: TextStyle(color: Colors.white)),
            SizedBox(height: 10),
            Text(widget.canalName, style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 64),
              SizedBox(height: 20),
              Text('Error al reproducir', style: TextStyle(color: Colors.white, fontSize: 18)),
              SizedBox(height: 10),
              Text(_errorMessage, style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _retryPlayback,
                child: Text('Reintentar'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Volver', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) return _buildErrorScreen();
    if (_isLoading || _chewieController == null) return _buildLoadingScreen();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Chewie(controller: _chewieController!),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.live_tv, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Expanded(child: Text(widget.canalName, style: TextStyle(color: Colors.white))),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
