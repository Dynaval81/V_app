import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/glass_kit.dart';
import '../theme_provider.dart';

class VTalkCompactInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback? onEmojiTap;
  final VoidCallback? onAttachTap;
  final VoidCallback? onCameraTap;
  final VoidCallback? onMicTap;
  final bool isMicMode;

  const VTalkCompactInput({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.onEmojiTap,
    this.onAttachTap,
    this.onCameraTap,
    this.onMicTap,
    this.isMicMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Поле ввода с иконками ВНУТРИ (одна строка, высота контролируется)
            Expanded(
              child: GlassKit.liquidGlass(
                radius: 20,
                isDark: isDark,
                opacity: 0.1,
                useBlur: true,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Сообщение...',
                    hintStyle: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.38) : Colors.black.withValues(alpha: 0.38), fontSize: 14),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    // Иконки ВНУТРИ поля
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Эмодзи
                          GestureDetector(
                            onTap: onEmojiTap,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.emoji_emotions_outlined,
                                color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.6),
                                size: 24,
                              ),
                            ),
                          ),
                          // Разделитель
                          Container(
                            width: 1,
                            height: 24,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
                          ),
                          // Прикрепление
                          GestureDetector(
                            onTap: () => _showAttachmentMenu(context, isDark),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.add_circle_outline,
                                color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.6),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: isMicMode ? onMicTap : onSend,
                        child: Icon(
                          isMicMode ? Icons.mic : Icons.send,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  maxLines: 1,
                  minLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true, // Properly handle safe areas
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.50, // Reduced to prevent overflow
      ),
      builder: (context) => GlassKit.liquidGlass(
        radius: 20,
        isDark: isDark,
        opacity: 0.15,
        useBlur: true,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Заголовок
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Прикрепить',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Опции - GridView без Expanded
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                  children: [
                    _buildAttachmentOption(
                      context,
                      Icons.photo_library,
                      'Галерея',
                      () => _pickImage(context),
                      isDark,
                    ),
                    _buildAttachmentOption(
                      context,
                      Icons.camera_alt,
                      'Камера',
                      () => _openCamera(context),
                      isDark,
                    ),
                    _buildAttachmentOption(
                      context,
                      Icons.attach_file,
                      'Файл',
                      () => _pickFile(context),
                      isDark,
                    ),
                    _buildAttachmentOption(
                      context,
                      Icons.location_on,
                      'Место',
                      () => _shareLocation(context),
                      isDark,
                    ),
                    _buildAttachmentOption(
                      context,
                      Icons.poll,
                      'Опрос',
                      () => _createPoll(context),
                      isDark,
                    ),
                    _buildAttachmentOption(
                      context,
                      Icons.contact_page,
                      'Контакт',
                      () => _shareContact(context),
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.54),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.54),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Галерея')),
    );
  }

  Future<void> _openCamera(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Камера')),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Файл')),
    );
  }

  Future<void> _shareLocation(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Геолокация')),
    );
  }

  Future<void> _createPoll(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Создание опроса')),
    );
  }

  Future<void> _shareContact(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Поделиться контактом')),
    );
  }
}
