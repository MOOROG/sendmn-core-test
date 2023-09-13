using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration.Agent
{
    public class AgentBankAccountDao : SwiftDao
    {
        public DbResult Update(string user, string abaId, string agentId, string bankName, string bankBranch,
                               string accountNo, string swiftCode, string routingNo,
                               string bankNameB, string bankBranchB,
                               string accountNoB, string swiftCodeB, 
                               string routingNoB, string isDefault)
        {
            string sql = "EXEC proc_agentBankAccount";
            sql += " @flag = " + (abaId == "0" || abaId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @abaId = " + FilterString(abaId);

            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @bankName = " + FilterString(bankName);
            sql += ", @bankBranch = " + FilterString(bankBranch);
            sql += ", @accountNo = " + FilterString(accountNo);
            sql += ", @swiftCode = " + FilterString(swiftCode);
            sql += ", @routingNo = " + FilterString(routingNo);

            sql += ", @bankNameB = " + FilterString(bankNameB);
            sql += ", @bankBranchB = " + FilterString(bankBranchB);
            sql += ", @accountNoB = " + FilterString(accountNoB);
            sql += ", @swiftCodeB = " + FilterString(swiftCodeB);
            sql += ", @routingNoB = " + FilterString(routingNoB);
            sql += ", @isDefault = " + FilterString(isDefault);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string abaId)
        {
            string sql = "EXEC proc_agentBankAccount";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @abaId = " + FilterString(abaId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string abaId)
        {
            string sql = "EXEC proc_agentBankAccount";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @abaId = " + FilterString(abaId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}