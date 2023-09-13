using log4net;
using Swift.DAL.SwiftDAL;
using System;
using System.Data;

namespace Swift.DAL.OnlineAgent {
  public class OnlineCustomerDao : RemittanceDao {
    private readonly ILog _log = LogManager.GetLogger(typeof(OnlineCustomerDao));
    
    public DbResult RegisterCustomer(OnlineCustomerModel onlineCustomerModel) {
      var sql = "EXEC proc_online_core_customerSetup";
      sql += " @Flag =" + FilterString(onlineCustomerModel.flag);
      sql += ",@customerId =" + FilterString(onlineCustomerModel.customerId);
      sql += ",@user = " + FilterString(onlineCustomerModel.createdBy);
      sql += ",@firstName=" + FilterString(onlineCustomerModel.firstName);
      sql += ",@middleName=" + FilterString(onlineCustomerModel.middleName);
      sql += ",@lastName1=" + FilterString(onlineCustomerModel.lastName1);
      sql += ",@custEmail=" + FilterString(onlineCustomerModel.email);
      sql += ",@custDOB=" + FilterString(onlineCustomerModel.dob);
      sql += ",@custAdd1=" + FilterStringUnicode(onlineCustomerModel.address);
      sql += ",@occupation=" + FilterString(onlineCustomerModel.occupation);
      sql += ",@custCity=" + FilterString(onlineCustomerModel.city);
      sql += ",@custPostal=" + FilterString(onlineCustomerModel.postalCode);
      sql += ",@country=" + FilterString(onlineCustomerModel.country);
      sql += ",@custNativecountry=" + FilterString(onlineCustomerModel.nativeCountry.ToString());
      sql += ",@customerIdType=" + FilterString(onlineCustomerModel.idType);
      sql += ",@customerIdNo=" + FilterStringUnicode(onlineCustomerModel.idNumber);
      sql += ",@custIdissueDate=" + FilterString(onlineCustomerModel.idIssueDate);
      sql += ",@custIdValidDate=" + FilterString(onlineCustomerModel.idExpiryDate);
      sql += ",@custMobile=" + FilterString(onlineCustomerModel.mobile);
      sql += ",@custTelNo=" + FilterString(onlineCustomerModel.telNo);
      sql += ",@ipAddress=" + FilterString(onlineCustomerModel.ipAddress);
      sql += ",@createdBy=" + FilterString(onlineCustomerModel.createdBy);
      sql += ",@custGender=" + FilterString(onlineCustomerModel.gender);
      sql += ",@verifyDoc1=" + FilterString(onlineCustomerModel.verifyDoc1);
      sql += ",@verifyDoc2=" + FilterString(onlineCustomerModel.verifyDoc2);
      sql += ",@verifyDoc3=" + FilterString(onlineCustomerModel.verifyDoc3);
      sql += ",@verifyDoc4=" + FilterString(onlineCustomerModel.verifyDoc4);
      sql += ",@bankId=" + FilterString(onlineCustomerModel.bankId);
      sql += ",@accountNumber=" + FilterString(onlineCustomerModel.accountNumber);
      sql += ",@HasDeclare=" + FilterString(onlineCustomerModel.HasDeclare.ToString());
      return ParseDbResult(sql);
    }

    public DataSet GetCustomerInfo(string user, string custId) {
      var sql = "EXEC proc_Customerinformation @flag='details'";
      sql += " ,@User =" + FilterString(user);
      sql += " ,@customerId =" + FilterString(custId);
      return ExecuteDataset(sql);
    }

    public DataRow GetCustomerData(string user, string customerId) {
      var sql = "EXEC proc_online_core_customerSetup @flag='customerdetail'";
      sql += " ,@User =" + FilterString(user);
      sql += " ,@customerId =" + FilterString(customerId);

      return ExecuteDataRow(sql);
    }

