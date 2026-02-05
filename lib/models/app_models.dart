/// Emergency types supported by the platform
enum EmergencyType {
  fire,
  accident,
  medical,
  disaster,
}

extension EmergencyTypeExtension on EmergencyType {
  String get displayName {
    switch (this) {
      case EmergencyType.fire:
        return 'Fire';
      case EmergencyType.accident:
        return 'Accident';
      case EmergencyType.medical:
        return 'Medical Emergency';
      case EmergencyType.disaster:
        return 'Natural Disaster';
    }
  }
  
  String get icon {
    switch (this) {
      case EmergencyType.fire:
        return '🔥';
      case EmergencyType.accident:
        return '🚗';
      case EmergencyType.medical:
        return '🏥';
      case EmergencyType.disaster:
        return '⚠️';
    }
  }
}

/// Incident severity levels
enum SeverityLevel {
  low,
  medium,
  high,
  critical,
}

extension SeverityLevelExtension on SeverityLevel {
  String get displayName {
    switch (this) {
      case SeverityLevel.low:
        return 'Low';
      case SeverityLevel.medium:
        return 'Medium';
      case SeverityLevel.high:
        return 'High';
      case SeverityLevel.critical:
        return 'Critical';
    }
  }
}

/// Incident status for tracking
enum IncidentStatus {
  reported,
  respondersAssigned,
  helpEnRoute,
  onSite,
  resolved,
}

extension IncidentStatusExtension on IncidentStatus {
  String get displayName {
    switch (this) {
      case IncidentStatus.reported:
        return 'Reported';
      case IncidentStatus.respondersAssigned:
        return 'Responders Assigned';
      case IncidentStatus.helpEnRoute:
        return 'Help En Route';
      case IncidentStatus.onSite:
        return 'On Site';
      case IncidentStatus.resolved:
        return 'Resolved';
    }
  }
}

/// User roles in the system
enum UserRole {
  citizen,
  authority,
  volunteer,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.citizen:
        return 'Citizen';
      case UserRole.authority:
        return 'Authority';
      case UserRole.volunteer:
        return 'NGO / Volunteer';
    }
  }
  
  String get description {
    switch (this) {
      case UserRole.citizen:
        return 'Report emergencies and get help quickly';
      case UserRole.authority:
        return 'Coordinate emergency response operations';
      case UserRole.volunteer:
        return 'Assist communities and support relief efforts';
    }
  }
}

/// Task status for volunteers
enum TaskStatus {
  pending,
  active,
  completed,
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.active:
        return 'Active';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}

/// Mock incident model
class Incident {
  final String id;
  final EmergencyType type;
  final SeverityLevel severity;
  final String location;
  final DateTime reportedAt;
  final IncidentStatus status;
  final String description;
  
  const Incident({
    required this.id,
    required this.type,
    required this.severity,
    required this.location,
    required this.reportedAt,
    required this.status,
    required this.description,
  });
  
  String get timeAgo {
    final difference = DateTime.now().difference(reportedAt);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Mock volunteer task model
class VolunteerTask {
  final String id;
  final String title;
  final String description;
  final String location;
  final double distance; // in km
  final TaskStatus status;
  final DateTime createdAt;
  
  const VolunteerTask({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.distance,
    required this.status,
    required this.createdAt,
  });
}

/// Mock timeline event for incident tracking
class TimelineEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  
  const TimelineEvent({
    required this.title,
    required this.description,
    required this.timestamp,
  });
}
