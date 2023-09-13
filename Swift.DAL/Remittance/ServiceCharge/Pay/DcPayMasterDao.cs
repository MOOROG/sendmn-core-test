using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Commission.Pay
{
    public class DcPayMasterDao : SwiftDao
    {
        public DbResult Update(string user, string dcPayMasterId, string code, string description,
                               string sCountry, string rCountry, string baseCurrency, string tranType,
                               string commissionBase,string commissionCurrency,  string isEnable)
        {
            string sql = "EXEC proc_dcPayMaster";
            sql += "  @flag = " + (dcPayMasterId == "0" || dcPayMasterId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @dcPayMasterId = " + FilterString(dcPayMasterId);
            sql += ", @code = " + FilterString(code);
            sql += ", @description = " + FilterString(description);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @baseCurrency = " + FilterString(baseCurrency);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @commissionBase = " + FilterString(commissionBase);
            sql += ", @commissionCurrency = " + FilterString(commissionCurrency);
            sql += ", @isEnable = " + FilterString(isEnable);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string dcPayMasterId)
        {
            string sql = "EXEC proc_dcPayMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcPayMasterId = " + FilterString(dcPayMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string dcPayMasterId)
        {
            string sql = "EXEC proc_dcPayMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcPayMasterId = " + FilterString(dcPayMasterId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string dcPayMasterId)
        {
            string sql = "EXEC proc_dcPayMaster";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcPayMasterId = " + FilterString(dcPayMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string dcPayMasterId)
        {
            string sql = "EXEC proc_dcPayMaster";
            sql += "  @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcPayMasterId = " + FilterString(dcPayMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}