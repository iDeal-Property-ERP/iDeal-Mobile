import 'package:ideal_mobile/presentation/product_detail/domain/entities/product_detail.dart';
import 'package:ideal_mobile/utils/typedef.dart';

mixin ProductDetailRepository {
  ResultFuture<ProductDetail> getProductDetail({required String id});
}
