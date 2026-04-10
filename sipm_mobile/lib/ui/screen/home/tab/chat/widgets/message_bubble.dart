import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/app/consts/app_config.dart';
import 'package:sipm_mobile/app/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sipm_mobile/app/provider/localization_provider.dart';
import '../../../../../../domain/entities/chat_message.dart';
// import 'full_screen_image_screen.dart'; // No longer needed for Navigator

class MessageBubble extends ConsumerStatefulWidget {
  final ChatMessage message;
  final String? senderName;

  const MessageBubble({super.key, required this.message, this.senderName});

  @override
  ConsumerState<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<MessageBubble>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep widget alive to prevent rebuild

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final message = widget.message;
    final isImage = message.message.startsWith('[image]');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: message.isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.isMine) const SizedBox(width: 48),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: isImage
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isMine ? AppColor.cMain : AppColor.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isMine ? 16 : 4),
                  bottomRight: Radius.circular(message.isMine ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isMine ? 16 : 4),
                  bottomRight: Radius.circular(message.isMine ? 4 : 16),
                ),
                child: isImage
                    ? _buildImageContent(context, ref)
                    : _buildNormalContent(context, ref),
              ),
            ),
          ),
          if (!message.isMine) const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildNormalContent(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: widget.message.isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        _buildContent(context, ref),
        if (!widget.message.message.startsWith('[image]')) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(widget.message.creationTime),
                style: TextStyle(
                  color: widget.message.isMine
                      ? AppColor.white.withValues(alpha: 0.7)
                      : AppColor.cMuted,
                  fontSize: 11,
                ),
              ),
              if (widget.message.isMine) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all,
                  size: 14,
                  color: AppColor.white.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildImageContent(BuildContext context, WidgetRef ref) {
    final text = widget.message.message;
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        _buildImage(context, ref, text.substring(7)),
        Positioned(
          bottom: 6,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(widget.message.creationTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.message.isMine) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 12, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final text = widget.message.message;
    if (text.startsWith('[file]')) {
      return _buildFile(context, ref, text.substring(6));
    }
    return Text(
      text,
      style: TextStyle(
        color: widget.message.isMine ? AppColor.white : AppColor.cTitle,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildImage(BuildContext context, WidgetRef ref, String jsonString) {
    try {
      final data = json.decode(jsonString);
      final id = data['id'];
      final contentType = data['contentType'];

      if (id == null || contentType == null) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Invalid Image',
            style: TextStyle(color: AppColor.cError),
          ),
        );
      }

      final baseUrl = AppConfig.baseUrl;
      // Use message.id (which is the actual MessageId stored in DB) for the 'id' parameter.
      // The server uses this to authorize and locate the file info from the message content.
      final url =
          '$baseUrl${AppConfig.getChatImage}?id=${widget.message.id}&contentType=${Uri.encodeComponent(contentType)}';

      final token = ref.watch(authTokenProvider)?.accessToken;
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      return GestureDetector(
        onTap: () {
          context.push(
            AppConfig.fullScreenImagePath,
            extra: {'imageUrl': url, 'headers': headers},
          );
        },
        child: RepaintBoundary(
          // ← Prevent repaint when parent rebuilds
          child: Hero(
            tag: 'image_${widget.message.id}',
            child: CachedNetworkImage(
              imageUrl: url,
              httpHeaders: headers,
              fit: BoxFit.cover,
              width: 250,
              // Use message ID as unique cache key
              cacheKey: 'chat_image_${widget.message.id}',
              // Memory cache to prevent reload
              memCacheWidth: 500, // 2x for better quality
              memCacheHeight: 400,
              errorWidget: (context, url, error) => Container(
                padding: const EdgeInsets.all(20),
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
              placeholder: (context, url) => Container(
                height: 200,
                width: 250,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColor.cMain),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: Text('Format Error', style: TextStyle(color: AppColor.cError)),
      );
    }
  }

  Widget _buildFile(BuildContext context, WidgetRef ref, String jsonString) {
    try {
      final data = json.decode(jsonString);
      final name = data['name'] ?? 'Unknown File';
      final id = data['id'];
      final contentType = data['contentType'];

      return GestureDetector(
        onTap: () => _downloadAndOpenFile(context, ref, id, name, contentType),
        child: Container(
          color: Colors.transparent, // Hit test
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.message.isMine
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColor.cGray_50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.insert_drive_file,
                  color: widget.message.isMine
                      ? AppColor.white
                      : AppColor.cMain,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: widget.message.isMine
                            ? AppColor.white
                            : AppColor.cTitle,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nhấn để mở',
                      style: TextStyle(
                        color: widget.message.isMine
                            ? AppColor.white.withValues(alpha: 0.7)
                            : AppColor.cMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return Text('Format Error', style: TextStyle(color: AppColor.cError));
    }
  }

  Future<void> _downloadAndOpenFile(
    BuildContext context,
    WidgetRef ref,
    String? id,
    String name,
    String? contentType,
  ) async {
    if (id == null) return;

    try {
      // 1. Get Url and Headers
      final baseUrl = AppConfig.baseUrl;
      // Use message.id instead of file Id
      final url =
          '$baseUrl${AppConfig.getChatFile}?id=${widget.message.id}&contentType=${Uri.encodeComponent(contentType ?? "")}';
      final token = ref.read(authTokenProvider)?.accessToken;

      // 2. Get Directory
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$name';

      // 3. Show Loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đang tải xuống...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // 4. Download
      final dio = Dio();
      await dio.download(
        url,
        savePath,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );

      // 5. Open File
      final result = await OpenFilex.open(savePath, type: contentType);
      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể mở file: ${result.message}'),
              backgroundColor: AppColor.cError,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải file: $e'),
            backgroundColor: AppColor.cError,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return context.l10n.justNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
