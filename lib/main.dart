import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/news_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/transaction_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/music_screen.dart';
import 'screens/ebook_screen.dart';
import 'screens/video_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/live_stream_screen.dart';

/// A Riverpod provider for tracking light/dark theme mode.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: HaliApp()));
}

class HaliApp extends ConsumerWidget {
  const HaliApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    final pageTransitions = const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hali App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        useMaterial3: true,
        pageTransitionsTheme: pageTransitions,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        useMaterial3: true,
        pageTransitionsTheme: pageTransitions,
      ),
      themeMode: themeMode,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const MainNavigation(),
        '/live': (_) => const LiveStreamScreen(),
      },
    );
  }
}

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  static const _tabs = <Widget>[
    HomeScreen(),
    NewsScreen(),
    ChatScreen(),
    TransactionScreen(),
    MarketplaceScreen(),
    MusicScreen(),
    EbookScreen(),
    VideoScreen(),
    SettingsScreen(),
    LiveStreamScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),            label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.article),         label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.chat),            label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront),      label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note),      label: 'Music'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book),       label: 'E-Books'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library),   label: 'Videos'),
          BottomNavigationBarItem(icon: Icon(Icons.settings),        label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.live_tv),         label: 'Live'),
        ],
      ),
    );
  }
}