    public DataRow GetCustomerDataForRefund(string user, string customerId) {
      var sql = "EXEC proc_customerRefund @flag='customerdetail'";
      sql += " ,@User =" + FilterString(user);
      sql += " ,@customerId =" + FilterString(customerId);

      return ExecuteDataRow(sql);
    }

    public DbResult AutoSetPassword(string User, string customerId) {
      var sql = "EXEC proc_online_core_customerSetup @flag='autosetpwd'";
      sql += " ,@User =" + FilterString(User);
      sql += " ,@customerId =" + FilterString(customerId);

      return ParseDbResult(sql);
    }

    public DbResult RegisterCustomerNew(OnlineCustomerModel onlineCustomerModel) {
      var sql = "EXEC proc_online_core_customerSetup";
      sql += " @Flag =" + FilterString(onlineCustomerModel.flag);
      sql += " ,@customerId =" + FilterString(onlineCustomerModel.customerId);
      sql += ",@user = " + FilterString(onlineCustomerModel.createdBy);
      sql += ",@customerType = " + FilterString(onlineCustomerModel.isOrg);
      if (onlineCustomerModel.companyName != null && onlineCustomerModel.companyName != "") {
        sql += ",@firstName=" + FilterString(onlineCustomerModel.companyName);
      } else {
        sql += ",@firstName=" + FilterString(onlineCustomerModel.firstName);
      }
      sql += ",@middleName=" + FilterString(onlineCustomerModel.middleName);
      sql += ",@lastName1=" + FilterString(onlineCustomerModel.lastName1);
      sql += ",@custEmail=" + FilterString(onlineCustomerModel.email);
      sql += ",@custDOB=" + FilterString(onlineCustomerModel.dob);
      sql += ",@custAdd1=" + FilterStringUnicode(onlineCustomerModel.address);
      sql += ",@occupation=" + FilterString(onlineCustomerModel.occupation);
      //sql += ",@custCity=" + FilterString(onlineCustomerModel.city);
      sql += ",@cityUnicode=" + FilterStringUnicode(onlineCustomerModel.senderCityjapan);
      sql += ",@streetUnicode=" + FilterStringUnicode(onlineCustomerModel.streetJapanese);
      sql += ",@custPostal=" + FilterString(onlineCustomerModel.postalCode);
      sql += ",@street=" + FilterString(onlineCustomerModel.street);
      sql += ",@state=" + FilterString(onlineCustomerModel.state);
      sql += ",@visaStatus=" + FilterString(onlineCustomerModel.visaStatus);
      sql += ",@employeeBusinessType=" + FilterString(onlineCustomerModel.employeeBusinessType);
      sql += ",@nameofEmployeer=" + FilterString(onlineCustomerModel.nameofEmployeer);
      sql += ",@SSNNO=" + FilterString(onlineCustomerModel.ssnNo);
      sql += ",@zipCode=" + FilterString(onlineCustomerModel.zipCode);
      sql += ",@sourceOfFound=" + FilterString(onlineCustomerModel.sourceOfFound);
      sql += ",@remittanceAllowed=" + onlineCustomerModel.remitanceAllowed;
      sql += ",@onlineUser=" + onlineCustomerModel.onlineUser;
      sql += ",@remarks=" + FilterString(onlineCustomerModel.remarks);
      sql += ",@country=" + FilterString(onlineCustomerModel.country);
      sql += ",@custNativecountry=" + FilterString(onlineCustomerModel.nativeCountry.ToString());
      sql += ",@custCity = " + FilterString(onlineCustomerModel.city).ToString();
      sql += ",@district=" + FilterString(onlineCustomerModel.district.ToString());
      sql += ",@customerIdType=" + FilterString(onlineCustomerModel.idType);
      sql += ",@customerIdNo=" + FilterStringUnicode(onlineCustomerModel.idNumber);
      sql += ",@custIdissueDate=" + FilterString(onlineCustomerModel.idIssueDate);
      sql += ",@custIdValidDate=" + FilterString(onlineCustomerModel.idExpiryDate);
      sql += ",@custMobile=" + FilterString(onlineCustomerModel.mobile);
      sql += ",@custTelNo=" + FilterString(onlineCustomerModel.telNo);
      sql += ",@ipAddress=" + FilterString(onlineCustomerModel.ipAddress);
      sql += ",@createdBy=" + FilterString(onlineCustomerModel.createdBy);
      sql += ",@custGender=" + FilterString(onlineCustomerModel.gender);
      sql += ",@bankId=" + FilterString(onlineCustomerModel.bankName).ToString();
      sql += ",@accountNumber=" + FilterString(onlineCustomerModel.accountNumber);
      sql += ",@nameOfAuthorizedPerson=" + FilterString(onlineCustomerModel.nameofAuthoPerson);
      sql += ",@registerationNo=" + FilterString(onlineCustomerModel.registrationNo);
      sql += ",@organizationType=" + FilterString(onlineCustomerModel.organizationType);
      sql += ",@dateOfIncorporation=" + FilterString(onlineCustomerModel.dateOfIncorporation);
      sql += ",@natureOfCompany=" + FilterString(onlineCustomerModel.natureOfCompany);
      sql += ",@position=" + FilterString(onlineCustomerModel.position);
      sql += ",@membershipId=" + FilterString(onlineCustomerModel.membershipId);
      sql += ",@companyName=" + FilterString(onlineCustomerModel.companyName);
      sql += ",@monthlyIncome=" + FilterString(onlineCustomerModel.MonthlyIncome);
      sql += ",@isCounterVisited=" + FilterString(onlineCustomerModel.IsCounterVisited);
      sql += ",@newPassword=" + FilterString(onlineCustomerModel.customerPassword);
      sql += ",@additionalAddress=" + FilterStringUnicode(onlineCustomerModel.AdditionalAddress);
      sql += ",@loginBranchId=" + FilterString(onlineCustomerModel.agentId.ToString());
      sql += ",@docType=" + FilterString(onlineCustomerModel.DocumentType);
      sql += ",@occupType=" + FilterString(onlineCustomerModel.occupType);
      sql += ",@isOrg=" + FilterString(onlineCustomerModel.isOrg);
      sql += ",@userName=" + FilterString(onlineCustomerModel.userName);
      sql += ",@nonMonPep=" + FilterString(onlineCustomerModel.nonMonPep);
      _log.Debug("Core RegisterCustomerNew : " + sql);
      return ParseDbResult(sql);
    }

