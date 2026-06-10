import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'models.dart';
import 'store.dart';

void main() {
  runApp(const GuidelineApp());
}

class GuidelineApp extends StatelessWidget {
  const GuidelineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '麻酔科ガイドライン',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const _Bootstrap(),
    );
  }
}

/// マニフェストと設定の読み込みを待ってからホームを表示
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late final Future<(GuidelineRepository, AppStore)> _future = () async {
    final repo = await GuidelineRepository.load();
    final store = await AppStore.load();
    return (repo, store);
  }();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('読み込みエラー: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final (repo, store) = snapshot.data!;
        return HomeScreen(repo: repo, store: store);
      },
    );
  }
}
