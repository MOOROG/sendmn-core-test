using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.Notification
{
    public class NotificationDao : SwiftDao
    {
        public DbResult DeleteMessage(string msgId, string userName)
        {
            string sql = "exec proc_applicationMessage @flag = 'd', @userName =" + FilterString(userName) + ", @msgId =" +
                         FilterString(msgId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataTable PopulateData(string msgId)
        {
            string sql = "exec proc_applicationMessage @flag = 'a', @msgId =" + FilterString(msgId);
            return ExecuteDataset(sql).Tables[0];
        }
        public DataTable SelectCountryInfoById(string user, string countryId)
        {
            string sql = "EXEC proc_ViewCountryInfo";
            sql += " @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryId = " + FilterString(countryId);

            return ExecuteDataset(sql).Tables[0];
        }
    }
}