    public DataRow GetCustomerDetails(string customerId, string user) {
      var sql = "EXEC proc_online_core_customerSetup";
      sql += " @Flag ='customer-details'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      return ExecuteDataRow(sql);
    }

    public DataRow GetBlackListAccount(string accountNum) {
      string sql = "Exec [proc_updateBlacklisted]";
      sql += " @holdFlg=" + FilterString("getData");
      sql += ", @accNum=" + FilterString(accountNum);
      var dt = ExecuteDataRow(sql);
      return dt;
    }

    public DbResult DeleteReceiver(string customerId, string user) {
      var sql = "EXEC proc_online_receiverSetup";
      sql += " @Flag ='d'";
      sql += ",@receiverId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      return ParseDbResult(sql);
    }

    public DataTable GetCustomerDetailsWitDT(string customerId, string user) {
      var sql = "EXEC proc_online_core_customerSetup";
      sql += " @Flag ='customer-details'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      return ExecuteDataTable(sql);
    }

    public DataTable GetDetailsForEditCustomer(string customerId, string user) {
      var sql = "EXEC proc_online_core_customerSetup";
      sql += " @Flag ='customer-details'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      return ExecuteDataTable(sql);
    }

    public DataTable GetCity(string provinceId) {
      var sql = "EXEC proc_online_dropDownList @flag='city',@provinceId =" + FilterString(provinceId);
      return ExecuteDataTable(sql);
    }

