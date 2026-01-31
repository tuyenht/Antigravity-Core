---
technology: Flutter
version: 3.x
last_updated: 2026-01-16
official_docs: https://flutter.dev
---

# Flutter - Best Practices & Conventions

**Version:** Flutter 3.x + Dart 3.x  
**Updated:** 2026-01-16  
**Source:** Official Flutter docs + community best practices

---

## Overview

Flutter is Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase using the Dart programming language.

---

## Project Structure

```
my_app/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── screens/
│   ├── widgets/
│   ├── providers/          # State management
│   ├── services/           # API, storage
│   └── utils/
├── test/
├── assets/
│   ├── images/
│   └── fonts/
└── pubspec.yaml
```

---

## Widget Patterns

### Stateless Widget

```dart
class MyWidget extends StatelessWidget {
  final String title;
  final int count;
  
  const MyWidget({
    super.key,
    required this.title,
    this.count = 0,
  });
  
  @override
  Widget build(BuildContext context) {
    return Text('$title: $count');
  }
}
```

### Stateful Widget

```dart
class Counter extends StatefulWidget {
  const Counter({super.key});
  
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;
  
  void _increment() {
    setState(() {
      _count++;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_count'),
        ElevatedButton(
          onPressed: _increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

---

## State Management (Riverpod)

### Provider Definition

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple state
final counterProvider = StateProvider<int>((ref) => 0);

// Async state
final userProvider = FutureProvider<User>((ref) async {
  final response = await http.get(Uri.parse('/api/user'));
  return User.fromJson(jsonDecode(response.body));
});

// StateNotifier for complex state
class TodosNotifier extends StateNotifier<List<Todo>> {
  TodosNotifier() : super([]);
  
  void addTodo(Todo todo) {
    state = [...state, todo];
  }
  
  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }
}

final todosProvider = StateNotifierProvider<TodosNotifier, List<Todo>>(
  (ref) => TodosNotifier(),
);
```

### Consumer Widget

```dart
class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    
    return Text('Count: $count');
  }
}

// Or use Consumer
Consumer(
  builder: (context, ref, child) {
    final count = ref.watch(counterProvider);
    return Text('Count: $count');
  },
)
```

---

## Navigation

### Named Routes

```dart
MaterialApp(
  routes: {
    '/': (context) => const HomeScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/settings': (context) => const SettingsScreen(),
  },
);

// Navigate
Navigator.pushNamed(context, '/profile');

// With arguments
Navigator.pushNamed(
  context,
  '/profile',
  arguments: {'userId': '123'},
);
```

### Go Router (Recommended)

```dart
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProfileScreen(userId: id);
      },
    ),
  ],
);

MaterialApp.router(
  routerConfig: router,
);

// Navigate
context.go('/profile/123');
context.push('/settings');
```

---

## Forms & Validation

```dart
class MyForm extends StatefulWidget {
  const MyForm({super.key});
  
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Process form
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email required';
              }
              if (!value.contains('@')) {
                return 'Invalid email';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

---

## API Integration

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://api.example.com';
  
  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
  
  Future<Post> createPost(Post post) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(post.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create post');
    }
  }
}
```

---

## Performance Optimization

### Const Constructors

```dart
// ✅ Good - const widget (immutable, reusable)
const Text('Hello');
const Icon(Icons.home);

// ❌ Bad - creates new instance every rebuild
Text('Hello');
Icon(Icons.home);
```

### ListView.builder

```dart
// ✅ Good - lazy loading
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
);

// ❌ Bad - loads all items at once
ListView(
  children: items.map((item) => ListTile(title: Text(item))).toList(),
);
```

### Image Optimization

```dart
// ✅ Cached network image
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
);

// ✅ Specify dimensions
Image.network(
  imageUrl,
  width: 200,
  height: 200,
  fit: BoxFit.cover,
);
```

---

## Responsive Design

```dart
class ResponsiveWidget extends StatelessWidget {
  const ResponsiveWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Tablet/Desktop
          return const DesktopLayout();
        } else {
          // Mobile
          return const MobileLayout();
        }
      },
    );
  }
}

// Media Query
final screenWidth = MediaQuery.of(context).size.width;
final isTablet = screenWidth > 600;
```

---

## Testing

### Unit Test

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Counter increments', () {
    final counter = Counter();
    counter.increment();
    expect(counter.value, 1);
  });
}
```

### Widget Test

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments UI', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    expect(find.text('0'), findsOneWidget);
    
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    
    expect(find.text('1'), findsOneWidget);
  });
}
```

---

## Platform-Specific Code

```dart
import 'dart:io' show Platform;

if (Platform.isAndroid) {
  // Android-specific code
} else if (Platform.isIOS) {
  // iOS-specific code
}

// Platform channels for native integration
const platform = MethodChannel('com.example.app/battery');

try {
  final int result = await platform.invokeMethod('getBatteryLevel');
  print('Battery level: $result%');
} catch (e) {
  print('Error: $e');
}
```

---

## Anti-Patterns to Avoid

❌ **Using setState in initState** → Use didChangeDependencies  
❌ **Not disposing controllers** → Memory leaks  
❌ **Building widgets in build method** → Extract to const/final  
❌ **Nested Column/Row hell** → Use proper layout widgets  
❌ **Not using const** → Performance impact  
❌ **Synchronous operations in build** → Use FutureBuilder  
❌ **Ignoring lint warnings** → Enable and fix lints

---

## Best Practices

✅ **Use const constructors** wherever possible  
✅ **ListView.builder** for long lists  
✅ **Dispose controllers** in dispose()  
✅ **Riverpod** for state management  
✅ **Go Router** for navigation  
✅ **Null safety** enabled  
✅ **Proper error handling** (try-catch)  
✅ **Widget testing** for UI components  
✅ **Image caching** for network images  
✅ **Responsive design** with LayoutBuilder

---

**References:**
- [Flutter Documentation](https://flutter.dev/)
- [Dart Language](https://dart.dev/)
- [Riverpod](https://riverpod.dev/)
- [Go Router](https://pub.dev/packages/go_router)
