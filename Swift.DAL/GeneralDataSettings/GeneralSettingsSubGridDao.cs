using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.GeneralDataSettings
{
    public class GeneralSettingsSubGridDao : SwiftDao
    {
        public DbResult Update(string user, string refid, string id, string code, string description)
        {
            string sql = "exec [Proc_GeneralDataSetting] @flag=" + ( string.IsNullOrWhiteSpace(refid) ? "'i'" : "'u'");
            sql = sql + ", @refid = " + FilterString(refid);
            sql = sql + ", @ref_rec_type = " + FilterString(id);
            sql = sql + ", @TYPE_TITLE = " + FilterString(code);
            sql = sql + ", @TYPE_DESC = " + FilterString(description);
            sql = sql + ", @USER = " + FilterString(user);
            
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult Delete(string id, string user)
        {
            var sql = "exec Proc_GeneralDataSetting @FLAG='D'";
            sql += ",@refid = " + FilterString(id);
            sql += ",@USER = " + FilterString(user);
            return ParseDbResult(sql);
        }
        public DataRow SelectById(string user, string refId)
        {
            string sql = "EXEC [Proc_GeneralDataSetting] @flag = 'v'";
            sql += ", @refid = " + FilterString(refId);

            return ExecuteDataRow(sql);
        }
        public DataRow SelectByRowId(string user, string Id)
        {
            string sql = "EXEC [Proc_GeneralDataSetting] @flag = 'r'";
            sql += ", @id = " + FilterString(Id);

            return ExecuteDataRow(sql);
        }
        public DataRow getData(string id)
        {
            string sql = "exec [Proc_UserLogs] @flag = 't'";
            sql += ",@rowId =" + FilterString(id);

            return ExecuteDataRow(sql);
        }
    }
}
