import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../models/character_model.dart';
import '../models/episode_model.dart';
import '../pages/character_detail_page.dart';
import '../services/api_service.dart';

class CharacterCard extends StatefulWidget {
  final Character character;
  final ApiService api;

  const CharacterCard({super.key, required this.character, required this.api});

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard>
    with SingleTickerProviderStateMixin {
  bool _hover = false; // web/desktop
  bool _expandedMobile = false; // mobile fallback
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 220));
  late final Animation<double> _curve =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

  Future<Episode>? _firstEpisodeFuture;

  void _ensureFirstEpisodeLoaded() {
    if (_firstEpisodeFuture != null) return;
    final urls = widget.character.episodeUrls;
    if (urls.isEmpty) return;
    _firstEpisodeFuture = widget.api.fetchEpisodeByUrl(urls.first);
    setState(() {});
  }

  void _setExpanded(bool value) {
    setState(() {
      _hover = value;
      if (value || _expandedMobile) {
        _ctrl.forward();
        _ensureFirstEpisodeLoaded();
      } else {
        _ctrl.reverse();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Tokens.radius),
          child: Image.network(
            c.image,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: Tokens.gap),
        Expanded(
          child: Text(
            c.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Tokens.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        const Icon(Icons.chevron_right, color: Tokens.textSecondary),
      ],
    );

    final details = SizeTransition(
      sizeFactor: _curve,
      axisAlignment: -1.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: DefaultTextStyle(
          style: const TextStyle(color: Tokens.textSecondary, height: 1.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _info('Espécie', c.species),
              _info('Status', c.status),
              _info('Gênero', c.gender),
              _info('Origem', c.originName),
              _info('Local atual', c.locationName),
              FutureBuilder<Episode>(
                future: _firstEpisodeFuture,
                builder: (context, snap) {
                  String value;
                  if (_firstEpisodeFuture == null) {
                    value = '—';
                  } else if (snap.connectionState == ConnectionState.waiting) {
                    value = 'carregando...';
                  } else if (snap.hasError || !snap.hasData) {
                    value = 'erro ao carregar';
                  } else {
                    final ep = snap.data!;
                    value = '${ep.name} (${ep.code})';
                  }
                  return _info('Primeira aparição', value);
                },
              ),
            ],
          ),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => _setExpanded(true),
      onExit: (_) => _setExpanded(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CharacterDetailPage(character: c, api: widget.api),
            ),
          );
        },
        onLongPress: () {
          setState(() => _expandedMobile = !_expandedMobile);
          _setExpanded(_expandedMobile);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Tokens.cardBlue,
            borderRadius: BorderRadius.circular(Tokens.radius),
            boxShadow: _hover
                ? const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [header, details],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
