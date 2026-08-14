class ApiEndpoints {
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  
  static const String usersMe = '/users/me';
  static const String updateLocation = '/users/me/location';
  static const String updateFcmToken = '/users/me/fcm-token';
  
  static const String categories = '/categories';
  
  static const String jobs = '/jobs';
  static const String myJobs = '/jobs/my-jobs';
  
  static String jobById(String id) => '/jobs/$id';
  static String matchProvider(String id) => '/jobs/$id/match';
  static String startJob(String id) => '/jobs/$id/start';
  static String completeJob(String id) => '/jobs/$id/complete';
  static String cancelJob(String id) => '/jobs/$id/cancel';
  
  static String nearbyProviders(String categoryId) => '/users/providers/$categoryId/nearby';
  
  static const String initiatePayment = '/payments/initiate';
  static String paymentByJobId(String jobId) => '/payments/$jobId';
}
