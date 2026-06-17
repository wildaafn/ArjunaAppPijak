import '../../../../shared/domain/models.dart';

abstract class AuditState {}

class AuditInitial extends AuditState {}

class AuditLoading extends AuditState {}

class AuditLoaded extends AuditState {
  final List<AuditPoint> auditPoints;
  final double averageAccuracy;

  AuditLoaded({
    required this.auditPoints,
    required this.averageAccuracy,
  });
}

class AuditError extends AuditState {
  final String message;
  AuditError(this.message);
}
