import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/comments/bloc/comments_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comment/comment.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comment/widgets/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/comments/controller/comments_controller.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';

class CommentsPage extends StatelessWidget {
  const CommentsPage({
    required this.post,
    required this.scrollController,
    required this.draggableScrollController,
    super.key,
  });

  final PostBlock post;
  final ScrollController scrollController;
  final DraggableScrollableController draggableScrollController;

  @override
  Widget build(BuildContext context) {
    final commentsController = CommentsController();

    return BlocProvider(
      create: (context) => CommentsBloc(
        postId: post.id,
        postsRepository: context.read<PostsRepository>(),
      )..add(const CommentsSubscriptionRequested()),
      child: RepositoryProvider.value(
        value: commentsController,
        child: CommentsView(
          post: post,
          scrollController: scrollController,
          scrollableSheetController: draggableScrollController,
        ),
      ),
    );
  }
}

class CommentsView extends StatelessWidget {
  const CommentsView({
    required this.post,
    required this.scrollController,
    required this.scrollableSheetController,
    super.key,
  });

  final PostBlock post;
  final ScrollController scrollController;
  final DraggableScrollableController scrollableSheetController;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.customReversedAdaptiveColor(
      dark: AppColors.background,
      light: AppColors.white,
    );

    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        centerTitle: true,
        toolbarHeight: 24,
        title: Text(
          'Comments',
          style: context.titleLarge?.copyWith(
            color: Colors.grey.shade500,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromRadius(AppSpacing.md),
          child: SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: CommentTextField(
        postId: post.id,
        controller: scrollableSheetController,
      ),
      body: CommentsListView(
        post: post,
        scrollController: scrollController,
      ),
    );
  }
}

class CommentsListView extends StatelessWidget {
  const CommentsListView({
    required this.post,
    required this.scrollController,
    super.key,
  });

  final PostBlock post;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final comments = context.select((CommentsBloc bloc) => bloc.state.comments);

    return CustomScrollView(
      cacheExtent: 2760,
      controller: scrollController,
      slivers: [
        if (comments.isNotEmpty)
          SliverList.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];

              return CommentView(comment: comment, post: post);
            },
          )
        else
          SliverFillRemaining(
            child: Center(
              child: Text(
                'No comments.',
                style: context.headlineSmall,
              ),
            ),
          ),
      ],
    );
  }
}
