import 'package:flutter/material.dart' ;
import 'package:faker/faker.dart' as fakers;
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    Center(child: Text("Home Screen", style: TextStyle(fontSize: 24))),
    YoloPayScreen(),
    Center(child: Text("Ginie Screen", style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "home"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "yolo pay"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "ginie"),
        ],
      ),
    );
  }
}

class YoloPayScreen extends StatefulWidget {
  @override
  _YoloPayScreenState createState() => _YoloPayScreenState();
}

class _YoloPayScreenState extends State<YoloPayScreen> with SingleTickerProviderStateMixin {
  bool isFrozen = true;
  final faker = fakers.Faker();
  late AnimationController _controller;

  // Number of ice fragments (3x3 grid = 9 pieces)
  final int rows = 3;
  final int cols = 3;
  List<Offset> randomOffsets = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _generateRandomOffsets();
  }

  void _generateRandomOffsets() {
    Random random = Random();
    randomOffsets = List.generate(rows * cols, (index) {
      return Offset(
        random.nextDouble() * 80 - 40, // Random X offset (-40 to +40)
        random.nextDouble() * 80 - 40, // Random Y offset (-40 to +40)
      );
    });
  }

  void _toggleFreeze() {
    setState(() {
      isFrozen = !isFrozen;
      _generateRandomOffsets();
      if (isFrozen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String cardNumber = List.generate(4, (_) => Random().nextInt(8999) + 1000).join(" ");
    String cardHolder = faker.person.name();
    String expiryDate = "${Random().nextInt(12) + 1}/${Random().nextInt(5) + 25}";

    double cardWidth = 350;
    double cardHeight = 200;
    double pieceWidth = cardWidth / cols;
    double pieceHeight = cardHeight / rows;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Text("select payment mode", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("choose your preferred payment method to make payment.", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 20),
            Row(
              children: [
                _buildPaymentModeButton("pay", false),
                SizedBox(width: 10),
                _buildPaymentModeButton("card", true),
              ],
            ),
            SizedBox(height: 30),
            Text("YOUR DIGITAL DEBIT CARD", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 10),

            // Card Stack with Ice Effect
            Stack(
              children: [
                // Card Background
                Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage("assets/card_bg.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(cardNumber, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text(cardHolder, style: GoogleFonts.poppins(fontSize: 14)),
                        Text("Exp: $expiryDate", style: GoogleFonts.poppins(fontSize: 14)),
                      ],
                    ),
                  ),
                ),

                // Ice Fragments
                if (isFrozen)
                  ...List.generate(rows * cols, (index) {
                    int row = index ~/ cols;
                    int col = index % cols;
                    return AnimatedPositioned(
                      duration: Duration(milliseconds: 10000),
                      curve: Curves.easeInOut,
                      left: isFrozen ? col * pieceWidth + randomOffsets[index].dx : col * pieceWidth,
                      top: isFrozen ? row * pieceHeight + randomOffsets[index].dy : row * pieceHeight,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topLeft,
                          widthFactor: 1 / cols,
                          heightFactor: 1 / rows,
                          child: Image.asset(
                            "assets/ice_texture.png", // Ice Texture Image
                            width: cardWidth,
                            height: cardHeight,
                            fit: BoxFit.cover,
                            alignment: Alignment(-1 + (col * 2 / (cols - 1)), -1 + (row * 2 / (rows - 1))),
                          ),
                        ),
                      ),
                    );
                  }),

                // Freeze Button
                Positioned(
                  right: 20,
                  top: 20,
                  child: GestureDetector(
                    onTap: _toggleFreeze,
                    child: Column(
                      children: [
                        Icon(Icons.ac_unit, color: Colors.red),
                        Text(isFrozen ? "unfreeze" : "freeze", style: GoogleFonts.poppins(color: Colors.red, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentModeButton(String label, bool selected) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.red : Colors.white),
        ),
        child: Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
