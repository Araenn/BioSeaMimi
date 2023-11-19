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
        child: Stack(
          children: [
            Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Image.asset(
                  'images/logo/logo2cut.png',
                  width: 250,
                  height: 200,
                ),
                SizedBox(height: 40),
                Text(
                  'Welcome to BioSeaMimi',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xffF4EBD6)),
                ),
                SizedBox(height: 70),
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
                  child: Text('Go to the map !'),
                ),
                SizedBox(height: 100),
                Text(
                  'Developped by : \n YEROMONAHOS Léa & PONCET Charline \n\nResearch made by : \n SERRALHEIRO Anthéa & SOULARD Florian \n MASINSKI Yann\n\nSupported by : DISSARD Anne-Marie (<3)' ,
                  style: TextStyle(fontSize: 14, color: Color(0xffF4EBD6)),
                ),
              ],
            ),
          ),
          Positioned(
              left: 16.0, // Ajustez la position horizontale selon vos besoins
              bottom: 16.0, // Ajustez la position verticale selon vos besoins
              child: Image.asset(
                'images/introduction/seatech-208.png',
                width: 50, // Ajustez la largeur selon vos besoins
                height: 50, // Ajustez la hauteur selon vos besoins
              ),
            ),
          ]
          
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
  
  void pop() {
    Navigator.pop(context);
  }
  

  void _handleMarkerTap(int markerIndex) {
  String descriptionFilePath = mapMarkers[markerIndex].description!;
  BuildContext currentContext = context;

  loadDescription(descriptionFilePath).then((descriptionContent) {
    Navigator.push(
      currentContext,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          title: mapMarkers[markerIndex].title.toString(),
          imagePath: mapMarkers[markerIndex].descriptionImage.toString().split('assets/').last,
          description: descriptionContent,
          infopagesImage: mapMarkers[markerIndex].infopagesImage.toString().split('assets/').last,
          backgroundOpacity: mapMarkers[markerIndex].backgroundOpacity!.toDouble(),
          quizQuestions: mapMarkers[markerIndex].quizQuestions,
          
        ),
      ),
    );
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

class MapMarker {
  final String? markerImage;
  final String? descriptionImage;
  final String? title;
  final String? description;
  final String? infopagesImage;
  final latLng.LatLng? location;
  final double? backgroundOpacity;
  final List<Question> quizQuestions;

  MapMarker({
    required this.markerImage,
    required this.descriptionImage,
    required this.title,
    required this.description,
    required this.infopagesImage,
    required this.location,
    this.backgroundOpacity,
    required this.quizQuestions,
  });
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


class Question {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });
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

final mapMarkers = [
  MapMarker(
    markerImage: 'assets/images/markers_img/01_algue_rouge.png',
    descriptionImage: 'assets/images/description/01_algue_rouge.jpg',
    title: 'Red Algae',
    description: 'descriptions/01_algue_rouge.txt',
    infopagesImage: 'assets/images/infopages/01_algue_rouge.png',
    location: latLng.LatLng(-20.7890, 57.5522),
    backgroundOpacity: 0.5,
    quizQuestions: [
      Question(
        questionText: 'Which type of algaes inspires bio-antifouling strategies due to its structure with antimicrobial, anti-algal, and anti-larval properties ?',
        options: ['Red and brown algaes', 'All marine algaes', 'Green algaes', 'None'],
        correctOptionIndex: 1,
      ),
    ],
  ),
  MapMarker(
    markerImage: 'assets/images/markers_img/02_Algue_brune.png',
    descriptionImage: 'assets/images/description/02_Algue_brune.jpg',
    title: 'Brown Algae',
    description: 'descriptions/02_Algue_brune.txt',
    infopagesImage: 'assets/images/infopages/02_Algue_brune.png',
    location: latLng.LatLng(-30.7890, -175.9012),
    backgroundOpacity: 0.5,
    quizQuestions: [
      Question(
  questionText: 'Which type of algaes inspires bio-antifouling strategies due to its structure with antimicrobial, anti-algal, and anti-larval properties ?',
  options: ['Red and brown algaes', 'All marine algaes', 'Green algaes', 'None'],
  correctOptionIndex: 1,
),
    ],
  ),
  MapMarker(
  markerImage: 'assets/images/markers_img/03_Membrane_cellulaire.png',
  descriptionImage: 'assets/images/description/03_Membrane_cellulaire.jpg',
  title: 'Cell Membrane',
  description: 'descriptions/03_Membrane_cellulaire.txt',
  infopagesImage: 'assets/images/infopages/03_Membrane_cellulaire.png',
  location: latLng.LatLng(53.4567, -179.6789),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'In Montpelier, a hybrid technological approach has been developed to desalt three times more seawater consuming 12% less electricity for each treated cubic meter. What inspired this technology ?',
  options: ['Natural filter made of volcanic stones', 'Naturally antibacterial and hypoallergenic flax fabric', 'Cell membranes which are permeable to water molecules while rejecting ions'],
  correctOptionIndex: 2,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/04_meduse.png',
  descriptionImage: 'assets/images/description/04_meduse.jpg',
  title: 'Jellyfish',
  description: 'descriptions/04_meduse.txt',
  infopagesImage: 'assets/images/infopages/04_meduse.png',
  location: latLng.LatLng(25.7890, 165.6789),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'What do electronic and computer components, paints, sunscreens and cosmetics, contrast agents for medical imaging, and medications have in common?',
  options: ['They contain nanoparticles that persist in the environment and are passed down from generation to generation in animal species.', 'They are all non-recyclable.', 'Their use is highly polluting: release of volatile organic compounds, significant energy consumption, etc.'],
  correctOptionIndex: 0,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/05_requin.png',
  descriptionImage: 'assets/images/description/05_requin.jpg',
  title: 'Shark',
  description: 'descriptions/05_requin.txt',
  infopagesImage: 'assets/images/infopages/05_requin.png',
  location: latLng.LatLng(30.6892, -41.0445),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'For what application did researchers at the University of Florida develop a non-polluting coating inspired by shark skin?',
  options: ['Antifouling strategy', 'Waterproofing for raincoats', 'Biodegradable plastic packaging'],
  correctOptionIndex: 0,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/06_Lotus.png',
  descriptionImage: 'assets/images/description/06_Lotus.jpg',
  title: 'Lotus',
  description: 'descriptions/06_Lotus.txt',
  infopagesImage: 'assets/images/infopages/06_Lotus.png',
  location: latLng.LatLng(30.6892, 120.0445),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'Like lotus leaves, rice leaves, reed leaves, rose petals, and cabbage flowers, which have superhydrophobic properties due to their microstructured surface that traps air, what insects already inspire antifouling technologies?',
  options: ['Butterflies', 'Flies', 'Cicadas', 'Bees'],
  correctOptionIndex: 0,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/07_scarabee.png',
  descriptionImage: 'assets/images/description/07_scarabee.jpg',
  title: 'Beetle',
  description: 'descriptions/07_scarabee.txt',
  infopagesImage: 'assets/images/infopages/07_scarabee.png',
  location: latLng.LatLng(27.6891, 24.3319),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'What feature of the desert beetle inspires the mist net?',
  options: ['Special elytra that capture atmospheric moisture.', 'Diet based on air humidity.', 'Ability to store large quantities of water in its body', 'Habit of seeking water in dry environments.'],
  correctOptionIndex: 0,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/08_plante_carnivore.png',
  descriptionImage: 'assets/images/description/08_plante_carnivore.jpg',
  title: 'Carnivorous Plant',
  description: 'descriptions/08_plante_carnivore.txt',
  infopagesImage: 'assets/images/infopages/08_plante_carnivore.png',
  location: latLng.LatLng(0.7893, 113.9213),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'Extremely slippery nano-ridged antifouling coatings are inspired by super-hydrophilic and microstructured surfaces that trap a thin layer of water on which insects slide and eventually fall into the digestive part of the species. Where are these surfaces found?',
  options: ['In the throat of certain birds', 'On the tongue of frogs', 'On the neck of the digestive urn of carnivorous plants Nepenthes'],
  correctOptionIndex: 2,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/09_Poisson.png',
  descriptionImage: 'assets/images/description/09_Poisson.jpg',
  title: 'Fish',
  description: 'descriptions/09_Poisson.txt',
  infopagesImage: 'assets/images/infopages/09_Poisson.png',
  location: latLng.LatLng(75.1234, -0.5678),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'What widely used system does the French company Eel Energy replace by drawing inspiration from the movements of fish tails?',
  options: ['Hydro-turbine propellers', 'Wind turbine blades', 'Swimming pool cleaning robot'],
  correctOptionIndex: 0,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/10_termites.png',
  descriptionImage: 'assets/images/description/10_termites.jpg',
  title: 'Termites',
  description: 'descriptions/10_termites.txt',
  infopagesImage: 'assets/images/infopages/10_termites.png',
  location: latLng.LatLng(20.6891, 0.3319),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'Researchers at Lund University have invented a system inspired by termite mounds that is used to reduce building consumption, like the Eastgate building, which requires only 10% of the energy consumed by a conventional building. What is it?',
  options: ['Staircase and corridor system', 'Water circulation system', 'Air conditioning system'],
  correctOptionIndex: 2,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/12_20_baleine_a_bosse.png',
  descriptionImage: 'assets/images/description/12_20_baleine_a_bosse.jpeg',
  title: 'Humpback Whale',
  description: 'descriptions/12_20_baleine_a_bosse.txt',
  infopagesImage: 'assets/images/infopages/12_20_baleine_a_bosse.png',
  location: latLng.LatLng(20.6891, -156.3319),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'What is better to diminish drag or enhance lift in a wind turbine ?',
  options: ['Smooth and even as a dolphin', 'Rough and uneven as a humpback'],
  correctOptionIndex: 1,
),

  ],
),
MapMarker(
  markerImage: 'assets/images/markers_img/13_Martin_pecheur.png',
  descriptionImage: 'assets/images/description/13_Martin_pecheur.jpg',
  title: 'Kingfisher',
  description: 'descriptions/13_Martin_pecheur.txt',
  infopagesImage: 'assets/images/infopages/13_Martin_pecheur.png',
  location: latLng.LatLng(64.7890, -124.5678),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'In addition to the shape of samaras, which species is the accessory for the PowerCone wind turbine from Biome Renewables inspired by to improve the air distribution towards the blades?',
  options: ['The seagull', 'The polar bear', 'The grasshopper', 'The kingfisher'],
  correctOptionIndex: 3,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/14_Papillon_greta_oto.png',
  descriptionImage: 'assets/images/description/14_Papillon_greta_oto.jpg',
  title: 'Greta Oto Butterfly',
  description: 'descriptions/14_Papillon_greta_oto.txt',
  infopagesImage: 'assets/images/infopages/14_Papillon_greta_oto.png',
  location: latLng.LatLng(16.6895, -97.1234),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'What invention inspired by the transparent and self-cleaning wings of the Greta oto butterfly has improved the production of solar energy?',
  options: ['A coating for solar panels that limits reflected rays', 'A shape of panels that captures more rays', 'A color of solar panels more sensitive to UV', 'All of the above'],
  correctOptionIndex: 0,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/15_tornade.png',
  descriptionImage: 'assets/images/description/15_tornade.jpeg',
  title: 'Tornado',
  description: 'descriptions/15_tornade.txt',
  infopagesImage: 'assets/images/infopages/15_tornade.png',
  location: latLng.LatLng(50.2232, -100.6267),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'What did PAX Scientific decide to market, inspired by the shape of tornadoes and swirls?',
  options: ['Less energy-consuming fans', 'More attractive decorative coils', 'More resistant plumbing conduits'],
  correctOptionIndex: 0,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/16_ours_polaire.png',
  descriptionImage: 'assets/images/description/16_ours_polaire.jpg',
  title: 'Polar Beer',
  description: 'descriptions/16_ours_polaire.txt',
  infopagesImage: 'assets/images/infopages/16_ours_polaire.png',
  location: latLng.LatLng(80.7893, -45.9213),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'For what application did the University of Science and Technology of China develop the bio-inspired Carbon Tube Aerogel based on the structure of polar bear hairs ?',
  options: ['Soft fabrics', 'Thermal insulation', 'Waterproof material', 'As a replacement for artificial turf'],
  correctOptionIndex: 1,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/17_cocotier.png',
  descriptionImage: 'assets/images/description/17_cocotier.jpeg',
  title: 'Coconut Tree',
  description: 'descriptions/17_cocotier.txt',
  infopagesImage: 'assets/images/infopages/17_cocotier.png',
  location: latLng.LatLng(30.3456, -75.5678),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'From which tree did the engineer-researchers at the University of Virginia draw inspiration to invent lightweight and deformable SUMR offshore wind turbine rotors capable of withstanding strong winds?',
  options: ['Oak', 'Coconut tree', 'Olive tree', 'Fir tree'],
  correctOptionIndex: 1,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/18_Blob.png',
  descriptionImage: 'assets/images/description/18_Blob.jpg',
  title: 'Blob',
  description: 'descriptions/18_Blob.txt',
  infopagesImage: 'assets/images/infopages/18_Blob.png',
  location: latLng.LatLng(63.9072, 27.0370),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'What organism is capable of doing the work of dozens of engineers working for years in a week mapping the subway of Tokyo ?',
  options: ['Ants', 'Blob', 'Termite', 'Bees'],
  correctOptionIndex: 1,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/19_arbre.png',
  descriptionImage: 'assets/images/description/19_arbre.jpeg',
  title: 'Tree',
  description: 'descriptions/19_arbre.txt',
  infopagesImage: 'assets/images/infopages/19_arbre.png',
  location: latLng.LatLng(-15.1234, -60.5678),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'What is the common point between a human toilet and tree ?',
  options: ['Use of tree evaporation to disperse water', 'Use of antibacterial envelope', 'Big network under them to collect from the ground'],
  correctOptionIndex: 0,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/20_Tardigrade.png',
  descriptionImage: 'assets/images/description/20_Tardigrade.jpg',
  title: 'Tardigrade',
  description: 'descriptions/20_Tardigrade.txt',
  infopagesImage: 'assets/images/infopages/20_Tardigrade.png',
  location: latLng.LatLng(74.4419, -170.2663),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'How a tardigrade is able to revolutionize medicine ?',
  options: ['Discovery of the secret of non-aging', 'Anti-radiation medicine', 'Disposal of toxic waste', 'Long term storage of vaccine'],
  correctOptionIndex: 3,
),

  ],
),

