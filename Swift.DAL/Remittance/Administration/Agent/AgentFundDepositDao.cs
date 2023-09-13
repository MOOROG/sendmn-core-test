using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration.Agent
{
    public class AgentFundDepositDao : SwiftDao
    {
        public DbResult Update(long rowId, string user, string agentId, string bankId, string amount, string remarks,string type)
        {
            string sql = "exec proc_fundDeposit @flag=" + (rowId == 0 ? "'i'" : "'u'");
            sql = sql + ", @rowId=" + FilterString(rowId.ToString());
            sql = sql + ", @user=" + FilterString(user);
            sql = sql + ", @agentId=" + FilterString(agentId);
            sql = sql + ", @bankId=" + FilterString(bankId);
            sql = sql + ", @amount = " + FilterString(amount);
            sql = sql + ", @remarks=" + FilterString(remarks);
            sql = sql + ", @imgType=" + FilterString(type);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult Delete(string user, string rowId)
        {
            string sql = "EXEC proc_fundDeposit";
            sql += " @flag = 'd'";
            sql += ", @rowId = " + rowId;
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DataRow SelectById(string rowId,string user)
        {
            string sql = "Exec proc_fundDeposit @flag='a',@rowId=" + FilterString(rowId) + "";
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public string SelectAgentNameById(string agentId)
        {
            string sql = "SELECT agentName FROM agentMaster WHERE agentId=" + agentId + "";
            return GetSingleResult(sql);
        }

        public DbResult VerifyApproveRejectFundDeposit(string rowId, string user, string status, string remark)
        {
            string sql = "EXEC proc_fundDeposit";
            sql += " @flag = 'approveReject'";
            sql += ", @rowId = " + rowId;
            sql += ", @user = " + FilterString(user);
            sql += ", @status = " + FilterString(status);
            sql += ", @remarks = " + FilterString(remark);
            return ParseDbResult(sql);
        }

        public DataTable GetDepositList(string agentId, string status)
        {
            string sql = "EXEC proc_fundDeposit";
            sql += " @flag = 'ss'";
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @status = " + FilterString(status);
            var dt = ExecuteDataTable(sql);
            return dt;
        }
  
    }
}
