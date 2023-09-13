using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration.Agent
{
    public class AgentDocumentDao : RemittanceDao
    {
        public DbResult Update(string user, string adId, string agentId, string fileDescription, string fileType)
        {
            string sql = "EXEC proc_agentDocument";
            sql += " @flag = " + (adId == "0" || adId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @adId = " + FilterString(adId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @fileDescription = " + FilterString(fileDescription);
            sql += ", @fileType = " + FilterString(fileType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string adId)
        {
            string sql = "EXEC proc_agentDocument";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @adId = " + FilterString(adId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataTable PopulateAgentDocument(string user, string agentId)
        {
            string sql = "EXEC proc_agentDocument";
            sql += " @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable Delete(string user, string adIds)
        {
            string sql = "EXEC proc_agentDocument";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @adIds = " + FilterString(adIds);
            return ExecuteDataset(sql).Tables[0];
        }
    }
}