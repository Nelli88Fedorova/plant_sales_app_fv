// lib/screens/catalog_screen.dart
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;
  List<String> _categories = [];
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await DatabaseHelper.instance.getAllProducts();
      final categories = products.map((p) => p.category).toSet().toList();
      setState(() {
        _products = products;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    }
  }

  List<Product> get _filteredProducts {
    var filtered = _products;
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (p.composition?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    return filtered;
  }

  void _hideKeyboard() {
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог препаратов'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Поиск с управлением фокусом
                TextField(
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию или составу...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _searchQuery = '');
                              _hideKeyboard();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSubmitted: (_) => _hideKeyboard(),
                ),
                const SizedBox(height: 8),
                // Фильтр по категориям
                if (_categories.isNotEmpty)
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildCategoryChip('Все', null);
                        }
                        final category = _categories[index - 1];
                        return _buildCategoryChip(category, category);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: _hideKeyboard,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _filteredProducts.isEmpty
                ? const Center(child: Text('Нет препаратов, соответствующих фильтру'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return _buildProductCard(product);
                    },
                  ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? value : null;
          });
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.green.shade100,
        checkmarkColor: Colors.green,
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    // Извлекаем первое действующее вещество из состава
    String firstSubstance = '';
    if (product.composition != null && product.composition!.isNotEmpty) {
      final parts = product.composition!.split(';');
      if (parts.isNotEmpty) {
        firstSubstance = parts.first.trim();
        // Если слишком длинное — обрезаем
        if (firstSubstance.length > 30) {
          firstSubstance = '${firstSubstance.substring(0, 30)}…';
        }
      }
    }

    // Формируем единицы измерения для нормы расхода
    String consumptionWithUnit = _formatConsumptionRate(
      product.consumptionRate,
      product.package,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildInfoRow('Категория', product.category),
            // if (firstSubstance.isNotEmpty)
            //   _buildInfoRow('ДВ', firstSubstance),
            if (product.price != null)
              _buildInfoRow('Цена', '${product.price!.toStringAsFixed(2)} ₽', isPrice: true),
          ],
        ),
        trailing: const Icon(Icons.keyboard_arrow_down),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.composition != null && product.composition!.isNotEmpty)
                  _buildDetailRow('Состав', product.composition!),
                if (product.manufacturer != null && product.manufacturer!.isNotEmpty)
                  _buildDetailRow('Производитель', product.manufacturer!),
                if (product.package != null && product.package!.isNotEmpty)
                  _buildDetailRow('Упаковка', product.package!),
                if (consumptionWithUnit.isNotEmpty)
                  _buildDetailRow('Норма расхода', consumptionWithUnit),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    'Цена: ${product.price != null ? '${product.price!.toStringAsFixed(2)} ₽' : 'не указана'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatConsumptionRate(String? rate, String? package) {
    if (rate == null || rate.isEmpty) return '';
    
    // Определяем единицу из упаковки (л, кг, г, мл)
    String unit = '';
    if (package != null) {
      final match = RegExp(r'(\d+)\s*(л|кг|г|мл|L|l|kg|g|ml)').firstMatch(package);
      if (match != null) {
        unit = match.group(2)?.toLowerCase() ?? '';
        // Приводим к стандартному виду
        if (unit == 'l') unit = 'л';
        if (unit == 'kg') unit = 'кг';
        if (unit == 'g') unit = 'г';
        if (unit == 'ml') unit = 'мл';
      }
    }
    
    // Если единица не определена, пробуем найти в самой норме
    if (unit.isEmpty) {
      final match = RegExp(r'(\d+(?:[.,]\d+)?)\s*(л|кг|г|мл|L|kg|g|ml)').firstMatch(rate);
      if (match != null) {
        unit = match.group(2)?.toLowerCase() ?? '';
        if (unit == 'l') unit = 'л';
        if (unit == 'kg') unit = 'кг';
        if (unit == 'g') unit = 'г';
        if (unit == 'ml') unit = 'мл';
        return '$rate'; // уже содержит единицу
      }
      return rate;
    }
    
    // Если единица есть, добавляем /га
    return '$rate $unit/га';
  }

  Widget _buildInfoRow(String label, String value, {bool isPrice = false}) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
              color: isPrice ? Colors.green.shade700 : Colors.black87,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
          const Divider(height: 12),
        ],
      ),
    );
  }
}