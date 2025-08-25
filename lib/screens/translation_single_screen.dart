import 'package:flutter/material.dart';
import '../models/translation_request.dart';
import '../services/translation_service.dart';
import '../utils/exceptions.dart';
import '../widgets/translation_single/language_selector.dart';
import '../widgets/translation_single/translation_input.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  
  bool _isLoading = false;
  String _sourceLang = 'en';
  String _targetLang = 'sr';
  String _errorMessage = '';
  
  late final TranslationService _translationService;

  @override
  void initState() {
    super.initState();
    _translationService = TranslationService();
  }

  @override
  void dispose() {
    _textController.dispose();
    _translationController.dispose();
    _translationService.dispose();
    super.dispose();
  }

  Future<void> _translateText() async {
    if (_textController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter text to translate';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _translationController.clear();
    });

    try {
      final request = TranslationRequest(
        text: _textController.text,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
      );

      final response = await _translationService.translate(request);
      
      setState(() {
        _translationController.text = response.translation;
      });
    } on TranslationException catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
      _textController.text = _translationController.text;
      _translationController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Language selector
            Row(
              children: [
                Expanded(
                  child: LanguageSelector(
                    value: _sourceLang,
                    onChanged: (value) {
                      setState(() {
                        _sourceLang = value!;
                      });
                    },
                    label: 'Source Language',
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _swapLanguages,
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Swap Languages',
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LanguageSelector(
                    value: _targetLang,
                    onChanged: (value) {
                      setState(() {
                        _targetLang = value!;
                      });
                    },
                    label: 'Target Language',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Input text field
            TranslationInput(
              controller: _textController,
              label: 'Enter text to translate',
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            
            // Translate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _translateText,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text('Translating...'),
                        ],
                      )
                    : const Text('Translate', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Error message
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            
            // Translation result
            Expanded(
              child: TranslationInput(
                controller: _translationController,
                label: 'Translation',
                maxLines: 0,
                readOnly: true,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}