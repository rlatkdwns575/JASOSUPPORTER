import 'dart:typed_data';

import 'package:flutter_gemini/flutter_gemini.dart';

class AiBinaryPart {
  const AiBinaryPart({
    required this.name,
    required this.bytes,
  });

  final String name;
  final Uint8List bytes;
}

abstract class AiService {
  Stream<String> streamText({
    required String prompt,
    List<AiBinaryPart> attachments = const [],
  });
}

class GeminiService implements AiService {
  const GeminiService({
    this.model = "gemini-2.5-flash",
  });

  final String model;

  static void initialize(String apiKey) {
    Gemini.init(apiKey: apiKey);
  }

  @override
  Stream<String> streamText({
    required String prompt,
    List<AiBinaryPart> attachments = const [],
  }) {
    final List<Part> parts = [
      Part.text(prompt),
      ...attachments.map(
        (AiBinaryPart attachment) => Part.inline(
          InlineData.fromUint8List(attachment.bytes),
        ),
      ),
    ];

    return Gemini.instance
        .promptStream(parts: parts, model: model)
        .map((event) => event?.output ?? "")
        .where(
          (String output) => output.isNotEmpty,
        );
  }
}
