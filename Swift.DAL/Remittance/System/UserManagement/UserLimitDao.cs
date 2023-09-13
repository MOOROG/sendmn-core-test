using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.UserManagement
{
    public class UserLimitDao :RemittanceDao
    {
        public DbResult Update(long userLimitId, string user, string userId, string currencyId, string sendLimit, string payLimit, string isEnable)
        {
            string sql = "exec [proc_agentUserLimit] @flag=" + (userLimitId ==0 ? "'i'" : "'u'");
            sql = sql + ", @userLimitId=" + FilterString(userLimitId.ToString());
            sql = sql + ", @user=" + FilterString(user);
            sql = sql + ", @userId=" + FilterString(userId);
            sql = sql + ", @currencyId=" + FilterString(currencyId);
            sql = sql + ", @sendLimit = " + FilterString(sendLimit);
            sql = sql + ", @payLimit=" + FilterString(payLimit);
            sql = sql + ", @isEnable=" + FilterString(isEnable);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult Delete(string user, string userLimitId)
        {
            string sql = "EXEC proc_agentUserLimit";
            sql += " @flag = 'd'";
            sql += ", @userLimitId = " + userLimitId;
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DataRow SelectById(string userId)
        {
            string sql = "Exec proc_agentUserLimit @flag='s1',@userId="+FilterString(userId)+"";

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DataRow SelectUserLimitById(string userLimitId)
        {
            string sql = "Exec proc_agentUserLimit @flag='a',@userLimitId=" + FilterString(userLimitId) + "";

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DataRow CheckCurrency(string agentId, string currencyId)
        {
            string sql = "Exec proc_agentUserLimit @flag='s2',@agentId=" + FilterString(agentId) + ",@currencyId="+FilterString(currencyId)+"";

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        //User Lock 
        public DbResult UpdateUserLock(long userLockId, string user, string userId, string fromDate, string toDate, string remarks)
        {
            string sql = "exec [proc_userLockDetail] @flag=" + (userLockId == 0 ? "'i'" : "'u'");
            sql = sql + ", @userLockId=" + FilterString(userLockId.ToString());
            sql = sql + ", @user=" + FilterString(user);
            sql = sql + ", @userId=" + FilterString(userId);
            sql = sql + ", @startDate=" + FilterString(fromDate);
            sql = sql + ", @endDate = " + FilterString(toDate);
            sql = sql + ", @lockDesc=" + FilterString(remarks);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectUserLockById(string userLockId)
        {
            string sql = "Exec proc_userLockDetail @flag='a',@userLockId=" + FilterString(userLockId) + "";

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult DeleteLock(string user, string userLockId)
        {
            string sql = "EXEC proc_userLockDetail";
            sql += " @flag = 'd'";
            sql += ", @userLockId = " + userLockId;
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}
