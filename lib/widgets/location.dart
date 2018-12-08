import 'package:flutter/material.dart';
//import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/location_data.dart';
import '../models/product.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Product product;

  LocationInput(this.setLocation, this.product);

  @override
  State<StatefulWidget> createState() {
    return LocationInputState();
  }
}

class LocationInputState extends State<LocationInput> {
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController = TextEditingController();
  LocationData _locationData;
  Uri _staticMapUri;

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    if (widget.product != null) {
      getStaticMap(widget.product.location.address, geocode: false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      getStaticMap(_addressInputController.text);
    }
  }

  void getStaticMap(String address, {bool geocode = true, double lat, double lng}) async {
    if (address.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    };

    _locationData = LocationData(
        address: 'Moscow',
        latitude: 50,
        longitude: 60);


  if (geocode) {
      final Uri uri = Uri.https(
          'maps.googleapis.com', '/maps/api/geocode/json', {
        'address': address,
        'key': 'AIzaSyAoxzEYuqUHKPcaJelPAWweiWVpbXrQXTw'
      });

      final http.Response response = await http.get(uri);
      final Map<String, dynamic> data = json.decode(response.body);

      if(response.statusCode == 200 && !data.containsKey('error_message')) {
        final formattedAddress = data['results'][0]['formatted_address'];
        final coords = data['results'][0]['geometry']['location'];
        _locationData = LocationData(
            address: formattedAddress,
            latitude: coords['lat'],
            longitude: coords['lng']);
      }
    } else if (lat == null && lng == null){
      _locationData = widget.product.location;
    } else {
    _locationData = LocationData(address: address, latitude: lat, longitude: lng);
  }

//    final StaticMapProvider staticMapViewProvider =
//        StaticMapProvider('AIzaSyCLQTG59usHzrIRrkQwmb8Pzu8OMqsa7ho');
//    final Uri staticMapUri = staticMapViewProvider.getStaticUriWithMarkers([
//      Marker('position', 'Position', _locationData.latitude,
//          _locationData.longitude)
//    ],
//        center: Location(_locationData.latitude, _locationData.longitude),
//        width: 500,
//        height: 300,
//        maptype: StaticMapViewType.roadmap);

    widget.setLocation(_locationData);

  if(mounted) {
    setState(() {
      _addressInputController.text = _locationData.address;
//      _staticMapUri = staticMapUri;
    });
  }
  }

  Future<String> _getAddress(double lat, double lng) async {
    final Uri uri = Uri.https(
        'maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${lat.toString()},${lng.toString()}',
      'key': 'AIzaSyAoxzEYuqUHKPcaJelPAWweiWVpbXrQXTw'
    });
    final http.Response response = await http.get(uri);
    final Map<String, dynamic> resp = json.decode(response.body);
    final String formattedAddress = resp['results'][0]['formatted_address'];
    return formattedAddress;
  }

  void _getUserLocation() async {
    final location = Location();
    final currentLocation = await location.getLocation();
    final String address = await _getAddress(currentLocation['latitude'], currentLocation['longitude']);
    getStaticMap(address, geocode: false, lat: currentLocation['latitude'], lng: currentLocation['longitude']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          focusNode: _addressInputFocusNode,
          controller: _addressInputController,
          validator: (String value) {
//            if (_locationData == null || value.isEmpty) {
//              return 'No valid location found';
//            }
          },
          decoration: InputDecoration(labelText: 'Address'),
        ),
        SizedBox(
          height: 10.0,
        ),
        FlatButton(child: Text('Locate user'),
        onPressed: _getUserLocation
        ),
        SizedBox(
          height: 10.0,
        ),
        _staticMapUri == null
            ? SizedBox()
            : Image.network(
                _staticMapUri.toString(),
              )
      ],
    );
  }

}
