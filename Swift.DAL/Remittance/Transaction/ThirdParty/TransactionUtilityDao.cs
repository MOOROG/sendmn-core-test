using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Transaction.ThirdParty
{
    public class TransactionUtilityDao : RemittanceDao
    {
        public DataTable GetSyncDateList(string agentCode, string user, string pass)
        {
            var sql = string.Format(@"EXEC proc_transactionUtility @flag='sync-date-list', @agentCode={0},@user={1},@pass={2}", FilterString(agentCode), FilterString(user), FilterString(pass));
            return ExecuteDataTable(sql);
        }
        public string GetCountryNameFromCountryCode(string user, string code)
        {
            var sql = "EXEC proc_countryMaster @flag='countryCode2Name'";
            sql += ",@user = " + FilterString(user);
            sql += ",@countryCode = " + FilterString(code);
            var name = GetSingleResult(sql);
            if (string.IsNullOrWhiteSpace(name)) name = code;
            return name;
        }

        public string GetControlNo2(string user, string controlNo)
        {
            var sql = "EXEC proc_transactionUtility @flag='c2'";
            sql += ",@user = " + FilterString(user);
            sql += ",@controlNo = " + FilterString(controlNo);
            return GetSingleResult(sql);
        }

        public DbResult GetTxnStatus(string user, string partnerId, string controlNo)
        {
            var sql = "EXEC proc_transactionUtility @flag='checkTxn'";
            sql += ",@user = " + FilterString(user);
            sql += ",@partnerId = " + FilterString(partnerId);
            sql += ",@controlNo = " + FilterString(controlNo);
            return ParseDbResult(sql);
        }

        public DbResult LogApiResponse(string user, string id, string controlNo, string agentId, string msg, string xmlResponse, string xmlRequest)
        {
            var sql = "EXEC proc_transactionUtility @flag='log'";
            sql += ",@user=" + FilterString(user);
            sql += ",@controlNo=" + FilterString(controlNo);
            sql += ",@agentId=" + FilterString(agentId);
            sql += ",@msg=" + FilterString(msg);
            sql += ",@xmlRequest=" + FilterString(xmlRequest);
            sql += ",@xmlResponse=" + FilterString(xmlResponse);

            return ParseDbResult(sql);
        }
    }
}
