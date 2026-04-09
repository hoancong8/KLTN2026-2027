import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:path_provider/path_provider.dart';

class FullScreenImageScreen extends StatefulWidget {
  final String imageUrl;
  final Map<String, String>? headers;

  const FullScreenImageScreen({
    super.key,
    required this.imageUrl,
    this.headers,
  });

  @override
  State<FullScreenImageScreen> createState() => _FullScreenImageScreenState();
}

class _FullScreenImageScreenState extends State<FullScreenImageScreen> {
  bool _isDownloading = false;

  Future<void> _saveImage() async {
    // Check permission first
    if (!await Gal.hasAccess()) {
      await Gal.requestAccess();
    }

    setState(() => _isDownloading = true);
    try {
      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final savePath =
          '${dir.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await dio.download(
        widget.imageUrl,
        savePath,
        options: Options(headers: widget.headers),
      );

      await Gal.putImage(savePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu ảnh vào thư viện'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu ảnh: $e'),
            backgroundColor: AppColor.cError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (_isDownloading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Lưu ảnh',
              onPressed: _saveImage,
            ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            httpHeaders: widget.headers,
            fit: BoxFit.contain,
            cacheKey: 'fullscreen_${widget.imageUrl.hashCode}',
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.cMain),
              ),
            ),
            errorWidget: (context, url, error) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broken_image, color: Colors.white, size: 50),
                    SizedBox(height: 8),
                    Text(
                      'Không thể tải ảnh',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
