import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';
import '../widgets/product_card.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Product> _cartItems = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All', 'Demon Slayer', 'Bleach', 'Chainsaw Man', 'Attack on Titan',
    'Hunter x Hunter', 'Jujutsu Kaisen', 'Solo Leveling',
    'Kaiju 8', 'Dr. Stone', 'Mashle', 'Hoodie',
  ];

  static const Map<String, Color> _categoryColors = {
    'All':            Color(0xFF990011),
    'Demon Slayer':   Color(0xFFB22222),
    'Bleach':         Color(0xFF1A1A2E),
    'Chainsaw Man':   Color(0xFFCC2200),
    'Attack on Titan':Color(0xFF4A5240),
    'Hunter x Hunter':Color(0xFF1565C0),
    'Jujutsu Kaisen': Color(0xFF4A148C),
    'Solo Leveling':  Color(0xFF0D47A1),
    'Kaiju 8':        Color(0xFF006064),
    'Dr. Stone':      Color(0xFF2E7D32),
    'Mashle':         Color(0xFF37474F),
    'Hoodie':         Color(0xFF5D4037),
  };

  final List<Product> _allProducts = [
  Product(id:'1', name:'Upper Moon One - Kokushibo', category:'Demon Slayer', price:39.0,
    imageUrl:'assets/images/product_1.png',
    rating:5.0, description:'Kokushibo - Upper Moon One t-shirt. Black acid wash oversized. Front: crescent moon. Back: 6-eyed butterfly with katana.'),
  Product(id:'2', name:'KON - Bleach', category:'Bleach', price:39.0,
    imageUrl:'assets/images/product_2.png',
    rating:5.0, description:'Kon (Modified Soul) t-shirt from Bleach. Black acid wash oversized.'),
  Product(id:'3', name:'Denji - Chainsaw Man', category:'Chainsaw Man', price:39.0,
    imageUrl:'assets/images/product_3.png',
    rating:5.0, description:'Denji / Chainsaw Man t-shirt. Black acid wash oversized. "DENJI / chainsaw man /" print.'),
  Product(id:'4', name:'Phantom Troupe - HxH', category:'Hunter x Hunter', price:39.0,
    imageUrl:'assets/images/product_4.png',
    rating:5.0, description:'Chrollo Lucilfer - Phantom Troupe from Hunter x Hunter. White acid wash oversized. Front & back design.'),
  Product(id:'5', name:'Upper Moon Two - Doma', category:'Demon Slayer', price:39.0,
    imageUrl:'assets/images/product_5.png',
    rating:5.0, description:'Doma - Upper Moon Two t-shirt from Demon Slayer. Black acid wash oversized. Crescent moon with sword design.'),
  Product(id:'6', name:'Muichiro Tokito', category:'Demon Slayer', price:39.0,
    imageUrl:'assets/images/product_6.png',
    rating:5.0, description:'Muichiro Tokito t-shirt from Demon Slayer. Black acid wash oversized. Front: butterfly cross. Back: Muichiro with katana.'),
  Product(id:'7', name:'Flame Hashira Rengoku', category:'Demon Slayer', price:39.0,
    imageUrl:'assets/images/product_7.png',
    rating:5.0, description:'Rengoku Kyojuro t-shirt from Kimetsu no Yaiba. Beige acid wash oversized. Front: small bird. Back: Rengoku with red sun.'),
  Product(id:'8', name:'Solo Leveling - ARISE', category:'Solo Leveling', price:39.0,
    imageUrl:'assets/images/product_8.png',
    rating:5.0, description:'Solo Leveling ARISE t-shirt. Gray acid wash oversized. Front: sword. Back: Beast Monarch "ARISE" print.'),
  Product(id:'9', name:'Toji Fushiguro', category:'Jujutsu Kaisen', price:39.0,
    imageUrl:'assets/images/product_9.png',
    rating:5.0, description:'Toji Fushiguro t-shirt from Jujutsu Kaisen. Black oversized. Character with chains and scythe design.'),
  Product(id:'10', name:'Gojo & Geto', category:'Jujutsu Kaisen', price:39.0,
    imageUrl:'assets/images/product_10.png',
    rating:5.0, description:'Satoru Gojo & Suguru Geto t-shirt from Jujutsu Kaisen. Black acid wash oversized. Koi fish motif with "SATORU SUGURU" text.'),
  Product(id:'11', name:'Attack on Titan - Titans', category:'Attack on Titan', price:39.0,
    imageUrl:'assets/images/product_11.png',
    rating:5.0, description:'Attack on Titan multi-titan collage t-shirt. Black acid wash oversized. Front: Scout Regiment emblem. Back: titans art.'),
  Product(id:'12', name:'Eren Yeager - Attack Titan', category:'Attack on Titan', price:39.0,
    imageUrl:'assets/images/product_12.png',
    rating:5.0, description:'Eren Yeager Attack Titan t-shirt. Black acid wash oversized. Front: Scout emblem. Back: Eren titan emerging.'),
  Product(id:'13', name:'Vasto Lorde - Bleach', category:'Bleach', price:39.0,
    imageUrl:'assets/images/product_13.png',
    rating:5.0, description:'Vasto Lorde Hollow (最上大虚) t-shirt from Bleach. Beige oversized. Large demon with horns front print.'),
  Product(id:'14', name:'Solo Leveling - Igris Dragon', category:'Solo Leveling', price:39.0,
    imageUrl:'assets/images/product_14.png',
    rating:5.0, description:'Solo Leveling character with purple flame dragon t-shirt. Black acid wash oversized. Front & back design.'),
  Product(id:'15', name:'Jujutsu Kaisen Characters', category:'Jujutsu Kaisen', price:39.0,
    imageUrl:'assets/images/product_15.png',
    rating:5.0, description:'Jujutsu Kaisen multi-character t-shirt. White oversized. Pink/magenta design with multiple JJK characters.'),
  Product(id:'16', name:'Dr. Stone - Senku', category:'Dr. Stone', price:39.0,
    imageUrl:'assets/images/product_16.png',
    rating:5.0, description:'Senku Ishigami t-shirt from Dr. Stone. Olive green acid wash oversized. Senku breaking from stone print.'),
  Product(id:'17', name:'Sukuna Demon', category:'Jujutsu Kaisen', price:39.0,
    imageUrl:'assets/images/product_17.png',
    rating:5.0, description:'Ryomen Sukuna t-shirt from Jujutsu Kaisen. Black acid wash oversized. Red demon face with dripping moon design.'),
];

  List<Product> get _filteredProducts {
    return _allProducts.where((p) {
      final matchCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  void _addToCart(Product product) {
    setState(() => _cartItems.add(product));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} сагсанд нэмлээ'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() => _cartItems.removeAt(index));
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Сайн байна уу, ${FirebaseAuth.instance.currentUser?.displayName ?? 'Guest'}!',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text('Аниме фэшн дэлгүүрт тавтай морил',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TextField(
                  style: const TextStyle(color: AppTheme.textPrimary),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Бараа хайх...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(right: 16),
                  itemCount: _categories.length,
                  itemBuilder: (_, i) => _buildCategoryCircle(_categories[i]),
                ),
              ),
            ],
          ),
        ),
        _filteredProducts.isEmpty
          ? const Expanded(
              child: Center(
                child: Text('Бараа олдсонгүй', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
              ),
            )
          : Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.72,
                  crossAxisSpacing: 12, mainAxisSpacing: 12,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (ctx, i) => ProductCard(
                  product: _filteredProducts[i],
                  onAddToCart: () => _addToCart(_filteredProducts[i]),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(
                      product: _filteredProducts[i],
                      onAddToCart: () => _addToCart(_filteredProducts[i]),
                    ))),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildCategoryCircle(String cat) {
    final isSelected = _selectedCategory == cat;
    final color = _categoryColors[cat] ?? AppTheme.primary;
    final label = cat == 'All' ? 'Бүгд' : cat;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: isSelected
                    ? Border.all(color: AppTheme.primary, width: 3)
                    : Border.all(color: Colors.transparent, width: 3),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))]
                    : [const BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Center(
                child: Text(
                  cat == 'All' ? '✦' : cat.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ангилал',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(right: 16),
                  itemCount: _categories.length,
                  itemBuilder: (_, i) => _buildCategoryCircle(_categories[i]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _filteredProducts.isEmpty
              ? const Center(
                  child: Text('Энэ ангилалд бараа байхгүй',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (ctx, i) => ProductCard(
                    product: _filteredProducts[i],
                    onAddToCart: () => _addToCart(_filteredProducts[i]),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                                  product: _filteredProducts[i],
                                  onAddToCart: () =>
                                      _addToCart(_filteredProducts[i]),
                                ))),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    void clearCart() => setState(() => _cartItems.clear());

    final List<Widget> screens = [
      _buildHome(),
      _buildCategory(),
      CartScreen(
        cartItems: _cartItems,
        onRemove: _removeFromCart,
        onPaymentSuccess: clearCart,
      ),
      const OrdersScreen(),
      ProfileScreen(onSignOut: _signOut),
    ];

    final themeNotifier = context.watch<ThemeNotifier>();
    final isDark = themeNotifier.isDark;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
                color: isDark ? Colors.amber : AppTheme.textPrimary,
                size: 22,
              ),
            ),
            onPressed: () => context.read<ThemeNotifier>().toggle(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.asset('assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox()),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Anime Store'),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.textPrimary),
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) =>
                    CartScreen(
                      cartItems: _cartItems,
                      onRemove: _removeFromCart,
                      onPaymentSuccess: clearCart,
                    ))),
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary, shape: BoxShape.circle),
                    child: Center(
                      child: Text('${_cartItems.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category_outlined), label: 'Category'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Захиалга'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}