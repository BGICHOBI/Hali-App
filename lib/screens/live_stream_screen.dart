import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../firebase_options.dart'; // Import to read your App ID if desired

const String agoraAppId = '23e8dd789b934052a74e7d8dabdf6f11'; // TODO: replace with your Agora App ID
const String channelName = 'test_channel';     // Or dynamic per session
const String token = ''; // If you have a token server, place your temp token here or leave empty

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  late RtcEngine _engine;
  final List<int> _remoteUids = [];
  bool _joined = false;
  int? _localUid;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    // 1. Request permissions
    await [Permission.camera, Permission.microphone].request();

    // 2. Create engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: agoraAppId,
      // token: token, // optional
    ));

    // 3. Register event handlers
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        setState(() {
          _joined = true;
          _localUid = connection.localUid;
        });
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        setState(() => _remoteUids.add(remoteUid));
      },
      onUserOffline: (connection, remoteUid, reason) {
        setState(() => _remoteUids.remove(remoteUid));
      },
    ));

    // 4. Enable video module & start camera
    await _engine.enableVideo();
    // 5. Join channel
    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Widget _renderLocalPreview() {
    if (!_joined) return const Center(child: CircularProgressIndicator());
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _renderRemoteVideo(int uid) {
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: uid),
        connection: const RtcConnection(channelId: channelName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Stream')),
      body: Stack(
        children: [
          // Fullscreen local preview
          Positioned.fill(child: _renderLocalPreview()),

          // Remote users in overlay
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: 120,
              height: 160,
              child: ListView(
                children: _remoteUids.map(_renderRemoteVideo).toList(),
              ),
            ),
          ),

          // Controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _joined ? Colors.red : Colors.green,
                ),
                child: Text(_joined ? 'Leave Channel' : 'Join Channel'),
                onPressed: () {
                  if (_joined) {
                    _engine.leaveChannel();
                    setState(() {
                      _joined = false;
                      _remoteUids.clear();
                    });
                  } else {
                    _initAgora();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
