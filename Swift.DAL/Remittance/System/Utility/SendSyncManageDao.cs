using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.Utility
{
    public class SendSyncManageDao : SwiftDao
    {
        public DataRow GetStatus(string user, string tranId, string controlNo)
        {
            var sql = "EXEC proc_syncSendManage @flag = 's'";
            sql += ",@tranID = " + FilterString(tranId);
            sql += ",@controlNo = " + FilterString(controlNo);
            return ExecuteDataRow(sql);
        }

        public DbResult Resend(string controlNo,string routeId)
        {
            var sql = "EXEC proc_syncSendManage @flag = 're-send'";
            sql += ",@controlNo = " + FilterString(controlNo);
            sql += ",@routeId = " + FilterString(routeId);
            return ParseDbResult(sql);
        }

        public DbResult DoNotSync(string controlNo, string routeId)
        {
            var sql = "EXEC proc_syncSendManage @flag = 'd-send'";
            sql += ",@controlNo = " + FilterString(controlNo);
            sql += ",@routeId = " + FilterString(routeId);
            return ParseDbResult(sql);
        }
    }
}
