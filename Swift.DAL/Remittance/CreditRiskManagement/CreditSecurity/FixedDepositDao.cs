using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.CreditRiskManagement.CreditSecurity
{
    public class FixedDepositDao : RemittanceDao
    {
        public DbResult Update(string user, string fdId, string agentId, string fixedDepositNo, string amount,
                               string currency, string bankName, string issuedDate, string expiryDate,
                               string followUpDate, string sessionId)
        {
            string sql = "EXEC proc_fixedDeposit";
            sql += " @flag = " + (fdId == "0" || fdId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @fdId = " + FilterString(fdId);

            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @bankName = " + FilterString(bankName);
            sql += ", @fixedDepositNo = " + FilterString(fixedDepositNo);
            sql += ", @amount = " + FilterString(amount);
            sql += ", @currency = " + FilterString(currency);

            sql += ", @issuedDate = " + FilterString(issuedDate);
            sql += ", @expiryDate = " + FilterString(expiryDate);
            sql += ", @followUpDate = " + FilterString(followUpDate);
            sql += ", @sessionId = " + FilterString(sessionId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string fdId)
        {
            string sql = "EXEC proc_fixedDeposit";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fdId = " + FilterString(fdId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string fdId)
        {
            string sql = "EXEC proc_fixedDeposit";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fdId = " + FilterString(fdId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}