    public DataTable GetProvince(string nativeId) {
      var sql = "EXEC proc_online_dropDownList @flag='province' ,@countryId =" + FilterString(nativeId);
      return ExecuteDataTable(sql);
    }

    public DataTable GetIdType(string nativeId, string userId) {
      var sql = "EXEC proc_online_dropDownList @flag='IdTypeWithDetails',@user='" + userId + "',@countryId=" + FilterString(nativeId);
      return ExecuteDataTable(sql);
    }

    public DataRow GetVerifyCustomerDetails(string customerId, string user) {
      var sql = "EXEC proc_online_core_customerSetup";
      sql += " @Flag ='verify-customer-details'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      return ExecuteDataRow(sql);
    }

    public DataSet GetVerifyCustomerDetailsNew(string customerId, string user) {
      var sql = "EXEC proc_online_core_customerSetup";
      sql += " @Flag ='verify-customer-details'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      return ExecuteDataset(sql);
    }

    public DataTable GetDocumentByCustomerId(string customerId) {
      string sql = "Exec proc_customerDocumentType @flag='getDocByCustomerId' ,@customerId=" + FilterString(customerId);
      return ExecuteDataTable(sql);
    }

    public DbResult VerifyCustomer(string customerId, string user) {
      var sql = "EXEC proc_online_core_customerSetup";
      sql += " @Flag ='verify-customer-agent'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      return ParseDbResult(sql);
    }

    public DbResult VerifyPending(string customerId, string user) {
      var sql = "EXEC proc_online_approve_Customer";
      sql += " @Flag ='verify-pending'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      return ParseDbResult(sql);
    }

    public DataSet ApprovePending(string customerId, string user, string BankAccName) {
      var sql = "EXEC proc_online_approve_Customer";
      sql += " @Flag ='approve-pending'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      sql += ",@CustomerBankName =N" + FilterString(BankAccName);
      return ExecuteDataset(sql);
    }

    public DataSet RejectPending(string customerId, string user, string BankAccName) {
      var sql = "EXEC proc_online_approve_Customer";
      sql += " @Flag ='reject-pending'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      sql += ",@CustomerBankName =N" + FilterString(BankAccName);
      return ExecuteDataset(sql);
    }

    public DbResult UpdateObpId(string customerId, string user, string obpId) {
      var sql = "EXEC proc_online_approve_Customer";
      sql += " @Flag ='update-obpId'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@obpId =" + FilterString(obpId);
      sql += ",@user =" + FilterString(user);

      return ParseDbResult(sql);
    }

    public DbResult RequestLog(string requestJson) {
      var sql = "EXEC ws_proc_VirtualAccountDepositNotification @flag='i'";
      sql += " ,@RequestJSon =N" + FilterString(requestJson);
      return ParseDbResult(sql);
    }

    public DataRow GetCustomerForModification(string User, string id) {
      var sql = "EXEC proc_online_core_customerSetup @flag='kj-modificationList'";
      sql += " ,@User =" + FilterString(User);
      sql += " ,@customerId =" + FilterString(id);
      return ExecuteDataRow(sql);
    }

    public DbResult UpdateCustomer(string User, string id, string Depositor) {
      var sql = "EXEC proc_online_core_customerSetup @flag='kj-modification'";
      sql += " ,@User =" + FilterString(User);
      sql += " ,@customerId =" + FilterString(id);
      sql += " ,@fullName =N" + FilterString(Depositor);
      return ParseDbResult(sql);
    }

    public DbResult ResetPassword(string User, string newPassword, string customerId, string email = null) {
      var sql = "EXEC proc_online_core_customerSetup @flag='resetpwd'";
      sql += " ,@User =" + FilterString(User);
      sql += " ,@customerId =" + FilterString(customerId);
      sql += " ,@newPassword =" + FilterString(newPassword);
      sql += " ,@custEmail =" + FilterString(email);

      return ParseDbResult(sql);
    }

