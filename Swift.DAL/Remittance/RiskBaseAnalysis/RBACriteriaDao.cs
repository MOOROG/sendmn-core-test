using System.Data;
using Swift.DAL.SwiftDAL;
using System.Text;

namespace Swift.DAL.BL.Remit.RiskBaseAnalysis
{
    public class RBACriteriaDao : RemittanceDao
    {
        public DbResult SaveHighRiskCountry(string user, string countryCode, string countryName, bool isBlocked)
        {
            string sql = "EXEC proc_RBA";
            sql += " @flag = 'i-hrc'";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryCode = " + FilterString(countryCode);
            sql += ", @countryName = " + FilterString(countryName);
            sql += ", @isBlocked = " + isBlocked;
            return ParseDbResult(sql);
        }
        public DbResult UpdateHighRiskCountry(string user, string countryCode, string countryName, bool isBlocked, string rowId)
        {
            string sql = "EXEC proc_RBA";
            sql += " @flag = 'u-hrc'";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryCode = " + FilterString(countryCode);
            sql += ", @countryName = " + FilterString(countryName);
            sql += ", @isBlocked = " + isBlocked;
            sql += ",@rowId=" + FilterString(rowId);
            return ParseDbResult(sql);
        }
        public DbResult Delete(string user, string rowId)
        {
            string sql = "exec proc_RBA";
            sql += " @flag = 'd-hrc'";
            sql += ",@rowId=" + FilterString(rowId);
            sql += ",@user=" + FilterString(user);
            return ParseDbResult(sql);
        }
        public DataRow GetDataByID(string user, string rowId)
        {
            string sql = "exec proc_RBA";
            sql += " @flag = 's-hrc-id'";
            sql += ",@rowId=" + FilterString(rowId);
            sql += ",@user=" + FilterString(user);
            return ExecuteDataRow(sql);
        }
    }
}