MapMarker(
  markerImage: 'assets/images/markers_img/21_Stenocara_beetle.png',
  descriptionImage: 'assets/images/description/21_Stenocara_beetle.jpg',
  title: 'Stenocara Beetle',
  description: 'descriptions/21_Stenocara_beetle.txt',
  infopagesImage: 'assets/images/infopages/21_Stenocara_beetle.png',
  location: latLng.LatLng(-6.4321, 22.1234),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'Where do scientists find a solution to transform humidity from the air into drinkable water ?',
  options: ['In the Amazon', 'In the Namibian desert', 'In the Russian tundra', 'In the forest of Europe'],
  correctOptionIndex: 1,
),

  ],
),
MapMarker(
  markerImage: 'assets/images/markers_img/22_fungi.png',
  descriptionImage: 'assets/images/description/22_fungi.jpg',
  title: 'Fungi',
  description: 'descriptions/22_fungi.txt',
  infopagesImage: 'assets/images/infopages/22_fungi.png',
  location: latLng.LatLng(43.5505, 0.4050),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'In construction, heat insulation is a major part of reducing energy consumption. What is an isolation panel outperforming traditional insulation materials made from ?',
  options: ['Wood', 'Mycelium', 'Glass wool'],
  correctOptionIndex: 1,
),

  ],
),
MapMarker(
  markerImage: 'assets/images/markers_img/23_bacillus_bacterium.png',
  descriptionImage: 'assets/images/description/23_bacillus_bacterium.jpg',
  title: 'Bacillus Bacterium',
  description: 'descriptions/23_bacillus_bacterium.txt',
  infopagesImage: 'assets/images/infopages/23_bacillus_bacterium.png',
  location: latLng.LatLng(61.1657, 84.4515),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'What will the next evolution of construction be due to the help of nature ?',
  options: ['Better structure inspired from canopy', 'Auto-healing concrete', 'Living structure'],
  correctOptionIndex: 1,
),

  ],
),
MapMarker(
  markerImage: 'assets/images/markers_img/24_mussels.png',
  descriptionImage: 'assets/images/description/24_mussels.jpg',
  title: 'Mussels',
  description: 'descriptions/24_mussels.txt',
  infopagesImage: 'assets/images/infopages/24_mussels.png',
  location: latLng.LatLng(57.7749, -22.4194),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'How do we prevent underwater adhesive from dispersing itself and polluting the environment ?',
  options: ['Learn from mussel how they attach themselves to rock', 'Learn from coral how they colonize a reef', 'Learn from remora how they stick themselves to shark'],
  correctOptionIndex: 0,
),

  ],
),
MapMarker(
  markerImage: 'assets/images/markers_img/25_coral.png',
  descriptionImage: 'assets/images/description/25_coral.jpg',
  title: 'Coral',
  description: 'descriptions/25_coral.txt',
  infopagesImage: 'assets/images/infopages/25_coral.png',
  location: latLng.LatLng(-31.8136, 174.9631),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'How can we reduce the need for limestone extracted from quarries for cement?',
  options: ['Recycle the old cement with bacteria', 'Extract limestone from water with coral', 'New structure of cement which needed less material for the same result'],
  correctOptionIndex: 1,
),

  ],
),
MapMarker(
  markerImage: 'assets/images/markers_img/26_School_of_fish.png',
  descriptionImage: 'assets/images/description/26_School_of_fish.jpeg',
  title: 'School of Fish',
  description: 'descriptions/26_School_of_fish.txt',
  infopagesImage: 'assets/images/infopages/26_School_of_fish.png',
  location: latLng.LatLng(82.4567, 143.6789),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'How to improve the placement of wind turbines to improve their performance ?',
  options: ['Space them as much as possible', 'Place them In battery like tree farm', 'Position them as a school of fish'],
  correctOptionIndex: 2,
),

  ],
),
MapMarker(
  markerImage: 'assets/images/markers_img/27_Spider_web.png',
  descriptionImage: 'assets/images/description/27_Spider_web.jpeg',
  title: 'Spider Web',
  description: 'descriptions/27_Spider_web.txt',
  infopagesImage: 'assets/images/infopages/27_Spider_web.png',
  location: latLng.LatLng(65.7890, 150.6789),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'How many birds are killed due to collisions with glass windows in Canada ?',
  options: ['70000 per year', '70000 per week', '70000 per day', '70000 per half day'],
  correctOptionIndex: 2,
),

  ],
),
MapMarker(
  markerImage: 'assets/images/markers_img/28_nematode.png',
  descriptionImage: 'assets/images/description/28_nematode.jpeg',
  title: 'Nematode',
  description: 'descriptions/28_nematode.txt',
  infopagesImage: 'assets/images/infopages/28_nematode.png',
  location: latLng.LatLng(35.6789, 70.5678),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'How can we reduce the use of pesticides with more sustainable solutions ?',
  options: ['Use pheromones of certain organisms to control the quality of the soils', 'New type of chemical coming from insect', 'Introduction of a predator bacteria'],
  correctOptionIndex: 0,
),

  ],
),
MapMarker(
  markerImage: 'assets/images/markers_img/29_marine_microorganisms.png',
  descriptionImage: 'assets/images/description/29_marine_microorganisms.jpg',
  title: 'Marine Microorganisms',
  description: 'descriptions/29_marine_microorganisms.txt',
  infopagesImage: 'assets/images/infopages/29_marine_microorganisms.png',
  location: latLng.LatLng(-14.1450, -120.4897),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'The future of biodegradable plastic will come from what ?',
  options: ['The mind of a great scientist', 'The ocean', 'Deep inside of the Amazon'],
  correctOptionIndex: 1,
),

  ],
),
MapMarker(
  markerImage: 'assets/images/markers_img/30_Pax_Lily.png',
  descriptionImage: 'assets/images/description/30_Pax_Lily.jpg',
  title: 'Pax Lily',
  description: 'descriptions/30_Pax_Lily.txt',
  infopagesImage: 'assets/images/infopages/30_Pax_Lily.png',
  location: latLng.LatLng(-33.8688, 151.2093),
  backgroundOpacity: 0.5,
  quizQuestions: [
    Question(
  questionText: 'How were engineers able to reduce by 30% the energy needed to mix tanks of liquid?',
  options: ['By observing plants', 'By observing shells', 'By observing animals', 'Every single precedents answers'],
  correctOptionIndex: 3,
),

  ],
),
];