import 'dart:convert';

class CsvUtils {
  static String _escape(String value) {
    final needsQuotes =
        value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    var escaped = value.replaceAll('"', '""');
    return needsQuotes ? '"$escaped"' : escaped;
  }

  static String encode(List<List<String>> rows) {
    final buffer = StringBuffer();
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      buffer.write(row.map(_escape).join(','));
      if (i < rows.length - 1) buffer.write('\n');
    }
    return buffer.toString();
  }

  static List<List<String>> decode(String content) {
    final rows = <List<String>>[];
    int i = 0;
    final len = content.length;
    List<String> currentRow = [];
    final buffer = StringBuffer();
    bool inQuotes = false;

    void endField() {
      currentRow.add(buffer.toString());
      buffer.clear();
    }

    void endRow() {
      rows.add(List<String>.from(currentRow));
      currentRow.clear();
    }

    while (i < len) {
      final ch = content[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < len && content[i + 1] == '"') {
            buffer.write('"');
            i += 2;
            continue;
          } else {
            inQuotes = false;
            i++;
            continue;
          }
        } else {
          buffer.write(ch);
          i++;
          continue;
        }
      } else {
        if (ch == '"') {
          inQuotes = true;
          i++;
          continue;
        }
        if (ch == ',') {
          endField();
          i++;
          continue;
        }
        if (ch == '\n') {
          endField();
          endRow();
          i++;
          continue;
        }
        if (ch == '\r') {
          i++;
          continue;
        }
        buffer.write(ch);
        i++;
      }
    }
    endField();
    endRow();
    return rows;
  }

  static List<int> toUtf8WithBom(String s) {
    final bytes = utf8.encode(s);
    return [0xEF, 0xBB, 0xBF, ...bytes];
  }
}
