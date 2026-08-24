// lib/app/consts/app_permissions.dart

/// Defines string constants for application's permission names.
/// Mirrors the backend AppPermissions.cs and DmsPermissions.cs.
class AppPermissions {
  // ===== COMMON PERMISSIONS (Pages) =====
  static const String pages = "Pages";
  static const String pagesDemoUiComponents = "Pages.DemoUiComponents";
  static const String pagesAdministration = "Pages.Administration";
  static const String pagesDeploymentSystemSetup = "Pages.DeploymentSystemSetup";

  // --- Roles ---
  static const String pagesAdministrationRoles = "Pages.Administration.Roles";
  static const String pagesAdministrationRolesCreate = "Pages.Administration.Roles.Create";
  static const String pagesAdministrationRolesEdit = "Pages.Administration.Roles.Edit";
  static const String pagesAdministrationRolesDelete = "Pages.Administration.Roles.Delete";

  // --- Users ---
  static const String pagesAdministrationUsers = "Pages.Administration.Users";
  static const String pagesAdministrationUsersCreate = "Pages.Administration.Users.Create";
  static const String pagesAdministrationUsersEdit = "Pages.Administration.Users.Edit";
  static const String pagesAdministrationUsersDelete = "Pages.Administration.Users.Delete";
  static const String pagesAdministrationUsersChangePermissions = "Pages.Administration.Users.ChangePermissions";
  static const String pagesAdministrationUsersImpersonation = "Pages.Administration.Users.Impersonation";
  static const String pagesAdministrationUsersUnlock = "Pages.Administration.Users.Unlock";

  // --- Languages ---
  static const String pagesAdministrationLanguages = "Pages.Administration.Languages";
  static const String pagesAdministrationLanguagesCreate = "Pages.Administration.Languages.Create";
  static const String pagesAdministrationLanguagesEdit = "Pages.Administration.Languages.Edit";
  static const String pagesAdministrationLanguagesDelete = "Pages.Administration.Languages.Delete";
  static const String pagesAdministrationLanguagesChangeTexts = "Pages.Administration.Languages.ChangeTexts";

  static const String pagesAdministrationAuditLogs = "Pages.Administration.AuditLogs";

  // --- Organization Units ---
  static const String pagesAdministrationOrganizationUnits = "Pages.Administration.OrganizationUnits";
  static const String pagesAdministrationOrganizationUnitsManageOrganizationTree = "Pages.Administration.OrganizationUnits.ManageOrganizationTree";
  static const String pagesAdministrationOrganizationUnitsManageMembers = "Pages.Administration.OrganizationUnits.ManageMembers";
  static const String pagesAdministrationOrganizationUnitsManageRoles = "Pages.Administration.OrganizationUnits.ManageRoles";

  static const String pagesAdministrationHangfireDashboard = "Pages.Administration.HangfireDashboard";
  static const String pagesAdministrationUiCustomization = "Pages.Administration.UiCustomization";
  
  // --- Webhooks ---
  static const String pagesAdministrationWebhookSubscription = "Pages.Administration.WebhookSubscription";
  static const String pagesAdministrationWebhookSubscriptionCreate = "Pages.Administration.WebhookSubscription.Create";
  static const String pagesAdministrationWebhookSubscriptionEdit = "Pages.Administration.WebhookSubscription.Edit";
  static const String pagesAdministrationWebhookSubscriptionChangeActivity = "Pages.Administration.WebhookSubscription.ChangeActivity";
  static const String pagesAdministrationWebhookSubscriptionDetail = "Pages.Administration.WebhookSubscription.Detail";
  static const String pagesAdministrationWebhookListSendAttempts = "Pages.Administration.Webhook.ListSendAttempts";
  static const String pagesAdministrationWebhookResendWebhook = "Pages.Administration.Webhook.ResendWebhook";

  // --- Dynamic Properties ---
  static const String pagesAdministrationDynamicProperties = "Pages.Administration.DynamicProperties";
  static const String pagesAdministrationDynamicPropertiesCreate = "Pages.Administration.DynamicProperties.Create";
  static const String pagesAdministrationDynamicPropertiesEdit = "Pages.Administration.DynamicProperties.Edit";
  static const String pagesAdministrationDynamicPropertiesDelete = "Pages.Administration.DynamicProperties.Delete";

  static const String pagesAdministrationDynamicPropertyValue = "Pages.Administration.DynamicPropertyValue";
  static const String pagesAdministrationDynamicPropertyValueCreate = "Pages.Administration.DynamicPropertyValue.Create";
  static const String pagesAdministrationDynamicPropertyValueEdit = "Pages.Administration.DynamicPropertyValue.Edit";
  static const String pagesAdministrationDynamicPropertyValueDelete = "Pages.Administration.DynamicPropertyValue.Delete";

