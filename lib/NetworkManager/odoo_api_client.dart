import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:medicall_app/Models/Clinique/clinique_model.dart';
import 'package:medicall_app/Models/Medical/physician_model.dart';
import 'package:medicall_app/Models/Medical/specialty_model.dart';
import 'package:medicall_app/helper/shared_pref.dart';
import '../Models/Appointment/create_appointment_response.dart';
import '../Models/Authentication/login_response.dart';
import '../Models/Authentication/register_response.dart';
import '../Models/Authentication/send_sms_code_response.dart';
import '../Models/Patient/check_patient_response.dart';
import '../Models/Patient/create_patient_response.dart';
import '../Models/base_response.dart';
import 'package:retrofit/retrofit.dart';
import 'api_url.dart';

part 'odoo_api_client.g.dart';

@RestApi(baseUrl: ApiUrl.baseUrl)
abstract class OdooApiClient {
  factory OdooApiClient(Dio dio) = _OdooApiClient;

  static Future<OdooApiClient> create() async {
    final dio = Dio(BaseOptions(
      receiveTimeout: const Duration(seconds: 15),
      connectTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
    ));

    final client = OdooApiClient(dio);
    await (client as _OdooApiClient)._initializeBaseUrl();
    return client;
  }


  // Authentication Endpoints
  @POST(ApiUrl.sendCodeUrl)
  Future<SendSmsCodeResponse> sendVerificationCode(
    @Body() Map<String, dynamic> body,
  );

  @POST(ApiUrl.registerUrl)
  Future<RegisterResponse> registerUser(
    @Body() Map<String, dynamic> body,
  );

  @POST(ApiUrl.loginUrl)
  Future<LoginResponse> loginUser(
    @Body() Map<String, dynamic> body,
  );

  @POST(ApiUrl.resetPasswordUrl)
  Future<BaseModel> resetPassword(
    @Body() Map<String, dynamic> body,
  );

  // Clinique Endpoints
  @POST(ApiUrl.cliniquesUrl)
  Future<CliniquesResponse> getCliniques();

  // Patient Endpoints
  @POST(ApiUrl.createPatientUrl)
  Future<CreatePatientResponse> createPatient(
    @Body() Map<String, dynamic> body,
  );

  @POST(ApiUrl.checkPatientExistsUrl)
  Future<CheckPatientResponse> checkPatientExists(
    @Body() Map<String, dynamic> body,
  );

  // Appointment Endpoints
  @POST(ApiUrl.createAppointmentUrl)
  Future<CreateAppointmentResponse> createAppointment(
    @Body() Map<String, dynamic> body,
  );
 @GET(ApiUrl.appointmentHistoryUrl)
  Future<AppointmentHistoryItem> getAppointmentHistory();

  // Medical Data Endpoints
  @POST(ApiUrl.specialtiesUrl)
  Future<SpecialtiesResponse> getSpecialties();

  @POST(ApiUrl.physiciansBySpecialtyUrl)
  Future<PhysiciansResponse> getPhysiciansBySpecialty(
    @Body() Map<String, dynamic> body,
  );

  @GET(ApiUrl.physicianDetailsUrl)
  Future<PhysiciansResponse> getPhysicianDetails();
}
