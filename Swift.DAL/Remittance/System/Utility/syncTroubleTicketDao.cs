using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.Utility
{
   public class syncTroubleTicketDao:SwiftDao
    {
       public DbResult Update(string user, string rowIds)
       {
           var sql = "proc_syncTroubleTicketManage @flag='i'";
           sql += ",@user=" + FilterString(user);
           sql += ",@rowIds = " + FilterString(rowIds);
          
           return ParseDbResult(sql);
       }

       public  DbResult Delete(string user, string rowid)
       {
           var sql = "proc_syncTroubleTicketManage @flag='d'";
           sql += ",@user=" + FilterString(user);
           sql += ",@rowIds = " + FilterString(rowid);
           return ParseDbResult(sql);
       }
    }
}