  static const String pagesAdministrationDynamicEntityProperties = "Pages.Administration.DynamicEntityProperties";
  static const String pagesAdministrationDynamicEntityPropertiesCreate = "Pages.Administration.DynamicEntityProperties.Create";
  static const String pagesAdministrationDynamicEntityPropertiesEdit = "Pages.Administration.DynamicEntityProperties.Edit";
  static const String pagesAdministrationDynamicEntityPropertiesDelete = "Pages.Administration.DynamicEntityProperties.Delete";

  static const String pagesAdministrationDynamicEntityPropertyValue = "Pages.Administration.DynamicEntityPropertyValue";
  static const String pagesAdministrationDynamicEntityPropertyValueCreate = "Pages.Administration.DynamicEntityPropertyValue.Create";
  static const String pagesAdministrationDynamicEntityPropertyValueEdit = "Pages.Administration.DynamicEntityPropertyValue.Edit";
  static const String pagesAdministrationDynamicEntityPropertyValueDelete = "Pages.Administration.DynamicEntityPropertyValue.Delete";
  
  static const String pagesAdministrationDynamicPropertiesUI = "Pages.Administration.DynamicPropertiesUI";
  static const String pagesAdministrationSettings = "Pages.Administration.Settings";

  // --- TENANT-SPECIFIC ---
  static const String pagesTenantDashboard = "Pages.Tenant.Dashboard";
  static const String pagesAdministrationTenantSettings = "Pages.Administration.Tenant.Settings";
  static const String pagesAdministrationTenantSubscriptionManagement = "Pages.Administration.Tenant.SubscriptionManagement";

  // --- HOST-SPECIFIC ---
  static const String pagesEditions = "Pages.Editions";
  static const String pagesEditionsCreate = "Pages.Editions.Create";
  static const String pagesEditionsEdit = "Pages.Editions.Edit";
  static const String pagesEditionsDelete = "Pages.Editions.Delete";
  static const String pagesEditionsMoveTenantsToAnotherEdition = "Pages.Editions.MoveTenantsToAnotherEdition";

  static const String pagesTenants = "Pages.Tenants";
  static const String pagesTenantsCreate = "Pages.Tenants.Create";
  static const String pagesTenantsEdit = "Pages.Tenants.Edit";
  static const String pagesTenantsChangeFeatures = "Pages.Tenants.ChangeFeatures";
  static const String pagesTenantsDelete = "Pages.Tenants.Delete";
  static const String pagesTenantsImpersonation = "Pages.Tenants.Impersonation";

  static const String pagesAdministrationHostMaintenance = "Pages.Administration.Host.Maintenance";
  static const String pagesAdministrationHostSettings = "Pages.Administration.Host.Settings";
  static const String pagesAdministrationHostDashboard = "Pages.Administration.Host.Dashboard";

  // --- Abp Customize ---
  static const String dashboard = "Pages.Dashboard";
  static const String dashboardWidget = "Pages.DashboardWidget";
  static const String dashboardWidgetCreate = "Pages.DashboardWidget.Create";
  static const String dashboardWidgetEdit = "Pages.DashboardWidget.Edit";
  static const String dashboardWidgetDelete = "Pages.DashboardWidget.Delete";
  
  static const String pagesEmailTemplates = "Pages.EmailTemplates";
  static const String pagesEmailTemplatesCreate = "Pages.EmailTemplates.Create";
  static const String pagesEmailTemplatesEdit = "Pages.EmailTemplates.Edit";
  static const String pagesEmailTemplatesDelete = "Pages.EmailTemplates.Delete";

  static const String currencyRate = "Pages.CurrencyRate";
  static const String currencyRateCreate = "Pages.CurrencyRate.Create";
  static const String currencyRateEdit = "Pages.CurrencyRate.Edit";
  static const String currencyRateDelete = "Pages.CurrencyRate.Delete";
}

/// Defines string constants for Dms specific permission names.
class DmsPermissions {
  static const String report = "Dms.Report";
  static const String employeeReport = "Reporting.Employee.EmployeeReport";
  
  static const String generalSettings = "Dms.GeneralSettings";
  
  // --- Nation ---
  static const String nation = "Dms.Nation";
  static const String nationCreate = "Dms.Nation.Create";
  static const String nationEdit = "Dms.Nation.Edit";
  static const String nationDelete = "Dms.Nation.Delete";

  // --- Ethnic ---
  static const String ethnic = "Dms.Ethnic";
  static const String ethnicCreate = "Dms.Ethnic.Create";
  static const String ethnicEdit = "Dms.Ethnic.Edit";
  static const String ethnicDelete = "Dms.Ethnic.Delete";
  
  // --- Location ---
  static const String location = "Dms.Location";
  static const String cityCreate = "Dms.City.Create";
  static const String cityEdit = "Dms.City.Edit";
  static const String cityDelete = "Dms.City.Delete";
  static const String wardCreate = "Dms.Ward.Create";
  static const String wardEdit = "Dms.Ward.Edit";
  static const String wardDelete = "Dms.Ward.Delete";
  
  static const String category = "Dms.Category";
  static const String tenantInfo = "Dms.TenantInfo";
  static const String tenantInfoEdit = "Dms.TenantInfo.Edit";
  
