import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:desktop_music_flutter/common/system_chrome.dart';
import 'package:desktop_music_flutter/pages/home/home_controller.dart';
import 'package:desktop_music_flutter/pages/home/widgets/play_mini_control.dart';
import 'package:desktop_music_flutter/values/svgs.dart';
import 'package:desktop_music_flutter/widgets/blur_widget.dart';
import 'package:desktop_music_flutter/widgets/heart_widget.dart';
import 'package:desktop_music_flutter/widgets/slider.dart';
import 'package:desktop_music_flutter/extension/duration_extensions.dart';
import 'package:desktop_music_flutter/widgets/svg_picture.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildVideo(),
          // 拖动组件
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) ...{
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 120,
              child: DragToMoveArea(
                child: SizedBox(),
              ),
            ),
          },

          /// 底部组件集合
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 120,
            child: Obx(
              () => SlideInUp(
                from: 120,
                duration: const Duration(seconds: 1),
                animate: controller.music.value != null,
                child: controller.music.value != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          // 封面底图
                          Positioned(
                            left: 15,
                            bottom: 15,
                            child: _buildCoverBackground(),
                          ),
                          // 控制条
                          BlurWidget(
                            child: _buildControls(context),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Obx(
              () => SlideInRight(
                duration: const Duration(seconds: 1),
                animate: controller.music.value != null,
                child: _buildThemeButton(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 主题按钮
  Widget _buildThemeButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (Get.isDarkMode) {
          Get.changeThemeMode(ThemeMode.light);
        } else {
          Get.changeThemeMode(ThemeMode.dark);
        }
      },
      icon: DMSvgPicture.asset(
        AssetsSvgs.moonBoldSvg,
        context.theme.colorScheme.onSurface,
      ),
    );
  }

  /// 视频组件
  Widget _buildVideo() {
    return MaterialVideoControlsTheme(
      normal: const MaterialVideoControlsThemeData(
        displaySeekBar: false,
        bottomButtonBar: [],
        primaryButtonBar: [],
      ),
      fullscreen: const MaterialVideoControlsThemeData(
        displaySeekBar: false,
        primaryButtonBar: [],
        topButtonBar: [],
        bottomButtonBar: [],
      ),
      child: MaterialDesktopVideoControlsTheme(
        normal: const MaterialDesktopVideoControlsThemeData(
          displaySeekBar: false,
          playAndPauseOnTap: false,
          toggleFullscreenOnDoublePress: false,
          bottomButtonBar: [],
        ),
        fullscreen: const MaterialDesktopVideoControlsThemeData(
          displaySeekBar: false,
          bottomButtonBar: [],
        ),
        child: Video(
          fit: BoxFit.cover,
          key: controller.keyVideo,
          controller: controller.playVideoController!,
          controls: Platform.isAndroid || Platform.isIOS
              ? NoVideoControls
              : AdaptiveVideoControls,
          onExitFullscreen: () async {
            SystemChromeUtils.set();
          },
          //controls: NoVideoControls,
        ),
      ),
    );
  }

  /// 控制组件
  Widget _buildControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        top: 20,
        right: 20,
        bottom: 20,
      ),
      child: Row(
        children: [
          _buildCover(),
          20.horizontalSpace,
          _buildMusicInfo(context),
          20.horizontalSpace,
          PlayMiniControl(
            controller: controller.playButtonController,
            onTapPlay: controller.onTapPlay,
            onTapPrevious: controller.onTapPrevious,
            onTapNext: controller.onTapNext,
          ),
          20.horizontalSpace,
          Obx(
            () => _buildTimeText(context, controller.position.value),
          ),
          Expanded(
            child: Obx(
              () => DMSlider(
                value: controller.progress.value,
                onChangeStart: (value) {
                  controller.dragProgress = true;
                },
                onChanged: (value) {
                  controller.progress.value = value;
                },
                onChangeEnd: (value) async {
                  controller.progress.value = value;
                  await controller.onTapProgress(value);
                  controller.dragProgress = false;
                },
              ),
            ),
          ),
          Obx(
            () => _buildTimeText(context, controller.duration.value),
          ),
          20.horizontalSpace,
          IconButton(
            onPressed: controller.fullscreen,
            icon: DMSvgPicture.asset(
              AssetsSvgs.fullScreenSvg,
              context.theme.colorScheme.onSurface.withOpacity(.6),
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// 歌曲时间信息
  Widget _buildTimeText(BuildContext context, Duration duration) {
    debugPrint("重绘Play播放页面 时间Position:");
    return Text(
      duration.format(),
      style: TextStyle(
        color: context.theme.colorScheme.onSurface.withOpacity(.6),
      ),
    );
  }

  /// 视频封面 - 迷你
  Widget _buildCoverBackground() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: controller.music.value!.cover,
        fit: BoxFit.cover,
        width: 90,
        height: 90,
        memCacheHeight: 10,
        memCacheWidth: 10,
      ),
    );
  }

  /// 视频封面
  Widget _buildCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: controller.music.value!.cover,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
      ),
    );
  }

  /// 歌曲信息
  Widget _buildMusicInfo(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  controller.music.value?.name ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    color: context.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // showModalBottomSheet(
                  //   context: Get.context!,
                  //   builder: (context) => const PlayListPage(),
                  // );
                  controller.music.value?.like.value =
                      !controller.music.value!.like.value;
                },
                icon: HeartWidget(
                    like: controller.music.value?.like.value ?? false),
              ),
            ],
          ),
          Text(
            controller.music.value?.author ?? "",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: context.theme.colorScheme.onSurface.withOpacity(.8),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
