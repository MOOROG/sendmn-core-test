using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.Utility
{
   public class FileDownloadLogDao : SwiftDao
    {
       public DataRow FileDetail(string user, string id)
       {
           var sql = "proc_fileDownloadLog @flag = 'fileDetailAdmin'";
           sql += ",@user=" + FilterString(user);
           sql += ",@id=" + FilterString(id);
           return ExecuteDataRow(sql);
       }

       public DataTable FileDetailAgent(string user, string id)
       {
           var sql = "proc_fileDownloadLog @flag = 'fileDetailAgent'";
           sql += ",@user=" + FilterString(user);
           sql += ",@id=" + FilterString(id);
           return ExecuteDataTable(sql);
       }
    }
}