    public DataTable GetCustomerDetailsByCustomerId(string customerId, string user) {
      string sql = "exec proc_core_GetCustomerDetailsByCustomerId";
      sql += " @flag ='s'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      var dt = ExecuteDataTable(sql);
      return dt;
    }

    public string GetEmail(string customerId, string user) {
      string sql = "exec proc_online_core_customerSetup";
      sql += " @flag ='sEmail'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);

      return GetSingleResult(sql);
    }

    public DataRow GetCustomerDetailsForEdit(string customerId, string user) {
      var sql = "EXEC proc_online_core_customerManage";
      sql += " @Flag ='s-customer'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      return ExecuteDataRow(sql);
    }

    public DbResult EnableDisable(string customerId, string user, string isActive) {
      string sql = "exec proc_online_core_customerManage";
      sql += " @flag ='enable-disable'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      sql += ",@isActive =" + FilterString(isActive);

      return ParseDbResult(sql);
    }

    public DbResult ModifyCustomer(OnlineCustomerModel onlineCustomerModel) {
      var sql = "EXEC proc_online_core_customerManage";
      sql += " @Flag =" + FilterString(onlineCustomerModel.flag);
      sql += ",@customerId =" + FilterString(onlineCustomerModel.customerId);
      sql += ",@custEmail = " + FilterString(onlineCustomerModel.email);
      sql += ",@firstName = " + FilterString(onlineCustomerModel.firstName);
      sql += ",@user = " + FilterString(onlineCustomerModel.createdBy);
      sql += ",@custAdd1 = " + FilterStringUnicode(onlineCustomerModel.address);
      sql += ",@occupation = " + FilterString(onlineCustomerModel.occupation);
      sql += ",@custCity = " + FilterString(onlineCustomerModel.city);
      sql += ",@country = " + FilterString(onlineCustomerModel.country);
      sql += ",@custNativecountry = " + FilterString(onlineCustomerModel.nativeCountry.ToString());
      sql += ",@customerIdType = " + FilterString(onlineCustomerModel.idType);
      sql += ",@customerIdNo = " + FilterStringUnicode(onlineCustomerModel.idNumber);
      sql += ",@custIdissueDate = " + FilterString(onlineCustomerModel.idIssueDate);
      sql += ",@custIdValidDate = " + FilterString(onlineCustomerModel.idExpiryDate);
      sql += ",@custMobile = " + FilterString(onlineCustomerModel.mobile);
      sql += ",@custTelNo = " + FilterString(onlineCustomerModel.telNo);
      sql += ",@custGender = " + FilterString(onlineCustomerModel.gender);
      sql += ",@verifyDoc1 = " + FilterString(onlineCustomerModel.verifyDoc1);
      sql += ",@verifyDoc2 = " + FilterString(onlineCustomerModel.verifyDoc2);
      sql += ",@verifyDoc3 = " + FilterString(onlineCustomerModel.verifyDoc3);
      sql += ",@verifyDoc4=" + FilterString(onlineCustomerModel.verifyDoc4);
      sql += ",@bankId = " + FilterString(onlineCustomerModel.bankId);
      sql += ",@accountNumber = " + FilterString(onlineCustomerModel.accountNumber);
      sql += ",@dob = " + FilterString(onlineCustomerModel.dob);
      sql += ",@expiryDate = " + FilterString(onlineCustomerModel.idExpiryDate);
      sql += ",@issueDate = " + FilterString(onlineCustomerModel.idIssueDate);
      return ParseDbResult(sql);
    }

    public DataRow GetCustomerDetailForBankUpdate(string searchBy, string user, string searchValue) {
      string sql = "exec proc_customerBankModify";
      sql += " @flag ='S'";
      sql += ",@searchKey =" + FilterString(searchBy);
      sql += ",@user =" + FilterString(user);
      sql += ",@searchValue =" + FilterString(searchValue);

      return ExecuteDataRow(sql);
    }

