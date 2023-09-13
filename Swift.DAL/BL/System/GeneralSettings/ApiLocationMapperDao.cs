using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.GeneralSettings
{
    public class ApiLocationMapperDao : SwiftDao
    {
        public DbResult Update(string user, string districtId, string apiDistrictCode)
        {
            string sql = "EXEC proc_apiLocationMapping";
            sql += " @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @districtId = " + FilterString(districtId);
            sql += ", @apiDistrictCode = " + FilterString(apiDistrictCode);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult UpdateLocation(string user, string districtId, string districtCode, string districtName, string isActive)
        {
            var sql = "EXEC proc_apiLocation";
            sql += "  @flag = " + (districtId == "0" || districtId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @districtId = " + FilterString(districtId);
            sql += ", @districtCode = " + FilterString(districtCode);
            sql += ", @districtName = " + FilterString(districtName);
            sql += ", @isActive = " + FilterString(isActive);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectLocation(string user, string districtId)
        {
            var sql = "EXEC proc_apiLocation";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @districtId = " + FilterString(districtId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult DeleteLocation(string user, string districtId)
        {
            var sql = "EXEC proc_apiLocation";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @districtId = " + FilterString(districtId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string rowId)
        {
            string sql = "EXEC proc_apiLocationMapping";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string apiDistrictCode)
        {
            string sql = "EXEC proc_apiLocationMapping";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @apiDistrictCode = " + FilterString(apiDistrictCode);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SelectStateByDistrict(string user, string districtId)
        {
            string sql = "EXEC proc_zoneDistrictMap @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @districtId = " + FilterString(districtId);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DbResult ImportLocation(string user)
        {
            string sql = "EXEC proc_importLocationAPI";
            sql += " @user = " + FilterString(user);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}