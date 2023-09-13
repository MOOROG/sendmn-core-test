using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Compliance
{
    public class SuspiciousTransactionDao : SwiftDao
    {

        public DbResult Update(string user,string controlNo, string reason)
        {
            string sql = "EXEC proc_suspiciousTransaction";
            sql += " @flag = 'i' ";
            sql += ", @user = " + FilterString(user);
            sql += ",@controlNo=" + FilterString(controlNo);
            sql += ",@reason=" + FilterString(reason);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}
