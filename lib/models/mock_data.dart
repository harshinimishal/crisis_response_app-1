import 'app_models.dart';

/// Mock data provider - simulates backend responses
class MockDataProvider {
  /// Generate mock incidents for authority dashboard
  static List<Incident> getMockIncidents() {
    final now = DateTime.now();
    
    return [
      Incident(
        id: 'INC-001',
        type: EmergencyType.fire,
        severity: SeverityLevel.critical,
        location: 'Main Street, Downtown',
        reportedAt: now.subtract(const Duration(minutes: 5)),
        status: IncidentStatus.respondersAssigned,
        description: 'Building fire reported with smoke visible',
      ),
      Incident(
        id: 'INC-002',
        type: EmergencyType.medical,
        severity: SeverityLevel.high,
        location: 'Park Avenue, Sector 12',
        reportedAt: now.subtract(const Duration(minutes: 15)),
        status: IncidentStatus.helpEnRoute,
        description: 'Person collapsed, needs immediate medical attention',
      ),
      Incident(
        id: 'INC-003',
        type: EmergencyType.accident,
        severity: SeverityLevel.medium,
        location: 'Highway 101, Exit 45',
        reportedAt: now.subtract(const Duration(hours: 1)),
        status: IncidentStatus.onSite,
        description: 'Two-vehicle collision, minor injuries',
      ),
      Incident(
        id: 'INC-004',
        type: EmergencyType.disaster,
        severity: SeverityLevel.high,
        location: 'Riverside District',
        reportedAt: now.subtract(const Duration(hours: 2)),
        status: IncidentStatus.respondersAssigned,
        description: 'Flooding affecting multiple buildings',
      ),
      Incident(
        id: 'INC-005',
        type: EmergencyType.fire,
        severity: SeverityLevel.low,
        location: 'Oak Street Apartments',
        reportedAt: now.subtract(const Duration(hours: 3)),
        status: IncidentStatus.resolved,
        description: 'Small kitchen fire, contained',
      ),
    ];
  }
  
  /// Generate mock volunteer tasks
  static List<VolunteerTask> getMockVolunteerTasks() {
    final now = DateTime.now();
    
    return [
      VolunteerTask(
        id: 'TASK-001',
        title: 'Food Distribution',
        description: 'Distribute relief supplies to affected families',
        location: 'Community Center, North District',
        distance: 2.3,
        status: TaskStatus.pending,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      VolunteerTask(
        id: 'TASK-002',
        title: 'Medical Camp Support',
        description: 'Assist medical team with patient registration',
        location: 'City Hospital Grounds',
        distance: 5.8,
        status: TaskStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      VolunteerTask(
        id: 'TASK-003',
        title: 'Shelter Setup',
        description: 'Help set up temporary shelter for displaced families',
        location: 'Sports Complex, East Wing',
        distance: 1.5,
        status: TaskStatus.active,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      VolunteerTask(
        id: 'TASK-004',
        title: 'Cleanup Drive',
        description: 'Post-flood cleanup and debris removal',
        location: 'Riverside Park',
        distance: 8.2,
        status: TaskStatus.completed,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
  
  /// Generate mock timeline for incident
  static List<TimelineEvent> getMockTimeline() {
    final now = DateTime.now();
    
    return [
      TimelineEvent(
        title: 'Incident Reported',
        description: 'Emergency reported via mobile app',
        timestamp: now.subtract(const Duration(minutes: 15)),
      ),
      TimelineEvent(
        title: 'Location Verified',
        description: 'GPS coordinates confirmed and validated',
        timestamp: now.subtract(const Duration(minutes: 14)),
      ),
      TimelineEvent(
        title: 'Units Dispatched',
        description: '2 fire trucks and 1 ambulance dispatched',
        timestamp: now.subtract(const Duration(minutes: 12)),
      ),
      TimelineEvent(
        title: 'Responders En Route',
        description: 'ETA: 8 minutes',
        timestamp: now.subtract(const Duration(minutes: 10)),
      ),
      TimelineEvent(
        title: 'On Scene',
        description: 'First responders arrived at location',
        timestamp: now.subtract(const Duration(minutes: 3)),
      ),
    ];
  }
}
