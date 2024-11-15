import 'package:desktop_music_flutter/pages/home/widgets/play_control_widget.dart';
import 'package:desktop_music_flutter/values/svgs.dart';
import 'package:desktop_music_flutter/widgets/svg_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';

/// 播放器控制组件 - 迷你
class PlayMiniControl extends PlayControlWidget {
  const PlayMiniControl({
    super.key,
    super.onTapPlayList,
    required super.onTapPlay,
    required super.onTapNext,
    required super.onTapPrevious,
    required super.controller,
  });

  @override
  State<PlayMiniControl> createState() => _PlayMiniControlState();
}

class _PlayMiniControlState extends State<PlayMiniControl> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    // if (theme.brightness == Brightness.dark) {
    //   //黑色主题更淡一些
    // }
    double iconSize = 32;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //上一首
        IconButton(
          onPressed: widget.onTapPrevious,
          icon: DMSvgPicture.asset(
            AssetsSvgs.skipPreviousBoldSvg,
            theme.colorScheme.onSurface.withOpacity(.5),
            iconSize: iconSize,
          ),
        ),
        10.horizontalSpace,
        //播放暂停
        IconButton(
          onPressed: widget.onTapPlay,
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              theme.colorScheme.onSurface.withOpacity(.5),
            ),
          ),
          icon: Padding(
            padding: const EdgeInsets.all(3),
            child: AnimatedIcon(
              size: 24,
              icon: AnimatedIcons.play_pause,
              color: Colors.white,
              progress: widget.controller,
            ),
          ),
        ),
        10.horizontalSpace,
        //下一首
        IconButton(
          onPressed: widget.onTapNext,
          icon: DMSvgPicture.asset(
            AssetsSvgs.skipNextBoldSvg,
            theme.colorScheme.onSurface.withOpacity(.5),
            iconSize: iconSize,
          ),
        ),
      ],
    );
  }
}
