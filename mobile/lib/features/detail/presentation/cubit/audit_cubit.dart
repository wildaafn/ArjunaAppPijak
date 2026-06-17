import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/data/commodity_repository.dart';
import 'audit_state.dart';

class AuditCubit extends Cubit<AuditState> {
  final ICommodityRepository _repository;

  AuditCubit(this._repository) : super(AuditInitial());

  Future<void> fetchAuditData(String subcategory) async {
    emit(AuditLoading());
    try {
      final points = await _repository.getAuditData(subcategory);
      
      if (points.isEmpty) {
        emit(AuditLoaded(auditPoints: [], averageAccuracy: 100.0));
        return;
      }

      // Calculate MAPE (Mean Absolute Percentage Error)
      double sumAbsoluteError = 0.0;
      for (final pt in points) {
        sumAbsoluteError += pt.residualPct.abs();
      }
      final mape = sumAbsoluteError / points.length;
      final averageAccuracy = (100.0 - mape).clamp(0.0, 100.0);

      emit(AuditLoaded(
        auditPoints: points,
        averageAccuracy: averageAccuracy,
      ));
    } catch (e) {
      emit(AuditError(e.toString()));
    }
  }
}
