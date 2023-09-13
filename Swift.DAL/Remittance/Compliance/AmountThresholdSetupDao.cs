using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Compliance
{
    public class AmountThresholdSetupDao : RemittanceDao
    {
        public DbResult SaveThresholdAmount(string sCountryId, string sCountryName, string rCountryId, string rCountryName, string sAgent, string Amount, string MessageTxt, string isActive, string user)
        {
            var sql = "EXEC proc_sendingAmtThreshold @flag='i'";
            sql += ",@sCountryId   =" + FilterString(sCountryId);
            sql += ",@sCountryName =" + FilterString(sCountryName);
            sql += ",@rCountryId   =" + FilterString(rCountryId);
            sql += ",@rCountryName =" + FilterString(rCountryName);
            sql += ",@sAgent =" + FilterString(sAgent);
            sql += ",@Amount =" + FilterString(Amount);
            sql += ",@MessageTxt =N"+ FilterString(MessageTxt);
            sql += ",@isActive =" + FilterString(isActive);
            sql += ",@user =" + FilterString(user);
            return ParseDbResult(sql);
        }
        public DbResult UpdateThresholdAmount(string id,string sCountryId, string sCountryName, string rCountryId, string rCountryName, string sAgent, string Amount,string MessageTxt,string isActive, string user)
        {
            var sql = "EXEC proc_sendingAmtThreshold @flag='u'";
            sql += ",@sAmtThresholdId = " + FilterString(id);
            sql += ",@sCountryId   =" + FilterString(sCountryId);
            sql += ",@sCountryName =" + FilterString(sCountryName);
            sql += ",@rCountryId   =" + FilterString(rCountryId);
            sql += ",@rCountryName =" + FilterString(rCountryName);
            sql += ",@sAgent =" + FilterString(sAgent);
            sql += ",@Amount =" + FilterString(Amount);
            sql += ",@MessageTxt =N" + FilterString(MessageTxt);
            sql += ",@isActive =" + FilterString(isActive);
            sql += ",@user =" + FilterString(user);
            return ParseDbResult(sql);
        }
        public DataRow SelectById(string user, string id)
        {
            string sql = "EXEC proc_sendingAmtThreshold";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sAmtThresholdId = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DbResult DeleteThreshold(string id, string user)
        {
            var sql = "EXEC proc_sendingAmtThreshold @flag='d'";
            sql += ", @sAmtThresholdId = " + FilterString(id);
            sql += ",@user =" + FilterString(user);
            return ParseDbResult(sql);
        }
    }
}
