
import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  final String title;
  final String dateTime;
  final String status;
  final Color statusColor;
  final String price;
  final int itemCount;
  final List<OrderItem> items;
  final String? detailsText;
  final Widget? actionButton;

  const HistoryCard({
    Key? key,
    required this.title,
    required this.dateTime,
    required this.status,
    required this.statusColor,
    required this.price,
    required this.itemCount,
    required this.items,
    this.detailsText,
    this.actionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3DD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 2),
                    Text(dateTime,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFFB0B0B0))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item.imageUrl, width: 38, height: 38, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF1A1A1A))),
                          if (item.description != null)
                            Text(item.description!,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFFB0B0B0))),
                        ],
                      ),
                    ),
                    if (item.price != null)
                      Text('Rp ${item.price}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1A1A1A))),
                  ],
                ),
              )),
          if (items.isNotEmpty) const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rp $price',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A))),
              Text('$itemCount item',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFFB0B0B0))),
            ],
          ),
          if (detailsText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(detailsText!,
                  style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          if (actionButton != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: actionButton!,
            ),
        ],
      ),
    );
  }
}

class OrderItem {
  final String imageUrl;
  final String name;
  final String? description;
  final String? price;
  const OrderItem({required this.imageUrl, required this.name, this.description, this.price});
}
