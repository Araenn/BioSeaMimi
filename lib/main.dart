import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'map_markers.dart';
import 'questions.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF124660)),
      ),
      home: IntroductionPage(),
      routes: {
        '/map': (context) => MapScreen(),
        '/introduction': (context) => IntroductionPage(),
      },
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xffF4EBD6)),
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
                style: TextStyle(fontSize: 14, color: Color(0xffF4EBD6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String folderPath = 'images/markers_img/'; // Remplacez par le chemin de votre dossier
List<MapMarker> mapMarkers = loadMarkersFromFiles(folderPath);


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
  
  void pop() {
    Navigator.pop(context);
  }
  

  void _handleMarkerTap(int markerIndex) {
  String descriptionFilePath = mapMarkers[markerIndex].description!;
  String questionsFilePath = mapMarkers[markerIndex].questionsFilePath;

  BuildContext currentContext = context;

  Future.wait([
    loadDescription(descriptionFilePath),
    loadQuestions(questionsFilePath),
  ]).then((List<Object?> results) {
    String descriptionContent = results[0] as String;
  List<Question>? quizQuestions = results[1] as List<Question>?;

  if (quizQuestions != null) {
    // Mettez à jour le champ quizQuestions pour le marqueur actuel
    mapMarkers[markerIndex].quizQuestions = quizQuestions;

    Navigator.push(
      currentContext,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          title: mapMarkers[markerIndex].title.toString(),
          imagePath: mapMarkers[markerIndex].descriptionImage.toString().split('assets/').last,
          description: descriptionContent,
          infopagesImage: mapMarkers[markerIndex].infopagesImage.toString().split('assets/').last,
          backgroundOpacity: mapMarkers[markerIndex].backgroundOpacity!.toDouble(),
          quizQuestions: quizQuestions,
        ),
      ),
    );
    }
  });
}



  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 164, 202, 233),
      title: const Text('World Map', style:TextStyle(color:Color(0xFF124660))),
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
        backgroundColor: Color(0xff709CA7),
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
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/map', // Le nom de la route pour la carte
                    ModalRoute.withName('/map'), // La condition pour retirer toutes les routes jusqu'à '/map'
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:Color.fromARGB(255, 164, 202, 233),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Back to the map'),
                
              ),
          ],
        ),
      ),
    ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final String title;
  final String imagePath;
  final String description;
  final String infopagesImage;
  final double backgroundOpacity;
  final List<Question> quizQuestions;

  QuizPage({
    required this.title,
    required this.imagePath,
    required this.description,
    required this.infopagesImage,
    required this.backgroundOpacity,
    required this.quizQuestions,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int _selectedOptionIndex = -1;
  bool showSeeDetailsButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mini Quiz - ${widget.title}', style:TextStyle(color:Color(0xFF124660))),
        backgroundColor: Color.fromARGB(255, 164, 202, 233),
      ),
      backgroundColor: Color(0XFFB8CBD0),
      body: Center(
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
                    widget.imagePath, // Utilisez la propriété imagePath de widget
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            QuestionWidget(
              question: widget.quizQuestions[currentQuestionIndex],
              selectedOptionIndex: _selectedOptionIndex,
              onOptionSelected: (selectedOptionIndex) {
                setState(() {
                  _selectedOptionIndex = selectedOptionIndex;
                });
              },
            ),
            
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _handleAnswer(_selectedOptionIndex);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 164, 202, 233),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 18),
                ),
              child: Text('Submit Answer'),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _handleAnswer(int selectedOptionIndex) {
    Question currentQuestion = widget.quizQuestions[currentQuestionIndex];

    if (selectedOptionIndex == currentQuestion.correctOptionIndex) {
      // The answer is correct
      correctAnswers++;
    }

    setState(() {
      if (currentQuestionIndex < widget.quizQuestions.length - 1) {
        // Move to the next question
        currentQuestionIndex++;
      } else {
        // All questions have been answered, set showSeeDetailsButton to true
        showSeeDetailsButton = true;
      }
    });

    // If all questions have been answered, display the "See Details" button
    if (showSeeDetailsButton) {
      _showResults();
    }
  }

  void _showResults() {
  // Afficher les résultats
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Quiz Results'),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Text(
        'You answered $correctAnswers questions correctly out of ${widget.quizQuestions.length}.'),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              // Naviguer vers la InfoPage après le quiz
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfoPage(
                    title: widget.title,
                    imagePath: widget.imagePath,
                    description: widget.description,
                    infopagesImage: widget.infopagesImage,
                    backgroundOpacity: widget.backgroundOpacity,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 164, 202, 233),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 18),
                ),
            child: Text('See Details'),
          ),
        ),
      ],
    ),
  );
}
}




class QuestionWidget extends StatelessWidget {
  final Question question;
  final int? selectedOptionIndex;
  final Function(int) onOptionSelected;

  QuestionWidget({
    required this.question,
    required this.selectedOptionIndex,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          question.questionText,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Column(
          children: List.generate(
            question.options.length,
            (index) => RadioListTile<int>(
              title: Text(question.options[index]),
              value: index,
              groupValue: selectedOptionIndex,
              onChanged: (value) {
                onOptionSelected(value!);
              },
            ),
          ),
        ),
      ],
    );
  }
}

