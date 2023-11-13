import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: library_prefixes
import 'package:latlong2/latlong.dart' as latLng;
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioSeaMimi',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: IntroductionPage(),
    );
  }
}

class IntroductionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/introduction/ocean_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to BioSeaMimi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 164, 202, 233),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Go see the map !'),
              ),
              SizedBox(height: 100),
              Text(
                'Developped by : \n YEROMONAHOS Léa & PONCET Charline \n\nResearches made by : \n SERRALHEIRO Anthéa & SOULARD Florian \n MASINSKI Yann\n\nSupported by : DISSARD Anne-Marie (<3)' ,
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class AppConstants {
  static const String mapBoxAccessToken =
      'pk.eyJ1IjoiYXJhZW5uIiwiYSI6ImNsb3hibGUwYzA0MHoya3A4ZTVrM3piMHQifQ.60VGzZQuf9pLA1Hc3iRpdg';

  static const String mapBoxStyleId = 'clnrpjn3300ge01pg1hrtcuie';

  static final myLocation = latLng.LatLng(51.5090214, -0.1982948);
}

class MapScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController();
  int selectedMarkerIndex = -1;
  Timer? _highlightTimer;

  void _handleMarkerTap(int markerIndex) {
    String descriptionFilePath = mapMarkers[markerIndex].description!;
    BuildContext currentContext = context;

    loadDescription(descriptionFilePath).then((descriptionContent) {
      Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder: (context) => InfoPage(
            title: mapMarkers[markerIndex].title.toString(),
            imagePath: mapMarkers[markerIndex].descriptionImage.toString().split('assets/').last,
            description: descriptionContent,
            infopagesImage: mapMarkers[markerIndex].infopagesImage.toString().split('assets/').last,
            backgroundOpacity: mapMarkers[markerIndex].backgroundOpacity!.toDouble(),
          ),
        ),
      );
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 15, 127, 192),
      title: const Text('World Map'),
    ),
    body: FlutterMap(
      mapController: mapController,
      options: MapOptions(
        minZoom: 2,
        maxZoom: 10,
        initialZoom: 2,
        initialCenter: AppConstants.myLocation,
        maxBounds: LatLngBounds(
          latLng.LatLng(-85.0, -180.0),
          latLng.LatLng(85.0, 180.0),
        ),
      ),
      children: [
        TileLayer(
          urlTemplate:
              "https://api.mapbox.com/styles/v1/araenn/clnrpjn3300ge01pg1hrtcuie/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYXJhZW5uIiwiYSI6ImNsb3hibGUwYzA0MHoya3A4ZTVrM3piMHQifQ.60VGzZQuf9pLA1Hc3iRpdg",
          additionalOptions: {
            'mapStyleId': AppConstants.mapBoxStyleId,
            'accessToken': AppConstants.mapBoxAccessToken,
          },
        ),
        MarkerLayer(
          markers: [
            for (int i = 0; i < mapMarkers.length; i++)
              Marker(
                height: 100,
                width: 100,
                point: mapMarkers[i].location ?? AppConstants.myLocation,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMarkerIndex = i;
                      _startHighlightTimer();
                      _handleMarkerTap(i);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedMarkerIndex == i
                            ? Colors.black
                            : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: Image.asset(
                      mapMarkers[i].markerImage.toString().split('assets/').last,
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}


  void _startHighlightTimer() {
    _highlightTimer?.cancel();
    _highlightTimer = Timer(Duration(milliseconds: 120), () {
      setState(() {
        selectedMarkerIndex = -1;
      });
    });
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }
}

class MapMarker {
  final String? markerImage;
  final String? descriptionImage;
  final String? title;
  final String? description;
  final String? infopagesImage;
  final latLng.LatLng? location;
  final double? backgroundOpacity;

  MapMarker({
    required this.markerImage,
    required this.descriptionImage,
    required this.title,
    required this.description,
    required this.infopagesImage,
    required this.location,
    this.backgroundOpacity
  });
}


final mapMarkers = [
  MapMarker(
    markerImage: 'assets/images/markers_img/bird.png',
    descriptionImage: 'assets/images/description/bird.png',
    title: 'Bird',
    description: 'descriptions/Lotus.txt',
    infopagesImage: 'assets/images/infopages/lotus.jpg',
    location: latLng.LatLng(20.5090214, -0.1982948),
    backgroundOpacity: 0.5,
  ),
  MapMarker(
    markerImage: 'assets/images/markers_img/lotus.jpg',
    descriptionImage: 'assets/images/description/lotus.jpg',
    title: 'Lotus',
    description: 'descriptions/Lotus.txt',
    infopagesImage: 'assets/images/infopages/lotus.jpg',
    location: latLng.LatLng(50, 100),
    backgroundOpacity: 0.5,
  ),
  MapMarker(
    markerImage: 'assets/images/markers_img/Whale.png',
    descriptionImage: 'assets/images/description/Whale.png',
    title: 'Whale',
    description: 'descriptions/Whales.txt',
    infopagesImage: 'assets/images/infopages/whale.jpg',
    location: latLng.LatLng(50, 40),
    backgroundOpacity: 0.5,
  ),
];

String readDescriptionsFromFileSync(String filePath) {
  File file = File(filePath);
  return file.existsSync() ? file.readAsStringSync() : "blabla";
}

Future<String> loadDescription(String path) async {
  return await rootBundle.loadString(path);
}

class InfoPage extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;
  final String infopagesImage;
  final double backgroundOpacity;

  InfoPage({required this.title, 
  required this.imagePath, 
  required this.description, 
  required this.infopagesImage,
  required this.backgroundOpacity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(infopagesImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(backgroundOpacity), // Appliquer l'opacité ici
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 300, // Définissez la largeur maximale souhaitée ici
                height: 150, // Définissez la hauteur maximale souhaitée ici
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    description,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizPage()),
                );
              },
              child: Text('Do you want to play ?'),
          ),
          ],
        ),
      ),
    ),
    );
  }
}

class QuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mini Quiz'),
      ),
      body: Center(
        child: Text('Quiz Creation Page'),
      ),
    );
  }
}
