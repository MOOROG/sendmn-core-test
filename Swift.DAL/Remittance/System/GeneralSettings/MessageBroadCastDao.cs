using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.GeneralSettings
{
    public class MessageBroadCastDao : RemittanceDao
    {
        public DbResult Update(string countryId, string agentId, string msgDetail, string branchId,
            string isActive, string msgTitle, string user, string msgBroadCastId, string userType)
        {
            string sql = "EXEC proc_msgBroadCast";
            sql += " @flag = " + (msgBroadCastId == "0" || msgBroadCastId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @msgBroadCastId = " + FilterString(msgBroadCastId);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @isActive = " + FilterString(isActive);
            sql += ", @msgTitle = N" + FilterString(msgTitle);
            sql += ", @msgDetail = N" + FilterString(msgDetail);
            sql += ", @userType = " + FilterString(userType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string msgBroadCastId)
        {
            string sql = "EXEC proc_msgBroadCast";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgBroadCastId = " + FilterString(msgBroadCastId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string msgBroadCastId)
        {
            string sql = "EXEC proc_msgBroadCast";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgBroadCastId = " + FilterString(msgBroadCastId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataTable ShowTopTitleMessage(string user, string conuntryId, string agentId, string branchId)
        {
            var sql = "EXEC [proc_messageBroadCast] @flag = 'msg-title'";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryId =" + FilterString(conuntryId);
            sql += ", @agentId =" + FilterString(agentId);
            sql += ", @branchId =" + FilterString(branchId);
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable ShowTopTittlDetailMessage(string user, string msgBroadCastId)
        {
            var sql = "EXEC [proc_messageBroadCast] @flag = 'msg-detail'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgBroadCastId =" + FilterString(msgBroadCastId);
            return ExecuteDataset(sql).Tables[0];
        }

    }
}
