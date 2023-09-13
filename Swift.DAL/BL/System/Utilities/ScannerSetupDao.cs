using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.Utilities
{
    public class ScannerSetupDao : RemittanceDao
    {
        public DataTable UpdateScanner(string userId, string scannerName)
        {

            var sql = "EXEC proc_UserDefaultDevice @flag = 'i'";
            sql += ",@userId=" + FilterString(userId);
            sql += ",@scannerName=" + FilterString(scannerName);
            return ExecuteDataTable(sql);
        }

        public string GetUserScanner(string user)
        {
            var sql = "EXEC proc_UserDefaultDevice @flag = 's'";
            sql += ",@userId=" + FilterString(user);

            var dt = ExecuteDataTable(sql);
            if (dt.Rows.Count > 0)
            {
                return dt.Rows[0]["scannerName"].ToString();
            }
            else
            {
                return "";
            }
        }

        public DataTable CheckDocument(string agentId, string tranId, string icn, string voucherType)
        {
            var sql = "EXEC proc_txnDocuments @flag = 'cd'";
            sql += ",@agentId=" + FilterString(agentId);
            sql += ",@tranId=" + FilterString(tranId);
            sql += ",@icn=" + FilterString(icn);
            sql += ",@voucherType=" + FilterString(voucherType);
            return ExecuteDataTable(sql);
        }
    }
}
