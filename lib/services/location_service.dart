import 'dart:async';

import 'package:location/location.dart';
import 'package:rapidpass_checkpoint/models/user_location.dart';

class LocationService {
  UserLocation _currentLocation;
  bool _hasPermission;
  bool _serviceEnabled;

  var location = Location();

  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>();

  Stream<UserLocation> get locationStream => _locationController.stream;

  LocationService() {
    Future.wait([
      location.serviceEnabled(),
      location.hasPermission(),
      location.changeSettings(distanceFilter: 10),
    ]).then((result) {
      _serviceEnabled = result[0];
      _hasPermission = result[1] == PermissionStatus.GRANTED ? true : false;

      location.getLocation().then((locationData) {
        _updateUserLocation(locationData?.latitude, locationData?.longitude);
      });

      location.onLocationChanged().listen((locationData) {
        _updateUserLocation(locationData?.latitude, locationData?.longitude);
      });

      Timer.periodic(Duration(minutes: 1), _checkStatus);
    });
  }

  void _checkStatus(Timer timer) async {
    bool serviceEnabled = await location.serviceEnabled();
    bool hasPermission =
        await location.hasPermission() == PermissionStatus.GRANTED
            ? true
            : false;

    if (serviceEnabled != _serviceEnabled || hasPermission != _hasPermission) {
      _serviceEnabled = serviceEnabled;
      _hasPermission = hasPermission;

      if (_serviceEnabled && _hasPermission) {
        final LocationData locationData = await location.getLocation();
        _updateUserLocation(locationData?.latitude, locationData?.longitude);
      } else {
        _updateUserLocation(null, null);
      }
    }
  }

  void _updateUserLocation(double latitude, double longitude) async {
    _locationController.add(UserLocation(
      latitude: latitude,
      longitude: longitude,
    ));
  }

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }

    return _currentLocation;
  }
}
