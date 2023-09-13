using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration.Agent
{
    public class AgentInfoDao : SwiftDao
    {
        public DbResult Update(string user, string agentInfoId, string agentId, string date, string subject,
                               string description)
        {
            string sql = "EXEC proc_agentInfo";
            sql += " @flag = " + (agentInfoId == "0" || agentInfoId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @agentInfoId = " + FilterString(agentInfoId);

            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @date = " + FilterString(date);
            sql += ", @subject = " + FilterString(subject);
            sql += ", @description = " + FilterString(description);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string agentInfoId)
        {
            string sql = "EXEC proc_agentInfo";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentInfoId = " + FilterString(agentInfoId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string agentInfoId)
        {
            string sql = "EXEC proc_agentInfo";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentInfoId = " + FilterString(agentInfoId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}