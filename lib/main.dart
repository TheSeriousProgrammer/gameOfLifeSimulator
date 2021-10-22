import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Simulator(),
      ),
    );
  }
}

class Simulator extends StatefulWidget {
  Simulator({Key key}) : super(key: key);

  @override
  _SimulatorState createState() => _SimulatorState();
}

class _SimulatorState extends State<Simulator> {
  static int xdimension = 15; //matrix dimensions
  static int ydimension = 15;

  var currentMatrix = new List<List<int>>(xdimension);
  var futureMatrix = new List<List<int>>(xdimension);

  bool player = false;

  void initState() {
    super.initState();
    for (int i = 0; i < xdimension; i++) {
      currentMatrix[i] = List<int>(ydimension);
      futureMatrix[i] = List<int>(ydimension);
      for (int j = 0; j < ydimension; j++) {
        if (i == j || i == (ydimension - j - 1)) {
          currentMatrix[i][j] = 1;
        } else {
          currentMatrix[i][j] = 0;
          futureMatrix[i][j] = 0;
        }
      }
    }
    Timer.periodic(Duration(milliseconds: 400), (Timer t) {
      if (player) performNextStep();
    });
  }

  void updateActiveCellFutureState(int i, int j) {
    int sum = 0;
    //adding up values of all spaces surrounded
    for (int k = -1; k < 2; k++) {
      for (int l = -1; l < 2; l++) {
        if (k != 0 || l != 0) {
          sum += (currentMatrix[(i - k) % xdimension][(j - l) % ydimension]);
        }
      }
    }

    if (sum < 2) {
      //Dies due to solitude
      futureMatrix[i][j] = 0;
    } else if (sum < 4) {
      //Survives
      futureMatrix[i][j] = 1;
    } else {
      futureMatrix[i][j] = 0; //Dies to over population
    }
  }

  void updateInActiveCellFutureState(int i, int j) {
    int sum = 0;
    //adding up values of all spaces surrounded
    for (int k = -1; k < 2; k++) {
      for (int l = -1; l < 2; l++) {
        if (k != 0 || l != 0)
          sum += (currentMatrix[(i - k) % xdimension][(j - l) % ydimension]);
      }
    }
    if (sum == 3) {
      futureMatrix[i][j] = 1;
    } else {
      futureMatrix[i][j] =
          2; //Marking as dead , to prevent revisiting vacantbox
    }
  }

  void updateVacantNeighBours(i, j) {
    for (int k = -1; k < 2; k++) {
      for (int l = -1; l < 2; l++) {
        if (k != 0 && l != 0) {
          int x = (i - k) % xdimension;
          int y = (j - l) % ydimension;
          if (currentMatrix[x][y] == 0 && futureMatrix[x][y] != 2) {
            //Checks if current cell is vacant,if vacan checking if its not visited before
            updateInActiveCellFutureState(x, y);
          }
        }
      }
    }
  }

  void performNextStep() {
    for (int i = 0; i < xdimension; i++) {
      for (int j = 0; j < ydimension; j++) {
        futureMatrix[i][j] = currentMatrix[i][j];
      }
    }

    for (int i = 0; i < xdimension; i++) {
      for (int j = 0; j < ydimension; j++) {
        if (currentMatrix[i][j] == 1) {
          //Checking for filled places
          updateVacantNeighBours(i,
              j); //If a filled place is found , then updating the future state of its vacant neighbours
          updateActiveCellFutureState(
              i, j); //Updating the future state of current active cell
        }
      }
    }

    for (int i = 0; i < xdimension; i++) {
      for (int j = 0; j < ydimension; j++) {
        currentMatrix[i][j] = (futureMatrix[i][j] % 2);
      }
    }
    setState(() {
      currentMatrix[0][0] = (currentMatrix[0][0] + 0);
    });

    //Now that the future state is completely determined , upload future state to current state and
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> matrix = List<Widget>(xdimension);
    for (int i = 0; i < xdimension; i++) {
      //x axis
      List<Widget> yAxis = List<Widget>(ydimension);
      for (int j = 0; j < ydimension; j++) {
        //y axis
        yAxis[j] = GestureDetector(
          //padding: EdgeInsets.all(1),
          child: Icon(
            (currentMatrix[i][j] == 1 ? Icons.add_box : Icons.remove),
            size: 18,
          ),
          onTap: () {
            setState(() {
              currentMatrix[i][j] = (currentMatrix[i][j] - 1) %
                  2; //This statement switches 0 to 1 and 1 to 0
            });
          },
        );
      }
      matrix[i] = Column(
        children: yAxis,
        mainAxisSize: MainAxisSize.min,
      );
    }
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Text("The Amazing Game of life simulator",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 30)),
              SizedBox(
                height: 30,
              ),
              Container(
                child: Row(children: matrix, mainAxisSize: MainAxisSize.min),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FloatingActionButton.extended(
                    label: Text("Clear"),
                    onPressed: () {
                      for (int i = 0; i < xdimension; i++) {
                        for (int j = 0; j < ydimension; j++) {
                          currentMatrix[i][j] = 0;
                        }
                      }
                      setState(() {
                        currentMatrix[0][0] = 0 + 0;
                        player = false;
                      });
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  FloatingActionButton.extended(
                    label: Text("Next Step"),
                    onPressed: () {
                      performNextStep();
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  FloatingActionButton.extended(
                    label: Text(player ? "Stop" : "Start"),
                    onPressed: () {
                      setState(() {
                        player = !player;
                      });
                    },
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              FloatingActionButton.extended(
                label: Text("Load Example"),
                onPressed: () {
                  setState(() {
                    player = false;
                    for (int i = 0; i < xdimension; i++) {
                      for (int j = 0; j < ydimension; j++) {
                        if (i == j || i == (ydimension - j - 1)) {
                          currentMatrix[i][j] = 1;
                        } else {
                          currentMatrix[i][j] = 0;
                        }
                      }
                    }
                  });
                },
              ),
              Text(
                """\nSimple Rules

Any live cell with fewer than two live neighbours dies,
as if by underpopulation.

Any live cell with two or three live neighbours lives 
on to the next generation.

Any live cell with more than three live neighbours dies,
as if by overpopulation.

Any dead cell with exactly three live neighbours becomes a live cell,
as if by reproduction.

Dead Cell is denoted by ' -- ' and 
alive cell is denoted by ' + ' """,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
