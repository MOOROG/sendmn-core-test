using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.CreditRiskManagement.CreditSecurity
{
    public class BankGuaranteeDao : RemittanceDao
    {
        public DbResult Update(string user, string bgId, string agentId, string guaranteeNo, string amount,
                               string currency, string bankName, string issuedDate, string expiryDate,
                               string followUpDate, string sessionId)
        {
            string sql = "EXEC proc_bankGuarantee";
            sql += " @flag = " + (bgId == "0" || bgId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @bgId = " + FilterString(bgId);

            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @guaranteeNo = " + FilterString(guaranteeNo);
            sql += ", @amount = " + FilterString(amount);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @bankName = " + FilterString(bankName);
            sql += ", @issuedDate = " + FilterString(issuedDate);
            sql += ", @expiryDate = " + FilterString(expiryDate);
            sql += ", @followUpDate = " + FilterString(followUpDate);
            sql += ", @sessionId = " + FilterString(sessionId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string bgId)
        {
            string sql = "EXEC proc_bankGuarantee";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @bgId = " + FilterString(bgId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string bgId)
        {
            string sql = "EXEC proc_bankGuarantee";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @bgId = " + FilterString(bgId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}