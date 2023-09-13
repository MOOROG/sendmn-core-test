using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Transaction.PayTransaction
{
    public class PayDao : RemittanceDao
    {
        public double GetPayAmountLimit(string user, string controlNo)
        {
            string sql = "EXEC proc_GetPayAmountLimit";
            sql += "  @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);            
            var res = GetSingleResult(sql);
            double ret;
            double.TryParse(res, out ret);
            return ret;            
        }

        public DataTable GetProviderByControlNo(string user, string controlNo)
        {
            var sql = "EXEC proc_GetProviderByControlNo ";
            sql += "@user = " + FilterString(user);
            sql += ",@controlNo = " + FilterString(controlNo);
            return ExecuteDataTable(sql);
        }

        public DataTable SearchTxnPriority(string user, string controlNo)
        {
            string sql = "EXEC proc_getTxnSearchPriority";
            sql += "  @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            return ExecuteDataTable(sql);
        }

        public DataTable LoadBranchUser(string agentId)
        {
            string sql = "EXEC proc_dropDownLists2 @flag = 'loadUser',";
            sql += "  @agentId = " + FilterString(agentId);
            return ExecuteDataTable(sql);
        }

        public DataSet GetThirdParyTxnDetail(string user, string rowId, string partnerId, string branchId)
        {
            var sql = "EXEC proc_payTransactionDetail";
            sql += "  @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @partnerId = " + FilterString(partnerId);
            sql += ", @pBranchId = " + FilterString(branchId);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DbResult CheckValidationDom(string user, string controlNo, string branchId, string partnerId)
        {
            var sql = "EXEC proc_payTxnValidation @flag='s'";
            sql += ",@user = " + FilterString(user);
            sql += ",@controlNo = " + FilterString(controlNo);
            sql += ",@partnerId = " + FilterString(partnerId);
            sql += ",@pBranchId = " + FilterString(branchId);
            return ParseDbResult(sql);
        }

        public DbResult CheckPinValidationIntl(string user, string controlNo, string branchId, string partnerId)
        {
            var sql = "EXEC proc_payTxnValidation @flag='s'";
            sql += ",@user = " + FilterString(user);
            sql += ",@controlNo = " + FilterString(controlNo);
            sql += ",@partnerId = " + FilterString(partnerId);
            sql += ",@pBranchId = " + FilterString(branchId);

            return ParseDbResult(sql);
        }
    }
}



