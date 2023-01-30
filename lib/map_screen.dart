import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googl_map/map_bloc.dart';
import 'package:googl_map/map_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(50.27, 30.31),
    zoom: 2.2,
  );

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => MapBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      builder: (context, _) {
        return SafeArea(
          child: Scaffold(
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
                          initialCameraPosition: _initialCameraPosition,
                          onMapCreated: (controller) => context
                              .read<MapBloc>()
                              .googleMapController = controller,
                          markers: mapSnapshot.hasData
                              ? {
                                  if (mapSnapshot.data!.firstMarker != null)
                                    mapSnapshot.data!.firstMarker!,
                                  if (mapSnapshot.data!.secondMarker != null)
                                    mapSnapshot.data!.secondMarker!
                                }
                              : {}),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          height: 250,
                          color: Colors.green,
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
                                  child: const Text('Go'))
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            context.read<MapBloc>().getCurrentPosition(),
                        icon: const Icon(Icons.my_location),
                      ),
                      if (mapSnapshot.hasData)
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
          ),
        );
      },
    );
  }
}
