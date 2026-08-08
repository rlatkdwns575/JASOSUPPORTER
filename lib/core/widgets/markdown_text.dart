import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:flutter/material.dart';

/// 경량 마크다운 렌더러.
///
/// AI 응답/자료 텍스트를 표(GFM table), 제목, 목록, 코드블록, 굵게/기울임/코드/링크
/// 인라인 서식으로 렌더링한다. 한글 줄바꿈을 위해 표시 텍스트에는
/// [StringExtension.softWrapWords] 를 적용한다.
class MarkdownText extends StatelessWidget {
  const MarkdownText(
    this.data, {
    super.key,
    this.baseStyle,
  });

  final String data;
  final TextStyle? baseStyle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle base = (baseStyle ??
            TextStyle(fontSize: 14, height: 1.5, color: scheme.onSurface))
        .copyWith(color: baseStyle?.color ?? scheme.onSurface);

    final List<Widget> blocks = _buildBlocks(data, base, scheme);
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: blocks,
      ),
    );
  }

  // ---- 블록 파싱 ----

  static List<Widget> _buildBlocks(String data, TextStyle base, ColorScheme scheme) {
    final List<String> lines =
        data.replaceAll("\r\n", "\n").replaceAll("\r", "\n").split("\n");
    final List<Widget> widgets = <Widget>[];
    int i = 0;

    void addSpacing() {
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: 8));
      }
    }

    while (i < lines.length) {
      final String line = lines[i];
      final String trimmed = line.trim();

      if (trimmed.isEmpty) {
        i++;
        continue;
      }

      // 코드 펜스
      if (trimmed.startsWith("```")) {
        final List<String> buf = <String>[];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith("```")) {
          buf.add(lines[i]);
          i++;
        }
        if (i < lines.length) {
          i++; // 닫는 펜스 소비
        }
        addSpacing();
        widgets.add(_codeBlock(buf.join("\n"), scheme));
        continue;
      }

      // 표: 현재 줄에 파이프가 있고 다음 줄이 구분선
      if (line.contains("|") &&
          i + 1 < lines.length &&
          _isTableDelimiter(lines[i + 1])) {
        final String header = line;
        final String delimiter = lines[i + 1];
        i += 2;
        final List<String> rows = <String>[];
        while (i < lines.length &&
            lines[i].trim().isNotEmpty &&
            lines[i].contains("|")) {
          rows.add(lines[i]);
          i++;
        }
        addSpacing();
        widgets.add(_table(header, delimiter, rows, base, scheme));
        continue;
      }

      // 제목
      final RegExpMatch? heading =
          RegExp(r"^(#{1,6})\s+(.*)$").firstMatch(trimmed);
      if (heading != null) {
        addSpacing();
        widgets.add(_heading(
          heading.group(1)!.length,
          heading.group(2)!.trim(),
          base,
          scheme,
        ));
        continue;
      }

      // 수평선
      if (RegExp(r"^(-{3,}|\*{3,}|_{3,})$").hasMatch(trimmed)) {
        addSpacing();
        widgets.add(Divider(color: scheme.outlineVariant, height: 16));
        i++;
        continue;
      }

      // 목록
      if (_listMatch(line) != null) {
        final List<Widget> items = <Widget>[];
        while (i < lines.length && _listMatch(lines[i]) != null) {
          final _ListLine parsed = _listMatch(lines[i])!;
          items.add(_listItem(parsed, base, scheme));
          i++;
        }
        addSpacing();
        widgets.add(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: items,
        ));
        continue;
      }

      // 문단: 빈 줄이나 블록 시작 전까지 수집
      final List<String> para = <String>[];
      while (i < lines.length &&
          lines[i].trim().isNotEmpty &&
          !_isBlockStart(lines, i)) {
        para.add(lines[i].trim());
        i++;
      }
      addSpacing();
      widgets.add(Text.rich(
        TextSpan(children: _parseInline(para.join("\n"), base, scheme)),
      ));
    }

    return widgets;
  }

  static bool _isBlockStart(List<String> lines, int i) {
    final String line = lines[i];
    final String trimmed = line.trim();
    if (trimmed.startsWith("```")) return true;
    if (RegExp(r"^#{1,6}\s+").hasMatch(trimmed)) return true;
    if (RegExp(r"^(-{3,}|\*{3,}|_{3,})$").hasMatch(trimmed)) return true;
    if (_listMatch(line) != null) return true;
    if (line.contains("|") &&
        i + 1 < lines.length &&
        _isTableDelimiter(lines[i + 1])) {
      return true;
    }
    return false;
  }

  // ---- 목록 ----

  static _ListLine? _listMatch(String line) {
    final RegExpMatch? unordered =
        RegExp(r"^(\s*)([-*+])\s+(.*)$").firstMatch(line);
    if (unordered != null) {
      return _ListLine(
        indent: unordered.group(1)!.length,
        marker: "•",
        text: unordered.group(3)!,
      );
    }
    final RegExpMatch? ordered =
        RegExp(r"^(\s*)(\d+)[.)]\s+(.*)$").firstMatch(line);
    if (ordered != null) {
      return _ListLine(
        indent: ordered.group(1)!.length,
        marker: "${ordered.group(2)!}.",
        text: ordered.group(3)!,
      );
    }
    return null;
  }

  static Widget _listItem(_ListLine item, TextStyle base, ColorScheme scheme) {
    return Padding(
      padding: EdgeInsets.only(left: 4.0 + item.indent * 1.0, top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 1),
            child: Text(item.marker, style: base.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(children: _parseInline(item.text, base, scheme)),
            ),
          ),
        ],
      ),
    );
  }

  // ---- 표 ----

  static bool _isTableDelimiter(String line) {
    if (!line.contains("-")) {
      return false;
    }
    final List<String> cells = _splitRow(line);
    if (cells.isEmpty) {
      return false;
    }
    return cells.every((String c) => RegExp(r"^:?-{1,}:?$").hasMatch(c.trim()));
  }

  static List<String> _splitRow(String row) {
    String r = row.trim();
    if (r.startsWith("|")) {
      r = r.substring(1);
    }
    if (r.endsWith("|")) {
      r = r.substring(0, r.length - 1);
    }
    return r.split("|").map((String c) => c.trim()).toList();
  }

  static TextAlign _alignFor(String delimiterCell) {
    final String c = delimiterCell.trim();
    final bool left = c.startsWith(":");
    final bool right = c.endsWith(":");
    if (left && right) return TextAlign.center;
    if (right) return TextAlign.right;
    return TextAlign.left;
  }

  static Widget _table(
    String header,
    String delimiter,
    List<String> rows,
    TextStyle base,
    ColorScheme scheme,
  ) {
    final List<String> headerCells = _splitRow(header);
    final List<String> delimiterCells = _splitRow(delimiter);
    final int columns = headerCells.length;

    List<String> normalize(List<String> cells) {
      final List<String> copy = List<String>.from(cells);
      while (copy.length < columns) {
        copy.add("");
      }
      return copy.take(columns).toList();
    }

    List<TextAlign> aligns = <TextAlign>[
      for (int c = 0; c < columns; c++)
        c < delimiterCells.length ? _alignFor(delimiterCells[c]) : TextAlign.left,
    ];

    TableRow buildRow(List<String> cells, {required bool isHeader}) {
      final List<String> norm = normalize(cells);
      return TableRow(
        decoration: isHeader
            ? BoxDecoration(color: scheme.surfaceContainerHigh)
            : null,
        children: [
          for (int c = 0; c < columns; c++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Text.rich(
                TextSpan(
                  children: _parseInline(
                    norm[c],
                    isHeader ? base.copyWith(fontWeight: FontWeight.w700) : base,
                    scheme,
                  ),
                ),
                textAlign: aligns[c],
              ),
            ),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Table(
        border: TableBorder.all(color: scheme.outlineVariant, width: 1),
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        columnWidths: <int, TableColumnWidth>{
          for (int c = 0; c < columns; c++) c: const FlexColumnWidth(1),
        },
        children: [
          buildRow(headerCells, isHeader: true),
          for (final String row in rows) buildRow(_splitRow(row), isHeader: false),
        ],
      ),
    );
  }

  // ---- 제목 / 코드블록 ----

  static Widget _heading(int level, String text, TextStyle base, ColorScheme scheme) {
    final double size = switch (level) {
      1 => 20,
      2 => 18,
      3 => 16,
      _ => 15,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text.rich(
        TextSpan(
          children: _parseInline(
            text,
            base.copyWith(fontSize: size, fontWeight: FontWeight.w800),
            scheme,
          ),
        ),
      ),
    );
  }

  static Widget _codeBlock(String code, ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontFamily: "monospace",
          fontSize: 13,
          height: 1.45,
          color: scheme.onSurface,
        ),
      ),
    );
  }

  // ---- 인라인 서식 ----

  static List<InlineSpan> _parseInline(String text, TextStyle base, ColorScheme scheme) {
    if (text.isEmpty) {
      return <InlineSpan>[TextSpan(text: "", style: base)];
    }
    final List<InlineSpan> out = <InlineSpan>[];
    final RegExp pattern = RegExp(
      r"(`[^`]+`)"
      r"|(\*\*[^*]+\*\*)"
      r"|(__[^_]+__)"
      r"|(\*[^*]+\*)"
      r"|(\[[^\]]+\]\([^)]+\))",
    );
    int last = 0;
    for (final RegExpMatch m in pattern.allMatches(text)) {
      if (m.start > last) {
        out.add(_plain(text.substring(last, m.start), base));
      }
      final String tok = m.group(0)!;
      if (tok.startsWith("`")) {
        out.add(TextSpan(
          text: tok.substring(1, tok.length - 1),
          style: base.copyWith(
            fontFamily: "monospace",
            backgroundColor: scheme.surfaceContainerHigh,
          ),
        ));
      } else if (tok.startsWith("**") || tok.startsWith("__")) {
        out.addAll(_parseInline(
          tok.substring(2, tok.length - 2),
          base.copyWith(fontWeight: FontWeight.w700),
          scheme,
        ));
      } else if (tok.startsWith("*")) {
        out.addAll(_parseInline(
          tok.substring(1, tok.length - 1),
          base.copyWith(fontStyle: FontStyle.italic),
          scheme,
        ));
      } else if (tok.startsWith("[")) {
        final RegExpMatch link =
            RegExp(r"\[([^\]]+)\]\(([^)]+)\)").firstMatch(tok)!;
        out.add(_plain(
          link.group(1)!,
          base.copyWith(
            color: scheme.primary,
            decoration: TextDecoration.underline,
          ),
        ));
      }
      last = m.end;
    }
    if (last < text.length) {
      out.add(_plain(text.substring(last), base));
    }
    return out;
  }

  static InlineSpan _plain(String text, TextStyle style) {
    return TextSpan(text: text.softWrapWords(), style: style);
  }
}

class _ListLine {
  const _ListLine({
    required this.indent,
    required this.marker,
    required this.text,
  });

  final int indent;
  final String marker;
  final String text;
}
