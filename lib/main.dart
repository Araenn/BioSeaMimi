import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'dart:io';
import 'dart:async';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'BioSeaMimi',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.access_alarm),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,  // ← Here.
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MapScreen(),
                    ),
                  );
                },
                child: Text('Voir la carte'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(pair.asLowerCase, style: style),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}


class AppConstants {
  static const String mapBoxAccessToken =
      'pk.eyJ1IjoiYXJhZW5uIiwiYSI6ImNsbnJwaDBjZjB6em4ycW56NHloNGY3MDUifQ.pbg-ntcCudg9voG_25uCIA';

  static const String mapBoxStyleId = 'clnrpjn3300ge01pg1hrtcuie';

  static final myLocation = latLng.LatLng(51.5090214, -0.1982948);
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController();
  int selectedMarkerIndex = -1;
  Timer? _highlightTimer;

  void _handleMarkerTap(int markerIndex) {
  String descriptionFilePath = mapMarkers[markerIndex].description!;
  String descriptionContent = readDescriptionsFromFileSync(descriptionFilePath);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => InfoPage(
        title: mapMarkers[markerIndex].title.toString(),
        imagePath: mapMarkers[markerIndex].description_image.toString().split('assets/').last,
        description: descriptionContent,
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 15, 127, 192),
        title: const Text('Flutter MapBox'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              minZoom: 1.5,
              maxZoom: 10,
              zoom: 1.5,
              center: AppConstants.myLocation,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/araenn/clnrpjn3300ge01pg1hrtcuie/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYXJhZW5uIiwiYSI6ImNsbnJwaDBjZjB6em4ycW56NHloNGY3MDUifQ.pbg-ntcCudg9voG_25uCIA",
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
                      builder: (_) {
                        return GestureDetector(
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
                            child: Image.asset(mapMarkers[i].marker_image.toString().split('assets/').last),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _startHighlightTimer() {
    // Cancel the previous timer if it exists
    _highlightTimer?.cancel();

    // Start a new timer to reset selectedMarkerIndex after a delay
    _highlightTimer = Timer(Duration(milliseconds: 120), () {
      setState(() {
        selectedMarkerIndex = -1; // Reset to normal state
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer to avoid memory leaks
    _highlightTimer?.cancel();
    super.dispose();
  }
}

class MapMarker {
  final String? marker_image;
  final String? description_image;
  final String? title;
  final String? description;
  final latLng.LatLng? location; // Change to latLng.LatLng

  MapMarker({
    required this.marker_image,
    required this.description_image,
    required this.title,
    required this.description,
    required this.location,
  });
}


final mapMarkers = [
  MapMarker(
    marker_image: 'assets/images/markers_img/bird.png',
    description_image: 'assets/images/description/bird.png',
    title: 'Bird',
    description: 'descriptions/Lotus.txt',
    location: latLng.LatLng(20.5090214, -0.1982948),
  ),
  MapMarker(
    marker_image: 'assets/images/markers_img/lotus.jpg',
    description_image: 'assets/images/description/lotus.jpg',
    title: 'Lotus',
    description: 'descriptions/Lotus.txt',
    location: latLng.LatLng(50, 100),
  ),
  MapMarker(
    marker_image: 'assets/images/markers_img/Whale.png',
    description_image: 'assets/images/description/Whale.png',
    title: 'Whale',
    description: 'descriptions/Whales.txt',
    location: latLng.LatLng(50, 40),
  ),
];

String readDescriptionsFromFileSync(String filePath) {
  File file = File(filePath);
  return file.existsSync() ? file.readAsStringSync() : "";
}


class InfoPage extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;

  InfoPage({required this.title, required this.imagePath, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Description for $title:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
