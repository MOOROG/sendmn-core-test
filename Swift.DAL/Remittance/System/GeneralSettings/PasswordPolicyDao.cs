using System;
using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.GeneralSettings
{
    public class PasswordPolicyDao : RemittanceDao
    {
        public DbResult Update(string user, string loginAttemptCount, string minPwdLength, string pwdHistoryNum,
                               string specialCharNo, string numericNo, string capNo, string isActive, 
                                string lockUserDays, string invalidControlNoForDay, string invalidControlNoContinous,
                                string operationTimeFrom, string operationTimeTo, string globalOperationTimeEnable)
        {
            string sql = "EXEC proc_passwordFormat";
            sql += " @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @loginAttemptCount = " + FilterString(loginAttemptCount);
            sql += ", @minPwdLength = " + FilterString(minPwdLength);
            sql += ", @pwdHistoryNum = " + FilterString(pwdHistoryNum);
            sql += ", @specialCharNo = " + FilterString(specialCharNo);
            sql += ", @numericNo = " + FilterString(numericNo);
            sql += ", @capNo = " + FilterString(capNo);
            sql += ", @invalidControlNoForDay = " + FilterString(invalidControlNoForDay);
            sql += ", @invalidControlNoContinous = " + FilterString(invalidControlNoContinous);
            sql += ", @isActive = " + FilterString(isActive);
            sql += ", @lockUserDays = " + FilterString(lockUserDays);
            sql += ", @operationTimeFrom = " + FilterString(operationTimeFrom);
            sql += ", @operationTimeTo = " + FilterString(operationTimeTo);
            sql += ", @globalOperationTimeEnable = " + FilterString(globalOperationTimeEnable);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string rowId)
        {
            string sql = "EXEC proc_passwordFormat";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow Select(string user)
        {
            string sql = "EXEC proc_passwordFormat";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public int GetLoginAttemptCount()
        {
            string sql = "SELECT TOP 1 loginAttemptCount FROM passwordFormat WITH(NOLOCK)";
            string res = GetSingleResult(sql);
            return res == null ? 0 : Convert.ToInt32(res);
        }

        public DbResult ManageInvalidControlNoAttempt(string user, string isNewAttempt)
        {
            var sql = "EXEC proc_tranViewAttempt @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @isNewAttempt = " + FilterString(isNewAttempt);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}