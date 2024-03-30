import 'package:bond/features/post/data/api.dart';
import 'package:bond/features/post/data/models/post.dart';
import 'package:bond_core/bond_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'list_state.dart';

final postsProvider =
    AsyncNotifierProvider.autoDispose<PostController, ListState<Post>>(
  () {
    final scrollController = ScrollController();

    return PostController(sl(), scrollController);
  },
);

class PostController extends AutoDisposeAsyncNotifier<ListState<Post>> {
  PostController(this._api, this.scrollController) : super() {
    scrollController.addListener(_scrollControllerListener);
    ref.onDispose(
      () {
        scrollController.dispose();
        scrollController.removeListener(_scrollControllerListener);
      },
    );
  }

  final PostsApi _api;
  final ScrollController scrollController;

  @override
  Future<ListState<Post>> build() async {
    final response = await _api.posts();
    return ListState.data(response);
  }

  void loadMore() async {
    state = AsyncData(state.requireValue.loading());
    state = await AsyncValue.guard(() async {
      final response = await _api.posts();
      return state.requireValue.success(response);
    });
  }

  void _scrollControllerListener() {
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    const delta = 200.0;
    if (maxScroll - currentScroll <= delta &&
        state.value?.status != ListStatus.loading) {
      loadMore();
    }
  }
}