    public DataRow GetAddressByZipCode(string zipCode, string user) {
      string sql = "exec proc_customerBankModify";
      sql += " @flag ='customerZip'";
      sql += ",@user =" + FilterString(user);
      sql += ",@searchKey =" + FilterString(zipCode);

      return ExecuteDataRow(sql);
    }

    public DataTable GetAddressByZipCodeNew(string zipCode, string user, string rowId) {
      string sql = "exec proc_customerBankModify";
      sql += " @flag ='customerZip'";
      sql += ",@user =" + FilterString(user);
      sql += ",@searchKey =" + FilterString(zipCode);
      sql += ",@rowId =" + FilterString(rowId);

      return ExecuteDataTable(sql);
    }

    public DataRow GetCustomerDetailForVerification(string searchBy, string user, string searchValue) {
      string sql = "exec proc_customerBankModify";
      sql += " @flag ='customervf'";
      sql += ",@searchKey =" + FilterString(searchBy);
      sql += ",@user =" + FilterString(user);
      sql += ",@searchValue =" + FilterString(searchValue);

      return ExecuteDataRow(sql);
    }

    public DbResult UpdateCustomerBankDetail(string user, string customerId, string newBank, string newAccNumber, string acNameInBank, string imageName) {
      string sql = "exec proc_customerBankModify";
      sql += " @flag ='U'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      sql += ",@bankId =" + FilterString(newBank);
      sql += ",@accNumber =" + FilterString(newAccNumber);
      sql += ",@acNameInBank =N" + FilterString(acNameInBank);
      sql += ",@verifyDoc3 =" + FilterString(imageName);

      return ParseDbResult(sql);
    }

    public DbResult AuditDocument(string id, string User) {
      string sql = "exec proc_customerBankModify";
      sql += " @flag ='Audit'";
      sql += ",@customerId =" + FilterString(id);
      sql += ",@user =" + FilterString(User);

      return ParseDbResult(sql);
    }

    public DataSet ApproveReject(string user, string type, string customerId) {
      string sql = "exec PROC_KFTC_APPROVE_REJECT";
      sql += " @flag ='approve-reject'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      sql += ",@type =" + FilterString(type);

      return ExecuteDataset(sql);
    }

    public DbResult InsertCustomerKYC(string user, string customerId, string kycmethod, string kycstatus, string selecteddate, string remarkstext, string trackNo = "") {
      string sql = "EXEC proc_customerKYC";
      sql += " @flag = 'i'";
      sql += ", @user = " + FilterString(user);
      sql += ", @customerId = " + FilterString(customerId);
      sql += ", @kycmethod = " + FilterString(kycmethod);
      sql += ", @kycstatus = " + FilterString(kycstatus);
      sql += ", @selecteddate = " + FilterString(selecteddate);
      sql += ", @remarkstext = " + FilterStringUnicode(remarkstext);
      sql += ", @trackingNo = " + FilterStringUnicode(trackNo);

      return ParseDbResult(sql);
    }

    public DbResult AddAndUpdateCustomerDocument(OnlineCustomerModel onlineCustomer) {
      var sql = "EXEC proc_online_core_customerSetup";
      sql += " @Flag =" + FilterString(onlineCustomer.flag);
      sql += ",@customerId =" + FilterString(onlineCustomer.customerId);
      sql += ",@verifyDoc1=" + FilterString(onlineCustomer.verifyDoc1); /////////// passport
      sql += ",@verifyDoc2=" + FilterString(onlineCustomer.verifyDoc2); /////////// id fornt
      sql += ",@verifyDoc3=" + FilterString(onlineCustomer.verifyDoc3); /////////// Id Back
      sql += ",@verifyDoc4=" + FilterString(onlineCustomer.verifyDoc4); /////////// selfie
      return ParseDbResult(sql);
    }

