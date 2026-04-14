class SellerSalesPoint {
  final String date; // yyyy-mm-dd
  final double totalSales;

  const SellerSalesPoint({required this.date, required this.totalSales});

  factory SellerSalesPoint.fromJson(Map<String, dynamic> json) {
    return SellerSalesPoint(
      date: (json['date'] ?? '').toString(),
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SellerOrdersPoint {
  final String date; // yyyy-mm-dd
  final int orderCount;

  const SellerOrdersPoint({required this.date, required this.orderCount});

  factory SellerOrdersPoint.fromJson(Map<String, dynamic> json) {
    return SellerOrdersPoint(
      date: (json['date'] ?? '').toString(),
      orderCount: (json['order_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class SellerRecentOrder {
  final int sellerOrderId;
  final String orderNumber;
  final String status;
  final double totalAmount;

  const SellerRecentOrder({
    required this.sellerOrderId,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
  });

  factory SellerRecentOrder.fromJson(Map<String, dynamic> json) {
    return SellerRecentOrder(
      sellerOrderId: (json['sellerOrderID'] as num?)?.toInt() ?? 0,
      orderNumber: (json['order_number'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

