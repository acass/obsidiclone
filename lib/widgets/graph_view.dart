import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class GraphView extends StatefulWidget {
  const GraphView({super.key});

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  double _zoom = 1.0;
  Offset _panOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Stack(
            children: [
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _panOffset += details.delta;
                  });
                },
                child: CustomPaint(
                  size: Size.infinite,
                  painter: GraphPainter(
                    notes: appState.notes,
                    zoom: _zoom,
                    panOffset: _panOffset,
                  ),
                ),
              ),
              _buildControls(appState),
              _buildZoomInfo(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls(AppState appState) {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _panOffset = Offset.zero;
                  _zoom = 1.0;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _zoom = (_zoom * 1.2).clamp(0.1, 3.0);
                });
              },
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.remove, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _zoom = (_zoom / 1.2).clamp(0.1, 3.0);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomInfo() {
    return Positioned(
      bottom: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${appState.notes.length} notes',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  '0 connections',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  'Zoom: ${(_zoom * 100).round()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final List notes;
  final double zoom;
  final Offset panOffset;

  GraphPainter({
    required this.notes,
    required this.zoom,
    required this.panOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < notes.length; i++) {
      final note = notes[i];
      final angle = (i * 2 * 3.14159) / notes.length;
      final radius = 100 * zoom;
      
      final x = centerX + panOffset.dx + radius * (i == 0 ? 0 : (i == 1 ? 0.5 : -0.5));
      final y = centerY + panOffset.dy + radius * (i == 0 ? -0.5 : (i == 1 ? 0.3 : 0.3));

      canvas.drawCircle(
        Offset(x, y),
        20 * zoom,
        paint,
      );

      textPainter.text = TextSpan(
        text: note.title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12 * zoom,
        ),
      );
      textPainter.layout();
      
      final textOffset = Offset(
        x - textPainter.width / 2,
        y + 25 * zoom,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}