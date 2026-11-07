import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/incident.dart';

extension CategoryUi on IncidentCategory {
  IconData get icon {
    switch (this) {
      case IncidentCategory.facilities:
        return Icons.apartment_rounded;
      case IncidentCategory.water:
        return Icons.water_drop_outlined;
      case IncidentCategory.electricity:
        return Icons.bolt_rounded;
      case IncidentCategory.safety:
        return Icons.shield_outlined;
      case IncidentCategory.sanitation:
        return Icons.delete_outline_rounded;
      case IncidentCategory.furniture:
        return Icons.chair_alt_outlined;
      case IncidentCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case IncidentCategory.facilities:
        return AppColors.teal;
      case IncidentCategory.water:
        return const Color(0xFF2F8FB5);
      case IncidentCategory.electricity:
        return const Color(0xFFD99A1E);
      case IncidentCategory.safety:
        return AppColors.persimmon;
      case IncidentCategory.sanitation:
        return AppColors.moss;
      case IncidentCategory.furniture:
        return const Color(0xFF9A6B4B);
      case IncidentCategory.other:
        return AppColors.lilac;
    }
  }
}

extension StatusUi on IncidentStatus {
  Color get fg {
    switch (this) {
      case IncidentStatus.submitted:
        return const Color(0xFF8A5A00);
      case IncidentStatus.inProgress:
        return const Color(0xFF54448A);
      case IncidentStatus.resolved:
        return const Color(0xFF2F6B3A);
    }
  }

  Color get bg {
    switch (this) {
      case IncidentStatus.submitted:
        return const Color(0xFFFCEBC8);
      case IncidentStatus.inProgress:
        return const Color(0xFFE6E0F3);
      case IncidentStatus.resolved:
        return const Color(0xFFDCEBDC);
    }
  }

  IconData get icon {
    switch (this) {
      case IncidentStatus.submitted:
        return Icons.send_rounded;
      case IncidentStatus.inProgress:
        return Icons.handyman_rounded;
      case IncidentStatus.resolved:
        return Icons.check_rounded;
    }
  }
}
