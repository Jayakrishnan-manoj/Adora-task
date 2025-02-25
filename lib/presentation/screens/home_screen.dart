import 'package:adora_location_task/constants/colors.dart';
import 'package:adora_location_task/data/location_data.dart';
import 'package:adora_location_task/domain/provider/tracking_provider.dart';
import 'package:adora_location_task/domain/services/database_service.dart';
import 'package:adora_location_task/domain/services/location_service.dart';
import 'package:adora_location_task/presentation/widgets/location_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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
                      return Shimmer.fromColors(
                        baseColor: AppColors.primaryColor,
                        highlightColor: AppColors.whiteColor,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white38,
                          ),
                          height: 150,
                          width: 280,
                        ),
                      );
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
                          onChanged: (value) async {
                            if (value) {
                              await _locationService.requestPermissions();
                              final enabledSnackBar = SnackBar(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                content: Text('Tracking enabled'),
                                backgroundColor: Colors.green,
                                elevation: 10,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(5),
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(enabledSnackBar);
                            } else {
                              final disabledSnackBar = SnackBar(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                content: Text('Tracking disabled'),
                                backgroundColor: Colors.red,
                                elevation: 10,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(5),
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(disabledSnackBar);
                            }
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
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white54),
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      children: [
                        const TextSpan(
                          text:
                              "Note: To monitor location changes in the background, enable ",
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: () {
                              print("pressed");
                              //Geolocator.openLocationSettings();
                              Geolocator.openAppSettings();
                            },
                            child: Text(
                              "Allow Everytime",
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: " in the location settings."),
                      ],
                    ),
                  ),
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
