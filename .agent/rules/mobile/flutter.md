# Flutter & Dart Development Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Flutter:** 3.19+  
> **Dart:** 3.3+  
> **Priority:** P0 - Load for Flutter projects

---

You are an expert in Flutter and Dart development for building beautiful, natively compiled applications.

## Core Principles

- Everything is a Widget
- Composition over inheritance
- Declarative UI
- State management is key

---

## 1) Project Structure

### Feature-First Architecture
```
lib/
├── main.dart                     # App entry point
├── app/
│   ├── app.dart                  # MaterialApp configuration
│   ├── router/
│   │   ├── router.dart           # go_router setup
│   │   └── routes.dart           # Route definitions
│   └── theme/
│       ├── app_theme.dart
│       ├── colors.dart
│       └── typography.dart
├── core/                         # Shared core code
│   ├── constants/
│   │   └── api_endpoints.dart
│   ├── errors/
│   │   └── failures.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── dio_client.dart
│   ├── utils/
│   │   └── validators.dart
│   └── widgets/                  # Shared widgets
│       ├── app_button.dart
│       ├── app_text_field.dart
│       └── loading_overlay.dart
├── features/                     # Feature modules
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       └── login_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   └── login_screen.dart
│   │       └── widgets/
│   │           └── login_form.dart
│   ├── home/
│   └── profile/
└── l10n/                         # Localization
    ├── app_en.arb
    └── app_vi.arb
```

---

## 2) Dart Fundamentals

### Null Safety & Type System
```dart
// ==========================================
// NULL SAFETY
// ==========================================

// Nullable vs Non-nullable
String name = 'John';      // Cannot be null
String? nickname;          // Can be null

// Null-aware operators
String displayName = nickname ?? 'Anonymous';  // Default value
int? length = nickname?.length;                // Safe access
String upper = nickname!.toUpperCase();        // Assert non-null (use carefully!)

// Late initialization
late final String userId;  // Will be initialized later

void init() {
  userId = 'user-123';
}

// Required named parameters
void createUser({
  required String email,
  required String password,
  String? name,
}) {
  // email and password are required, name is optional
}


// ==========================================
// CLASSES AND CONSTRUCTORS
// ==========================================

class User {
  final String id;
  final String email;
  final String? name;
  final DateTime createdAt;

  // Primary constructor with initializer list
  const User({
    required this.id,
    required this.email,
    this.name,
    required this.createdAt,
  });

  // Named constructor
  User.guest()
      : id = 'guest',
        email = 'guest@example.com',
        name = 'Guest',
        createdAt = DateTime.now();

  // Factory constructor
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'created_at': createdAt.toIso8601String(),
      };

  // copyWith pattern
  User copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}


// ==========================================
// EXTENSIONS
// ==========================================

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}

extension DateTimeExtensions on DateTime {
  String get formatted => '$day/$month/$year';
  
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

// Usage
final name = 'john'.capitalize(); // 'John'
final isValid = 'test@example.com'.isValidEmail; // true


// ==========================================
// ASYNC / AWAIT
// ==========================================

Future<User> fetchUser(String id) async {
  try {
    final response = await dio.get('/users/$id');
    return User.fromJson(response.data);
  } on DioException catch (e) {
    throw ServerException(e.message ?? 'Unknown error');
  }
}

// Parallel execution
Future<void> loadData() async {
  final results = await Future.wait([
    fetchUser('1'),
    fetchProducts(),
    fetchSettings(),
  ]);
  
  final user = results[0] as User;
  final products = results[1] as List<Product>;
  final settings = results[2] as Settings;
}

// Stream handling
Stream<int> countDown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
  }
}
```

### Sealed Classes & Pattern Matching
```dart
// ==========================================
// SEALED CLASSES (Dart 3)
// ==========================================

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;
  const Failure(this.message, [this.exception]);
}

final class Loading<T> extends Result<T> {
  const Loading();
}

// Usage with pattern matching
Widget buildContent(Result<User> result) {
  return switch (result) {
    Success(:final data) => UserCard(user: data),
    Failure(:final message) => ErrorWidget(message: message),
    Loading() => const CircularProgressIndicator(),
  };
}


// ==========================================
// FREEZED (Code generation)
// ==========================================

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? name,
    @Default(false) bool isVerified,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// Freezed gives you:
// - copyWith
// - == and hashCode
// - toString
// - fromJson/toJson (with json_serializable)
// - Immutability
```

