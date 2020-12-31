import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import '../../api/repositories.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../shared/app_sheet.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key, required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(reviewsForListingProvider(listingId));
    final listing = ref.watch(listingByIdProvider(listingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        leading: IconButton(
          icon: const Icon(IconsaxPlusLinear.arrow_left_2),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          TwendeSpacing.xxl,
          TwendeSpacing.xl,
          TwendeSpacing.xxl,
          TwendeSpacing.xxxl,
        ),
        children: [
          Text(listing.value?.title ?? 'Listing', style: TwendeTypography.h2),
          const SizedBox(height: TwendeSpacing.xl),
          reviews.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(
              "Couldn't load: $e",
              style: TwendeTypography.body.copyWith(color: TwendeColors.danger),
            ),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: TwendeSpacing.mega,
                  ),
                  child: Center(
                    child: Text('No reviews yet', style: TwendeTypography.body),
                  ),
                );
              }
              return Column(
                children: [
                  for (final r in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: TwendeSpacing.md),
                      child: _ReviewCard(
                        listingId: listingId,
                        reviewId: r.id,
                        author: r.author,
                        rating: r.rating,
                        comment: r.comment,
                        operatorReply: r.operatorReply,
                        when: DateFormat('MMM d, yyyy').format(r.createdAt),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends ConsumerStatefulWidget {
  const _ReviewCard({
    required this.listingId,
    required this.reviewId,
    required this.author,
    required this.rating,
    required this.comment,
    required this.operatorReply,
    required this.when,
  });
  final String listingId;
  final String reviewId;
  final String author;
  final int rating;
  final String comment;
  final String? operatorReply;
  final String when;

  @override
  ConsumerState<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<_ReviewCard> {
  late final TextEditingController _reply;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reply = TextEditingController(text: widget.operatorReply ?? '');
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TwendeSpacing.xl),
      decoration: BoxDecoration(
        color: TwendeColors.surfaceMuted,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(widget.author, style: TwendeTypography.title),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    IconsaxPlusBold.star_1,
                    size: 14,
                    color: i < widget.rating
                        ? TwendeColors.warning
                        : TwendeColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(widget.when, style: TwendeTypography.caption),
          const SizedBox(height: TwendeSpacing.sm),
          Text(widget.comment, style: TwendeTypography.body),
          if ((widget.operatorReply ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: TwendeSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(TwendeSpacing.md),
              decoration: BoxDecoration(
                color: TwendeColors.surface,
                borderRadius: BorderRadius.circular(TwendeSpacing.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your reply', style: TwendeTypography.caption),
                  const SizedBox(height: TwendeSpacing.xs),
                  Text(widget.operatorReply!, style: TwendeTypography.body),
                ],
              ),
            ),
          ],
          const SizedBox(height: TwendeSpacing.lg),
          FilledButton(
            onPressed: _busy ? null : _showReplySheet,
            child: Text(
              (widget.operatorReply ?? '').trim().isEmpty
                  ? 'Reply'
                  : 'Edit reply',
            ),
          ),
        ],
      ),
    );
  }

  void _showReplySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final inset =
            MediaQuery.viewInsetsOf(sheetContext).bottom +
            MediaQuery.viewPaddingOf(sheetContext).bottom;
        return Container(
          decoration: const BoxDecoration(
            color: TwendeColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(TwendeSpacing.radiusXl),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            TwendeSpacing.xxl,
            TwendeSpacing.md,
            TwendeSpacing.xxl,
            TwendeSpacing.xxl + inset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: TwendeSpacing.xl),
                  decoration: BoxDecoration(
                    color: TwendeColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Reply to review', style: TwendeTypography.h2),
              const SizedBox(height: TwendeSpacing.lg),
              TextField(
                controller: _reply,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write a thoughtful reply',
                ),
              ),
              const SizedBox(height: TwendeSpacing.xl),
              ElevatedButton(
                onPressed: () => _submitReply(sheetContext),
                child: const Text('Save reply'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitReply(BuildContext sheetContext) async {
    final reply = _reply.text.trim();
    if (reply.isEmpty) {
      AppSheet.show(context, title: 'Reply is empty', kind: SheetKind.warning);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(listingsRepoProvider)
          .replyToReview(
            listingId: widget.listingId,
            reviewId: widget.reviewId,
            reply: reply,
          );
      ref.invalidate(reviewsForListingProvider(widget.listingId));
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
      if (mounted) {
        AppSheet.toast(context, 'Reply saved', kind: SheetKind.success);
      }
    } catch (e) {
      if (mounted) AppSheet.error(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
