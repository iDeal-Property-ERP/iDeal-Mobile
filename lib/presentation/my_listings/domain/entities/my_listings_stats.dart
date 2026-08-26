import 'package:equatable/equatable.dart';

class MyListingsStats extends Equatable {
  const MyListingsStats({
    this.totalCount = 0,
    this.approvedCount = 0,
    this.pendingCount = 0,
    this.rentedCount = 0,
    this.rejectedCount = 0,
    this.archivedCount = 0,
  });

  final int totalCount;
  final int approvedCount;
  final int pendingCount;
  final int rentedCount;
  final int rejectedCount;
  final int archivedCount;

  static const empty = MyListingsStats();

  @override
  List<Object?> get props => [
    totalCount,
    approvedCount,
    pendingCount,
    rentedCount,
    rejectedCount,
    archivedCount,
  ];
}
