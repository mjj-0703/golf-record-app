import 'package:flutter/material.dart';
import 'package:golf_record_app/utils/youtube_search_utils.dart';

class VideoSearchPage extends StatefulWidget {
  const VideoSearchPage({required this.query, super.key});

  final String query;

  @override
  State<VideoSearchPage> createState() => _VideoSearchPageState();
}

class _VideoSearchPageState extends State<VideoSearchPage> {
  var _isLaunching = false;
  String? _errorMessage;

  Uri get _searchUrl => buildYouTubeSearchUrl(widget.query);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openBrowser());
  }

  Future<void> _openBrowser() async {
    setState(() {
      _isLaunching = true;
      _errorMessage = null;
    });

    try {
      final launched = await launchVideoSearchInBrowser(_searchUrl);
      if (!mounted) {
        return;
      }
      setState(() {
        _isLaunching = false;
        if (!launched) {
          _errorMessage = 'ブラウザを開けませんでした';
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLaunching = false;
        _errorMessage = youtubeLaunchError(error) ?? 'ブラウザを開けませんでした';
      });
    }
  }

  Future<void> _copyQuery() async {
    await copySearchQuery(widget.query);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('検索ワードをコピーしました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTubeで検索'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '検索ワード',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.query),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'YouTube の検索結果をブラウザで開きます。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isLaunching ? null : _openBrowser,
            icon: _isLaunching
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_circle_outline),
            label: Text(_isLaunching ? 'YouTubeを開いています…' : 'YouTubeで検索'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _copyQuery,
            icon: const Icon(Icons.copy),
            label: const Text('検索ワードをコピー'),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Play Store の「更新」画面が出た場合\n'
            'Chrome または YouTube の更新が必要です。1回「更新」を押してから、'
            '「YouTubeで検索」をもう一度タップしてください。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
