// ignore_for_file: must_be_immutable

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/controllers/main_page_data_controller.dart';
import 'package:movie_app/models/main_page_data.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/models/search_category.dart';
import 'package:movie_app/widgets/movie_tile.dart';

final mainPageDataControllerProvider =
    StateNotifierProvider<MainPageDataController, MainPageData>((ref) {
  return MainPageDataController();
});

final selectedMoviePosterURLProvider = StateProvider<String?>((ref) {
  final _movies = ref.watch(mainPageDataControllerProvider).movies;
  return _movies.isNotEmpty ? _movies[0].posterURL() : null;
});

class MainPage extends ConsumerWidget {
  double? _deviceHeight;
  double? _deviceWidth;
  String? _selectedMoviePosterURL;

  TextEditingController? _searchTextFieldController;
  MainPageDataController? _mainPageDataController;
  MainPageData? _mainPageData;

  MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _searchTextFieldController = TextEditingController();
    _selectedMoviePosterURL = ref.watch(selectedMoviePosterURLProvider);

    _mainPageDataController =
        ref.watch(mainPageDataControllerProvider.notifier);
    _mainPageData = ref.watch(mainPageDataControllerProvider);
    _searchTextFieldController?.text = _mainPageData!.searchText;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SizedBox(
        height: _deviceHeight,
        width: _deviceWidth,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _backgroundWidget(),
            _foregroundWidgets(),
          ],
        ),
      ),
    );
  }

  Widget _backgroundWidget() {
    if (_selectedMoviePosterURL != null) {
      return Container(
        height: _deviceHeight,
        width: _deviceWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: NetworkImage(_selectedMoviePosterURL!),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: _deviceHeight,
        width: _deviceWidth,
        color: Colors.black,
      );
    }
  }

  Widget _foregroundWidgets() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, _deviceHeight! * 0.02, 0, 0),
      width: _deviceWidth! * 0.88,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _topbarWidget(),
          Container(
            height: _deviceHeight! * 0.83,
            padding: EdgeInsets.symmetric(vertical: _deviceHeight! * 0.01),
            child: _moviesListViewWidget(),
          ),
        ],
      ),
    );
  }

  Widget _topbarWidget() {
    return Container(
      height: _deviceHeight! * 0.08,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _searchFieldWidget(),
          _categoryselectionWidget(),
        ],
      ),
    );
  }

  Widget _searchFieldWidget() {
    const _border = InputBorder.none;
    return SizedBox(
      width: _deviceWidth! * 0.5,
      height: _deviceHeight! * 0.05,
      child: TextField(
        controller: _searchTextFieldController,
        onSubmitted: (_input) =>
            _mainPageDataController!.updateTextSearch(_input),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          focusedBorder: _border,
          border: _border,
          prefixIcon: Icon(Icons.search, color: Colors.white24),
          hintStyle: TextStyle(color: Colors.white54),
          fillColor: Colors.white24,
          filled: false,
          hintText: 'Search....',
        ),
      ),
    );
  }

  Widget _categoryselectionWidget() {
    return DropdownButton(
      dropdownColor: Colors.black38,
      value: _mainPageData!.searchCategory,
      icon: const Icon(Icons.menu, color: Colors.white24),
      underline: Container(
        height: 1,
        color: Colors.white24,
      ),
      onChanged: (dynamic _value) => _value.toString().isNotEmpty
          ? _mainPageDataController!.updateSearchCategory(_value)
          : null,
      items: const [
        DropdownMenuItem(
          child: Text(
            SearchCategory.popular,
            style: TextStyle(color: Colors.white),
          ),
          value: SearchCategory.popular,
        ),
        DropdownMenuItem(
          child: Text(
            SearchCategory.upcoming,
            style: TextStyle(color: Colors.white),
          ),
          value: SearchCategory.upcoming,
        ),
        DropdownMenuItem(
          child: Text(
            SearchCategory.none,
            style: TextStyle(color: Colors.white),
          ),
          value: SearchCategory.none,
        ),
      ],
    );
  }

  Widget _moviesListViewWidget() {
    final List<Movie> _movies = _mainPageData!.movies;
    if (_movies.isNotEmpty) {
      return NotificationListener(
        onNotification: (dynamic _onScrollNotification) {
          if (_onScrollNotification is ScrollEndNotification) {
            final before = _onScrollNotification.metrics.extentBefore;
            final max = _onScrollNotification.metrics.maxScrollExtent;
            if (before == max) {
              _mainPageDataController?.getMovies();
              return true;
            }
            return false;
          }
          return false;
        },
        child: ListView.builder(
          itemCount: _movies.length,
          itemBuilder: (BuildContext context, int _count) {
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: _deviceHeight! * 0.01,
                horizontal: 0,
              ),
              child: GestureDetector(
                onTap: () {
                  _selectedMoviePosterURL = _movies[_count].posterURL();
                },
                child: MovieTile(
                  movie: _movies[_count],
                  height: _deviceHeight! * 0.20,
                  width: _deviceWidth! * 0.85,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
      );
    }
  }
}
