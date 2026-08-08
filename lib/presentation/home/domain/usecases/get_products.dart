import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/home/domain/entities/product.dart';
import 'package:ideal_mobile/presentation/home/domain/repositories/product_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetProducts with UseCaseWithoutParams<List<Product>> {
  const GetProducts(this._repository);

  final ProductRepository _repository;

  @override
  ResultFuture<List<Product>> call() async => _repository.getProducts();
}
