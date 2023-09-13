using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ServiceCharge
{
    public class DscMasterDao : SwiftDao
    {
        public DbResult Update(string user, string dscMasterId, string code, string description,
                               string sCountry, string rCountry, string baseCurrency, string tranType,
                               string isEnable)
        {
            string sql = "EXEC proc_dscMaster";
            sql += "  @flag = " + (dscMasterId == "0" || dscMasterId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @dscMasterId = " + FilterString(dscMasterId);
            sql += ", @code = " + FilterString(code);
            sql += ", @description = " + FilterString(description);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @baseCurrency = " + FilterString(baseCurrency);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @isEnable = " + FilterString(isEnable);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string dscMasterId)
        {
            string sql = "EXEC proc_dscMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dscMasterId = " + FilterString(dscMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string dscMasterId)
        {
            string sql = "EXEC proc_dscMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dscMasterId = " + FilterString(dscMasterId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string dscMasterId)
        {
            string sql = "EXEC proc_dscMaster";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dscMasterId = " + FilterString(dscMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string dscMasterId)
        {
            string sql = "EXEC proc_dscMaster";
            sql += "  @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dscMasterId = " + FilterString(dscMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataTable GetSlabList(string dscMasterId, string user)
        {
            string sql = "EXEC ttt";
            //var sql = "EXEC proc_dscDetail @flag='s'";
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable GetCountryList()
        {
            string sql = "EXEC proc_dscMaster @flag='scl'";
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable GetReceivingCountryList(string sCountryId)
        {
            string sql = "EXEC proc_dscMaster @flag='rcl'";
            sql += ", @sCountry = " + FilterString(sCountryId);

            return ExecuteDataset(sql).Tables[0];
        }
    }
}