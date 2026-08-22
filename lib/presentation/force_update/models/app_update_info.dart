import 'package:equatable/equatable.dart';

enum AppUpdateType {
  none,
  normal,
  critical;

  static AppUpdateType fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'critical':
        return AppUpdateType.critical;
      case 'normal':
        return AppUpdateType.normal;
      case 'none':
      default:
        return AppUpdateType.none;
    }
  }
}

class AppUpdateInfo extends Equatable {
  const AppUpdateInfo({
    required this.updateType,
    required this.currentVersion,
    this.latestVersion,
    this.storeUrl,
  });

  factory AppUpdateInfo.none({String currentVersion = ''}) {
    return AppUpdateInfo(
      updateType: AppUpdateType.none,
      currentVersion: currentVersion,
    );
  }

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    final updateTypeStr = json['update_type'] as String?;
    final currentVersion = (json['current_version'] as String?)?.trim() ?? '';
    final latestVersion = (json['latest_version'] as String?)?.trim();
    final storeUrl = (json['store_url'] as String?)?.trim();

    return AppUpdateInfo(
      updateType: AppUpdateType.fromString(updateTypeStr),
      currentVersion: currentVersion,
      latestVersion: latestVersion?.isNotEmpty ?? false ? latestVersion : null,
      storeUrl: storeUrl?.isNotEmpty ?? false ? storeUrl : null,
    );
  }

  final AppUpdateType updateType;
  final String currentVersion;
  final String? latestVersion;
  final String? storeUrl;

  bool get isCritical => updateType == AppUpdateType.critical;
  bool get isNormal => updateType == AppUpdateType.normal;
  bool get hasUpdate => isCritical || isNormal;

  @override
  List<Object?> get props => [
    updateType,
    currentVersion,
    latestVersion,
    storeUrl,
  ];
}
