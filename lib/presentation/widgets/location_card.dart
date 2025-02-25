import 'package:adora_location_task/constants/colors.dart';
import 'package:adora_location_task/data/location_data.dart';
import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.item,
    required this.formattedTime,
  });

  final LocationData item;
  final String formattedTime;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  "Latitude",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  double.parse(item.latitude).toStringAsFixed(4),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "Longitude",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  double.parse(item.longitude).toStringAsFixed(4),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "Time",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  formattedTime,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
