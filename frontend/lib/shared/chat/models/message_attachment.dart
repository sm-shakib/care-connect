/// The kind of file carried by a [MessageAttachment].
enum AttachmentKind { image, video, document, voice }

/// A single file attached to a [ChatMessage] — a photo, video, document, or
/// recorded voice note. `localPath` points at a file on device (dummy data
/// and freshly-picked/recorded attachments both resolve this way, since
/// there is no upload backend yet); `remoteUrl` is left as the seam for a
/// real media server.
class MessageAttachment {
  const MessageAttachment({
    required this.id,
    required this.kind,
    required this.fileName,
    this.localPath,
    this.remoteUrl,
    this.fileSizeBytes = 0,
    this.mimeType,
    this.duration,
    this.width,
    this.height,
  });

  final String id;
  final AttachmentKind kind;
  final String fileName;
  final String? localPath;
  final String? remoteUrl;
  final int fileSizeBytes;
  final String? mimeType;

  /// Playback length, for [AttachmentKind.voice] and [AttachmentKind.video].
  final Duration? duration;

  /// Pixel dimensions, for [AttachmentKind.image] and [AttachmentKind.video].
  final int? width;
  final int? height;

  /// Best-effort path/URL to render or open this attachment from.
  String? get resolvedSource => localPath ?? remoteUrl;

  String get fileExtension {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) return '';
    return fileName.substring(dotIndex + 1).toUpperCase();
  }

  String get formattedSize {
    if (fileSizeBytes <= 0) return '';
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = fileSizeBytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(size >= 10 || unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }
}
