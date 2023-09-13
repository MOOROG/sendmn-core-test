using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration
{
    public class GroupLocationMapDao : RemittanceDao
    {
        public DbResult Update(string user, string districtIds, string groupId)
        {
            string sql = "EXEC proc_groupLocationMap";
            sql += " @flag = 'u'";
            sql += ", @user = " + FilterString(user);
            sql += ", @groupId = " + FilterString(groupId);
            sql += ", @districtIds = " + FilterString(districtIds);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult UpdateLocationMaping(string user, string districtIds, string groupCat, string groupDetail)
        {
            string sql = "EXEC proc_locationGroupMaping";
            sql += " @flag = 'u'";
            sql += ", @user = " + FilterString(user);
            sql += ", @GroupCat = " + FilterString(groupCat);
            sql += ", @GroupDetail = " + FilterString(groupDetail);
            sql += ", @locationCode = " + FilterString(districtIds);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string districtId, string groupId)
        {
            string sql = "EXEC proc_groupLocationMap";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @districtId = " + FilterString(districtId);
            sql += ", @groupId = " + FilterString(groupId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ParseDbResult(ds.Tables[0]);
        }

        public DbResult DeleteRow(string user, string rowId)
        {
            string sql = "EXEC proc_locationGroupMaping";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ParseDbResult(ds.Tables[0]);
        }
    }
}