using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.BL.SwiftSystem
{
    public class UserGroupMappingDao : RemittanceDao
    {

        public DbResult Update(string user, string rowId, string userId, string GroupCat, string GroupDetail, string userName)
        {
            string sql = "EXEC proc_userGroupMapping ";
            sql += " @flag = " + (rowId == "0" || rowId == "" ? "'i'" : "'u'");
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @user = " + FilterString(user);
            sql += ", @userId = " + FilterString(userId);
            sql += ", @GroupCat = " + FilterString(GroupCat);
            sql += ", @GroupDetail = " + FilterString(GroupDetail);
            sql += ", @userName = " + FilterString(userName);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DataRow SelectById(string user, string rowId)
        {
            string sql = "EXEC proc_userGroupMapping ";
            sql += " @flag ='a'";
            sql += ", @rowId =" + FilterString(rowId);
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DbResult Delete(string user, string rowId)
        {
            string sql = "EXEC proc_userGroupMapping";
            sql += "  @flag='d'";
            sql += ", @user=" + FilterString(user);
            sql += ", @rowId=" + FilterString(rowId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        #region User Zone Mapping
        public DbResult UpdateUserZone(string user, string rowId, string zoneName, string userName)
        {
            string sql = "EXEC proc_userZoneMapping ";
            sql += "  @flag = " + (rowId == "0" || rowId == "" ? "'i'" : "'u'");
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @user = " + FilterString(user);
            sql += ", @zoneName = " + FilterString(zoneName);
            sql += ", @userName = " + FilterString(userName);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult DeleteUserZone(string user, string rowId)
        {
            string sql = "EXEC proc_userZoneMapping";
            sql += "  @flag='d'";
            sql += ", @user=" + FilterString(user);
            sql += ", @rowId=" + FilterString(rowId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DataRow SelectByIdUserZone(string user, string rowId)
        {
            string sql = "EXEC proc_userZoneMapping ";
            sql += " @flag ='a'";
            sql += ", @rowId =" + FilterString(rowId);
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        #endregion

        #region User Agent Mapping
        public DbResult UpdateUserAgent(string user, string rowId, string agentId, string userName)
        {
            string sql = "EXEC proc_userAgentMapping ";
            sql += "  @flag = 'i'";
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @userName = " + FilterString(userName);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult DeleteUserAgent(string user, string rowId)
        {
            string sql = "EXEC proc_userAgentMapping";
            sql += "  @flag='d'";
            sql += ", @user=" + FilterString(user);
            sql += ", @rowId=" + FilterString(rowId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        #endregion
    }
}
