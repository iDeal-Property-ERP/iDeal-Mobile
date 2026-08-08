import 'package:ideal_mobile/presentation/home/domain/entities/product.dart';
import 'package:ideal_mobile/utils/typedef.dart';

mixin ProductRepository {
  ResultFuture<List<Product>> getProducts();
}
