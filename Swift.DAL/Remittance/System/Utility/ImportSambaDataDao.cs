using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.Utility
{
   public class ImportSambaDataDao:SwiftDao
    {
       public DbResult ImportData(string user, string fromDate, string toDate, string sessionId)
       {
           var sql = "EXEC [proc_OMRemitGate_GetUnpaidList] @flag = 'i'";
           sql += ",@user=" + FilterString(user);
           sql += ",@fromDate=" + FilterString(fromDate);
           sql += ",@toDate=" + FilterString(toDate);
           sql += ",@session_id=" + FilterString(sessionId);
           return ParseDbResult(sql);
       }

       public DbResult UpdateData(string user, string sessionId)
       {
           var sql = "EXEC [proc_OMRemitGate_GetUnpaidList] @flag = 'a'";
           sql += ", @user=" + FilterString(user);
           sql += ",@session_id=" + FilterString(sessionId);
           return ParseDbResult(sql);
       }

       public DataTable ShowData(string user, string fromDate , string toDate, string sessionId)
       {
           var sql = "EXEC [proc_OMRemitGate_GetUnpaidList] @flag = 's'";
           sql += ",@user=" + FilterString(user);
           sql += ",@fromDate=" + FilterString(fromDate);
           sql += ",@toDate=" + FilterString(toDate);
           sql += ",@session_id=" + FilterString(sessionId);
           return ExecuteDataTable(sql);
       }

    }
}
