import '../models/character_model.dart';
import '../models/episode_model.dart';
import '../services/api_service.dart';

class CharacterRepository {
  final ApiService api;
  CharacterRepository(this.api);

  Future<CharactersPage> list({String? name, String? pageUrl}) {
    return api.fetchCharactersPaginated(name: name, pageUrl: pageUrl);
  }

  Future<Episode> firstEpisode(String url) => api.fetchEpisodeByUrl(url);
}

class CharactersPage {
  final List<Character> results;
  final String? nextPageUrl;
  CharactersPage({required this.results, this.nextPageUrl});
}
