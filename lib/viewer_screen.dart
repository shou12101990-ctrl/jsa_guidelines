import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models.dart';

/// 同梱PDFのビューア
class ViewerScreen extends StatefulWidget {
  final Guideline guideline;

  const ViewerScreen({super.key, required this.guideline});

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  final _controller = PdfViewerController();
  int _page = 1;
  int _pageCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guideline.title,
            style: const TextStyle(fontSize: 16), maxLines: 2),
        actions: [
          if (_pageCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('$_page / $_pageCount',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: '原典ページを開く',
            onPressed: () => launchUrl(Uri.parse(widget.guideline.url),
                mode: LaunchMode.externalApplication),
          ),
        ],
      ),
      body: PdfViewer.asset(
        widget.guideline.assetPath,
        controller: _controller,
        params: PdfViewerParams(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          onViewerReady: (document, controller) {
            setState(() => _pageCount = document.pages.length);
          },
          onPageChanged: (page) {
            if (page != null && mounted) setState(() => _page = page);
          },
        ),
      ),
    );
  }
}
