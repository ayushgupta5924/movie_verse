import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/show.dart';
import '../view_model/show_provider.dart';

class ShowDetailsScreen extends StatelessWidget {
  final Show show;

  const ShowDetailsScreen({super.key, required this.show});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300.h,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'show-${show.id}',
                  child: CachedNetworkImage(
                    imageUrl: show.imageUrl ?? '',
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.movie, size: 100),
                    ),
                  ),
                ),
              ),
              actions: [
                Consumer<ShowProvider>(
                  builder: (context, provider, child) {
                    return IconButton(
                      icon: Icon(
                        provider.isFavorite(show)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => provider.toggleFavorite(show),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      show.name,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (show.rating != null)
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20.sp),
                          SizedBox(width: 4.w),
                          Text(
                            show.rating!.toStringAsFixed(1),
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ],
                      ),
                    SizedBox(height: 16.h),
                    if (show.genres.isNotEmpty)
                      Wrap(
                        spacing: 8.w,
                        children: show.genres
                            .map((genre) => Chip(label: Text(genre)))
                            .toList(),
                      ),
                    SizedBox(height: 16.h),
                    if (show.summary != null)
                      Text(
                        show.summary!.replaceAll(RegExp(r'<[^>]*>'), ''),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