---

## 3) Widgets

### Core Widget Patterns
```dart
// ==========================================
// STATELESS WIDGET
// ==========================================

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(user.name?.substring(0, 1) ?? 'U'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? 'Unknown',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      user.email,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}


// ==========================================
// STATEFUL WIDGET WITH HOOKS (flutter_hooks)
// ==========================================

class SearchScreen extends HookConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final debouncer = useDebouncer(duration: const Duration(milliseconds: 500));
    final isFocused = useState(false);
    
    useEffect(() {
      void listener() {
        debouncer.run(() {
          ref.read(searchQueryProvider.notifier).state = searchController.text;
        });
      }
      
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);
    
    final results = ref.watch(searchResultsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
        ),
      ),
      body: results.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(items[index].name),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}


// ==========================================
// REUSABLE COMPONENTS
// ==========================================

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      height: 48,
      child: switch (variant) {
        ButtonVariant.primary => FilledButton(
            onPressed: isLoading ? null : onPressed,
            child: _buildChild(theme),
          ),
        ButtonVariant.secondary => OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: _buildChild(theme),
          ),
        ButtonVariant.text => TextButton(
            onPressed: isLoading ? null : onPressed,
            child: _buildChild(theme),
          ),
      },
    );
  }

  Widget _buildChild(ThemeData theme) {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }
    
    return Text(label);
  }
}

enum ButtonVariant { primary, secondary, text }


// ==========================================
// TEXT FIELD WITH VALIDATION
// ==========================================

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
```

---

## 4) State Management (Riverpod)

### Provider Setup
```dart
// ==========================================
// RIVERPOD PROVIDERS
// ==========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

// Simple provider
@riverpod
String greeting(GreetingRef ref) {
  return 'Hello, World!';
}

// Provider with parameter
@riverpod
Future<User> user(UserRef ref, String id) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUser(id);
}

// Notifier (mutable state)
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

// Async Notifier
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    return _checkAuthState();
  }

  Future<User?> _checkAuthState() async {
    final token = await ref.read(storageProvider).getToken();
    if (token == null) return null;
    
    try {
      return await ref.read(authRepositoryProvider).getProfile();
    } catch (e) {
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).login(email, password);
      return user;
    });
  }

  Future<void> logout() async {
    await ref.read(storageProvider).clearToken();
    state = const AsyncData(null);
  }
}


// ==========================================
// REPOSITORY PROVIDER
// ==========================================

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await ref.read(storageProvider).getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) {
      if (error.response?.statusCode == 401) {
        ref.read(authNotifierProvider.notifier).logout();
      }
      handler.next(error);
    },
  ));

  return dio;
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
ProductRepository productRepository(ProductRepositoryRef ref) {
  return ProductRepositoryImpl(ref.watch(dioProvider));
}


// ==========================================
// USING PROVIDERS IN WIDGETS
// ==========================================

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: authState.maybeWhen(
          data: (user) => Text('Welcome, ${user?.name ?? 'Guest'}'),
          orElse: () => const Text('Home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: products.when(
        data: (items) => ProductGrid(products: items),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(productsProvider),
        ),
      ),
    );
  }
}
```

---

## 5) Navigation (go_router)

