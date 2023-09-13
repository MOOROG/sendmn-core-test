using Swift.DAL.SwiftDAL;
using System.Data;
using System;

namespace Swift.DAL.Remittance.CustomerDeposits
{
    public class CustomerDepositDao : RemittanceDao
    {
        public DataTable GetDataForMapping(string user,string isSkipped)
        {
            string sql = "EXEC PROC_CUSTOMER_DEPOSITS";
            sql += " @flag = 's'";
            sql += ", @isSkipped=" + FilterString(isSkipped);
            sql += ", @user = " + FilterString(user);
            return ExecuteDataTable(sql);
        }
        public DataTable GetDepositDetail(string user, string from ,string to,string status)
        {
            string sql = "EXEC PROC_CUSTOMER_DEPOSITS";
            sql += " @flag = 's-detail'";
            sql += ", @user = " + FilterString(user);
            sql += ", @from =" + FilterString(from);
            sql += ", @to = " + FilterString(to);
            sql += ", @status = " + FilterString(status);
            return ExecuteDataTable(sql);
        }
        public DataSet GetDataForSendMapping(string user, string trnDate,string particulars, string customerId,string amount)
        {
            string sql = "EXEC PROC_CUSTOMER_DEPOSITS";
            sql += " @flag = 's-filteredList'";
            sql += ", @user = " + FilterString(user);
            sql += ", @trnDate = " + FilterString(trnDate);
            sql += ", @particulars = " + FilterString(particulars);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @amount = " + FilterString(amount);

            return ExecuteDataset(sql);
        }

        public DbResult SaveCustomerDeposit(string user, string logId, string customerId,string bankId)
        {
            string sql = "EXEC PROC_CUSTOMER_DEPOSITS";
            sql += " @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(logId);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @bankId = " + FilterString(bankId);
            return ParseDbResult(sql);
        }

        public DbResult SaveMapping(string user, string tranId, string id)
        {
            string sql = "EXEC PROC_CUSTOMER_DEPOSITS";
            sql += " @flag = 'map-txn'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @id = " + FilterString(id);

            return ParseDbResult(sql);
        }

        public DataTable GetHoldTxnList(string user)
        {
            string sql = "EXEC proc_ApproveHoldedTXN ";
            sql += "@flag = 's-admin-map'";
            sql += ", @user = " + FilterString(user);

            return ExecuteDataTable(sql);
        }

        public DbResult SaveMultipleCustomerDeposit(string user, string tranIds, string customerId)
        {
            string sql = "EXEC PROC_CUSTOMER_DEPOSITS";
            sql += " @flag = 'i-multiple'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @customerId = " + FilterString(customerId);
            return ParseDbResult(sql);
        }

        public DbResult UnMapCustomerDeposit(string user, string tranIds, string customerId)
        {
            string sql = "EXEC PROC_CUSTOMER_DEPOSITS";
            sql += " @flag = 'unmap'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @customerId = " + FilterString(customerId);
            return ParseDbResult(sql);
        }
     
        public DbResult RefundCustomerDeposit(string user, string tranIds, string customerId)
        {
            string sql = "EXEC PROC_CUSTOMER_DEPOSITS";
            sql += " @flag = 'refund'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranIds);
            sql += ", @customerId = " + FilterString(customerId);
            return ParseDbResult(sql);
        }
        public DbResult SkipCustomerDeposits(string user, string tranIds, string customerId)
        {
            string sql = "EXEC PROC_CUSTOMER_DEPOSITS";
            sql += " @flag = 'skip'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranIds);
            sql += ", @customerId = " + FilterString(customerId);
            return ParseDbResult(sql);
        }
        public DbResult UnMapCustomerDeposit2(string user, string tranId)
        {
            string sql = "EXEC PROC_CUSTOMER_DEPOSITS";
            sql += " @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            return ParseDbResult(sql);
        }
        public DataRow GetCustomerDetail(string customerId, string user)
        {
            string sql = "EXEC PROC_CUSTOMER_DEPOSITS";
            sql += " @flag = 'DETAIL'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            return ExecuteDataRow(sql);
        }

        public DbResult CustomerSkipped(string user, string logId,string isSkipped)
        {
            string sql = "EXEC PROC_CUSTOMER_DEPOSITS";
            sql += " @flag = 'skipped'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(logId);
            sql += ", @isSkipped = " + FilterString(isSkipped);
            return ParseDbResult(sql);
        }
        public DbResult UpdateVisaStatus(string user, string visaStatusId, string customerId)
        {
            string sql = "EXEC PROC_VISASTATUS";
            sql += " @flag = 'update'";
            sql += ", @user = " + FilterString(user);
            sql += ", @visaStatusId = " + FilterString(visaStatusId);
            sql += ", @customerId = " + FilterString(customerId);
            return ParseDbResult(sql);
        }
    }
}
