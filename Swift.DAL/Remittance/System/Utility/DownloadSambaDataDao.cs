using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;


namespace Swift.DAL.BL.System.Utility
{
   public class DownloadSambaDataDao:SwiftDao
    {

       public DataTable DownLoadData(string user, string fromDate, string toDate)
       {
           var sql = "EXEC [proc_downloadSambaPaidData] @flag = 's'";
           sql += ",@user=" + FilterString(user);
           sql += ",@fromDate=" + FilterString(fromDate);
           sql += ",@toDate=" + FilterString(toDate);
           return ExecuteDataTable(sql);
       }
    }
}
