import 'package:ierp_mobile/domain/entities/employee.dart';

abstract class ProfileRepository {
  Future<Employee> getProfile(int employeeId);
  Future<void> changeProfile({required Employee employee});
}
