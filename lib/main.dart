import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const TwoPlayerLudoApp());
}

class TwoPlayerLudoApp extends StatelessWidget {
  const TwoPlayerLudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo Dice (2 Players)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const LudoTwoPlayerHome(),
    );
  }
}

class Player {
  String name;
  int score;
  String avatar; // asset path

  Player({
    required this.name,
    this.score = 0,
    this.avatar = 'assets/avatars/default.png',
  });
}

class LudoTwoPlayerHome extends StatefulWidget {
  const LudoTwoPlayerHome({super.key});

  @override
  State<LudoTwoPlayerHome> createState() => _LudoTwoPlayerHomeState();
}

class _LudoTwoPlayerHomeState extends State<LudoTwoPlayerHome> {
  final List<Player> _players = [
    Player(name: 'Player 1', avatar: 'assets/avatars/player1.png'),
    Player(name: 'Player 2', avatar: 'assets/avatars/player2.png'),
  ];

  int _currentPlayerIndex = 0;
  int _lastRoll = 1;
  final Random _rng = Random();

  void _rollDice() {
    final roll = _rng.nextInt(6) + 1;
    setState(() {
      _lastRoll = roll;
      _players[_currentPlayerIndex].score += roll;
    });
  }

  void _nextPlayer() {
    setState(() {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % 2;
    });
  }

  void _resetGame() {
    setState(() {
      _lastRoll = 1;
      _currentPlayerIndex = 0;
      for (var p in _players) p.score = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Game Reset!')),
    );
  }

  Color _cardColor(int idx) =>
      idx == 0 ? const Color(0xFFEF5350) : const Color(0xFF5C6BC0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎲 Ludo Dice - 2 Players'),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Settings'),
                content: const Text('Settings coming soon!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFFFFA94D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              "It's ${_players[_currentPlayerIndex].name}'s Turn!",
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // 🎲 Dice Image
            Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  'assets/dice/dice$_lastRoll.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.casino, size: 80, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🎯 Roll Button
            ElevatedButton.icon(
              onPressed: _rollDice,
              icon: const Icon(Icons.casino_outlined),
              label: const Text('Roll Dice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple,
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🧾 Scoreboard
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Scoreboard',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < _players.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _cardColor(i),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: AssetImage(_players[i].avatar),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _players[i].name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            _players[i].score.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const Spacer(),

            // 🔘 Floating Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'reset',
                  onPressed: _resetGame,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  child: const Icon(Icons.refresh),
                ),
                FloatingActionButton(
                  heroTag: 'next',
                  onPressed: _nextPlayer,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                  child: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
