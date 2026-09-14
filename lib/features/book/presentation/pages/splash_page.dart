import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'library_page.dart';

/// Pantalla de presentación: muestra la imagen de Watson
/// durante 3.5 segundos y entra en la biblioteca.
class SplashPage extends StatefulWidget {
  static const displayDuration = Duration(milliseconds: 3500);

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashPage.displayDuration, _enterLibrary);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _enterLibrary() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (ctx, anim, secAnim) => const LibraryPage(),
        transitionsBuilder: (ctx, animation, secAnim, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1009),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo difuminado de la propia imagen: rellena cualquier
          // pantalla (vertical u horizontal) sin recortes visibles.
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Image.asset(
              'assets/Splash_Watson.jpg',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) =>
                  const SizedBox.shrink(),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.45)),
          // Imagen completa, siempre sin recortes.
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final imageMaxH = constraints.maxHeight * 0.62;
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: imageMaxH),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.amber.shade200,
                                    width: 2),
                                borderRadius:
                                    BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 16,
                                      offset: Offset(0, 6)),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(14),
                                child: Image.asset(
                                  'assets/Splash_Watson.jpg',
                                  fit: BoxFit.contain,
                                  errorBuilder: (ctx, err, stack) =>
                                      const Padding(
                                    padding: EdgeInsets.all(32),
                                    child: Icon(Icons.search,
                                        size: 120,
                                        color: Colors.amber),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Elemental, querido Watson',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                    blurRadius: 8,
                                    color: Colors.black,
                                    offset: Offset(0, 2)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Baker Street 221B, Londres',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              shadows: [
                                Shadow(
                                    blurRadius: 6,
                                    color: Colors.black,
                                    offset: Offset(0, 1)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
