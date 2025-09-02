# Contributing to MovieVerse 🎬

First off, thank you for considering contributing to MovieVerse! It's people like you that make MovieVerse such a great tool for movie enthusiasts.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Style Guidelines](#style-guidelines)
- [Commit Messages](#commit-messages)
- [Pull Requests](#pull-requests)

## 📜 Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, sex characteristics, gender identity and expression, level of experience, education, socio-economic status, nationality, personal appearance, race, religion, or sexual identity and orientation.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Git
- A code editor (VS Code, Android Studio, or IntelliJ)
- TMDB API key (free registration required)

### First Time Setup

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/movieverse.git
   cd movieverse
   ```
3. **Add the upstream repository**:
   ```bash
   git remote add upstream https://github.com/original-owner/movieverse.git
   ```
4. **Install dependencies**:
   ```bash
   flutter pub get
   ```
5. **Set up your API key** in `.env` file
6. **Run the app** to make sure everything works:
   ```bash
   flutter run
   ```

## 🤝 How Can I Contribute?

### 🐛 Reporting Bugs

Before creating bug reports, please check the issue list as you might find that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed and what behavior you expected**
- **Include screenshots if applicable**
- **Specify Flutter/Dart version and platform**

### 💡 Suggesting Features

Feature suggestions are welcome! Please provide:

- **Clear and descriptive title**
- **Detailed description of the feature**
- **Use cases and examples**
- **Mockups or wireframes if applicable**
- **Consider the scope and complexity**

### 💻 Code Contributions

#### Types of Contributions We're Looking For

- **Bug fixes**
- **New features**
- **Performance improvements**
- **UI/UX enhancements**
- **Documentation improvements**
- **Test coverage improvements**
- **Accessibility improvements**

## 🛠️ Development Setup

### Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── cache/              # Caching utilities
│   ├── config/             # App configuration
│   ├── constants/          # Constants and themes
│   └── database/           # Local database
├── data/                   # Data layer
│   └── models/            # Data models and API services
└── presentation/          # UI layer
    ├── providers/         # State management
    ├── screens/          # App screens
    └── widgets/          # Reusable UI components
```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Building for Release

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 📝 Style Guidelines

### Dart Code Style

We follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style):

- Use `lowerCamelCase` for variables, methods, and parameters
- Use `UpperCamelCase` for classes, enums, and typedefs
- Use `lowercase_with_underscores` for libraries and source files
- Prefer `final` over `var` when possible
- Use meaningful names for variables and functions

### Code Organization

- **Group imports**: dart, flutter, third-party, then relative
- **Order class members**: constructors, public methods, private methods
- **Use meaningful comments** for complex logic
- **Extract reusable widgets** into separate files
- **Keep methods small** and focused on a single responsibility

### Example:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../services/api_service.dart';

class MovieProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Movie> _movies = [];
  bool _isLoading = false;

  MovieProvider(this._apiService);

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;

  Future<void> fetchMovies() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _movies = await _apiService.getPopularMovies();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## 📝 Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/) specification:

### Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (formatting, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to build process or auxiliary tools

### Examples
```bash
feat(search): add advanced search filters

fix(favorites): resolve duplicate entries in favorites list

docs(readme): update installation instructions

style(theme): improve dark theme color scheme

refactor(api): simplify movie data fetching logic

perf(images): optimize image caching mechanism

test(search): add unit tests for search functionality

chore(deps): update dependencies to latest versions
```

## 🔄 Pull Requests

### Before Submitting

1. **Check the issue tracker** for existing discussions
2. **Create an issue** for major changes to discuss approach
3. **Fork the repository** and create a branch from `main`
4. **Make your changes** following the style guidelines
5. **Add tests** if applicable
6. **Update documentation** if needed
7. **Run tests** and ensure they pass
8. **Test on both Android and iOS** if possible

### Pull Request Process

1. **Create a clear title** following conventional commit format
2. **Provide detailed description** of changes
3. **Reference related issues** using keywords like "fixes #123"
4. **Add screenshots** for UI changes
5. **Ensure CI checks pass**
6. **Respond to review feedback** promptly

### Pull Request Template

```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] I have run existing tests and they pass
- [ ] I have tested on both Android and iOS (if applicable)

## Screenshots (if applicable)
Add screenshots to help explain your changes.

## Checklist
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] My changes generate no new warnings
- [ ] Any dependent changes have been merged and published
```

## 🏷️ Issue Labels

We use labels to help organize and prioritize issues:

- **bug**: Something isn't working
- **enhancement**: New feature or request
- **documentation**: Improvements or additions to documentation
- **good first issue**: Good for newcomers
- **help wanted**: Extra attention is needed
- **priority-high**: High priority issue
- **priority-low**: Low priority issue
- **ui/ux**: User interface and experience related

## 🎉 Recognition

Contributors will be recognized in:

- README.md contributors section
- Release notes for significant contributions
- Special mention in app credits

## ❓ Questions?

Don't hesitate to ask questions by:

- Opening an issue with the "question" label
- Reaching out to maintainers directly
- Joining our community discussions

---

Thank you for contributing to MovieVerse! 🎬✨
