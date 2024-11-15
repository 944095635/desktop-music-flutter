import 'dart:async';

import 'package:desktop_music_flutter/api/test_api.dart';
import 'package:desktop_music_flutter/models/music.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // 播放器 - 音乐
  late final Player? _playerMusic;

  // 播放器
  late final Player? _playerVideo;

  // 播放控制器 - 背景视图
  late final VideoController? playVideoController;

  // 播放器状态保存
  late final GlobalKey<VideoState> keyVideo = GlobalKey<VideoState>();

  /// 播放按钮动画控制器
  late AnimationController playButtonController;

  /// 当前进度
  var progress = 0.0.obs;

  /// 当前正在拖动进度条
  var dragProgress = false;

  /// 当前歌曲播放进度
  final Rx<Duration> position = Rx(Duration.zero);

  /// 当前歌曲长度
  final Rx<Duration> duration = Rx(Duration.zero);

  /// 当前音乐
  final Rxn<Music> music = Rxn();

  /// 歌曲列表
  List<Music>? playlist;

  /// 监听事件
  StreamSubscription? subPlaying;
  StreamSubscription? subPlaylist;
  StreamSubscription? subPosition;
  StreamSubscription? subDuration;

  @override
  void onInit() {
    super.onInit();
    // 播放器
    _playerVideo = Player();
    // 播放控制器
    playVideoController = VideoController(_playerVideo!);
    // 设置循环模式 + 音频渲染
    _playerVideo.setPlaylistMode(PlaylistMode.loop);
    _playerVideo.setAudioTrack(AudioTrack.no());

    // 音乐播放器
    _playerMusic = Player();
    //_playerMusic!.setVolume(1);
    // 关闭视频渲染
    _playerMusic!.setVideoTrack(VideoTrack.no());
    // 监听音乐回调
    subPlaying = _playerMusic.stream.playing.listen(onPlayingCall);
    subPlaylist = _playerMusic.stream.playlist.listen(onPlaylistCall);
    subPosition = _playerMusic.stream.position.listen(onPositionCall);
    subDuration = _playerMusic.stream.duration.listen(onDurationCall);

    // 按钮控制器
    playButtonController =
        AnimationController(vsync: this, duration: Durations.long2);
  }

  @override
  void onClose() {
    super.onClose();
    //销毁音频播放器
    _playerMusic?.dispose();
    //销毁视频播放器
    _playerVideo?.dispose();
    //取消回调监听
    subPlaying?.cancel();
    subPlaylist?.cancel();
    subPosition?.cancel();
    subDuration?.cancel();
  }

  @override
  void onReady() {
    super.onReady();

    _playerVideo!.open(Media('asset:///assets/video.mp4'));

    _initMusic();
  }

  _initMusic() async {
    await Future.delayed(const Duration(seconds: 2));

    /// 初始化音乐信息 测试
    playlist = TestApi.getMusicList();
    _playerMusic?.open(
      Playlist(
        playlist!.map((e) => Media(e.source)).toList(),
      ),
    );
  }

  /// 点击播放暂停按钮
  Future? onTapPlay() {
    return _playerMusic?.playOrPause();
  }

  /// 点击上一首
  onTapPrevious() {
    progress.value = 0;
    _playerMusic?.previous();
  }

  /// 点击下一首
  onTapNext() {
    progress.value = 0;
    _playerMusic?.next();
  }

  void onPlayingCall(bool playing) {
    if (playing) {
      // 切换到暂停状态
      playButtonController.forward();
    } else {
      // 切换到播放状态
      playButtonController.reverse();
    }
  }

  /// 播放进度回调
  void onPositionCall(Duration newPosition) {
    // 更新进度
    position.value = newPosition;
    // 拖拽进度条的时候不会更新到进度条上面
    if (!dragProgress) {
      // 新的进度
      double newProgress = newPosition.inMicroseconds /
          _playerMusic!.state.duration.inMicroseconds;
      if (newProgress > 0 && newProgress < 1) {
        progress.value = newProgress;
      }
    }
  }

  /// 歌曲长度监听
  void onDurationCall(Duration newDuration) {
    duration.value = newDuration;
  }

  /// 最大化全屏
  void fullscreen() {
    keyVideo.currentState?.enterFullscreen();
    // if (keyVideo.currentState?.isFullscreen() ?? false) {
    // }
  }

  /// 点击进度条
  Future onTapProgress(double percentage) async {
    Duration newPosition = Duration(
        seconds: (_playerMusic!.state.duration.inSeconds * percentage).toInt());
    await _playerMusic.seek(newPosition);
  }

  /// 播放列表更新
  void onPlaylistCall(Playlist event) {
    music.value = playlist![event.index];
  }
}
