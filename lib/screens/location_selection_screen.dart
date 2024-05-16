import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationSelectionScreen extends StatefulWidget {
  @override
  _LocationSelectionScreenState createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  late GoogleMapController? mapController; // Alterado para aceitar nulo inicialmente
  late LatLng _selectedLocation;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(0.0, 0.0); // Coordenadas iniciais
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    mapController?.dispose(); // Dispose apenas se não for nulo
    _addressController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _getAddressFromCoordinates(location);
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
      Placemark placemark = placemarks.first;
      setState(() {
        _addressController.text = '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}';
      });
    } catch (e) {
      setState(() {
        _addressController.text = 'Endereço não encontrado';
      });
    }
  }

  void _selectLocation() {
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecionar Localização'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              onTap: _onMapTap,
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 15,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Endereço:'),
                TextField(
                  controller: _addressController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Clique no mapa para selecionar uma localização',
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _selectLocation,
                  child: Text('Salvar Localização'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
