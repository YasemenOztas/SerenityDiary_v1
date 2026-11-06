import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serenity_diary/models/notebook.dart';
import 'package:serenity_diary/providers/notebooks/notebooks_provider.dart';
import 'package:serenity_diary/screens/notebooks/notebook_detail_screen.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

// Predefined fairycore colors for notebooks
const _kColors = [
  '#BF9B7A', '#8FA67A', '#B8A8C8', '#E8C5C5',
  '#ADD8C7', '#D4A853', '#D4829A', '#7A9BB8',
];

// Predefined emojis for notebooks
const _kEmojis = [
  '🍄', '🌿', '📋', '🌸', '🦋', '⭐', '🍃', '🌙',
  '🎨', '📚', '🌺', '🪄', '🍵', '🌾', '🦚', '🪶',
];

class NotebooksScreen extends StatefulWidget {
  const NotebooksScreen({super.key});

  @override
  State<NotebooksScreen> createState() => _NotebooksScreenState();
}

class _NotebooksScreenState extends State<NotebooksScreen> {
  // ── Add / Edit dialog ──────────────────────────────────────────

  void _showNotebookDialog(BuildContext context, {Notebook? editing}) {
    final nameCtrl =
        TextEditingController(text: editing?.name ?? '');
    String selectedEmoji = editing?.emoji ?? _kEmojis[0];
    String selectedColor = editing?.colorHex ?? _kColors[0];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: FairyTheme.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: FairyTheme.gold.withOpacity(0.4)),
          ),
          title: Row(
            children: [
              Text(selectedEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                editing == null ? 'Yeni Defter' : 'Defteri Düzenle',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: FairyTheme.inkBrown,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name field
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  style: GoogleFonts.nunito(
                      color: FairyTheme.inkBrown, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Defter adı...',
                    hintStyle: GoogleFonts.nunito(
                        color: FairyTheme.lightBrown.withOpacity(0.5)),
                    filled: true,
                    fillColor: FairyTheme.parchment,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: FairyTheme.gold.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: FairyTheme.goldDark, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Emoji picker
                Text('Emoji',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: FairyTheme.medBrown)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _kEmojis.map((e) {
                    final isSel = e == selectedEmoji;
                    return GestureDetector(
                      onTap: () =>
                          setDialogState(() => selectedEmoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSel
                              ? FairyTheme.lavender.withOpacity(0.6)
                              : FairyTheme.parchment,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel
                                ? FairyTheme.lavenderDark
                                : FairyTheme.parchmentDark,
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child:
                              Text(e, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Color picker
                Text('Renk',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: FairyTheme.medBrown)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _kColors.map((hex) {
                    final color = Color(
                        int.parse(hex.replaceFirst('#', '0xFF')));
                    final isSel = hex == selectedColor;
                    return GestureDetector(
                      onTap: () =>
                          setDialogState(() => selectedColor = hex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel
                                ? FairyTheme.inkBrown
                                : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 6,
                                  )
                                ]
                              : null,
                        ),
                        child: isSel
                            ? Icon(Icons.check_rounded,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('İptal',
                  style:
                      GoogleFonts.nunito(color: FairyTheme.lightBrown)),
            ),
            TextButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final provider = context.read<NotebooksProvider>();
                if (editing == null) {
                  provider.addNotebook(Notebook(
                    name: name,
                    emoji: selectedEmoji,
                    colorHex: selectedColor,
                    createdAt: DateTime.now(),
                  ));
                } else {
                  provider.updateNotebook(Notebook(
                    id: editing.id,
                    name: name,
                    emoji: selectedEmoji,
                    colorHex: selectedColor,
                    createdAt: editing.createdAt,
                  ));
                }
                Navigator.pop(ctx);
              },
              child: Text(
                editing == null ? 'Oluştur' : 'Kaydet',
                style: GoogleFonts.nunito(
                    color: FairyTheme.goldDark,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Notebook nb) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FairyTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: FairyTheme.gold.withOpacity(0.4)),
        ),
        title: Text('🗑️ Defteri Sil',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FairyTheme.inkBrown)),
        content: Text(
          '"${nb.name}" defterini ve içindeki tüm notları silmek istediğine emin misin?',
          style: GoogleFonts.nunito(color: FairyTheme.medBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hayır',
                style: GoogleFonts.nunito(color: FairyTheme.lightBrown)),
          ),
          TextButton(
            onPressed: () {
              context.read<NotebooksProvider>().deleteNotebook(nb.id!);
              Navigator.pop(ctx);
            },
            child: Text('Evet, Sil',
                style: GoogleFonts.nunito(
                    color: FairyTheme.berryPink,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B7D58),
              FairyTheme.bgSage,
              Color(0xFF8A9B76),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FairyTheme.cardSurface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: FairyTheme.gold.withOpacity(0.4)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: FairyTheme.inkBrown),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Text('📚', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text('Defterlerim',
                            style: GoogleFonts.dancingScript(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: FairyTheme.cream)),
                      ],
                    ),
                    const Spacer(),
                    // Add button
                    GestureDetector(
                      onTap: () =>
                          _showNotebookDialog(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FairyTheme.gold,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: FairyTheme.goldDark.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.add_rounded,
                            size: 20, color: FairyTheme.cream),
                      ),
                    ),
                  ],
                ),
              ),

              // Grid
              Expanded(
                child: Consumer<NotebooksProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return Center(
                          child: CircularProgressIndicator());
                    }
                    if (provider.notebooks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📖',
                                style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text('Henüz defter yok',
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 16,
                                    color: FairyTheme.cream,
                                    fontStyle: FontStyle.italic)),
                            const SizedBox(height: 6),
                            Text('+ butonuna basarak defter oluştur',
                                style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    color: FairyTheme.cream
                                        .withOpacity(0.7))),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: provider.notebooks.length,
                      itemBuilder: (context, i) {
                        final nb = provider.notebooks[i];
                        return _NotebookCard(
                          notebook: nb,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  NotebookDetailScreen(notebook: nb),
                            ),
                          ),
                          onEdit: () =>
                              _showNotebookDialog(context, editing: nb),
                          onDelete: () =>
                              _showDeleteConfirm(context, nb),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotebookCard extends StatelessWidget {
  final Notebook notebook;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NotebookCard({
    required this.notebook,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = notebook.color;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showOptions(context),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: FairyTheme.inkBrown.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Book spine
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor.withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                  border: Border(
                    right: BorderSide(
                        color: FairyTheme.inkBrown.withOpacity(0.1)),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notebook.emoji,
                      style: const TextStyle(fontSize: 36)),
                  const Spacer(),
                  Text(
                    notebook.name,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: FairyTheme.cream,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Long press hint
                  Row(
                    children: [
                      Icon(Icons.touch_app_rounded,
                          size: 10,
                          color: FairyTheme.cream.withOpacity(0.6)),
                      const SizedBox(width: 3),
                      Text('uzun bas',
                          style: GoogleFonts.nunito(
                            fontSize: 9,
                            color: FairyTheme.cream.withOpacity(0.6),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: FairyTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: FairyTheme.parchmentDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(notebook.emoji,
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(notebook.name,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: FairyTheme.inkBrown)),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.edit_rounded, color: FairyTheme.medBrown),
                title: Text('Düzenle',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600,
                        color: FairyTheme.inkBrown)),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded,
                    color: FairyTheme.berryPink),
                title: Text('Sil',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600,
                        color: FairyTheme.berryPink)),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
