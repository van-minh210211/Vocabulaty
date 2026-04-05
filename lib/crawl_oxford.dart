import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

void main() async {
  final baseUrl = 'https://www.oxfordlearnersdictionaries.com';
  final listUrl = '$baseUrl/wordlists/oxford3000-5000';
  
  print('--- Bắt đầu Crawl TOÀN BỘ Oxford 3000-5000 (A-Z) ---');
  print('Quá trình này có thể mất nhiều thời gian. Dữ liệu sẽ được lưu dần vào data/json_new/');

  try {
    final response = await http.get(Uri.parse(listUrl), headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36'
    });

    if (response.statusCode != 200) {
      print('Lỗi tải danh sách: ${response.statusCode}');
      return;
    }

    var document = parse(response.body);
    var wordElements = document.querySelectorAll('ul.top-g li');
    print('Tìm thấy tổng cộng ${wordElements.length} từ.');

    Map<String, List<Map<String, dynamic>>> categorizedWords = {};
    String currentProcessedLetter = '';

    for (var i = 0; i < wordElements.length; i++) {
      var element = wordElements[i];
      String word = element.attributes['data-hw'] ?? '';
      String? detailUrl = element.querySelector('a')?.attributes['href'];

      if (word.isNotEmpty && detailUrl != null) {
        String firstLetter = word[0].toLowerCase();
        
        // Nếu chuyển sang chữ cái mới, lưu file chữ cái cũ lại
        if (currentProcessedLetter != '' && currentProcessedLetter != firstLetter) {
          await saveLetterFile(currentProcessedLetter, categorizedWords[currentProcessedLetter]!);
          categorizedWords.remove(currentProcessedLetter); // Giải phóng bộ nhớ
        }
        currentProcessedLetter = firstLetter;

        print('[${i + 1}/${wordElements.length}] Đang xử lý: $word');
        
        var data = await fetchFullDetails('$baseUrl$detailUrl', word);
        if (data.isNotEmpty) {
          categorizedWords.putIfAbsent(firstLetter, () => []).add(data);
        }

        // Nghỉ một chút để tránh bị block IP (Rất quan trọng)
        await Future.delayed(Duration(milliseconds: 600));
      }
    }

    // Lưu chữ cái cuối cùng
    if (currentProcessedLetter != '') {
      await saveLetterFile(currentProcessedLetter, categorizedWords[currentProcessedLetter]!);
    }

    print('\n--- HOÀN THÀNH TOÀN BỘ ---');
  } catch (e) {
    print('Lỗi tổng quát: $e');
  }
}

Future<void> saveLetterFile(String letter, List<Map<String, dynamic>> words) async {
  final jsonDir = Directory('data/json_new');
  if (!await jsonDir.exists()) await jsonDir.create(recursive: true);
  
  final file = File('data/json_new/$letter.json');
  await file.writeAsString(jsonEncode(words));
  print('==> Đã lưu xong chữ cái [$letter]: ${words.length} từ vào ${file.path}');
}

Future<Map<String, dynamic>> fetchFullDetails(String url, String headword) async {
  try {
    final response = await http.get(Uri.parse(url), headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36'
    });

    if (response.statusCode == 200) {
      var doc = parse(response.body);
      String pos = doc.querySelector('.pos')?.text.trim() ?? '';
      
      var ukContainer = doc.querySelector('.phons_br');
      String ukMp3 = ukContainer?.querySelector('.sound')?.attributes['data-src-mp3'] ?? '';
      String ukIpa = ukContainer?.querySelector('.phon')?.text.trim() ?? '';
      
      var usContainer = doc.querySelector('.phons_n_am');
      String usMp3 = usContainer?.querySelector('.sound')?.attributes['data-src-mp3'] ?? '';
      String usIpa = usContainer?.querySelector('.phon')?.text.trim() ?? '';

      List<Map<String, dynamic>> senses = [];
      var senseElements = doc.querySelectorAll('.sense');

      for (var senseEl in senseElements) {
        String definition = senseEl.querySelector('.def')?.text.trim() ?? '';
        
        List<String> examples = [];
        // Lấy tất cả ví dụ trong thẻ .x
        var exampleElements = senseEl.querySelectorAll('.x');
        for (var exEl in exampleElements) {
          String text = exEl.text.trim();
          if (text.isNotEmpty) examples.add(text);
        }

        if (definition.isNotEmpty) {
          senses.add({
            'definition': definition,
            'examples': examples,
          });
        }
      }

      return {
        'word': headword,
        'pos': pos,
        'phonetic': ukMp3,
        'phonetic_text': ukIpa,
        'phonetic_am': usMp3,
        'phonetic_am_text': usIpa,
        'senses': senses,
      };
    }
  } catch (e) {}
  return {};
}
