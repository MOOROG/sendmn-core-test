using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.GeneralSettings
{
    public class StaticDataDao : SwiftDao
    {
        public DbResult Update(string user, string valueId, string typeID, string detailTitle, string detailDesc, string isActive)
        {
            string sql = "EXEC proc_staticDataValue";
            sql += " @flag = " + (valueId == "0" || valueId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @valueId = " + FilterString(valueId);

            sql += ", @typeID = " + FilterString(typeID);
            sql += ", @detailTitle = " + FilterString(detailTitle);
            sql += ", @detailDesc = " + FilterString(detailDesc);
            sql += ", @isActive = " + FilterString(isActive);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string valueId)
        {
            string sql = "EXEC proc_staticDataValue";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @valueId = " + FilterString(valueId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string valueId)
        {
            string sql = "EXEC proc_staticDataValue";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @valueId = " + FilterString(valueId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string valueId)
        {
            string sql = "EXEC proc_staticDataValue";
            sql += " @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @valueId = " + FilterString(valueId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string valueId)
        {
            string sql = "EXEC proc_staticDataValue";
            sql += " @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @valueId = " + FilterString(valueId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}