    public DbResult DeleteCustomerKYC(string st_id, string user) {
      string sql = "Exec [proc_customerKYC]";
      sql += " @flag ='d'";
      sql += ", @user=" + FilterString(user);
      sql += ", @rowid=" + FilterString(st_id);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DbResult DeleteCustomer(string st_id, string user) {
      string sql = "Exec proc_online_core_customerSetup";
      sql += " @flag ='delete'";
      sql += ", @user=" + FilterString(user);
      sql += ", @rowid=" + FilterString(st_id);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DbResult AddCustomerSignature(string customerId, string user, string fileName) {
      string sql = "exec proc_customerDocumentType @flag='AddSignature',@customerId =" + FilterString(customerId);
      sql += " ,@user=" + FilterString(user);
      sql += " ,@fileName=" + FilterString(fileName);
      return ParseDbResult(sql);
    }

    public DbResult UpdateCustomerDocument(string cdId, string customerId, string fileName, string fileDescription, string fileType, string documentType, string user) {
      string sql = "exec proc_customerDocumentType";
      if (cdId != "") {
        sql += " @flag ='u'";
      } else {
        sql += " @flag ='i'";
      }
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@cdId =" + FilterString(cdId);
      sql += ",@fileName =" + FilterString(fileName);
      sql += ",@fileDescription =" + FilterString(fileDescription);
      sql += ",@fileType =" + FilterString(fileType);
      sql += ",@documentType =" + FilterString(documentType);
      sql += ",@user =" + FilterString(user);

      return ParseDbResult(sql);
    }

    public DataRow GetCustomerDocumentByDocumentId(string documentId, string user) {
      var sql = "EXEC proc_customerDocumentType @flag='getById'";
      sql += " ,@user =" + FilterString(user);
      sql += " ,@cdId =" + FilterString(documentId);
      return ExecuteDataRow(sql);
    }

    public DbResult UpdateBenificiarInformation(BenificiarData benificiar, string user) {
      string sql = "exec proc_online_receiverSetup";
      sql += " @flag =" + FilterString(benificiar.Flag);
      sql += ",@country =" + FilterString(benificiar.Country);
      sql += ",@nativeCountry =" + FilterString(benificiar.NativeCountry);
      sql += ",@receiverType =" + FilterString(benificiar.BenificiaryType);
      sql += ",@email =" + FilterString(benificiar.Email);
      sql += ",@firstName =" + FilterString(benificiar.ReceiverFName);
      sql += ",@middleName =" + FilterString(benificiar.ReceiverMName);
      sql += ",@lastName1 =" + FilterString(benificiar.ReceiverLName);
      sql += ",@lastName2 =" + FilterString(benificiar.ReceiverLName2);
      sql += ",@address =" + FilterStringUnicode(benificiar.ReceiverAddress);
      sql += ",@city =" + FilterString(benificiar.ReceiverCity);
      sql += ",@homePhone =" + FilterString(benificiar.ContactNo);
      sql += ",@mobile =" + FilterString(benificiar.SenderMobileNo);
      sql += ",@relationship =" + FilterString(benificiar.Relationship);
      sql += ",@placeOfIssue =" + FilterString(benificiar.PlaceOfIssue);
      sql += ",@idType =" + FilterString(benificiar.TypeId);
      sql += ",@idNumber =" + FilterStringUnicode(benificiar.TypeValue);
      sql += ",@purposeOfRemit =" + FilterString(benificiar.PurposeOfRemitance);
      sql += ",@paymentMode =" + FilterString(benificiar.PaymentMode);
      sql += ",@payOutPartner =" + FilterString(benificiar.PayoutPatner);
      sql += ",@bankLocation =" + FilterString(benificiar.BankLocation);
      sql += ",@bankName =" + FilterString(benificiar.BankName);
      sql += ",@receiverAccountNo =" + FilterString(benificiar.BenificaryAc);
      sql += ",@remarks =" + FilterString(benificiar.Remarks);
      sql += ",@receiverId =" + FilterString(benificiar.ReceiverId);
      sql += ",@customerId =" + FilterString(benificiar.customerId);
      sql += ",@membershipId =" + FilterString(benificiar.membershipId);
      sql += ",@otherRelationDesc =" + FilterString(benificiar.OtherRelationDescription);
      sql += ",@user =" + FilterString(user);
      sql += ",@loginBranchId=" + FilterString(benificiar.agentId.ToString());
      sql += ",@isOrg=" + FilterString(benificiar.isOrg.ToString());
      sql += ",@bInn=" + FilterString(benificiar.bInn);
      sql += ",@bIkk=" + FilterString(benificiar.bIkk);
      sql += ",@approvedBy=" + FilterString(benificiar.approvedBy);
      _log.Debug("Core BeneficiarRegister : " + sql);
      return ParseDbResult(sql);
    }

    public DbResult SaveCustomerRefundData(string user, string customerId, string refAmount, string refundRemarks, string addCharge, string addRemarks, string collMode, string bankId) {
      var sql = "EXEC proc_customerRefund @flag='i'";
      sql += " ,@user =" + FilterString(user);
      sql += " ,@customerId =" + FilterString(customerId);
      sql += " ,@refundAmount =" + FilterString(refAmount);
      sql += " ,@refundCharge =" + FilterString(addCharge);
      sql += " ,@refundRemarks =" + FilterString(refundRemarks);
      sql += " ,@redfundChargeRemarks =" + FilterString(addRemarks);
      sql += " ,@collMode =" + FilterString(collMode);
      sql += " ,@bankId =" + FilterString(bankId);
      return ParseDbResult(sql);
    }

    public DbResult DeleteCustomerRefund(string st_id, string user) {
      string sql = "Exec [proc_customerRefund]";
      sql += " @flag ='d'";
      sql += ", @user=" + FilterString(user);
      sql += ", @rowid=" + FilterString(st_id);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DataSet GetRequiredField(string countryId, string agentId, string user) {
      var sql = "EXEC proc_customerRefund @flag = 'collMode'";
      sql += ", @countryId = " + FilterString(countryId);
      sql += ", @agentId = " + FilterString(agentId);
      sql += ", @user = " + FilterString(user);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }

    public DataTable LoadDataPaymentModeDdl(string sCountryid, string pCountry, string collMode, string agentId, string flag, string user) {
      //var sql = "EXEC proc_dropDownLists @flag = 'collModeByCountry'";
      //sql += ", @param = " + FilterString(pCountry);

      var sql = "EXEC proc_sendPageLoadData @flag =" + FilterString(flag);
      sql += ", @countryId = " + FilterString(sCountryid);
      sql += ", @pCountryId = " + FilterString(pCountry);
      sql += ", @param = " + FilterString(collMode);
      sql += ", @agentId = " + FilterString(agentId);
      sql += ", @user = " + FilterString(user);

      var ds = ExecuteDataset(sql);

      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0];
    }

    public DataRow GetRequiredCustomerDetails(string customerId, string user) {
      var sql = "EXEC proc_online_remitance_core_customerSetup";
      sql += " @Flag ='requiredCustomer-details'";
      sql += ",@customerId =" + FilterString(customerId);
      sql += ",@user =" + FilterString(user);
      return ExecuteDataRow(sql);
    }

    public DataSet GetCustomerInfoFromMembershiId(string user, string membershipId) {
      var sql = "EXEC proc_Customerinformation @flag='detals-fromMembershipId'";
      sql += " ,@User =" + FilterString(user);
      sql += " ,@membershipId =" + FilterString(membershipId);
      return ExecuteDataset(sql);
    }
  }
}