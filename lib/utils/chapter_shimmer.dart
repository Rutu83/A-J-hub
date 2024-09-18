import 'package:allinone_app/utils/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ChapterShimmer extends StatelessWidget {
  const ChapterShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ShimmerWidget(
            height: 50,
            width: context.width(),
          ).paddingSymmetric(vertical: 16, horizontal: 16),
          AnimatedListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16, top: 16, right: 16, left: 16),
            itemCount: 20,
            shrinkWrap: true,
            listAnimationType: ListAnimationType.None,
            itemBuilder: (_, index) {
              return Container(
                width: context.width(),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: context.scaffoldBackgroundColor,
                    border: Border.all(color: context.dividerColor),
                    borderRadius: radius()),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerWidget(height: 80, width: 5),
                        5.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                      borderRadius: radius(8),
                                      color: Colors.transparent),
                                  child: ShimmerWidget(
                                      height: 20,
                                      width: context.width() * 0.024),
                                ).flexible(),
                                8.width,
                                const ShimmerWidget(height: 20, width: 10),
                              ],
                            ),
                            4.height,
                            ShimmerWidget(height: 20, width: context.width()),
                            4.height,
                            ShimmerWidget(height: 20, width: context.width()),
                          ],
                        ).expand(),
                      ],
                    ).paddingAll(8),
                    Container(
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: context.cardColor,
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                      ),
                      width: context.width(),
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          8.height,
                          ShimmerWidget(height: 10, width: context.width()),
                          8.height,
                          Divider(height: 0, color: context.dividerColor),
                          ShimmerWidget(height: 10, width: context.width()),
                          8.height,
                          Divider(height: 0, color: context.dividerColor),
                          ShimmerWidget(height: 10, width: context.width()),
                          8.height,
                          Divider(height: 0, color: context.dividerColor),
                          ShimmerWidget(height: 10, width: context.width()),
                          8.height,
                        ],
                      ).paddingAll(8),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
