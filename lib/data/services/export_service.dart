import 'dart:convert';
import 'dart:io' show File, Directory;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:chatgptmini/core/utils/api_error_message.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

enum ExportArtifactType {
  experienceSummary,
  masterEssay,
  portfolioProject,
  interviewAnswer,
  applicationRecord,
  generic,
}

class ExportRequest {
  const ExportRequest({
    required this.defaultBaseName,
    required this.content,
    this.artifactType = ExportArtifactType.generic,
    this.title = "",
    this.sourceIds = const [],
  });

  final String defaultBaseName;
  final String content;
  final ExportArtifactType artifactType;
  final String title;
  final List<String> sourceIds;
}

/// 텍스트 / PDF / Word(docx) 저장 도우미.
class ExportService {
  ExportService._();

  static Future<void> pickFormatAndSave(
    BuildContext context, {
    required String defaultBaseName,
    required String content,
  }) async {
    return pickFormatAndSaveRequest(
      context,
      request: ExportRequest(
        defaultBaseName: defaultBaseName,
        content: content,
      ),
    );
  }

  static Future<void> pickFormatAndSaveRequest(
    BuildContext context, {
    required ExportRequest request,
  }) async {
    final String? choice = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("저장 형식"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("저장할 형식을 선택하세요.", style: TextStyle(fontSize: 14)),
              SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.text_snippet_outlined),
                title: Text("텍스트 (.txt)"),
                onTap: () => Navigator.pop(ctx, "txt"),
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf_outlined),
                title: Text("PDF (.pdf)"),
                onTap: () => Navigator.pop(ctx, "pdf"),
              ),
              ListTile(
                leading: Icon(Icons.description_outlined),
                title: Text("Word (.docx)"),
                subtitle: Text("간단 문서 형식으로 저장됩니다.", style: TextStyle(fontSize: 11)),
                onTap: () => Navigator.pop(ctx, "docx"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("취소")),
          ],
        );
      },
    );

    if (choice == null) {
      return;
    }

    try {
      final Uint8List bytes;
      final String ext;
      switch (choice) {
        case "txt":
          bytes = Uint8List.fromList(utf8.encode(_withMetadata(request)));
          ext = "txt";
        case "pdf":
          bytes = await _buildPdf(_withMetadata(request));
          ext = "pdf";
        case "docx":
          bytes = _buildSimpleDocx(_withMetadata(request));
          ext = "docx";
        default:
          return;
      }

      if (!context.mounted) {
        return;
      }
      await _writeOrShare(context, bytes, ext, request.defaultBaseName);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(actionErrorMessage('저장 실패', e))),
        );
      }
    }
  }

  static String _withMetadata(ExportRequest request) {
    final List<String> metadata = [];
    if (request.title.trim().isNotEmpty) {
      metadata.add("제목: ${request.title.trim()}");
    }
    metadata.add("유형: ${_artifactTypeLabel(request.artifactType)}");
    if (request.sourceIds.isNotEmpty) {
      metadata.add("연결 ID: ${request.sourceIds.join(", ")}");
    }
    if (metadata.length == 1 && request.artifactType == ExportArtifactType.generic) {
      return request.content;
    }
    return "${metadata.join("\n")}\n\n${request.content}";
  }

  static String _artifactTypeLabel(ExportArtifactType type) {
    return switch (type) {
      ExportArtifactType.experienceSummary => "경험·스펙 요약",
      ExportArtifactType.masterEssay => "마스터 자소서",
      ExportArtifactType.portfolioProject => "포트폴리오 프로젝트",
      ExportArtifactType.interviewAnswer => "면접 답변",
      ExportArtifactType.applicationRecord => "지원 기록",
      ExportArtifactType.generic => "일반 문서",
    };
  }

  static Future<Uint8List> _buildPdf(String content) async {
    pw.Font? font;
    try {
      final data = await rootBundle.load("assets/fonts/ProductSans-Regular.ttf");
      font = pw.Font.ttf(data);
    } catch (_) {
      font = null;
    }

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (ctx) => [
          pw.Text(
            content,
            style: pw.TextStyle(fontSize: 11, lineSpacing: 4, font: font),
          ),
        ],
      ),
    );
    return doc.save();
  }

  static Uint8List _buildSimpleDocx(String plain) {
    final String escaped = plain.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");

    final StringBuffer body = StringBuffer();
    for (final String line in const LineSplitter().convert(escaped)) {
      body.write(
        "<w:p><w:r><w:t xml:space=\"preserve\">$line</w:t></w:r></w:p>",
      );
    }

    final String documentXml =
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        "<w:body>${body.toString()}</w:body>"
        "</w:document>";

    const String contentTypes =
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
        "</Types>";

    const String rels =
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
        "</Relationships>";

    const String docRels =
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>';

    final Archive archive = Archive();
    void addUtf8(String path, String text) {
      final List<int> data = utf8.encode(text);
      archive.addFile(ArchiveFile(path, data.length, data));
    }

    addUtf8("[Content_Types].xml", contentTypes);
    addUtf8("_rels/.rels", rels);
    addUtf8("word/_rels/document.xml.rels", docRels);
    addUtf8("word/document.xml", documentXml);

    final ZipEncoder encoder = ZipEncoder();
    return encoder.encodeBytes(archive);
  }

  static Future<void> _writeOrShare(
    BuildContext context,
    Uint8List bytes,
    String ext,
    String baseName,
  ) async {
    final String safe = baseName.replaceAll(RegExp(r"[^\w\-]+"), "_");
    final String fileName = "${safe}_JasoSupporter.$ext";

    if (kIsWeb) {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(bytes, mimeType: _mimeFor(ext), name: fileName),
          ],
        ),
      );
      return;
    }

    final String? path = await FilePicker.saveFile(
      dialogTitle: "저장 위치",
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [ext],
    );

    if (path == null) {
      final Directory dir = await getTemporaryDirectory();
      final File f = File("${dir.path}/$fileName");
      await f.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(ShareParams(files: [XFile(f.path)]));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("공유 창으로 전달했습니다.")),
        );
      }
      return;
    }

    final String out = path.toLowerCase().endsWith(".$ext") ? path : "$path.$ext";
    await File(out).writeAsBytes(bytes, flush: true);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장했습니다: $out")),
      );
    }
  }

  static String _mimeFor(String ext) {
    switch (ext) {
      case "pdf":
        return "application/pdf";
      case "docx":
        return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
      default:
        return "text/plain";
    }
  }
}
