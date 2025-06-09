// lib/screens/live_stream_screen.dart

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

const String agoraAppId   = '23e8dd789b934052a74e7d8dabdf6f11';
const String channelName  = 'test_channel';
const String token        = ''; // or your token

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({Key? key}) : super(key: key);

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  late final RtcEngine _engine;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  bool _joined = false;
  int? _localUid;
  final List<int> _remoteUids = [];

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    // 1. Permissions
    await [Permission.camera, Permission.microphone].request();

    // 2. Engine init
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: agoraAppId));

    // 3. Handlers
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) async {
        setState(() {
          _joined   = true;
          _localUid = connection.localUid;
        });
        await _analytics.logEvent(
          name: 'live_join_channel',
          parameters: {
            'channel':   channelName,
            'local_uid': connection.localUid!,
          },
        );
      },
      onUserJoined: (connection, remoteUid, elapsed) async {
        setState(() => _remoteUids.add(remoteUid));
        await _analytics.logEvent(
          name: 'live_user_joined',
          parameters: {
            'channel':    channelName,
            'remote_uid': remoteUid,
          },
        );
      },
      onUserOffline: (connection, remoteUid, reason) async {
        setState(() => _remoteUids.remove(remoteUid));
        await _analytics.logEvent(
          name: 'live_user_left',
          parameters: {
            'channel':    channelName,
            'remote_uid': remoteUid,
            'reason':     reason.toString(),
          },
        );
      },
    ));

    // 4. Video & join
    await _engine.enableVideo();
    await _engine.joinChannel(
      token:      token,
      channelId:  channelName,
      uid:        0,
      options:    const ChannelMediaOptions(),
    );
  }

  Future<void> _toggleChannel() async {
    if (_joined) {
      // log leave
      await _analytics.logEvent(
        name: 'live_leave_channel',
        parameters: {
          'channel':   channelName,
          'local_uid': _localUid!,
        },
      );
      await _engine.leaveChannel();
      setState(() {
        _joined = false;
        _remoteUids.clear();    // ← clear instead of reassign
      });
    } else {
      // re-join
      await _analytics.logEvent(
        name: 'live_rejoin_channel',
        parameters: { 'channel': channelName },
      );
      _initAgora();
    }
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
        canvas:    const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _renderRemoteVideo(int uid) {
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine:  _engine,
        canvas:     VideoCanvas(uid: uid),
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
          Positioned.fill(child: _renderLocalPreview()),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _joined ? Colors.red : Colors.green,
                ),
                onPressed: _toggleChannel,
                child: Text(_joined ? 'Leave Channel' : 'Join Channel'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

