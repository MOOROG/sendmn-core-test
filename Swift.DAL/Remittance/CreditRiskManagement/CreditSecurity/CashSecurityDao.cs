using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.CreditRiskManagement.CreditSecurity
{
    public class CashSecurityDao : RemittanceDao
    {
        public DbResult Update(string user, string csId, string agentId, string depositAcNo, string cashDeposit,
                               string currency, string depositedDate, string bankName)
        {
            string sql = "EXEC proc_cashSecurity";
            sql += " @flag = " + (csId == "0" || csId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @csId = " + FilterString(csId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @depositAcNo = " + FilterString(depositAcNo);
            sql += ", @cashDeposit = " + FilterString(cashDeposit);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @depositedDate = " + FilterString(depositedDate);
            sql += ", @bankName = " + FilterString(bankName);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string csId)
        {
            string sql = "EXEC proc_cashSecurity";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csId = " + FilterString(csId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string csId)
        {
            string sql = "EXEC proc_cashSecurity";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csId = " + FilterString(csId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}