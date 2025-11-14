import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/shopping_list_provider.dart';
import '../models/shopping_item.dart';
import '../widgets/item_detail_dialog.dart';

class ListDetailScreen extends StatefulWidget {
  final String listId;

  const ListDetailScreen({super.key, required this.listId});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final TextEditingController _addItemController = TextEditingController();

  @override
  void dispose() {
    _addItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ShoppingListProvider>(
          builder: (context, provider, child) {
            final list = provider.getListById(widget.listId);
            return Text(list?.title ?? '쇼핑 리스트');
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<ShoppingListProvider>(
            builder: (context, provider, child) {
              final list = provider.getListById(widget.listId);
              final hasCompletedItems =
                  list?.items.any((item) => item.isCompleted) ?? false;

              if (!hasCompletedItems) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: '완료된 항목 삭제',
                onPressed: () => _confirmDeleteCompleted(context),
              );
            },
          ),
        ],
      ),
      body: Consumer<ShoppingListProvider>(
        builder: (context, provider, child) {
          final list = provider.getListById(widget.listId);

          if (list == null) {
            return const Center(child: Text('리스트를 찾을 수 없습니다.'));
          }

          final activeItems =
              list.items.where((item) => !item.isCompleted).toList();
          final completedItems =
              list.items.where((item) => item.isCompleted).toList();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    if (activeItems.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          '구매할 물품',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      ...activeItems.map(
                        (item) => _ItemCard(
                          item: item,
                          listId: widget.listId,
                        ),
                      ),
                    ],
                    if (completedItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          '완료됨',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      ...completedItems.map(
                        (item) => _ItemCard(
                          item: item,
                          listId: widget.listId,
                        ),
                      ),
                    ],
                    if (activeItems.isEmpty && completedItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            '물품이 없습니다.\n아래에서 추가해보세요!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addItemController,
                          decoration: const InputDecoration(
                            hintText: '물품 이름',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _addItem(provider),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _addItem(provider),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('추가'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addItem(ShoppingListProvider provider) {
    final text = _addItemController.text.trim();
    if (text.isNotEmpty) {
      provider.addItem(widget.listId, text);
      _addItemController.clear();
    }
  }

  void _confirmDeleteCompleted(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('완료된 항목 삭제'),
        content: const Text('완료된 모든 항목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<ShoppingListProvider>()
                  .deleteCompletedItems(widget.listId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ShoppingItem item;
  final String listId;

  const _ItemCard({
    required this.item,
    required this.listId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (value) {
            context.read<ShoppingListProvider>().toggleItemComplete(
                  listId,
                  item.id,
                );
          },
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            color: item.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: _buildSubtitle(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
        onTap: () => _showEditDialog(context),
      ),
    );
  }

  Widget? _buildSubtitle() {
    final details = <String>[];

    if (item.quantity != null) {
      details.add('수량: ${item.quantity}');
    }
    if (item.price != null) {
      details.add('가격: ${item.price}원');
    }
    if (item.volume != null && item.volume!.isNotEmpty) {
      details.add('용량: ${item.volume}');
    }

    if (details.isEmpty) return null;

    return Text(
      details.join(' · '),
      style: TextStyle(
        fontSize: 12,
        color: item.isCompleted ? Colors.grey : Colors.grey[600],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ItemDetailDialog(
        item: item,
        listId: listId,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('물품 삭제'),
        content: Text('${item.name}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<ShoppingListProvider>().removeItem(listId, item.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
