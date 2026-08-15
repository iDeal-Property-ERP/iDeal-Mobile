import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_photo_viewer.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_image.dart';
import 'package:ideal_mobile/widgets/app_top_bar/app_top_bar.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const photos = [
    ListingPhoto(
      id: 1,
      imageUrl: 'https://example.com/one.jpg',
      caption: null,
      isPrimary: true,
      sortOrder: 0,
    ),
    ListingPhoto(
      id: 2,
      imageUrl: 'https://example.com/two.jpg',
      caption: null,
      isPrimary: false,
      sortOrder: 1,
    ),
  ];

  testWidgets('fullscreen images zoom while viewer thumbnails cover', (
    tester,
  ) async {
    await tester.runWidgetTest(child: const ListingPhotoViewer(photos: photos));

    expect(find.byType(PhotoViewGallery), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(find.byType(PhotoViewGestureDetectorScope), findsOneWidget);

    final photoView = tester.widget<PhotoView>(find.byType(PhotoView).first);
    expect(photoView.initialScale, PhotoViewComputedScale.contained);
    expect(photoView.minScale, PhotoViewComputedScale.contained);
    expect(photoView.maxScale, PhotoViewComputedScale.contained * 4);
    expect(
      tester.widget<PageView>(find.byType(PageView)).physics,
      isNot(isA<NeverScrollableScrollPhysics>()),
    );
    expect(
      tester
          .widgetList<ListingCardImage>(find.byType(ListingCardImage))
          .any((image) => image.fit == BoxFit.cover),
      isTrue,
    );
  });

  testWidgets('viewer keeps thumbnail navigation available', (tester) async {
    await tester.runWidgetTest(child: const ListingPhotoViewer(photos: photos));

    expect(
      find.byKey(const Key('listing_photo_viewer_thumbnail_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('listing_photo_viewer_thumbnail_1')),
      findsOneWidget,
    );
  });

  testWidgets('close control stays below the safe-area inset and is tappable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.reset);

    await tester.runWidgetTest(child: const ListingPhotoViewer(photos: photos));

    final close = find.byTooltip('Close');
    expect(close, findsOneWidget);
    expect(tester.getTopLeft(close).dy, 36);
    expect(tester.getSize(close), const Size(44, 44));
    expect(
      tester.widget<AppTopBarAction>(find.byType(AppTopBarAction)),
      isA<AppTopBarAction>(),
    );
    expect(
      tester.widget<AppTopBarAction>(find.byType(AppTopBarAction)).style,
      AppTopBarActionStyle.overlay,
    );
  });
}
