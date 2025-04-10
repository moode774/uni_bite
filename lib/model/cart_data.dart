class CartItem {
  final String name;
  final String imagePath;
  final int price;
  final String? storeId;
  final String? productId;
  int quantity;
  
  final String? additionName; 
  final int additionPrice;   

  CartItem({
    required this.name,
    required this.imagePath,
    required this.price,
    required this.quantity,
    this.storeId,
    this.productId, 
    this.additionName,
    this.additionPrice = 0,
  });
}

List<CartItem> cartItems = [];

Map<String, dynamic>? paymentCardData;

void addToCart(CartItem newItem) {
  final existingItem = cartItems.firstWhere(
    (item) {
      final String itemAddition = item.additionName ?? '';
      final String newAddition = newItem.additionName ?? '';
      return item.name == newItem.name &&
          item.storeId == newItem.storeId &&
          item.productId == newItem.productId && 
          itemAddition == newAddition;
    },
    orElse: () => newItem,
  );
  if (cartItems.contains(existingItem)) {
    existingItem.quantity += newItem.quantity;
  } else {
    cartItems.add(newItem);
  }
}