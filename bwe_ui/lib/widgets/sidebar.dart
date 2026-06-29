import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<String> _tabLabels = ['Pages', 'Outline', 'Comments'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab navigation
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _tabLabels.length,
            itemBuilder: (context, index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _currentPage = index);
                    _pageController.jumpToPage(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _currentPage == index
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _tabLabels[index],
                      style: TextStyle(
                        fontWeight: _currentPage == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Divider(height: 1),

        // Tab content
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _PagesTab(),
              _OutlineTab(),
              _CommentsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _PagesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentProvider>();
    final doc = provider.currentDocument;
    final isSyncing = provider.isSyncing;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatCard(
            label: 'Pages',
            value: '${doc.pageCount}',
            isLoading: isSyncing,
          ),
          const SizedBox(height: 8),
          _StatCard(
            label: 'Words',
            value: '${doc.wordCount}',
            isLoading: isSyncing,
          ),
          const SizedBox(height: 8),
          _StatCard(
            label: 'Characters',
            value: '${doc.characterCount}',
            isLoading: isSyncing,
          ),
          const SizedBox(height: 16),
          const Text(
            'Document Info',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Title: ${doc.title}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Modified: ${_formatDate(doc.lastModified)}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'File: ${doc.filePath.isEmpty ? 'Not saved' : doc.filePath}',
            style: const TextStyle(fontSize: 12),
          ),
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Error: ${provider.error}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red[600],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _OutlineTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Document Outline',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Headings will appear here as you type them.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              final headingLevels = ['Heading 1', 'Heading 2', 'Heading 3'];
              return Padding(
                padding: EdgeInsets.only(left: (index * 16).toDouble()),
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    headingLevels[index],
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 11,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CommentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comments',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No comments yet. Highlight text and click the comment button to add a comment.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isLoading;

  const _StatCard({
    required this.label,
    required this.value,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
        ],
      ),
    );
  }
}
