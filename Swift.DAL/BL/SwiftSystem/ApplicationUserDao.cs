using System;
using System.Data;
using Swift.DAL.Common;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.UserManagement {
  public class ApplicationUserDao : RemittanceDao {

    public DbResult Update(string user, string agentId, string userId, string userName, string firstName, string middleName, string lastName, string state,
                         string address, string country, string telephoneNo, string mobileNo, string email,
                         string pwdChangeDays, string pwdChangeWarningDays, string sessionTimeOutPeriod,
                         string loginTime, string logoutTime, string userAccessLevel, string maxReportViewDays, string userType, string district
                         , string salutation, string gender, string password, string currencyIds, string agentCode) {
      string sql = "exec [proc_applicationUsers] @flag=" + (userId == "0" ? "'i'" : "'u'");
      sql = sql + ", @userId=" + FilterString(userId);
      sql = sql + ", @agentCode='" + agentCode + "'";
      sql = sql + ", @agentId=" + FilterString(agentId);
      sql = sql + ", @userName=" + FilterString(userName);
      sql = sql + ", @user=" + FilterString(user);
      sql = sql + ", @firstName=" + FilterString(firstName);
      sql = sql + ", @middleName=" + FilterString(middleName);
      sql = sql + ", @lastName=" + FilterString(lastName);
      sql = sql + ", @state=" + FilterString(state);
      sql = sql + ", @address=" + FilterString(address);
      sql = sql + ", @countryId=" + FilterString(country);
      sql = sql + ", @telephoneNo=" + FilterString(telephoneNo);
      sql = sql + ", @mobileNo=" + FilterString(mobileNo);
      sql = sql + ", @email=" + FilterString(email);
      sql = sql + ", @pwdChangeDays=" + FilterString(pwdChangeDays);
      sql = sql + ", @pwdChangeWarningDays=" + FilterString(pwdChangeWarningDays);
      sql = sql + ", @sessionTimeOutPeriod=" + FilterString(sessionTimeOutPeriod);
      sql = sql + ", @loginTime=" + FilterString(loginTime);
      sql = sql + ", @logoutTime=" + FilterString(logoutTime);
      sql = sql + ", @userAccessLevel = " + FilterString(userAccessLevel);
      sql = sql + ", @maxReportViewDays = " + FilterString(maxReportViewDays);
      sql = sql + ", @userType = " + FilterString(userType);
      sql = sql + ", @salutation = " + FilterString(salutation);
      sql = sql + ", @gender = " + FilterString(gender);
      sql = sql + ", @district = " + FilterString(district);
      sql = sql + ", @pwd = " + FilterString(password);
      sql = sql + ", @currencyIds = " + FilterString(currencyIds);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }


    public DataRow SelectById(string user, string userId) {
      string sql = "EXEC proc_applicationUsers";
      sql += " @flag = 'a'";
      sql += ", @user = " + FilterString(user);
      sql += ", @userId = " + FilterString(userId);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0].Rows[0];
    }

    public DbResult Delete(string user, string userId) {
      string sql = "EXEC proc_applicationUsers @flag='d'";
      sql += ", @user=" + FilterString(user);
      sql += ", @userId=" + FilterString(userId);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DbResult ValidateDcId(string dcId, string dcUserName, string ipAddress) {
      var sql = "EXEC proc_siteAccessLog @flag = 'v'";
      sql += ", @dcId = " + FilterString(dcId);
      sql += ", @dcUserName = " + FilterString(dcUserName);
      sql += ", @ipAddress = " + FilterString(ipAddress);

      return ParseDbResult(sql);
    }

    public DbResult GetIpStatus(string IP, string fieldValue) {
      var ipArr = IP.Trim().Split('.');
      var ipAddress = "";
      for(int i = 0; i < ipArr.Length; i++) {
        if(ipArr[i].Length == 1) {
          ipArr[i] = "00" + ipArr[i];
        } else if(ipArr[i].Length == 2) {
          ipArr[i] = "0" + ipArr[i];
        }
        ipAddress += ipArr[i];
      }
      string sql = "Exec [proc_IPBlacklist] @flag='c'";
      sql += ",@IPAddress=" + FilterString(ipAddress);
      sql += ",@ipAdrs=" + FilterString(IP);
      sql += ",@fieldValues=" + FilterString(fieldValue);
      //string val = GetSingleResult(sql);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }
    public UserDetails DoLogin(string userName, string pwd, string userCode, string ipAddress, string userDetail, Location location, string OTPCode, string twoFAuth = "N") {
      string sql = "exec [proc_applicationLogin] @flag = 'l'";
      sql += ", @userName =" + FilterString(userName);
      sql += ", @pwd = " + FilterString(pwd);
      sql += ", @userId = " + FilterString(userCode);
      sql += ", @ipAddress = " + FilterString(ipAddress);
      sql += ", @UserInfoDetail = " + FilterString(userDetail);
      sql += ", @LOGIN_COUNTRY = N" + FilterString(location.CountryName);
      sql += ", @LOGIN_COUNTRY_CODE = N" + FilterString(location.CountryCode);
      sql += ", @LOGIN_CITY = N" + FilterString(location.City);
      sql += ", @LOGIN_LAT = N" + FilterString(location.Lat);
      sql += ", @LOGIN_LONG = N" + FilterString(location.Long);
      sql += ", @LOGIN_REGION = N" + FilterString((location.errorCode == "0") ? location.Region : location.errorMsg);
      sql += ", @LOGIN_TIMEZONE = N" + FilterString(location.TimeZone);
      sql += ", @LOGIN_ZIPCODDE = N" + FilterString(location.ZipCode);
      sql += ", @OTP_USED = " + FilterString(OTPCode);
      sql += ", @IS_OTP_ENABLED = " + FilterString(twoFAuth);

      return ParseLoginResult(ExecuteDataset(sql).Tables[0], location);
    }

    public void Log2FAuth(string logId, string errorCode) {
      string sql = "exec [proc_applicationLogs] @flag = 'log-update'";
      sql += ", @rowId =" + FilterString(logId);
      sql += ", @IS_SUCCESSFUL =" + FilterString(errorCode);

      ExecuteDataRow(sql);
    }

    public UserDetails DoLoginForAgent(string userName, string pwd, string agentCode, string userCode, string userInfo, string ipAddress, string dcSerialNumber, string dcUserName) {
      string sql = "exec [proc_applicationLogin] @flag = 'lfa'";
      sql = sql + ", @userName =" + FilterString(userName);
      sql = sql + ", @pwd = " + FilterString(pwd);
      sql = sql + ", @agentCode = " + FilterString(agentCode);
      sql = sql + ", @employeeId = " + FilterString(userCode);
      sql = sql + ", @UserInfoDetail = " + FilterString(userInfo);
      sql = sql + ", @ipAddress = " + FilterString(ipAddress);
      sql += ", @dcSerialNumber = " + FilterString(dcSerialNumber);
      sql += ", @dcUserName = " + FilterString(dcUserName);

      return ParseAgentLoginResult(ExecuteDataset(sql).Tables[0]);
    }

    public UserDetails DoLoginForIntlAgent(string userName, string pwd, string userCode, string userInfo, string ipAddress, string dcSerialNumber, string dcUserName,
                                                Location location, string OTPCode, string agentId, string twoFACode = "N") {
      string sql = "exec [proc_applicationIntlLogin] @flag = 'lfai'";
      sql = sql + ", @userName =" + FilterString(userName);
      sql = sql + ", @pwd = " + FilterString(pwd);
      sql = sql + ", @employeeId = " + FilterString(userCode);
      sql = sql + ", @UserInfoDetail = " + FilterString(userInfo);
      sql = sql + ", @ipAddress = " + FilterString(ipAddress);
      sql += ", @dcSerialNumber = " + FilterString(dcSerialNumber);
      sql += ", @dcUserName = " + FilterString(dcUserName);
      sql += ", @LOGIN_COUNTRY = N" + FilterString(location.CountryName);
      sql += ", @LOGIN_COUNTRY_CODE = N" + FilterString(location.CountryCode);
      sql += ", @LOGIN_CITY = N" + FilterString(location.City);
      sql += ", @LOGIN_LAT = N" + FilterString(location.Lat);
      sql += ", @LOGIN_LONG = N" + FilterString(location.Long);
      sql += ", @LOGIN_REGION = N" + FilterString((location.errorCode == "0") ? location.Region : location.errorMsg);
      sql += ", @LOGIN_TIMEZONE = N" + FilterString(location.TimeZone);
      sql += ", @LOGIN_ZIPCODDE = N" + FilterString(location.ZipCode);
      sql += ", @OTP_USED = " + FilterString(OTPCode);
      sql += ", @IS_OTP_ENABLED = " + FilterString(twoFACode);
      sql += ", @agentCode = " + FilterString(agentId);
      //sql += ", @selectedAgentId = " + FilterString(agentId);

      return ParseAgentLoginResult(ExecuteDataset(sql).Tables[0], location);

    }

    public UserDetails DoAgentLogin(string userName, string pwd, string userCode, string ipAddress, string userDetail) {
      string sql = "exec [proc_applicationLogin] @flag = 'la'";
      sql += ", @userName =" + FilterString(userName);
      sql += ", @pwd = " + FilterString(pwd);
      sql += ", @userId = " + FilterString(userCode);
      sql += ", @ipAddress = " + FilterString(ipAddress);
      sql += ", @UserData = " + FilterString(userDetail);
      return ParseLoginResult(ExecuteDataset(sql).Tables[0]);
    }
    public DbResult DoLogOut(string userName) {
      string sql = "exec [proc_applicationUsers] @flag = 'lo', @userName =" + FilterString(userName);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }


    public DbResult DoLockAccount(string userName, string lockReason) {
      string sql = "exec [proc_applicationUsers] @flag = 'loc', @userName =" + FilterString(userName);
      sql += ", @lockReason = " + FilterString(lockReason);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DataRow GetUser2FAuthDetails(string user, string userId, string userUniqueKeyEncrypted, string userName) {
      string sql = "exec [PROC_TWO_FACTOR_AUT] @flag = 'EMAIL', @USER =" + FilterString(user);
      sql += ", @USER_ID = " + FilterString(userId);
      sql += ", @USER_NAME = " + FilterString(userName);
      sql += ", @USER_UNIQUE_CODE = " + FilterString(userUniqueKeyEncrypted);

      return ExecuteDataRow(sql);
    }

    public bool HasRight(string functionId, string user) {
      string sql = "SELECT dbo.FNAHasRight(" + FilterString(user) + "," + FilterString(functionId) + ") res";
      DataTable dataTable = ExecuteDataset(sql).Tables[0];
      bool hasRight = false;
      if(dataTable.Rows.Count > 0) {
        hasRight = (dataTable.Rows[0]["res"].ToString().ToUpper() == "Y" ? true : false);
      }
      return hasRight;
    }

    public DataRow PullDefaultValueById(string user, string agentId) {
      string sql = "EXEC proc_applicationUsers";
      sql += " @flag = 'pullDefault'";
      sql += ", @user = " + FilterString(user);
      sql += ", @agentId = " + FilterString(agentId);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0].Rows[0];
    }
    public DbResult ResetPassword(string user, string userName, string pwd) {
      string sql = "exec [proc_applicationUsers] @flag='r'"
            + ", @user=" + FilterString(user)
            + ", @userName=" + FilterString(userName)
            + ", @pwd=" + FilterString(pwd);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }
    public DbResult ChangePassword(string user, string pwd, string oldPwd) {
      string sql = "exec [proc_applicationUsers] @flag='cp',@userName=" + FilterString(user) + ", @pwd=" +
                         FilterString(pwd);
      sql = sql + ", @oldPwd=" + FilterString(oldPwd);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DbResult ResetPassword(string userName, string userId) {
      string sql = "exec [proc_applicationUsers] @flag='r', @user=" + FilterString(userName) + ", @userId = " + FilterString(userId);
      return ParseDbResult(sql);
    }

    public bool IsForceChangePwd(string user) {
      string sql = "EXEC [proc_applicationUsers] @flag='cps', @userName=" + FilterString(user);
      string val = GetSingleResult(sql);
      if(val == "Y")
        return true;
      return false;
    }

    public bool IsPasswordExpire(string user) {
      string sql = "EXEC [proc_applicationUsers] @flag='cpe', @userName=" + FilterString(user);
      string val = GetSingleResult(sql);
      if(val == "Y")
        return true;
      return false;
    }

    public DataRow GetLockReason(string user) {
      string sql = "EXEC proc_applicationUsers @flag = 'lr', @userName = " + FilterString(user);
      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0].Rows[0];
    }

    public DbResult CheckPwdChangeWarningDays(string user) {
      string sql = "EXEC proc_applicationUsers @flag='cpcwd', @userName=" + FilterString(user);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public string GetUserAccessLevel(string username) {
      string sql = "SELECT userAccessLevel FROM applicationUsers WITH(NOLOCK) WHERE userName = " +
                         FilterString(username);
      return GetSingleResult(sql);
    }

    public DbResult GetIpStatus(string IP) {
      string sql = "Exec [proc_IPBlacklist] @flag='c' ,@IPAddress=" + FilterString(IP);
      //string val = GetSingleResult(sql);
      return ParseDbResult(sql);

    }

    public DbResult LockUnlockUser(string user, string userId) {
      var sql = "EXEC proc_applicationUsers @flag = 'lockUser'";
      sql += ", @user = " + FilterString(user);
      sql += ", @userId = " + FilterString(userId);

      return ParseDbResult(sql);
    }

    public DbResult RestoreDeletedUser(string user, string userId) {
      var sql = "EXEC proc_applicationUsers @flag = 'rdu'";
      sql += ", @user = " + FilterString(user);
      sql += ", @userId = " + FilterString(userId);

      return ParseDbResult(sql);
    }

    public UserDetails CheckUserForLoginScreen(string userName) {
      string sql = "exec [proc_checkUserForLoginScreen] @flag = 'lfa'";
      sql = sql + ", @userName =" + FilterString(userName);
      return ParseLoginResult(ExecuteDataset(sql).Tables[0]);
    }

    public DbResult RecordSiteAccessLog(string dcId, string dcUserName, string ipAddress) {
      var sql = "EXEC proc_siteAccessLog @flag = 'i'";
      sql += ", @dcId = " + FilterString(dcId);
      sql += ", @dcUserName = " + FilterString(dcUserName);
      sql += ", @ipAddress = " + FilterString(ipAddress);

      var ds = ExecuteDataset(sql);
      return ParseDbResult(ds.Tables[0]);
    }

    #region Password policy and security
    public DbResult PasswordPolicy(string user, string isActive, string cddCheck, string eddCheck, string txnApprove, string holdCustTxnMoreBrnch) {
      var sql = "EXEC proc_passwordFormat @flag = 'i'";
      sql += ", @user = " + FilterString(user);
      sql += ", @isActive = " + FilterString(isActive);
      sql += ", @cddCheck = " + FilterString(cddCheck);
      sql += ", @eddCheck = " + FilterString(eddCheck);
      sql += ", @txnApprove = " + FilterString(txnApprove);
      sql += ", @holdCustTxnMoreBrnch = " + FilterString(holdCustTxnMoreBrnch);

      var ds = ExecuteDataset(sql);
      return ParseDbResult(ds.Tables[0]);
    }
    public DataRow GetPolicyData(string user) {
      var sql = "EXEC proc_passwordFormat @flag = 'a'";
      sql += ", @user = " + FilterString(user);

      var ds = ExecuteDataset(sql);
      return ds.Tables[0].Rows[0];
    }

    #endregion
  }
}