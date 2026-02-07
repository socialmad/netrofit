import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bloc/countries_cubit.dart';
import 'bloc/countries_state.dart';
import 'pages/country_detail_page.dart';
import 'theme/neo_theme.dart';
import 'widgets/neo_card.dart';
import 'widgets/neo_scaffold.dart';
import 'widgets/neo_text_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Netrofit Neo Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
        scaffoldBackgroundColor: NeoColors.background,
      ),
      home: BlocProvider(
        create: (context) => CountriesCubit()..loadCountries(),
        child: const CountriesPage(),
      ),
    );
  }
}

class CountriesPage extends StatefulWidget {
  const CountriesPage({super.key});

  @override
  State<CountriesPage> createState() => _CountriesPageState();
}

class _CountriesPageState extends State<CountriesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<CountriesCubit>().searchCountries(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return NeoScaffold(
      title: 'Countries',
      bottom: NeoTextField(
        controller: _searchController,
        hintText: 'SEARCH COUNTRY...',
        prefixIcon: const Icon(Icons.search, color: NeoColors.dark),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: NeoColors.dark),
          onPressed: () {
            _searchController.clear();
          },
        ),
      ),
      body: BlocBuilder<CountriesCubit, CountriesState>(
        builder: (context, state) {
          if (state is CountriesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: NeoColors.primary),
            );
          }

          if (state is CountriesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: NeoColors.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          if (state is CountriesLoaded) {
            final countries = state.filteredCountries;

            if (countries.isEmpty) {
              return const Center(
                child: Text(
                  'NO COUNTRIES FOUND',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: countries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final country = countries[index];
                return NeoCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CountryDetailPage(country: country),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: NeoColors.border, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: NeoColors.border,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Image.network(
                          country.flags.png,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.flag),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              country.name.common.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              country.region.toUpperCase(),
                              style: const TextStyle(
                                color: NeoColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: NeoColors.border),
                    ],
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
