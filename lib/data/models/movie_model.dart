import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final String originalLanguage;
  final String originalTitle;
  final double popularity;
  final bool adult;
  final bool video;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    required this.originalLanguage,
    required this.originalTitle,
    required this.popularity,
    required this.adult,
    required this.video,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
      adult: json['adult'] ?? false,
      video: json['video'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'genre_ids': genreIds,
      'original_language': originalLanguage,
      'original_title': originalTitle,
      'popularity': popularity,
      'adult': adult,
      'video': video,
    };
  }

  String get fullPosterPath {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get fullBackdropPath {
    if (backdropPath == null) return '';
    return 'https://image.tmdb.org/t/p/w1280$backdropPath';
  }

  // Getters المفقودة
  String get formattedRating {
    return voteAverage.toStringAsFixed(1);
  }

  String get year {
    if (releaseDate.isEmpty) return '';
    try {
      return DateTime.parse(releaseDate).year.toString();
    } catch (e) {
      return '';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        overview,
        posterPath,
        backdropPath,
        releaseDate,
        voteAverage,
        voteCount,
        genreIds,
        originalLanguage,
        originalTitle,
        popularity,
        adult,
        video,
      ];

  @override
  String toString() => 'Movie(id: $id, title: $title)';
}

// Movie Details Model
class MovieDetails {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<Genre> genres;
  final String originalLanguage;
  final String originalTitle;
  final double popularity;
  final bool adult;
  final bool video;
  final int? budget;
  final String? homepage;
  final String? imdbId;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final int? revenue;
  final int? runtime;
  final List<SpokenLanguage> spokenLanguages;
  final String status;
  final String? tagline;

  const MovieDetails({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genres,
    required this.originalLanguage,
    required this.originalTitle,
    required this.popularity,
    required this.adult,
    required this.video,
    this.budget,
    this.homepage,
    this.imdbId,
    required this.productionCompanies,
    required this.productionCountries,
    this.revenue,
    this.runtime,
    required this.spokenLanguages,
    required this.status,
    this.tagline,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      genres: (json['genres'] as List<dynamic>? ?? [])
          .map((genre) => Genre.fromJson(genre))
          .toList(),
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
      adult: json['adult'] ?? false,
      video: json['video'] ?? false,
      budget: json['budget'],
      homepage: json['homepage'],
      imdbId: json['imdb_id'],
      productionCompanies:
          (json['production_companies'] as List<dynamic>? ?? [])
              .map((company) => ProductionCompany.fromJson(company))
              .toList(),
      productionCountries:
          (json['production_countries'] as List<dynamic>? ?? [])
              .map((country) => ProductionCountry.fromJson(country))
              .toList(),
      revenue: json['revenue'],
      runtime: json['runtime'],
      spokenLanguages: (json['spoken_languages'] as List<dynamic>? ?? [])
          .map((language) => SpokenLanguage.fromJson(language))
          .toList(),
      status: json['status'] ?? '',
      tagline: json['tagline'],
    );
  }

  String get fullPosterPath {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get fullBackdropPath {
    if (backdropPath == null) return '';
    return 'https://image.tmdb.org/t/p/w1280$backdropPath';
  }

  // Getters المفقودة
  String get formattedRating {
    return voteAverage.toStringAsFixed(1);
  }

  String get year {
    if (releaseDate.isEmpty) return '';
    try {
      return DateTime.parse(releaseDate).year.toString();
    } catch (e) {
      return '';
    }
  }

  String get formattedRuntime {
    if (runtime == null || runtime == 0) return '';
    int hours = runtime! ~/ 60;
    int minutes = runtime! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieDetails &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Genre extends Equatable {
  final int id;
  final String name;

  const Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  @override
  List<Object> get props => [id, name];
}

class ProductionCompany {
  final int id;
  final String name;
  final String? logoPath;
  final String? originCountry;

  const ProductionCompany({
    required this.id,
    required this.name,
    this.logoPath,
    this.originCountry,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logoPath: json['logo_path'],
      originCountry: json['origin_country'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionCompany &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ProductionCountry {
  final String iso;
  final String name;

  const ProductionCountry({
    required this.iso,
    required this.name,
  });

  factory ProductionCountry.fromJson(Map<String, dynamic> json) {
    return ProductionCountry(
      iso: json['iso_3166_1'] ?? '',
      name: json['name'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionCountry &&
          runtimeType == other.runtimeType &&
          iso == other.iso;

  @override
  int get hashCode => iso.hashCode;
}

class SpokenLanguage {
  final String iso;
  final String englishName;
  final String name;

  const SpokenLanguage({
    required this.iso,
    required this.englishName,
    required this.name,
  });

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) {
    return SpokenLanguage(
      iso: json['iso_639_1'] ?? '',
      englishName: json['english_name'] ?? '',
      name: json['name'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpokenLanguage &&
          runtimeType == other.runtimeType &&
          iso == other.iso;

  @override
  int get hashCode => iso.hashCode;
}

class Cast {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  const Cast({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
      order: json['order'] ?? 0,
    );
  }

  String get fullProfilePath {
    if (profilePath == null) return '';
    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cast && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Crew {
  final int id;
  final String name;
  final String job;
  final String department;
  final String? profilePath;

  const Crew({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  });

  factory Crew.fromJson(Map<String, dynamic> json) {
    return Crew(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      job: json['job'] ?? '',
      department: json['department'] ?? '',
      profilePath: json['profile_path'],
    );
  }

  String get fullProfilePath {
    if (profilePath == null) return '';
    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Crew && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MovieVideo {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;

  const MovieVideo({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
  });

  factory MovieVideo.fromJson(Map<String, dynamic> json) {
    return MovieVideo(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      site: json['site'] ?? '',
      type: json['type'] ?? '',
      official: json['official'] ?? false,
    );
  }

  String get youtubeUrl {
    if (site.toLowerCase() == 'youtube') {
      return 'https://www.youtube.com/watch?v=$key';
    }
    return '';
  }

  // Getters المفقودة
  bool get isTrailer {
    return type.toLowerCase().contains('trailer');
  }

  bool get isYouTube {
    return site.toLowerCase() == 'youtube';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieVideo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