### Router Configuration
```dart
// ==========================================
// GO_ROUTER SETUP
// ==========================================

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'router.g.dart';

// Route constants
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const productDetails = '/products/:id';
  static const profile = '/profile';
  static const settings = '/settings';
}

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authNotifierProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    
    // Redirect logic
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == AppRoutes.login ||
                          state.matchedLocation == AppRoutes.signup;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      
      // Still loading auth state
      if (authState.isLoading && isSplash) {
        return null;
      }
      
      // Not logged in and not on auth screen
      if (!isLoggedIn && !isLoggingIn) {
        return AppRoutes.login;
      }
      
      // Logged in but on auth screen
      if (isLoggedIn && (isLoggingIn || isSplash)) {
        return AppRoutes.home;
      }
      
      return null;
    },
    
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'products/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProductDetailsScreen(productId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    
    // Error page
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
}


// ==========================================
// SHELL WITH BOTTOM NAVIGATION
// ==========================================

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
            case 1:
              context.go('/search');
            case 2:
              context.go(AppRoutes.profile);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}


// ==========================================
// NAVIGATION USAGE
// ==========================================

// Navigate to route
context.go('/home');

// Push (adds to stack)
context.push('/products/123');

// Go back
context.pop();

// Replace
context.replace('/login');

// With extra data
context.push('/products/123', extra: product);

// Access extra in destination
final product = GoRouterState.of(context).extra as Product?;
```

---

## 6) Animations

### Implicit & Explicit Animations
```dart
// ==========================================
// IMPLICIT ANIMATIONS
// ==========================================

class AnimatedCard extends StatelessWidget {
  final bool isSelected;
  final Widget child;

  const AnimatedCard({
    super.key,
    required this.isSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.2 : 0.1),
            blurRadius: isSelected ? 20 : 10,
            offset: Offset(0, isSelected ? 10 : 5),
          ),
        ],
      ),
      child: child,
    );
  }
}


// ==========================================
// EXPLICIT ANIMATIONS
// ==========================================

class PulsingDot extends StatefulWidget {
  final Color color;

  const PulsingDot({super.key, required this.color});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              ),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}


// ==========================================
// HERO ANIMATION
// ==========================================

// Source
Hero(
  tag: 'product-${product.id}',
  child: Image.network(product.imageUrl),
)

// Destination
Hero(
  tag: 'product-${product.id}',
  child: Image.network(product.imageUrl),
)


// ==========================================
// STAGGERED ANIMATIONS
// ==========================================

class StaggeredList extends StatefulWidget {
  final List<Widget> children;

  const StaggeredList({super.key, required this.children});

  @override
  State<StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<StaggeredList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100 * widget.children.length),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.children.length, (index) {
        final start = index / widget.children.length;
        final end = (index + 1) / widget.children.length;
        
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOut),
          )),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(start, end),
              ),
            ),
            child: widget.children[index],
          ),
        );
      }),
    );
  }
}
```

---

## 7) Testing

### Widget & Integration Tests
```dart
// ==========================================
// WIDGET TESTS
// ==========================================

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginScreen', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    Widget createWidget() {
      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    testWidgets('shows validation errors for empty fields', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('calls login on valid submission', (tester) async {
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => User(id: '1', email: 'test@example.com'));

      await tester.pumpWidget(createWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.login('test@example.com', 'password123'))
          .called(1);
    });

    testWidgets('shows loading indicator during login', (tester) async {
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return User(id: '1', email: 'test@example.com');
      });

      await tester.pumpWidget(createWidget());

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}


// ==========================================
// INTEGRATION TESTS
// ==========================================

// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('complete login flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should be on login screen
      expect(find.text('Login'), findsOneWidget);

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Tap login
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Should be on home screen
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
```

---

## Best Practices Checklist

### Code Quality
- [ ] Use const constructors
- [ ] Follow Dart style guide
- [ ] Enable strict analysis
- [ ] Use code generation (freezed, riverpod_generator)

### Performance
- [ ] Avoid rebuild with const
- [ ] Use ListView.builder
- [ ] Profile with DevTools
- [ ] Minimize widget depth

### Architecture
- [ ] Feature-first structure
- [ ] Clean separation of concerns
- [ ] Repository pattern
- [ ] Proper error handling

### Testing
- [ ] Widget tests for UI
- [ ] Unit tests for logic
- [ ] Integration tests for flows
- [ ] Golden tests for visuals

---

**References:**
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Riverpod](https://riverpod.dev/)
- [go_router](https://pub.dev/packages/go_router)
