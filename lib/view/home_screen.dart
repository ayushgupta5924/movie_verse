import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../core/enums.dart';
import '../view_model/show_provider.dart';
import '../view_model/theme_provider.dart';
import '../widgets/show_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShowProvider>().loadTrendingShows();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ShowProvider>().loadMoreShows();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ShowProvider>(
          builder: (context, provider, child) {
            String filterName = provider.currentFilter.name;
            filterName = filterName[0].toUpperCase() + filterName.substring(1);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Smollan Movie Verse'),
                Text(
                  filterName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ],
            );
          },
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode),
                onPressed: themeProvider.toggleTheme,
              );
            },
          ),
          Consumer<ShowProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<FilterCategory>(
                onSelected: (filter) => provider.setFilter(filter),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: FilterCategory.trending,
                    child: Text('Trending Movies'),
                  ),
                  const PopupMenuItem(
                    value: FilterCategory.popular,
                    child: Text('Popular Movies'),
                  ),
                  const PopupMenuItem(
                    value: FilterCategory.upcoming,
                    child: Text('Upcoming Movies'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ShowProvider>(
        builder: (context, provider, child) {
          switch (provider.uiState) {
            case UIState.loading:
              return Center(
                child: Lottie.asset(
                  'assets/animations/loading.json',
                  width: 100.w,
                  height: 100.h,
                ),
              );
            case UIState.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/empty.json',
                      width: 150.w,
                      height: 150.h,
                    ),
                    Text(provider.errorMessage ?? 'An error occurred'),
                    ElevatedButton(
                      onPressed: () => provider.loadTrendingShows(),
                      child: const Text('Please Retry'),
                    ),
                  ],
                ),
              );
            case UIState.success:
              if (provider.shows.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/empty.json',
                        width: 150.w,
                        height: 150.h,
                      ),
                      const Text('No shows found'),
                    ],
                  ),
                );
              }
              return GridView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(8.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                ),
                itemCount:
                    provider.shows.length + (provider.isLoadingMore ? 2 : 0),
                itemBuilder: (context, index) {
                  if (index >= provider.shows.length) {
                    return Center(
                      child: Lottie.asset(
                        'assets/animations/loading.json',
                        width: 50.w,
                        height: 50.h,
                      ),
                    );
                  }
                  return AnimatedOpacity(
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    opacity: 1.0,
                    child: ShowCard(show: provider.shows[index]),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
