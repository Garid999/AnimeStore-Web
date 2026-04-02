import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
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

  final List<String> _categories = ['All', 'Shirts', 'Pants', 'Jackets', 'Shoes'];

  final List<Product> _allProducts = [
  Product(id:'1', name:'Classic White Shirt', category:'Shirts', price:29.99,
    imageUrl:'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400',
    rating:4.5, description:'A timeless classic white shirt perfect for any occasion.'),
  Product(id:'2', name:'Slim Fit Chinos', category:'Pants', price:39.99,
    imageUrl:'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=400',
    rating:4.3, description:'Modern slim fit chino pants for a sharp look.'),
  Product(id:'3', name:'Leather Jacket', category:'Jackets', price:89.99,
    imageUrl:'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
    rating:4.8, description:'Premium genuine leather jacket for a bold style.'),
  Product(id:'4', name:'Casual Sneakers', category:'Shoes', price:49.99,
    imageUrl:'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
    rating:4.6, description:'Comfortable and stylish casual sneakers for everyday wear.'),
  Product(id:'5', name:'Denim Jeans', category:'Pants', price:44.99,
    imageUrl:'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400',
    rating:4.4, description:'Classic denim jeans with a perfect fit.'),
  Product(id:'6', name:'Polo Shirt', category:'Shirts', price:24.99,
    imageUrl:'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=400',
    rating:4.2, description:'Comfortable polo shirt for a smart casual look.'),
  Product(id:'7', name:'Formal Blazer', category:'Jackets', price:79.99,
    imageUrl:'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400',
    rating:4.7, description:'Elegant formal blazer for business and special occasions.'),
  Product(id:'8', name:'Running Shoes', category:'Shoes', price:59.99,
    imageUrl:'https://images.unsplash.com/photo-1608231387042-66d1773d3028?w=400',
    rating:4.5, description:'High performance running shoes for active lifestyle.'),
  Product(id:'9', name:'Oxford Shirt', category:'Shirts', price:34.99,
    imageUrl:'https://images.unsplash.com/photo-1620012253295-c15cc3e65df4?w=400',
    rating:4.3, description:'Classic oxford shirt for a polished look.'),
  Product(id:'10', name:'Cargo Pants', category:'Pants', price:49.99,
    imageUrl:'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400',
    rating:4.1, description:'Functional cargo pants with multiple pockets.'),
  Product(id:'11', name:'Bomber Jacket', category:'Jackets', price:99.99,
    imageUrl:'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400',
    rating:4.6, description:'Stylish bomber jacket for a cool casual look.'),
  Product(id:'12', name:'Loafers', category:'Shoes', price:69.99,
    imageUrl:'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?w=400',
    rating:4.4, description:'Elegant loafers for a smart casual style.'),
  Product(id:'13', name:'Striped T-Shirt', category:'Shirts', price:19.99,
    imageUrl:'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=400',
    rating:4.0, description:'Classic striped t-shirt for casual wear.'),
  Product(id:'14', name:'Track Pants', category:'Pants', price:34.99,
    imageUrl:'https://images.unsplash.com/photo-1552902865-b72c031ac5ea?w=400',
    rating:4.2, description:'Comfortable track pants for sports and leisure.'),
  Product(id:'15', name:'Windbreaker', category:'Jackets', price:74.99,
    imageUrl:'https://images.unsplash.com/photo-1544923246-77307dd654cb?w=400',
    rating:4.3, description:'Lightweight windbreaker for outdoor activities.'),
  Product(id:'16', name:'Chelsea Boots', category:'Shoes', price:89.99,
    imageUrl:'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?w=400',
    rating:4.7, description:'Classic chelsea boots for a stylish look.'),
  Product(id:'17', name:'Linen Shirt', category:'Shirts', price:27.99,
    imageUrl:'https://images.unsplash.com/photo-1604695573706-53170668f6a6?w=400',
    rating:4.1, description:'Breathable linen shirt perfect for summer.'),
  Product(id:'18', name:'Jogger Pants', category:'Pants', price:37.99,
    imageUrl:'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
    rating:4.3, description:'Comfortable jogger pants for everyday wear.'),
  Product(id:'19', name:'Denim Jacket', category:'Jackets', price:69.99,
    imageUrl:'https://images.unsplash.com/photo-1576871337622-98d48d1cf531?w=400',
    rating:4.5, description:'Classic denim jacket for a casual cool look.'),
  Product(id:'20', name:'Dress Shoes', category:'Shoes', price:79.99,
    imageUrl:'https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=400',
    rating:4.6, description:'Elegant dress shoes for formal occasions.'),
  Product(id:'21', name:'Graphic T-Shirt', category:'Shirts', price:22.99,
    imageUrl:'https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=400',
    rating:4.0, description:'Cool graphic t-shirt for casual style.'),
  Product(id:'22', name:'Chino Shorts', category:'Pants', price:29.99,
    imageUrl:'https://images.unsplash.com/photo-1591195853828-11db59a44f43?w=400',
    rating:4.2, description:'Smart chino shorts for warm weather.'),
  Product(id:'23', name:'Parka Jacket', category:'Jackets', price:119.99,
    imageUrl:'https://images.unsplash.com/photo-1548883354-7622d03aca27?w=400',
    rating:4.8, description:'Warm parka jacket for cold weather.'),
  Product(id:'24', name:'High Top Sneakers', category:'Shoes', price:74.99,
    imageUrl:'https://images.unsplash.com/photo-1600269452121-4f2416e55c28?w=400',
    rating:4.4, description:'Trendy high top sneakers for a bold look.'),
  Product(id:'25', name:'Henley Shirt', category:'Shirts', price:26.99,
    imageUrl:'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=400',
    rating:4.3, description:'Casual henley shirt for a relaxed style.'),
  Product(id:'26', name:'Slim Jeans', category:'Pants', price:47.99,
    imageUrl:'https://images.unsplash.com/photo-1604176354204-9268737828e4?w=400',
    rating:4.5, description:'Slim fit jeans for a modern silhouette.'),
  Product(id:'27', name:'Trench Coat', category:'Jackets', price:139.99,
    imageUrl:'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=400',
    rating:4.9, description:'Classic trench coat for a sophisticated look.'),
  Product(id:'28', name:'Slip On Shoes', category:'Shoes', price:44.99,
    imageUrl:'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=400',
    rating:4.1, description:'Easy slip on shoes for everyday comfort.'),
  Product(id:'29', name:'V-Neck T-Shirt', category:'Shirts', price:18.99,
    imageUrl:'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=400',
    rating:4.0, description:'Simple v-neck t-shirt for casual wear.'),
  Product(id:'30', name:'Wide Leg Pants', category:'Pants', price:54.99,
    imageUrl:'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=400',
    rating:4.2, description:'Trendy wide leg pants for a fashion forward look.'),
  Product(id:'31', name:'Varsity Jacket', category:'Jackets', price:94.99,
    imageUrl:'https://images.unsplash.com/photo-1617137968427-85924c800a22?w=400',
    rating:4.6, description:'Classic varsity jacket for a sporty style.'),
  Product(id:'32', name:'Boat Shoes', category:'Shoes', price:64.99,
    imageUrl:'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?w=400',
    rating:4.3, description:'Classic boat shoes for a nautical look.'),
  Product(id:'33', name:'Flannel Shirt', category:'Shirts', price:32.99,
    imageUrl:'https://images.unsplash.com/photo-1589310243389-96a5483213a8?w=400',
    rating:4.4, description:'Warm flannel shirt for a rugged casual style.'),
  Product(id:'34', name:'Sweatpants', category:'Pants', price:39.99,
    imageUrl:'https://images.unsplash.com/photo-1607703703520-bb638e84caf2?w=400',
    rating:4.1, description:'Cozy sweatpants for relaxed days at home.'),
  Product(id:'35', name:'Quilted Jacket', category:'Jackets', price:109.99,
    imageUrl:'https://images.unsplash.com/photo-1548126032-079a0fb0099d?w=400',
    rating:4.5, description:'Warm quilted jacket for cold weather comfort.'),
  Product(id:'36', name:'Oxford Shoes', category:'Shoes', price:84.99,
    imageUrl:'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=400',
    rating:4.7, description:'Classic oxford shoes for formal occasions.'),
  Product(id:'37', name:'Long Sleeve Shirt', category:'Shirts', price:28.99,
    imageUrl:'https://images.unsplash.com/photo-1588359348347-9bc6cbbb689e?w=400',
    rating:4.2, description:'Versatile long sleeve shirt for any season.'),
  Product(id:'38', name:'Pleated Trousers', category:'Pants', price:59.99,
    imageUrl:'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400',
    rating:4.4, description:'Elegant pleated trousers for a formal look.'),
  Product(id:'39', name:'Sherpa Jacket', category:'Jackets', price:84.99,
    imageUrl:'https://images.unsplash.com/photo-1605908502724-9093a79a6889?w=400',
    rating:4.6, description:'Cozy sherpa jacket for ultimate warmth.'),
  Product(id:'40', name:'Monk Strap Shoes', category:'Shoes', price:94.99,
    imageUrl:'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?w=400',
    rating:4.5, description:'Stylish monk strap shoes for a distinctive look.'),
  Product(id:'41', name:'Button Down Shirt', category:'Shirts', price:31.99,
    imageUrl:'https://images.unsplash.com/photo-1598032895397-b9472444bf93?w=400',
    rating:4.3, description:'Classic button down shirt for smart casual wear.'),
  Product(id:'42', name:'Corduroy Pants', category:'Pants', price:52.99,
    imageUrl:'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=400',
    rating:4.2, description:'Textured corduroy pants for a vintage style.'),
  Product(id:'43', name:'Field Jacket', category:'Jackets', price:114.99,
    imageUrl:'https://images.unsplash.com/photo-1544923246-77307dd654cb?w=400',
    rating:4.7, description:'Rugged field jacket for outdoor adventures.'),
  Product(id:'44', name:'Derby Shoes', category:'Shoes', price:77.99,
    imageUrl:'https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=400',
    rating:4.4, description:'Classic derby shoes for a smart look.'),
  Product(id:'45', name:'Muscle Fit Shirt', category:'Shirts', price:23.99,
    imageUrl:'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400',
    rating:4.1, description:'Muscle fit shirt to show off your physique.'),
  Product(id:'46', name:'Straight Jeans', category:'Pants', price:46.99,
    imageUrl:'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400',
    rating:4.3, description:'Classic straight fit jeans for everyday wear.'),
  Product(id:'47', name:'Coach Jacket', category:'Jackets', price:72.99,
    imageUrl:'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400',
    rating:4.4, description:'Lightweight coach jacket for a sporty style.'),
  Product(id:'48', name:'Ankle Boots', category:'Shoes', price:87.99,
    imageUrl:'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?w=400',
    rating:4.6, description:'Stylish ankle boots for a sharp look.'),
  Product(id:'49', name:'Oversized Shirt', category:'Shirts', price:25.99,
    imageUrl:'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=400',
    rating:4.2, description:'Trendy oversized shirt for a relaxed fit.'),
  Product(id:'50', name:'Tapered Pants', category:'Pants', price:48.99,
    imageUrl:'https://images.unsplash.com/photo-1552902865-b72c031ac5ea?w=400',
    rating:4.5, description:'Modern tapered pants for a clean silhouette.'),
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
        content: Text('${product.name} added to cart'),
        backgroundColor: const Color(0xFFE53935),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() => _cartItems.removeAt(index));
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
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
                'Hello, ${FirebaseAuth.instance.currentUser?.displayName ?? 'Guest'}!',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text('Find your perfect outfit',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Search outfits...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
        _filteredProducts.isEmpty
          ? const Expanded(
              child: Center(
                child: Text('No products found', style: TextStyle(color: Colors.grey, fontSize: 16)),
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

  Widget _buildCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Categories',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (ctx, i) {
                    final cat = _categories[i];
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE53935) : const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          )),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHome(),
      _buildCategory(),
      CartScreen(cartItems: _cartItems, onRemove: _removeFromCart),
      ProfileScreen(onSignOut: _signOut),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('OutfitHub'),
        backgroundColor: const Color(0xFF121212),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) =>
                    CartScreen(cartItems: _cartItems, onRemove: _removeFromCart))),
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935), shape: BoxShape.circle),
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
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFFE53935),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category_outlined), label: 'Category'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}