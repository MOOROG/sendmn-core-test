using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.DomesticOperation.UserWiseTxnLimit
{
    public class UserWiseTxnLimitDao : SwiftDao
    {
        public DbResult Update(string user, string limitId, string userId, string sendPerDay, string sendPerTxn,
                                  string payPerDay, string payPerTxn,string cancelPerDay, string cancelPerTxn)
        {
            string sql = "EXEC proc_userWiseTxnLimit";
            sql += "  @flag = " + (limitId == "0" || limitId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @limitId = " + FilterString(limitId);
            sql += ", @userId = " + FilterString(userId);
            sql += ", @sendPerDay = " + FilterString(sendPerDay);
            sql += ", @sendPerTxn = " + FilterString(sendPerTxn);
            sql += ", @payPerDay = " + FilterString(payPerDay);
            sql += ", @payPerTxn = " + FilterString(payPerTxn);
            sql += ", @cancelPerDay = " + FilterString(cancelPerDay);
            sql += ", @cancelPerTxn = " + FilterString(cancelPerTxn);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string limitId)
        {
            string sql = "EXEC proc_userWiseTxnLimit";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @limitId = " + FilterString(limitId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string limitId)
        {
            string sql = "EXEC proc_userWiseTxnLimit";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @limitId = " + FilterString(limitId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}