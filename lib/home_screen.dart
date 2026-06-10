import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models.dart';
import 'store.dart';
import 'viewer_screen.dart';

const _categoryIcons = <String, IconData>{
  '教育': Icons.school_outlined,
  '本学会制定ガイドライン': Icons.gavel_outlined,
  'プラクティカルガイド': Icons.medical_services_outlined,
  '救急救命士マニュアル': Icons.emergency_outlined,
  '他学会合同': Icons.handshake_outlined,
  '医薬品': Icons.medication_outlined,
  'その他': Icons.more_horiz,
};

class HomeScreen extends StatefulWidget {
  final GuidelineRepository repo;
  final AppStore store;

  const HomeScreen({super.key, required this.repo, required this.store});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _categoryFilter; // null = 全て, '★' = お気に入り

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onStoreChanged() => setState(() {});

  List<Guideline> get _filtered {
    final q = normalizeForSearch(_query.trim());
    return widget.repo.items.where((g) {
      if (_categoryFilter == '★' && !widget.store.isFavorite(g.id)) {
        return false;
      }
      if (_categoryFilter != null &&
          _categoryFilter != '★' &&
          g.category != _categoryFilter) {
        return false;
      }
      if (q.isNotEmpty && !normalizeForSearch(g.title).contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  void _open(Guideline g) {
    widget.store.addRecent(g.id);
    if (g.external) {
      launchUrl(Uri.parse(g.url), mode: LaunchMode.externalApplication);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ViewerScreen(guideline: g)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final showSections = _query.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('麻酔科ガイドライン'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'このアプリについて',
            onPressed: _showAbout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ガイドラインを検索',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip(null, '全て'),
                _chip('★', '★ お気に入り'),
                for (final c in widget.repo.categories) _chip(c, c),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('該当するガイドラインがありません'))
                : showSections
                    ? _sectionedList(filtered)
                    : _flatList(filtered),
          ),
        ],
      ),
    );
  }

  Widget _chip(String? value, String label) {
    final selected = _categoryFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _categoryFilter = value),
      ),
    );
  }

  Widget _sectionedList(List<Guideline> items) {
    final recents = widget.store.recents
        .map((id) => items.where((g) => g.id == id).firstOrNull)
        .whereType<Guideline>()
        .take(5)
        .toList();

    final children = <Widget>[];
    if (recents.isNotEmpty && _categoryFilter == null) {
      children.add(_sectionHeader('最近見た項目', Icons.history));
      children.addAll(recents.map(_tile));
    }
    for (final cat in widget.repo.categories) {
      final inCat = items.where((g) => g.category == cat).toList();
      if (inCat.isEmpty) continue;
      children.add(
          _sectionHeader(cat, _categoryIcons[cat] ?? Icons.description));
      children.addAll(inCat.map(_tile));
    }
    return ListView(children: children);
  }

  Widget _flatList(List<Guideline> items) =>
      ListView(children: items.map(_tile).toList());

  Widget _sectionHeader(String title, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: scheme.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _tile(Guideline g) {
    final fav = widget.store.isFavorite(g.id);
    return ListTile(
      leading: Icon(
        g.external ? Icons.open_in_new : Icons.picture_as_pdf_outlined,
        color: g.external
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(g.title),
      subtitle: Text(
        g.external ? '外部リンク • ${g.category}' : '${g.sizeLabel} • ${g.category}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: Icon(
          fav ? Icons.star : Icons.star_border,
          color: fav ? Colors.amber : null,
        ),
        onPressed: () => widget.store.toggleFavorite(g.id),
      ),
      onTap: () => _open(g),
    );
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('このアプリについて'),
        content: SingleChildScrollView(
          child: Text(
            '日本麻酔科学会が公開している指針・ガイドライン'
            '(${widget.repo.fetched} 時点)をオフラインで閲覧するための'
            '個人用ビューアです。\n\n'
            '各文書の著作権は日本麻酔科学会および各学会に帰属します。'
            '再配布はしないでください。\n\n'
            '最新版は必ず原典で確認してください:\n${widget.repo.source}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => launchUrl(Uri.parse(widget.repo.source),
                mode: LaunchMode.externalApplication),
            child: const Text('原典ページを開く'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
