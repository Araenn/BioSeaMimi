import 'package:latlong2/latlong.dart' as latLng;
import 'dart:io';
import '../questions.dart';

class MapMarker {
  final String? markerImage;
  final String? descriptionImage;
  final String? title;
  final String? description;
  final String? infopagesImage;
  final latLng.LatLng? location;
  final double? backgroundOpacity;
  final String questionsFilePath; // Nouveau champ pour le chemin du fichier de questions
  List<Question>? quizQuestions; // Modification pour permettre la récupération depuis le fichier

  MapMarker({
    required this.markerImage,
    required this.descriptionImage,
    required this.title,
    required this.description,
    required this.infopagesImage,
    required this.location,
    this.backgroundOpacity,
    required this.questionsFilePath,
  });
}

List<MapMarker> loadMarkersFromFiles(String folderPath) {
  // Charger le contenu du fichier de localisation
  String locationsFileContent = File('locations.txt').readAsStringSync();

  // Séparer le contenu en lignes
  List<String> locationLines = locationsFileContent.split('\n');

  // Charger les fichiers d'espèces
  List<FileSystemEntity> files = Directory(folderPath).listSync();

  List<MapMarker> markers = [];

  for (int i = 0; i < files.length; i++) {
    String fileName = files[i].uri.pathSegments.last;
    String name = fileName.split('.').first;

    // Extraire les coordonnées de la ligne correspondante
    String locationLine = locationLines[i].trim();
    List<String> coordinates = locationLine
        .replaceAll('latLng.LatLng(', '')
        .replaceAll(')', '')
        .split(', ')
        .map((coordinate) => coordinate.trim())
        .toList();

double latitude = double.parse(coordinates[0]);
double longitude = double.parse(coordinates[1]);

    // Créer l'objet LatLng
    latLng.LatLng location = latLng.LatLng(latitude, longitude);

    markers.add(MapMarker(
      markerImage: 'assets/images/markers_img/$fileName',
      descriptionImage: 'assets/images/description/$fileName',
      title: name,
      description: 'descriptions/$name.txt',
      infopagesImage: 'assets/images/infopages/$fileName',
      location: location,
      backgroundOpacity: 0.5,
      questionsFilePath: 'questions/$name.txt',
    ));


  }

  return markers;
}