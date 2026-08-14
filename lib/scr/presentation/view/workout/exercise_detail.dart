import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';
import 'package:gym/scr/presentation/widgets/common/common_app_bar.dart';
import 'package:gym/scr/presentation/widgets/common/common_button.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseDetailScreen extends GetView<WorkoutController> {
  const ExerciseDetailScreen({super.key});

  @override
  WorkoutController get controller => WorkoutController.resolve();

  @override
  Widget build(BuildContext context) {
    final exercise = Get.arguments is WorkoutExercise
        ? Get.arguments as WorkoutExercise
        : controller.allExercises.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: exercise.title),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ExerciseMedia(exercise: exercise),
              const SizedBox(height: 20),
              Row(
                children: [
                  _Metric(
                    icon: Icons.sync_alt_rounded,
                    value: exercise.sets,
                    label: 'Sets',
                  ),
                  _Metric(
                    icon: Icons.repeat_rounded,
                    value: exercise.reps,
                    label: 'Reps',
                  ),
                  _Metric(
                    icon: Icons.timer_outlined,
                    value: exercise.rest,
                    label: 'Rest',
                  ),
                  _Metric(
                    icon: Icons.local_fire_department_outlined,
                    value: exercise.calories,
                    label: 'Burn',
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text('How to do', style: TextHelper.homeTitle),
              const SizedBox(height: 13),
              for (
                var index = 0;
                index < exercise.instructions.length;
                index++
              ) ...[
                if (index > 0) const SizedBox(height: 12),
                _InstructionStep(
                  step: index + 1,
                  text: exercise.instructions[index],
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Obx(() {
          final isAdded = controller.isExerciseSelected(exercise);
          return CommonButton(
            label: isAdded ? 'Added to My Workout' : 'Add to Workout',
            onPressed: isAdded || !controller.canAddExercise
                ? null
                : () => controller.addExercise(exercise),
            icon: isAdded ? Icons.check_rounded : Icons.add_rounded,
          );
        }),
      ),
    );
  }
}

class _ExerciseMedia extends StatefulWidget {
  const _ExerciseMedia({required this.exercise});

  final WorkoutExercise exercise;

  @override
  State<_ExerciseMedia> createState() => _ExerciseMediaState();
}

class _ExerciseMediaState extends State<_ExerciseMedia> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  bool _isLoading = false;
  bool _hasError = false;

  Future<void> _handleTap() async {
    final youtubeVideoId = _youtubeIdFromUrl(widget.exercise.videoUrl);
    if (youtubeVideoId != null) {
      _youtubeController ??= YoutubePlayerController.fromVideoId(
        videoId: youtubeVideoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          mute: false,
          strictRelatedVideos: true,
        ),
      );
      if (mounted) {
        setState(() {});
      }
      return;
    }

    final currentController = _videoController;
    if (currentController != null) {
      if (currentController.value.isPlaying) {
        await currentController.pause();
      } else {
        await currentController.play();
      }
      if (mounted) {
        setState(() {});
      }
      return;
    }

    if (_isLoading || !widget.exercise.hasVideo) {
      return;
    }

    final uri = Uri.parse(widget.exercise.videoUrl!.trim());
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final controller = VideoPlayerController.networkUrl(uri);
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      _videoController = controller;
      await controller.play();
      setState(() => _isLoading = false);
    } catch (_) {
      await controller.dispose();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _youtubeController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;
    final isDirectVideoReady = controller?.value.isInitialized == true;
    final youtubeController = _youtubeController;
    final isYoutubeReady = youtubeController != null;
    final isAnyVideoReady = isDirectVideoReady || isYoutubeReady;

    return AspectRatio(
      aspectRatio: 1.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: AppColors.black,
          child: InkWell(
            onTap: widget.exercise.hasVideo && !isYoutubeReady
                ? _handleTap
                : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isYoutubeReady)
                  Center(child: YoutubePlayer(controller: youtubeController))
                else if (isDirectVideoReady)
                  Center(
                    child: AspectRatio(
                      aspectRatio: controller!.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  )
                else
                  _ExerciseImage(exercise: widget.exercise),
                if (!isAnyVideoReady)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.transparent,
                          AppColors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                if (!isAnyVideoReady)
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.exercise.category,
                          style: TextHelper.poppins,
                        ),
                        Text(
                          widget.exercise.focus,
                          style: TextHelper.homeTitle2,
                        ),
                      ],
                    ),
                  ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                else if (_hasError)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.replay_rounded, color: AppColors.white),
                          SizedBox(width: 8),
                          Text(
                            'Unable to play. Tap to retry.',
                            style: TextStyle(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (widget.exercise.hasVideo &&
                    (!isDirectVideoReady || !controller!.value.isPlaying) &&
                    !isYoutubeReady)
                  Center(
                    child: Container(
                      key: const ValueKey('exercise-video-play'),
                      height: 58,
                      width: 58,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.35),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.white,
                        size: 36,
                      ),
                    ),
                  ),
                if (isDirectVideoReady)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: VideoProgressIndicator(
                      controller!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: AppColors.textMuted,
                        backgroundColor: AppColors.field,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _youtubeIdFromUrl(String? value) {
  final uri = Uri.tryParse(value?.trim() ?? '');
  if (uri == null) {
    return null;
  }

  final host = uri.host.toLowerCase().replaceFirst('www.', '');
  if (host == 'youtu.be') {
    return uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
  }

  if (host != 'youtube.com' && host != 'm.youtube.com') {
    return null;
  }

  final queryVideoId = uri.queryParameters['v'];
  if (queryVideoId?.isNotEmpty == true) {
    return queryVideoId;
  }

  if (uri.pathSegments.length >= 2 &&
      const {'embed', 'shorts', 'live'}.contains(uri.pathSegments.first)) {
    return uri.pathSegments[1];
  }

  return null;
}

class _ExerciseImage extends StatelessWidget {
  const _ExerciseImage({required this.exercise});

  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    if (exercise.hasNetworkImage) {
      return Image.network(
        exercise.image,
        fit: BoxFit.cover,
        alignment: exercise.imageAlignment,
        errorBuilder: (_, _, _) => const _ImageFallback(),
      );
    }

    return Image.asset(
      exercise.image,
      fit: BoxFit.cover,
      alignment: exercise.imageAlignment,
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.field,
      child: Center(
        child: Icon(
          Icons.fitness_center_rounded,
          color: AppColors.primary,
          size: 42,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextHelper.homeTitle3,
          ),
          const SizedBox(height: 2),
          Text(label, style: TextHelper.homeSubtitle),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({required this.step, required this.text});

  final int step;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 26,
          width: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Text('$step', style: TextHelper.poppins),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(text, style: TextHelper.poppins.copyWith(height: 1.45)),
        ),
      ],
    );
  }
}
