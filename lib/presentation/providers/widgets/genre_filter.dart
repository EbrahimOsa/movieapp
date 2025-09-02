import 'package:flutter/material.dart';

class GenreModel {
  final int id;
  final String name;
  final String emoji;

  const GenreModel({
    required this.id,
    required this.name,
    required this.emoji,
  });
}

class GenreFilter extends StatefulWidget {
  final List<GenreModel> genres;
  final List<int> selectedGenreIds;
  final Function(List<int>) onSelectionChanged;

  const GenreFilter({
    super.key,
    required this.genres,
    required this.selectedGenreIds,
    required this.onSelectionChanged,
  });

  @override
  State<GenreFilter> createState() => _GenreFilterState();
}

class _GenreFilterState extends State<GenreFilter> {
  late List<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedGenreIds);
  }

  void _toggleGenre(int genreId) {
    setState(() {
      if (_selectedIds.contains(genreId)) {
        _selectedIds.remove(genreId);
      } else {
        _selectedIds.add(genreId);
      }
    });
    widget.onSelectionChanged(_selectedIds);
  }

  void _clearAll() {
    setState(() {
      _selectedIds.clear();
    });
    widget.onSelectionChanged(_selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filter by Genre',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (_selectedIds.isNotEmpty)
                TextButton(
                  onPressed: _clearAll,
                  child: const Text('Clear All'),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Selected count
          if (_selectedIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedIds.length} genre${_selectedIds.length == 1 ? '' : 's'} selected',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          if (_selectedIds.isNotEmpty) const SizedBox(height: 12),

          // Genre chips
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.genres.map((genre) {
                  final isSelected = _selectedIds.contains(genre.id);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: FilterChip(
                      selected: isSelected,
                      onSelected: (_) => _toggleGenre(genre.id),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(genre.emoji),
                          const SizedBox(width: 4),
                          Text(genre.name),
                        ],
                      ),
                      selectedColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pre-defined genres with emojis
class MovieGenres {
  static const List<GenreModel> predefined = [
    GenreModel(id: 28, name: 'Action', emoji: '💥'),
    GenreModel(id: 12, name: 'Adventure', emoji: '🗺️'),
    GenreModel(id: 16, name: 'Animation', emoji: '🎨'),
    GenreModel(id: 35, name: 'Comedy', emoji: '😂'),
    GenreModel(id: 80, name: 'Crime', emoji: '🔍'),
    GenreModel(id: 99, name: 'Documentary', emoji: '📹'),
    GenreModel(id: 18, name: 'Drama', emoji: '🎭'),
    GenreModel(id: 10751, name: 'Family', emoji: '👨‍👩‍👧‍👦'),
    GenreModel(id: 14, name: 'Fantasy', emoji: '🧙‍♂️'),
    GenreModel(id: 36, name: 'History', emoji: '📚'),
    GenreModel(id: 27, name: 'Horror', emoji: '👻'),
    GenreModel(id: 10402, name: 'Music', emoji: '🎵'),
    GenreModel(id: 9648, name: 'Mystery', emoji: '🔮'),
    GenreModel(id: 10749, name: 'Romance', emoji: '💕'),
    GenreModel(id: 878, name: 'Sci-Fi', emoji: '🚀'),
    GenreModel(id: 10770, name: 'TV Movie', emoji: '📺'),
    GenreModel(id: 53, name: 'Thriller', emoji: '😰'),
    GenreModel(id: 10752, name: 'War', emoji: '⚔️'),
    GenreModel(id: 37, name: 'Western', emoji: '🤠'),
  ];

  static GenreModel? getGenreById(int id) {
    try {
      return predefined.firstWhere((genre) => genre.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<GenreModel> getGenresByIds(List<int> ids) {
    return ids
        .map((id) => getGenreById(id))
        .where((genre) => genre != null)
        .cast<GenreModel>()
        .toList();
  }
}
