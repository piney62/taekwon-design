import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/widgets/tul_app_bar.dart';

enum _Sender { user, ai }

class _Message {
  _Message(this.sender, this.text);
  final _Sender sender;
  final String text;
}

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final _messages = <_Message>[
    _Message(
      _Sender.ai,
      "Annyeong! I'm your training companion. Ask me anything about ITF "
      "Taekwon-Do — patterns, terminology, technique, or what to practice next.",
    ),
  ];
  final _draft = TextEditingController();
  final _scrollCtl = ScrollController();

  @override
  void dispose() {
    _draft.dispose();
    _scrollCtl.dispose();
    super.dispose();
  }

  void _send([String? override]) {
    final text = (override ?? _draft.text).trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(_Sender.user, text));
      _messages.add(_Message(
        _Sender.ai,
        "Great question — let's break it down. The walking stance (앞굽이) puts "
        "70% of your weight on the front leg, which should be bent so the knee "
        "aligns over the toes. Try this drill: hold the stance for 30s on each "
        "side, twice.",
      ));
      _draft.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtl.hasClients) {
        _scrollCtl.animateTo(
          _scrollCtl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Scaffold(
      backgroundColor: palette.stage,
      body: SafeArea(
        child: Column(
          children: [
            TulAppBar(
              title: 'Coach',
              onBack: () => context.pop(),
              action: _IconChip(
                icon: LucideIcons.refreshCw,
                onTap: () {
                  setState(() {
                    _messages
                      ..clear()
                      ..add(_messages.isEmpty
                          ? _Message(_Sender.ai, 'Hi!')
                          : _Message(
                              _Sender.ai,
                              "Annyeong! I'm your training companion. Ask me "
                              "anything about ITF Taekwon-Do.",
                            ));
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollCtl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                itemCount: _messages.length,
                itemBuilder: (context, i) => _Bubble(message: _messages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final s in const [
                          'What should I practice today?',
                          'Explain the 5 tenets',
                          'What is ap kubi stance?',
                          'Improve my Chon-Ji',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _SuggestChip(label: s, onTap: () => _send(s)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _draft,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: 'Ask anything…',
                            fillColor: palette.card,
                            border: OutlineInputBorder(
                              borderRadius: TulRadius.brLg,
                              borderSide: BorderSide(color: palette.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: TulRadius.brLg,
                              borderSide: BorderSide(color: palette.border),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _SendButton(onTap: _send),
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
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final _Message message;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final isUser = message.sender == _Sender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? null : palette.card,
              gradient: isUser ? TulGradients.brand : null,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 6),
                bottomRight: Radius.circular(isUser ? 6 : 16),
              ),
              border: isUser ? null : Border.all(color: palette.border),
            ),
            child: Text(
              message.text,
              style: TulTextStyles.subtitle(
                color: isUser ? Colors.white : palette.text,
              ).copyWith(height: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestChip extends StatelessWidget {
  const _SuggestChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Material(
      color: palette.card,
      borderRadius: TulRadius.brMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: TulRadius.brMd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: TulRadius.brMd,
            border: Border.all(color: palette.border),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TulTextStyles.small(color: palette.text2)),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: TulRadius.brLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: TulRadius.brLg,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: TulGradients.brand,
            borderRadius: TulRadius.brLg,
          ),
          child: const Icon(LucideIcons.send, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Material(
      color: palette.card,
      borderRadius: TulRadius.brMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: TulRadius.brMd,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: TulRadius.brMd,
            border: Border.all(color: palette.border),
          ),
          child: Icon(icon, size: 16, color: palette.text2),
        ),
      ),
    );
  }
}
