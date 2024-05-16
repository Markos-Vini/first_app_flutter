import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelectionScreen extends StatefulWidget {
  @override
  _LocationSelectionScreenState createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  late GoogleMapController mapController;
  LatLng _selectedLocation = LatLng(-22.9035, -43.2096); // Posição inicial do mapa

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
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
              mapType: MapType.normal, // Certifique-se de que o tipo de mapa está definido
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Endereço:'),
                TextField(
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
                  onPressed: () {
                    Navigator.pop(context, _selectedLocation);
                  },
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
