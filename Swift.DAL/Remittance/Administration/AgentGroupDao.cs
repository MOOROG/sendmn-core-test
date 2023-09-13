using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration
{
    public class AgentGroupDao : RemittanceDao
    {
        public DbResult Update(string user, string rowId, string agentId, string groupCat, string groupDetail)
        {
            string sql = "EXEC proc_agentGroup ";
            sql += " @flag = " + (rowId == "0" || rowId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @AgentID = " + FilterString(agentId);
            sql += ", @GroupCat = " + FilterString(groupCat);
            sql += ", @GroupDetail = " + FilterString(groupDetail);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DataRow SelectById(string user, string rowId)
        {
            string sql = "EXEC proc_agentGroup ";
            sql += " @flag ='a'";
            sql += ", @rowId =" + FilterString(rowId);
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Delete(string user, string rowid)
        {
            string sql = "EXEC proc_agentGroup";
            sql += " @flag = 'd'";
            sql += ",@user = " + FilterString(user);
            sql += ",@rowid = " + FilterString(rowid);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ParseDbResult(ds.Tables[0]);
        }
    }
}