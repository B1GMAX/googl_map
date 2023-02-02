import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:googl_map/map/map_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../utils/device_utils.dart';
import '../model/map_model.dart';
import '../user_profile/user_profile_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(50.27, 30.31),
    zoom: 2.2,
  );

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => MapBloc(navigator: Navigator.of(context)),
      dispose: (context, bloc) => bloc.dispose(),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () =>
                    context.read<MapBloc>().getCurrentPositionForButton(),
                icon: const Icon(Icons.my_location),
              ),
            ],
          ),
          drawer: Drawer(
            child: Column(
              children: [
                const SizedBox(
                  height: 35,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person,
                    size: 32,
                  ),
                  title: const Text(
                    'Profile',
                    style: TextStyle(fontSize: 22),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfileScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.home, size: 32),
                  title: const Text(
                    'Home',
                    style: TextStyle(fontSize: 22),
                  ),
                  onTap: () {
                    context.read<MapBloc>().logOut();
                  },
                ),
              ],
            ),
          ),
          body: StreamBuilder<MapModel>(
              stream: context.read<MapBloc>().mapModelStream,
              builder: (context, mapSnapshot) {
                return Stack(
                  children: [
                    GoogleMap(
                        polylines: mapSnapshot.hasData
                            ? {
                                if (mapSnapshot.data!.directions != null)
                                  Polyline(
                                    polylineId:
                                        const PolylineId('info_polyline'),
                                    color: Colors.red,
                                    width: 5,
                                    points: mapSnapshot
                                        .data!.directions!.polylinePoints
                                        .map((e) =>
                                            LatLng(e.latitude, e.longitude))
                                        .toList(),
                                  ),
                              }
                            : {},
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        initialCameraPosition: _initialCameraPosition,
                        onTap: (position) {
                          context
                              .read<MapBloc>()
                              .customInfoWindowController
                              .hideInfoWindow!();
                          context.read<MapBloc>().clearInfo();
                        },
                        onCameraMove: (position) {
                          context
                              .read<MapBloc>()
                              .customInfoWindowController
                              .onCameraMove!();
                        },
                        onMapCreated: (controller) => context
                            .read<MapBloc>()
                            .customInfoWindowController
                            .googleMapController = controller,
                        markers: mapSnapshot.hasData
                            ? mapSnapshot.data!.markers
                            : {}),
                    CustomInfoWindow(
                      controller:
                          context.read<MapBloc>().customInfoWindowController,
                      height: 170,
                      width: DeviceUtils.getDeviceHeight(context) / 3.5,
                      offset: 35,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        height: DeviceUtils.getDeviceHeight(context) / 4.3,
                        color: Colors.indigo,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 10, left: 10, top: 10),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Start',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                controller: context
                                    .read<MapBloc>()
                                    .originTextController,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Destination',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                controller: context
                                    .read<MapBloc>()
                                    .destinationTextController,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<MapBloc>()
                                    .addMarkerByButtonPress();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white),
                              child: const Text(
                                'GO',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (mapSnapshot.hasData &&
                        mapSnapshot.data!.totalDistance.isNotEmpty)
                      Positioned(
                        top: 20.0,
                        left: 150,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellowAccent,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 6.0,
                              )
                            ],
                          ),
                          child: Text(
                            mapSnapshot.data!.totalDistance,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
        );
      },
    );
  }
}
