using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.Utility
{
    public class PaySyncManageDao : SwiftDao
    {
        public DataRow GetStatus(string user, string tranId, string controlNo)
        {
            var sql = "EXEC proc_syncPayManage @flag = 's'";
            sql += ",@tranID = " + FilterString(tranId);
            sql += ",@controlNo = " + FilterString(controlNo);
            return ExecuteDataRow(sql);
        }

        public DbResult Resend(string controlNo, string pRouteId)
        {
            var sql = "EXEC proc_syncPayManage @flag = 're-send'";
            sql += ",@controlNo = " + FilterString(controlNo);
            sql += ",@pRouteId = " + FilterString(pRouteId);
            return ParseDbResult(sql);
        }

        public DbResult DoNotSync(string controlNo, string pRouteId)
        {
            var sql = "EXEC proc_syncPayManage @flag = 'd-send'";
            sql += ",@controlNo = " + FilterString(controlNo);
            sql += ",@pRouteId = " + FilterString(pRouteId);
            return ParseDbResult(sql);
        }
    }
}
