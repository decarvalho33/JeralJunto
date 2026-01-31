import 'package:flutter/material.dart';

class ScheduleSheetPlaceholder extends StatefulWidget {
  const ScheduleSheetPlaceholder({super.key});

  @override
  State<ScheduleSheetPlaceholder> createState() =>
      _ScheduleSheetPlaceholderState();
}

class _ScheduleSheetPlaceholderState extends State<ScheduleSheetPlaceholder> {
  static const double _minSize = 0.12;
  static const double _initialSize = 0.28;
  static const double _maxSize = 0.80;
  static const Duration _animateDuration = Duration(milliseconds: 260);

  final DraggableScrollableController _controller =
      DraggableScrollableController();

  void _toggleSheet() {
    // ✅ compatível com versões que não têm hasClients
    if (!_controller.isAttached) return;

    final current = _controller.size;
    final target = current <= (_minSize + 0.02) ? _maxSize : _minSize;

    _controller.animateTo(
      target,
      duration: _animateDuration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      controller: _controller,
      initialChildSize: _initialSize,
      minChildSize: _minSize,
      maxChildSize: _maxSize,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBFE),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleSheet,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'Cronograma',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController, // ✅ essencial
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.schedule),
                      title: Text('Atividade ${index + 1}'),
                      subtitle: const Text('Detalhes do plano da party'),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
