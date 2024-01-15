import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ColorProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TicTacToe(),
    );
  }
}

class TicTacToe extends StatefulWidget {
  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  late List<List<String>> board;
  late bool isPlayer1Turn; // true: O, false: X
  late bool gameEnded;
  late int player1Wins;
  late int player2Wins;
  late int ties;
  TextEditingController sizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeBoard(3); // 기본적으로 3x3 크기의 보드로 시작
    initializeGameStats();
  }

  void initializeBoard(int size) {
    board = List.generate(size, (i) => List.generate(size, (j) => ''));
    isPlayer1Turn = true;
    gameEnded = false;
  }

  void initializeGameStats() {
    player1Wins = 0;
    player2Wins = 0;
    ties = 0;
  }

  @override
  Widget build(BuildContext context) {
    ColorProvider colorProvider = Provider.of<ColorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tic-Tac-Toe ${board.length}x${board.length}'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10.0),
            child: Row(
              children: [
                const Text('크기:'),
                const SizedBox(width: 5.0),
                SizedBox(
                  width: 50.0,
                  child: TextField(
                    controller: sizeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 5.0),
                ElevatedButton(
                  onPressed: () {
                    changeBoardSize();
                  },
                  child: const Text('확인'),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: board.length,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: board.length * board.length,
            itemBuilder: (context, index) {
              int row = index ~/ board.length;
              int col = index % board.length;
              return GestureDetector(
                onTap: () {
                  if (!gameEnded && board[row][col].isEmpty) {
                    makeMove(row, col);
                  }
                },
                child: Container(
                  color: colorProvider.gameBoxColor, // 게임 박스 색상
                  alignment: Alignment.center,
                  child: Text(
                    board[row][col],
                    style: const TextStyle(fontSize: 30.0),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              resetGame();
            },
            child: const Text('다시하기'),
          ),
          const SizedBox(height: 20.0),
          const Text(
            '게임 기록',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          Text('Player 1 승리: $player1Wins'),
          Text('Player 2 승리: $player2Wins'),
          Text('무승부: $ties'),
        ],
      ),
    );
  }

  void makeMove(int row, int col) {
    setState(() {
      board[row][col] = isPlayer1Turn ? 'O' : 'X';
      isPlayer1Turn = !isPlayer1Turn;
      if (checkWinner(row, col)) {
        gameEnded = true;
        updateGameStats();
        showResetDialog();
      }
    });
  }

  bool checkWinner(int row, int col) {
    // Check row
    if (board[row].every((cell) => cell == board[row][0]) &&
        board[row][0].isNotEmpty) {
      return true;
    }
    // Check column
    if (board.every((row) => row[col] == board[0][col]) &&
        board[0][col].isNotEmpty) {
      return true;
    }
    // Check diagonals
    if ((row == col || row + col == board.length - 1) &&
        (board[0][0] == board[row][col] ||
            (board[0][board.length - 1] == board[row][col] &&
                row + col == board.length - 1))) {
      return board.every((row) => row.every((cell) => cell.isNotEmpty));
    }
    // Check for a tie
    if (!board.any((row) => row.any((cell) => cell.isEmpty))) {
      gameEnded = true;
      ties++;
      showResetDialog();
    }
    return false;
  }

  void resetGame() {
    setState(() {
      initializeBoard(board.length);
      gameEnded = false;
    });
  }

  void showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게임 종료'),
          content: const Text('다시 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text('예'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('아니오'),
            ),
          ],
        );
      },
    );
  }

  void updateGameStats() {
    if (isPlayer1Turn) {
      player2Wins++;
    } else {
      player1Wins++;
    }
  }

  void changeBoardSize() {
    int newSize = int.tryParse(sizeController.text) ?? 3;
    if (newSize >= 3) {
      setState(() {
        initializeBoard(newSize);
      });
    }
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ColorProvider colorProvider = Provider.of<ColorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Map Color:'),
            const SizedBox(height: 10.0),
            Container(
              width: 50.0,
              height: 50.0,
              color: colorProvider.mapColor,
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                _showColorPicker(context, colorProvider, isMapColor: false);
              },
              child: const Text('Change Game Box Color'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showColorPicker(
      BuildContext context, ColorProvider colorProvider,
      {required bool isMapColor}) async {
    Color selectedColor = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: isMapColor
                  ? colorProvider.mapColor
                  : colorProvider.gameBoxColor,
              onColorChanged: (Color color) {
                if (isMapColor) {
                  colorProvider.setMapColor(color);
                } else {
                  colorProvider.setGameBoxColor(color);
                }
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(isMapColor
                    ? colorProvider.mapColor
                    : colorProvider.gameBoxColor);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    colorProvider.setMapColor(selectedColor);
    colorProvider.setGameBoxColor(selectedColor);
  }
}

class ColorProvider extends ChangeNotifier {
  Color _mapColor = Colors.blue; // 기본 색상은 파란색으로 설정
  Color _gameBoxColor = Colors.blue; // 게임 박스 색상

  Color get mapColor => _mapColor;
  Color get gameBoxColor => _gameBoxColor;

  void setMapColor(Color color) {
    _mapColor = color;
    notifyListeners();
  }

  void setGameBoxColor(Color color) {
    _gameBoxColor = color;
    notifyListeners();
  }
}
