import 'package:flutter/material.dart';
import '../../../constants.dart';

class AddressSection extends StatelessWidget {
  final String address;
  final Function(String) onAddressChanged;

  const AddressSection({
    Key? key,
    required this.address,
    required this.onAddressChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.grey.withOpacity(0.1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: kPrimaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Delivery Address",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: address,
            onChanged: onAddressChanged,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Enter your delivery address",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: kPrimaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 