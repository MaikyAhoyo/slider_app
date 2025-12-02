import 'package:flutter/material.dart';

class DraggableCar extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;
  final Function(double xPosition)? onPositionChanged;

  const DraggableCar({
    super.key,
    required this.imagePath,
    this.width = 100,
    this.height = 60,
    this.onPositionChanged,
  });

  @override
  State<DraggableCar> createState() => _DraggableCarState();
}

class _DraggableCarState extends State<DraggableCar> {
  double _xPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula los límites para que el carro no salga de la pantalla
        final maxWidth = constraints.maxWidth;
        final carHalfWidth = widget.width / 2;

        // Limita la posición entre los bordes
        final minX = -maxWidth / 2 + carHalfWidth;
        final maxX = maxWidth / 2 - carHalfWidth;

        return Container(
          width: maxWidth,
          height: widget.height + 20,
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(_xPosition, 0),
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _xPosition += details.delta.dx;
                  _xPosition = _xPosition.clamp(minX, maxX);

                  widget.onPositionChanged?.call(_xPosition);
                });
              },
              child: Image.asset(
                widget.imagePath,
                width: widget.width,
                height: widget.height,
                fit: BoxFit.fill,
              ),
            ),
          ),
        );
      },
    );
  }
}

class DraggableCarHorizontal extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;
  final Function(double yPosition)? onPositionChanged;

  const DraggableCarHorizontal({
    super.key,
    required this.imagePath,
    this.width = 60,
    this.height = 100,
    this.onPositionChanged,
  });

  @override
  State<DraggableCarHorizontal> createState() => _DraggableCarHorizontalState();
}

class _DraggableCarHorizontalState extends State<DraggableCarHorizontal> {
  double _yPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final carHalfHeight = widget.height / 2;

        final minY = -maxHeight / 2 + carHalfHeight;
        final maxY = maxHeight / 2 - carHalfHeight;

        return Container(
          width: widget.width + 20,
          height: maxHeight,
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(0, _yPosition),
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _yPosition += details.delta.dy;
                  _yPosition = _yPosition.clamp(minY, maxY);

                  widget.onPositionChanged?.call(_yPosition);
                });
              },
              child: RotatedBox(
                quarterTurns: 1,
                child: Image.asset(
                  widget.imagePath,
                  width: widget.height,
                  height: widget.width,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
