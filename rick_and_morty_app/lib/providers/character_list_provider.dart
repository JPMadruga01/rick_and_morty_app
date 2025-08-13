import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_model.dart';
import '../services/api_service.dart';
import '../repositories/character_repository.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final characterRepositoryProvider = Provider<CharacterRepository>(
    (ref) => CharacterRepository(ref.watch(apiServiceProvider)));

final characterListProvider =
    StateNotifierProvider<CharacterListNotifier, CharacterListState>((ref) {
  final repo = ref.watch(characterRepositoryProvider);
  return CharacterListNotifier(repo);
});

class CharacterListState {
  final List<Character> items;
  final bool isLoading;
  final String? nextPageUrl;
  final String? query;
  final String? error;

  const CharacterListState({
    required this.items,
    this.isLoading = false,
    this.nextPageUrl,
    this.query,
    this.error,
  });

  CharacterListState copyWith({
    List<Character>? items,
    bool? isLoading,
    String? nextPageUrl,
    String? query,
    String? error,
  }) {
    return CharacterListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      nextPageUrl: nextPageUrl ?? this.nextPageUrl,
      query: query ?? this.query,
      error: error,
    );
  }

  factory CharacterListState.initial() => const CharacterListState(items: []);
}

class CharacterListNotifier extends StateNotifier<CharacterListState> {
  final CharacterRepository repo;
  Timer? _debounce;
  int _searchId = 0;

  CharacterListNotifier(this.repo) : super(CharacterListState.initial()) {
    _performSearch('');
  }

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final id = ++_searchId;
    state =
        state.copyWith(isLoading: true, items: [], query: query, error: null);
    try {
      final page = await repo.list(name: query.isEmpty ? null : query);
      if (id != _searchId) return;
      state = state.copyWith(
        items: page.results,
        nextPageUrl: page.nextPageUrl,
        isLoading: false,
      );
    } catch (e) {
      if (id != _searchId) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.nextPageUrl == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final page = await repo.list(pageUrl: state.nextPageUrl);
      state = state.copyWith(
        items: [...state.items, ...page.results],
        nextPageUrl: page.nextPageUrl,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
