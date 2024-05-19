import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationSelectionScreen extends StatefulWidget {
  @override
  _LocationSelectionScreenState createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  late GoogleMapController mapController;
  LatLng _selectedLocation = LatLng(-22.9035, -43.2096); // Posição inicial do mapa
  TextEditingController _addressController = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  Future<void> _searchAndNavigate() async {
    String address = _addressController.text;
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location firstLocation = locations.first;
        setState(() {
          _selectedLocation = LatLng(firstLocation.latitude!, firstLocation.longitude!);
        });
        mapController.animateCamera(CameraUpdate.newLatLng(_selectedLocation));
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Endereço não encontrado'),
            content: Text('Não foi possível encontrar o endereço informado.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Erro ao buscar endereço: $e');
    }
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
              markers: {
                Marker(
                  markerId: MarkerId('selected_location'),
                  position: _selectedLocation,
                ),
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Digite o endereço:'),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: 'Digite o endereço',
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: _searchAndNavigate,
                      child: Text('Buscar'),
                    ),
                  ],
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
