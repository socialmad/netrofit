import 'package:flutter/material.dart';
import '../models/country.dart';
import '../theme/neo_theme.dart';
import '../widgets/neo_card.dart';

class CountryDetailPage extends StatelessWidget {
  final Country country;

  const CountryDetailPage({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      appBar: AppBar(
        backgroundColor: NeoColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NeoColors.border),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          country.cca2,
          style: const TextStyle(
            color: NeoColors.border,
            fontWeight: FontWeight.w900,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            color: NeoColors.border,
            height: NeoDimensions.borderWidth,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Flag
            Hero(
              tag: 'flag_${country.cca2}',
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: NeoColors.border,
                    width: NeoDimensions.borderWidth,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: NeoColors.border,
                      offset: NeoDimensions.shadowOffset,
                    ),
                  ],
                ),
                child: Image.network(
                  country.flags.png,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.flag, size: 64),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title Section
            NeoCard(
              backgroundColor: NeoColors.primary,
              child: Column(
                children: [
                  Text(
                    country.name.common.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: NeoColors.light,
                      border: Border.all(width: 2),
                    ),
                    child: Text(
                      country.name.official,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'POPULATION',
                    _formatPopulation(country.population),
                    NeoColors.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'REGION',
                    country.region.toUpperCase(),
                    NeoColors.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'CAPITAL',
                    (country.capital?.firstOrNull ?? 'N/A').toUpperCase(),
                    NeoColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('CODE', country.cca2, Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return NeoCard(
      backgroundColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: NeoColors.dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: NeoColors.dark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatPopulation(int population) {
    if (population >= 1000000000) {
      return '${(population / 1000000000).toStringAsFixed(1)}B';
    } else if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(1)}M';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(1)}K';
    }
    return population.toString();
  }
}
