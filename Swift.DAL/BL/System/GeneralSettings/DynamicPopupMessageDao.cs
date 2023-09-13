using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.GeneralSettings
{
    public class DynamicPopupMessageDao : SwiftDao
    {
        public DbResult Update(string rowId, string user, string scope, string description, string fileType, string enable, string fromDate, string toDate, string imageLink)
        {
            var sql = "exec [proc_dynamicPopupMessage]";
            sql += "  @flag =" + (rowId == "0" ? "'i'" : "'u'");
            sql += ",@rowId=" + FilterString(rowId);
            sql += ",@user=" + FilterString(user);
            sql += ",@scope=" + FilterString(scope);
            sql += ",@description=" + FilterString(description);
            sql += ",@fileType=" + FilterString(fileType);
            sql += ",@isEnable=" + FilterString(enable);
            sql += ",@fromDate=" + FilterString(fromDate);
            sql += ",@toDate=" + FilterString(toDate);
            sql += ",@imageLink=" + FilterString(imageLink);
            return ParseDbResult(sql);
        }
        public DataRow SelectById(string rowId, string user)
        {
            string sql = "Exec [proc_dynamicPopupMessage]";
            sql += " @flag ='a'";
            sql += ", @rowId=" + FilterString(rowId);
            sql += ", @user=" + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DataRow SelectByIdTxn(string user, string rowId)
        {
            string sql = "EXEC proc_dynamicPopupMessage";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DataTable DisplayDocs(string user, string id)
        {
            var sql = "EXEC proc_dynamicPopupMessage @flag='displayDoc'";
            sql += ",@user=" + FilterString(user);
            sql += ",@rowId=" + FilterString(id);
            return ExecuteDataTable(sql);
        }
        public DataTable PopulateDyanmicPopupAgentIntl(string user, string scopeId, string fromDate, string toDate)
        {
            string sql = "EXEC proc_dynamicPopupMessage";
            sql += " @flag = 'sa'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scope = " + FilterString(scopeId);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            return ExecuteDataset(sql).Tables[0];
        }
        public DataTable PopulateDyanmicPopupAgent(string user, string scopeId, string fromDate, string toDate)
        {
            string sql = "EXEC proc_dynamicPopupMessage";
            sql += " @flag = 'sa'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scope = " + FilterString(scopeId);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            return ExecuteDataset(sql).Tables[0];
        }
        public DataTable PopulateDyanmicPopupAdmin(string user, string scopeId, string fromDate, string toDate)
        {
            string sql = "EXEC proc_dynamicPopupMessage";
            sql += " @flag = 'sa'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scope = " + FilterString(scopeId);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            return ExecuteDataset(sql).Tables[0];
        }
        public DbResult DeleteDoc(string user, string rowId)
        {
            var sql = "EXEC proc_dynamicPopupMessage @flag='deleteDoc'";
            sql += ",@user=" + FilterString(user);
            sql += ",@rowId=" + FilterString(rowId);
            return ParseDbResult(sql);
        }
    }
}
