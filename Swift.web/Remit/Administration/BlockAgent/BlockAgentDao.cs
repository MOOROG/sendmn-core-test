using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration.BlockAgent
{
    public class BlockAgentDao : SwiftDao
    {
        public DbResult UpdateBlockAgent(string user, string id, string agentId, string status, string remarks)
        {
            string sql = "EXEC proc_agentBlock ";
            sql += " @flag = " + (id == "0" || id == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @agentStatus = " + FilterString(status);
            sql += ", @remarks = " + FilterString(remarks);
            return ParseDbResult(sql);
        }

        public DataRow GetBlockAgentById(string user, string id)
        {
            string sql = "EXEC proc_agentBlock ";
            sql += "  @flag = " + "'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);

            return ExecuteDataRow(sql);
        }
    }
}