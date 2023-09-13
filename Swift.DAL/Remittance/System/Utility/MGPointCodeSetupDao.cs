using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.Utility
{
   public class MGPointCodeSetupDao:SwiftDao
    {
       public DbResult Update(string user, string id, string pointCode, string userName, string pwd, string branchId)
       {
           var sql = "EXEC proc_mgPointCodeSetup";
           sql += "  @flag = " + (id == "0" || id == "" ? "'i'" : "'u'");
           sql += ",@id=" + FilterString(id);
           sql += ",@pointCode=" + FilterString(pointCode);
           sql += ",@userName=" + FilterString(userName);
           sql += ",@pwd=" + FilterString(pwd);
           sql += ",@branchId=" + FilterString(branchId);
           sql += ",@user=" + FilterString(user);
           return ParseDbResult(sql);
       }

       public  DbResult Delete(string user, string id)
       {
           var sql = "EXEC proc_mgPointCodeSetup @flag='d'";
           sql += ",@id=" + FilterString(id);
           return ParseDbResult(sql);
       }
    }
}
