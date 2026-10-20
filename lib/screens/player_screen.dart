import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';
import '../models/event.dart';
import '../services/token_service.dart';
import '../widgets/live_tag.dart';

class PlayerScreen extends StatefulWidget {
  final Event event;
  final String m3u8Url;
  final String token;
  final int ttl;
  final Future<String> Function() onTokenRefresh;

  const PlayerScreen({
    super.key,
    required this.event,
    required this.m3u8Url,
    required this.token,
    required this.ttl,
    required this.onTokenRefresh,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  bool _controlsVisible = true;
  bool _isBuffering = false;
  Timer? _hideTimer;
  Timer? _tokenTimer;
  double _progress = 0.0;
  bool _dragging = false;
  final _tokenService = TokenService();

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _startTokenRenewal();
  }

  Future<void> _initPlayer() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.m3u8Url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    await _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _controller!.play();
      _controller!.addListener(_onPlayerListener);
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _isBuffering = false);
    });
  }

  void _onPlayerListener() {
    if (!mounted || _controller == null) return;
    setState(() => _isBuffering = _controller!.value.isBuffering);
    if (!_dragging && _controller!.value.duration.inMilliseconds > 0) {
      setState(() {
        _progress = _controller!.value.position.inMilliseconds /
            _controller!.value.duration.inMilliseconds;
      });
    }
  }

  void _startTokenRenewal() {
    _tokenTimer = Timer.periodic(const Duration(seconds: 55), (_) async {
      try {
        final freshUrl = await widget.onTokenRefresh();
        if (mounted && _controller != null) {
          await _controller!.pause();
          _controller = VideoPlayerController.networkUrl(
            Uri.parse(freshUrl),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
          await _controller!.initialize();
          _controller!.addListener(_onPlayerListener);
          _controller!.play();
          if (mounted) setState(() {});
        }
      } catch (_) {}
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
    _scheduleHide();
  }

  void _seekRelative(int seconds) {
    if (_controller == null) return;
    final pos = _controller!.value.position;
    final target = pos + Duration(seconds: seconds);
    _controller!.seekTo(target);
    _scheduleHide();
  }

  void _goToLive() {
    if (_controller == null) return;
    _controller!.seekTo(_controller!.value.duration);
    setState(() => _progress = 1.0);
    _scheduleHide();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _tokenTimer?.cancel();
    _controller?.removeListener(_onPlayerListener);
    _controller?.dispose();
    _tokenService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF000000),
      child: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            if (_controller != null && _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            else
              Container(
                color: const Color(0xFF000000),
                child: const Center(
                  child: CupertinoActivityIndicator(radius: 14),
                ),
              ),
            if (_isBuffering && _controlsVisible)
              const Center(child: _BufferIndicator()),
            if (_controlsVisible) ...[
              Positioned(
                top: 44,
                left: 0,
                right: 0,
                child: _topControls(),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _bottomControls(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _topControls() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF000000), Color(0x00000000)],
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(
                CupertinoIcons.chevron_down,
                size: 26,
                color: Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const LiveTag(live: true),
                      const SizedBox(width: 8),
                      Text(
                        widget.event.sport,
                        style: const TextStyle(
                          color: Color(0xFF9CA0A5),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _controlButton(CupertinoIcons.tv, onPressed: () {}),
                _controlButton(CupertinoIcons.arrow_right, onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomControls() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0xFF000000)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _controlButton(CupertinoIcons.gobackward_10,
                    onPressed: () => _seekRelative(-10)),
                const SizedBox(width: 24),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _togglePlayPause,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _controller?.value.isPlaying ?? false
                          ? CupertinoIcons.pause
                          : CupertinoIcons.play_fill,
                      size: 28,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                _controlButton(CupertinoIcons.goforward_10,
                    onPressed: () => _seekRelative(10)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  _formatDuration(_controller?.value.position ?? Duration.zero),
                  style: const TextStyle(
                    color: Color(0xFF9CA0A5),
                    fontSize: 13,
                    fontFamily: 'SF Pro Rounded',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CupertinoSlider(
                    value: _dragging
                        ? _progress
                        : ((_controller?.value.position.inMilliseconds ?? 0) /
                            (_controller?.value.duration.inMilliseconds ?? 1)),
                    min: 0,
                    max: 1,
                    onChanged: (v) {
                      setState(() {
                        _dragging = true;
                        _progress = v;
                      });
                    },
                    onChangeEnd: (v) {
                      if (_controller != null) {
                        final pos = Duration(
                            milliseconds: (v *
                                _controller!.value.duration.inMilliseconds)
                            .round());
                        _controller!.seekTo(pos);
                      }
                      setState(() => _dragging = false);
                    },
                    activeColor: const Color(0xFF0A84FF),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_controller?.value.duration ?? Duration.zero),
                  style: const TextStyle(
                    color: Color(0xFF9CA0A5),
                    fontSize: 13,
                    fontFamily: 'SF Pro Rounded',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _outlineButton(CupertinoIcons.textformat_alt, onPressed: () {}),
                _outlineButton(CupertinoIcons.arrow_right, onPressed: () {}),
                CupertinoButton.filled(
                  onPressed: _goToLive,
                  child: const Text('IR AL DIRECTO',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton(IconData icon, {VoidCallback? onPressed}) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed ?? _scheduleHide,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 24, color: const Color(0xFFFFFFFF)),
      ),
    );
  }

  Widget _outlineButton(IconData icon, {VoidCallback? onPressed}) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed ?? _scheduleHide,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.3),
            width: 1,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: const Color(0xFFFFFFFF)),
      ),
    );
  }
}

class _BufferIndicator extends StatelessWidget {
  const _BufferIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF000000).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CupertinoActivityIndicator(),
        ),
      ),
    );
  }
}
