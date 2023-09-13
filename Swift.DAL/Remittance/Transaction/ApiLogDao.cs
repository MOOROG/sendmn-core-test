using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.Remittance.Transaction
{
    public class ApiLogDao : RemittanceDao
    {
        public DataRow GetApiLogRecord(string id)
        {
            var sql = "EXEC proc_ApiLogs @flag='a',@rowId=" + FilterString(id);
            return ExecuteDataRow(sql);
        }

        public DataRow GetKFTCLogRecord(string id,string User)
        {
            var sql = "EXEC proc_KFTCApiLogs @flag='a',@rowId=" + FilterString(id);
            sql += " , @User = "+ FilterString(User);
            return ExecuteDataRow(sql);
        }
    }
}
