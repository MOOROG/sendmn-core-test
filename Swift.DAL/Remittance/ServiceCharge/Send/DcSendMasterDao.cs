using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Commission.Send
{
    public class DcSendMasterDao : SwiftDao
    {
        public DbResult Update(string user, string dcSendMasterId, string code, string description,
                               string sCountry, string rCountry, string baseCurrency, string tranType,
                               string commissionBase, string isEnable)
        {
            string sql = "EXEC proc_dcSendMaster";
            sql += "  @flag = " + (dcSendMasterId == "0" || dcSendMasterId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @dcSendMasterId = " + FilterString(dcSendMasterId);
            sql += ", @code = " + FilterString(code);
            sql += ", @description = " + FilterString(description);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @baseCurrency = " + FilterString(baseCurrency);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @commissionBase = " + FilterString(commissionBase);
            sql += ", @isEnable = " + FilterString(isEnable);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string dcSendMasterId)
        {
            string sql = "EXEC proc_dcSendMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcSendMasterId = " + FilterString(dcSendMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string dcSendMasterId)
        {
            string sql = "EXEC proc_dcSendMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcSendMasterId = " + FilterString(dcSendMasterId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string dcSendMasterId)
        {
            string sql = "EXEC proc_dcSendMaster";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcSendMasterId = " + FilterString(dcSendMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string dcSendMasterId)
        {
            string sql = "EXEC proc_dcSendMaster";
            sql += "  @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcSendMasterId = " + FilterString(dcSendMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}