using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.DomesticOperation.CreditLimit
{
    public class CreditLimitDomesticDao : SwiftDao
    {
        public DbResult Update(string user, string crLimitId, string agentId, string currency, string limitAmt,
                               string perTopUpAmt, string maxLimitAmt, string expiryDate)
        {
            string sql = "EXEC proc_creditLimitDomestic";
            sql += " @flag = " + (crLimitId == "0" || crLimitId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @crLimitId = " + FilterString(crLimitId);

            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @limitAmt = " + FilterString(limitAmt);
            sql += ", @perTopUpAmt = " + FilterString(perTopUpAmt);
            sql += ", @maxLimitAmt = " + FilterString(maxLimitAmt);
            sql += ", @expiryDate = " + FilterString(expiryDate);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string crLimitId)
        {
            string sql = "EXEC proc_creditLimitDomestic";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @crLimitId = " + FilterString(crLimitId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string crLimitId)
        {
            string sql = "EXEC proc_creditLimitDomestic";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @crLimitId = " + FilterString(crLimitId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SelectAgentAcDetail(string user, string agentId)
        {
            string sql = "EXEC proc_creditLimitDomestic @flag = 'detail'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SelectCreditLimitAuthority(string user)
        {
            var sql = "EXEC proc_topUpLimit @flag = 'cla'";
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}