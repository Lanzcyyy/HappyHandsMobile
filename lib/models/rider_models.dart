class RiderOrderSummary {
  final int sellerOrderId;
  final String orderNumber;
  final String status;
  final String? customerName;

  const RiderOrderSummary({
    required this.sellerOrderId,
    required this.orderNumber,
    required this.status,
    required this.customerName,
  });

  factory RiderOrderSummary.fromJson(Map<String, dynamic> json) {
    return RiderOrderSummary(
      sellerOrderId: (json['sellerOrderID'] as num?)?.toInt() ?? 0,
      orderNumber: (json['order_number'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      customerName: json['customer_name']?.toString(),
    );
  }
}

