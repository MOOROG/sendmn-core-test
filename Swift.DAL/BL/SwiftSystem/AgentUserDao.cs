using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.BL.SwiftSystem
{
    public class AgentUserDao : RemittanceDao
    {
        public DbResult Update(string user, string agentId, string userId, string userName, string firstName, string middleName, string lastName, string state,
                               string address, string country, string telephoneNo, string mobileNo, string email,
                               string pwdChangeDays, string pwdChangeWarningDays, string sessionTimeOutPeriod,
                               string loginTime, string logoutTime, string userAccessLevel, string maxReportViewDays, string userType, string district
                               , string salutation, string gender, string zipCode, string SendTrnFrom, string SendTrnTo, string PayTrnFrom, string PayTrnTo)
        {
            string sql = "exec [proc_agentUsers] @flag=" + (userId == "0" ? "'i'" : "'u'");
            sql = sql + ", @userId=" + FilterString(userId);
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
            sql = sql + ", @zip = " + FilterString(zipCode);
            sql = sql + ", @fromSendTrnTime = " + FilterString(SendTrnFrom);
            sql = sql + ", @toSendTrnTime = " + FilterString(SendTrnTo);
            sql = sql + ", @fromPayTrnTime = " + FilterString(PayTrnFrom);
            sql = sql + ", @toPayTrnTime = " + FilterString(PayTrnTo);


            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow PullDefaultValueById(string user, string agentId)
        {
            string sql = "EXEC proc_applicationUsers";
            sql += " @flag = 'pullDefault'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }


        public DataRow SelectById(string user, string userId)
        {
            string sql = "EXEC proc_agentUsers";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @userId = " + FilterString(userId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Delete(string user, string userId)
        {
            string sql = "EXEC proc_agentUsers @flag='d'";
            sql += ", @user=" + FilterString(user);
            sql += ", @userId=" + FilterString(userId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult ResetPassword(string userName, string userId)
        {
            string sql = "exec [proc_agentUsers] @flag='resetPwd', @user=" + FilterString(userName) + ", @userId = " + FilterString(userId);
            return ParseDbResult(sql);
        }

        public DbResult LockUnlockUser(string user, string userId)
        {
            var sql = "EXEC proc_agentUsers @flag = 'lockUser'";
            sql += ", @user = " + FilterString(user);
            sql += ", @userId = " + FilterString(userId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}
