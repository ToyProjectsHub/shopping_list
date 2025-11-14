import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/shopping_item.dart';
import '../services/shopping_list_provider.dart';

class ItemDetailDialog extends StatefulWidget {
  final ShoppingItem item;
  final String listId;

  const ItemDetailDialog({
    super.key,
    required this.item,
    required this.listId,
  });

  @override
  State<ItemDetailDialog> createState() => _ItemDetailDialogState();
}

class _ItemDetailDialogState extends State<ItemDetailDialog> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _volumeController;
  late TextEditingController _linkController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(
      text: widget.item.quantity?.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: widget.item.price?.toString() ?? '',
    );
    _volumeController = TextEditingController(text: widget.item.volume ?? '');
    _linkController = TextEditingController(text: widget.item.link ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _volumeController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('물품 상세 정보'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '물품명',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: '수량',
                border: OutlineInputBorder(),
                suffixText: '개',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: '가격',
                border: OutlineInputBorder(),
                suffixText: '원',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _volumeController,
              decoration: const InputDecoration(
                labelText: '용량',
                border: OutlineInputBorder(),
                hintText: '예: 500ml, 1kg',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                labelText: '링크',
                border: const OutlineInputBorder(),
                hintText: 'https://',
                suffixIcon: _linkController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: _openLink,
                      )
                    : null,
              ),
              keyboardType: TextInputType.url,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _saveItem,
          child: const Text('저장'),
        ),
      ],
    );
  }

  void _saveItem() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('물품명을 입력해주세요.')),
      );
      return;
    }

    final quantity = _quantityController.text.isEmpty
        ? null
        : int.tryParse(_quantityController.text);
    final price = _priceController.text.isEmpty
        ? null
        : double.tryParse(_priceController.text);
    final volume = _volumeController.text.trim();
    final link = _linkController.text.trim();

    final updatedItem = widget.item.copyWith(
      name: name,
      quantity: quantity,
      price: price,
      volume: volume.isEmpty ? null : volume,
      link: link.isEmpty ? null : link,
    );

    context.read<ShoppingListProvider>().updateItem(
          widget.listId,
          widget.item.id,
          updatedItem,
        );

    Navigator.pop(context);
  }

  Future<void> _openLink() async {
    final link = _linkController.text.trim();
    if (link.isEmpty) return;

    final uri = Uri.tryParse(link);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('유효하지 않은 링크입니다.')),
        );
      }
    }
  }
}