  // --- Module Hrm ---
  static const String categoryModuleHrm = "Dms.CategoryModuleHrm";
  static const String device = "Dms.Device";
  static const String deviceView = "Dms.Device.View";
  static const String deviceCreate = "Dms.Device.Create";
  static const String deviceEdit = "Dms.Device.Edit";
  static const String deviceDelete = "Dms.Device.Delete";
  
  static const String workShift = "Dms.WorkShift.Index";
  static const String workShiftView = "Dms.WorkShift.View";
  static const String workShiftCreate = "Dms.WorkShift.Create";
  static const String workShiftEdit = "Dms.WorkShift.Edit";
  static const String workShiftDelete = "Dms.WorkShift.Delete";
  
  static const String leaveRequest = "Dms.LeaveRequest";
  static const String leaveRequestView = "Dms.LeaveRequest.View";
  static const String leaveRequestCreate = "Dms.LeaveRequest.Create";
  static const String leaveRequestEdit = "Dms.LeaveRequest.Edit";
  static const String leaveRequestDelete = "Dms.LeaveRequest.Delete";

  static const String categoryModuleMeeting = "Dms.CategoryModuleMeeting";
  static const String categoryModuleRecruitment = "Dms.CategoryModuleRecruitment";
  
  static const String systemAdministration = "Dms.SystemAdministration";
  
  // --- Employee ---
  static const String employee = "Dms.Employee";
  static const String employeeCreate = "Dms.Employee.Create";
  static const String employeeEdit = "Dms.Employee.Edit";
  static const String employeeDelete = "Dms.Employee.Delete";
  static const String employeeResetPassword = "Dms.Employee.ResetPassword";
  
  // --- Department & Position ---
  static const String workDepartment = "Dms.WorkDepartment";
  static const String workDepartmentCreate = "Dms.WorkDepartment.Create";
  static const String workDepartmentEdit = "Dms.WorkDepartment.Edit";
  static const String workDepartmentDelete = "Dms.WorkDepartment.Delete";
  
  static const String workPosition = "Dms.WorkPosition";
  static const String workPositionCreate = "Dms.WorkPosition.Create";
  static const String workPositionEdit = "Dms.WorkPosition.Edit";
  static const String workPositionDelete = "Dms.WorkPosition.Delete";

  static const String moduleHrm = "Dms.ModuleHrm";
  
  // --- Attendance ---
  static const String attendance = "Dms.Attendancel";
  static const String attendanceView = "Dms.Attendancel.View";
  static const String attendanceCreate = "Dms.Attendancel.Create";
  static const String attendanceEdit = "Dms.Attendancel.Edit";
  static const String attendanceDelete = "Dms.Attendancel.Delete";

  static const String moduleMeeting = "Dms.ModuleMeeting";
  static const String meeting = "Dms.Meeting";
  static const String meetingCreate = "Dms.Meeting.Create";
  static const String meetingEdit = "Dms.Meeting.Edit";
  static const String meetingDelete = "Dms.Meeting.Delete";

  static const String moduleRecruitment = "Dms.ModuleRecruitment";
  
  // --- Job Posting ---
  static const String jobPosting = "Dms.JobPosting";
  static const String jobPostingView = "Dms.JobPosting.View";
  static const String jobPostingCreate = "Dms.JobPosting.Create";
  static const String jobPostingEdit = "Dms.JobPosting.Edit";
  static const String jobPostingDelete = "Dms.JobPosting.Delete";
  
  // --- Recruitment Plan ---
  static const String recruitmentPlan = "Dms.RecruitmentPlan.Index";
  static const String recruitmentPlanView = "Dms.RecruitmentPlan.View";
  static const String recruitmentPlanCreate = "Dms.RecruitmentPlan.Create";
  static const String recruitmentPlanEdit = "Dms.RecruitmentPlan.Edit";
  static const String recruitmentPlanDelete = "Dms.RecruitmentPlan.Delete";

  // --- v1 System & Badminton Club Permissions ---
  static const String systemAdministrator = "System.Administrator";

  static const String courtsCreate = "Courts.Create";
  static const String courtsUpdate = "Courts.Update";
  static const String courtsDelete = "Courts.Delete";
  static const String courtsRead = "Courts.Read";

  static const String venuesCreate = "Venues.Create";
  static const String venuesUpdate = "Venues.Update";
  static const String venuesDelete = "Venues.Delete";
  static const String venuesRead = "Venues.Read";

  static const String venueSchedulesCreate = "VenueSchedules.Create";
  static const String venueSchedulesUpdate = "VenueSchedules.Update";
  static const String venueSchedulesDelete = "VenueSchedules.Delete";
  static const String venueSchedulesRead = "VenueSchedules.Read";

  static const String courtPricingsCreate = "CourtPricings.Create";
  static const String courtPricingsUpdate = "CourtPricings.Update";
  static const String courtPricingsDelete = "CourtPricings.Delete";
  static const String courtPricingsRead = "CourtPricings.Read";
}
