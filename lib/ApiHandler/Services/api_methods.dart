class ApiMethods {
  static final ApiMethods _apiMethods = ApiMethods._internal();

  factory ApiMethods() {
    return _apiMethods;
  }

  ApiMethods._internal();

  String login = 'login';
  String logout = 'logout';
  String logoutAllDevices = 'logout_all';
  String OtpVerify = 'verify_otp';
  String updateProfile = 'user_edit';
  String registerUser = 'user_register';
   String mobileOtpVerify = 'MobileVerify/mobileOtpVerify';
  String updateToken = 'updatetoken/usercurrenttoken';
  String resetPassword = 'reset_password';
  String sendOtp = 'send_otp';
  String forgotpassword = 'forgot_pass';
  String addphotographer = 'create_photographer';
  String addclient = 'create_client';
  String editClientPhotoApi = 'update_photographer';
  String getProfile = 'get_profile';
  String getphotoclient = 'get_photographer_client_data';
  String getRventstype = 'get_all_cat';
  String addquatation = 'add_quatation';
  String getSetting = 'static_pages';
  String getfaq = 'faq';
  String getPlan = 'get_plans';
  String getQuotation = 'get_quatation';
  String getEventType = 'event_type';
  String getCitiesApi = 'get_cities';
  String getJobsListApi = 'get_job_list';

}