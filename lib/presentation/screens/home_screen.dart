import 'package:adora_location_task/constants/colors.dart';
import 'package:adora_location_task/data/location_data.dart';
import 'package:adora_location_task/domain/provider/tracking_provider.dart';
import 'package:adora_location_task/domain/services/database_service.dart';
import 'package:adora_location_task/domain/services/location_service.dart';
import 'package:adora_location_task/presentation/widgets/location_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService.instance;
  late Future<String> _locationFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture = _locationService.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.sizeOf(context).height * 0.5,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "You are currently at",
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gap(40),
                FutureBuilder(
                  future: _locationFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    final String location = snapshot.data!;
                    return Container(
                      padding: EdgeInsets.all(20),
                      width: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white38,
                      ),
                      child: Text(
                        location.toString(),
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                    );
                  },
                ),
                Gap(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Enable Background Tracking",
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Consumer<TrackingProvider>(
                      builder: (context, trackingProvider, child) {
                        return Switch(
                          value: trackingProvider.isTrackingEnabled,
                          onChanged: (value) {
                            trackingProvider.toggleTracking(value);
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Color(0xFF1DC7AC), // Lighter teal
                          inactiveThumbColor: Colors.white70,
                          inactiveTrackColor: Colors.blueGrey.shade700,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "Logged Locations",
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: FutureBuilder(
                future: DatabaseService.instance.getLocation(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No location data available."));
                  }
                  List<LocationData> data = snapshot.data!;
                  return ListView.separated(
                    padding: EdgeInsets.all(0),
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 15);
                    },
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      LocationData item = data[index];
                      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                        item.timeStamp,
                      );
                      String formattedTime = DateFormat(
                        'yyyy-MM-dd HH:mm',
                      ).format(dateTime);
                      return LocationCard(
                        item: item,
                        formattedTime: formattedTime,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
