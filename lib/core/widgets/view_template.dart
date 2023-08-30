import 'package:flutter/material.dart';
import 'package:social_media/core/widgets/app_bar_custom.dart';

class ViewTemplate extends StatelessWidget {
  final Widget widget;
  final String? querySearch;
  const ViewTemplate({
    required this.widget,
    this.querySearch,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sizeWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBarCustom(query: querySearch),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            if (sizeWidth > 720) Expanded(child: Container()),
            Expanded(
              flex: sizeWidth < 1280 ? 2 : 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: widget,
              ),
            ),
            if (sizeWidth > 720) Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}
