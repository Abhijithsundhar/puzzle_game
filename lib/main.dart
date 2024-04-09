import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MyApp());

class PuzzleBloc extends Cubit<int> {
  PuzzleBloc() : super(0);

  void increment() => emit(state + 1);

  void reset() => emit(0);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => PuzzleBloc(),
        child: PuzzleGame(),
      ),
    );
  }
}

class PuzzleGame extends StatefulWidget {
  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  late List<int> puzzlePieces;
  final int gridSize = 3;
  late PuzzleBloc puzzleBloc;
  late int emptyIndex;
  late Timer timer;
  int secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    initializePuzzle();
    puzzleBloc = BlocProvider.of<PuzzleBloc>(context);
  }

  void initializePuzzle() {
    puzzlePieces = List.generate(gridSize * gridSize, (index) => index);
    puzzlePieces.shuffle();
    emptyIndex = puzzlePieces.indexOf(8);
  }

  bool isPuzzleComplete() {
    for (int i = 0; i < puzzlePieces.length - 1; i++) {
      if (puzzlePieces[i] != i) {
        return false;
      }
    }
    return true;
  }

  void handlePieceTap(int index) {
    int row = index ~/ gridSize;
    int col = index % gridSize;
    int emptyRow = emptyIndex ~/ gridSize;
    int emptyCol = emptyIndex % gridSize;

    if ((row == emptyRow && (col == emptyCol - 1 || col == emptyCol + 1)) ||
        (col == emptyCol && (row == emptyRow - 1 || row == emptyRow + 1))) {
      // Allow moving the piece if it's adjacent to the empty space
      setState(() {
        // Swap the tapped piece with the empty space
        puzzlePieces[emptyIndex] = puzzlePieces[index];
        puzzlePieces[index] = 8;
        emptyIndex = index;

        // Check if the puzzle is complete after the move
        if (isPuzzleComplete()) {
          // Puzzle is complete, you can handle this event
          print("Puzzle Complete!");
          timer.cancel(); // Stop the timer when the puzzle is complete
        }

        puzzleBloc.increment(); // Increment move count
      });
    }
  }

  void resetGame() {
    setState(() {
      initializePuzzle();
      secondsElapsed = 0;
      puzzleBloc.reset();
    });
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Navigate back to home or main menu
              // You can replace this with your own logic
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => handlePieceTap(index),
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    color: Colors.blue,
                    child: Center(
                      child: Text(
                        puzzlePieces[index] == 8
                            ? ''
                            : '${puzzlePieces[index]}',
                        style: TextStyle(fontSize: 24.0, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
              itemCount: puzzlePieces.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Undo logic here (if applicable)
                  },
                  child: Text('Undo'),
                ),
                ElevatedButton(
                  onPressed: resetGame,
                  child: Text('Reset'),
                ),
              ],
            ),
          ),
          BlocBuilder<PuzzleBloc, int>(
            builder: (context, moveCount) {
              return Text(
                'Moves: $moveCount, Time: ${Duration(seconds: secondsElapsed).toString()}',
                style: TextStyle(fontSize: 18.0),
              );
            },
          ),
        ],
      ),
    );
  }
}
