import 'package:flutter/material.dart';
import 'package:preharness/widgets/responsive_scaffold.dart';
import 'package:preharness/routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'ホーム',
      currentPage: AppRoutes.home,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimatedTitle(context),
            const SizedBox(height: 16),
            Text(
              '製造現場をもっとスマートに。\n直感的なUIと高速処理で作業を支援します。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _FeatureCard(
                  icon: Icons.dashboard_customize,
                  title: '圧着作業',
                  description: 'work40',
                  routeName: AppRoutes.work40,
                ),
                _FeatureCard(
                  icon: Icons.file_upload,
                  title: '出荷作業',
                  description: "temp",
                  routeName: AppRoutes.temp,
                ),
                _FeatureCard(
                  icon: Icons.settings,
                  title: '設定',
                  description: 'setting',
                  routeName: AppRoutes.settings,
                ),
                _FeatureCard(
                  icon: Icons.settings,
                  title: 'インポート',
                  description: 'import',
                  routeName: AppRoutes.import,
                ),
                _FeatureCard(
                  icon: Icons.music_note,
                  title: 'リズムゲーム',
                  description: 'Pata-Pon!',
                  routeName: AppRoutes.rhythmGame,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.deepPurple, Colors.pink, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              'PreHarnessPro',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'Montserrat',
                fontSize: 42,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final String routeName;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.routeName,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, widget.routeName),
          child: AnimatedOpacity(
            opacity: _isHovered ? 1.0 : 0.95,
            duration: const Duration(milliseconds: 200),
            child: Material(
              elevation: _isHovered ? 6 : 3,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 240,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(widget.icon, size: 48, color: Colors.deepPurple),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
