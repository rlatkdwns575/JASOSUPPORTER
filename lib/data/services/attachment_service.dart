import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart' as mime;

class PickedAttachment {
  const PickedAttachment({
    required this.name,
    required this.bytes,
    this.mimeType = 'application/octet-stream',
  });

  final String name;
  final Uint8List bytes;
  final String mimeType;
}

class AttachmentPickResult {
  const AttachmentPickResult({
    required this.attachments,
    required this.messages,
  });

  final List<PickedAttachment> attachments;
  final List<String> messages;
}

class AttachmentService {
  const AttachmentService({
    this.maxBinaryBytes = 5 * 1024 * 1024,
    this.maxBinaryCount = 6,
  });

  final int maxBinaryBytes;
  final int maxBinaryCount;

  Future<AttachmentPickResult> pickBinaryFiles({
    required int existingCount,
  }) async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ["pdf", "png", "jpg", "jpeg", "webp", "gif"],
    );
    if (result == null || result.files.isEmpty) {
      return const AttachmentPickResult(attachments: [], messages: []);
    }

    final List<PickedAttachment> attachments = [];
    final List<String> messages = [];

    for (final PlatformFile file in result.files) {
      if (existingCount + attachments.length >= maxBinaryCount) {
        messages.add("첨부는 최대 $maxBinaryCount개까지입니다.");
        break;
      }

      final Uint8List? bytes = file.bytes;
      if (bytes == null) {
        messages.add("${file.name}: 데이터를 불러오지 못했습니다. 다시 선택해 주세요.");
        continue;
      }
      if (bytes.isEmpty) {
        continue;
      }
      if (bytes.length > maxBinaryBytes) {
        messages.add("${file.name}: 파일당 ${maxBinaryBytes ~/ (1024 * 1024)}MB 이하만 가능합니다.");
        continue;
      }

      final String? mimeType = mime.lookupMimeType(file.name, headerBytes: bytes) ?? mime.lookupMimeType(file.name);
      if (mimeType == null || !_isBinarySupported(mimeType)) {
        messages.add("${file.name}: 지원 형식은 이미지(png, jpg, webp, gif)와 PDF입니다.");
        continue;
      }

      attachments.add(PickedAttachment(name: file.name, bytes: bytes, mimeType: mimeType));
    }

    return AttachmentPickResult(
      attachments: attachments,
      messages: messages,
    );
  }

  bool _isBinarySupported(String mimeType) {
    return mimeType.startsWith("image/") || mimeType == "application/pdf";
  }
}
