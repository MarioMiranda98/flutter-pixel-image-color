import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Uint8List _imageBytes;
  final int numberOfPixelsPerAixs = 50;
  List<Color> colors = List.empty(growable: true);
  Map<Color, int> predominantColor = {};
  final String _imageUrl =
      'https://i.blogs.es/0b3236/age-of-empires-2-captura/1366_2000.jpg';

  @override
  void initState() {
    _initProcess();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Colors(
                numberOfPixelsPerAixs: numberOfPixelsPerAixs, colors: colors),
            SizedBox(height: 20.0),
            _PredominantColor(predominantColor: predominantColor),
          ],
        ),
      ),
    );
  }

  void _initProcess() async {
    await _readImageBytes();
    await _extractPixelsColors();
  }

  Future<void> _readImageBytes() async {
    _imageBytes =
        (await NetworkAssetBundle(Uri.parse(_imageUrl)).load(_imageUrl))
            .buffer
            .asUint8List();
  }

  Future<void> _extractPixelsColors() async {
    Uint8List values = _imageBytes.buffer.asUint8List();
    image_lib.Image? image = image_lib.decodeImage(values);

    List<image_lib.Pixel> pixels = List.empty(growable: true);

    int width = image!.width;
    int height = image.height;

    int xChunk = width ~/ (numberOfPixelsPerAixs + 1);
    int yChunk = height ~/ (numberOfPixelsPerAixs + 1);

    for (int i = 1; i < numberOfPixelsPerAixs + 1; i++) {
      for (int j = 1; j < numberOfPixelsPerAixs + 1; j++) {
        image_lib.Pixel pixel = image.getPixel(xChunk * j, yChunk * i);
        pixels.add(pixel);
        final aux = Color.fromARGB(
            pixel.a.toInt(), pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
        colors.add(aux);

        if (predominantColor[aux] == null) {
          predominantColor[aux] = 0;
        }

        predominantColor[aux] = (predominantColor[aux]! + 1);
      }
    }

    setState(() {});
  }
}

class _PredominantColor extends StatelessWidget {
  final Map<Color, int> predominantColor;

  _PredominantColor({required this.predominantColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      width: double.infinity,
      child: Row(
        children: [
          Text('Color predominante'),
          _getPredominantColor(),
        ],
      ),
    );
  }

  Widget _getPredominantColor() {
    int value = 0;
    Color color = Colors.black;

    predominantColor.forEach((k, v) {
      if (v > value) {
        value = v;
        color = k;
      }
    });

    return Container(
      width: 50.0,
      height: 50.0,
      margin: EdgeInsets.only(left: 20.0),
      decoration:
          BoxDecoration(color: color, border: Border.all(color: Colors.black)),
    );
  }
}

class _Colors extends StatelessWidget {
  const _Colors({
    required this.numberOfPixelsPerAixs,
    required this.colors,
  });

  final int numberOfPixelsPerAixs;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500.0,
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: numberOfPixelsPerAixs),
        children: List.generate(
            colors.length, (index) => _ColorTile(color: colors[index])),
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  final Color color;

  _ColorTile({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.0),
      decoration:
          BoxDecoration(color: color, border: Border.all(color: Colors.black)),
      width: 100.0,
      height: 100.0,
    );
  }
}
