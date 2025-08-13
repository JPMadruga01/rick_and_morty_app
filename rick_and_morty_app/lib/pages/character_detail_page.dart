import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../models/character_model.dart';
import '../models/episode_model.dart';
import '../services/api_service.dart';

class CharacterDetailPage extends StatefulWidget {
  final Character character;
  final ApiService api;

  const CharacterDetailPage(
      {super.key, required this.character, required this.api});

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  Future<Episode>? _firstEpisodeFuture;

  @override
  void initState() {
    super.initState();
    if (widget.character.episodeUrls.isNotEmpty) {
      _firstEpisodeFuture =
          widget.api.fetchEpisodeByUrl(widget.character.episodeUrls.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;
    return Scaffold(
      appBar: AppBar(title: Text(c.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Tokens.radius),
                child: Image.network(c.image,
                    width: 220, height: 220, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            _block(label: 'Nome', value: c.name),
            _block(label: 'Status', value: c.status),
            _block(label: 'Espécie', value: c.species),
            _block(label: 'Gênero', value: c.gender),
            _block(label: 'Origem', value: c.originName),
            _block(label: 'Local atual', value: c.locationName),
            FutureBuilder<Episode>(
              future: _firstEpisodeFuture,
              builder: (context, snap) {
                String v;
                if (_firstEpisodeFuture == null) {
                  v = '—';
                } else if (snap.connectionState == ConnectionState.waiting) {
                  v = 'carregando...';
                } else if (snap.hasError || !snap.hasData) {
                  v = 'erro ao carregar';
                } else {
                  final ep = snap.data!;
                  v = '${ep.name} (${ep.code})';
                }
                return _block(label: 'Primeira aparição', value: v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _block({required String label, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Tokens.cardBlue,
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: Tokens.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Tokens.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
