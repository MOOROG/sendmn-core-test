using Swift.DAL.SwiftDAL;
using System;
using System.Data;

namespace Swift.DAL.Remittance.ExchangeRate
{
    public class ImportSettlementRateDao : RemittanceDao
    {
        public DataSet ImportSettlementRate(string user, string xml, string sessionId)
        {
            string sql = "EXEC PROC_UPDATE_EX_RATE ";
            sql += "@flag = 'U'";
            sql += ",@user = " + FilterString(user);
            sql += ",@XML = N'" + FilterStringForXml(xml) + "'";
            sql += ",@SESSION_ID = " + FilterString(sessionId);

            return ExecuteDataset(sql);
        }

        public DbResult ConfirmSave(string user, string ids, string sessionId)
        {
            string sql = "EXEC PROC_UPDATE_EX_RATE ";
            sql += "@flag = 'APPROVE'";
            sql += ",@user = " + FilterString(user);
            sql += ",@ids = " + FilterString(ids);
            sql += ",@SESSION_ID = " + FilterString(sessionId);

            return ParseDbResult(sql);
        }

        public void ClearData(string user, string sessionId)
        {
            string sql = "EXEC PROC_UPDATE_EX_RATE ";
            sql += "@flag = 'CLEAR'";
            sql += ",@SESSION_ID = " + FilterString(sessionId);
            sql += ",@user = " + FilterString(user);

            ExecuteDataRow(sql);
        }

        public DbResult SaveTransactionInficare(string user, string xml, string flag, string msg = "")
        {
            string sql = "EXEC PROC_DOWNLOAD_INFICARE_SYSTEM_TXNS ";
            sql += "@FLAG = '" + flag + "'";
            sql += ",@XML = N'" + xml + "'";
            sql += ",@user = " + FilterString(user);
            sql += ",@DATE = " + FilterString(msg);

            return ParseDbResult(sql);
        }

        public DbResult RunJob(string user, string jobName)
        {
            return ExecuteJob(jobName);
        }

        public DataSet ShowInficareTempData(string user, string map)
        {
            string sql = "EXEC PROC_DOWNLOAD_INFICARE_SYSTEM_TXNS ";
            sql += "@flag = 'SHOW'";
            sql += ",@user = " + FilterString(user);
            sql += ",@filter1 = " + FilterString(map);

            return ExecuteDataset(sql);
        }

        public DataSet ShowCustomerReceiverData(string user)
        {
            string sql = "EXEC PROC_DOWNLOAD_INFICARE_SYSTEM_TXNS ";
            sql += "@flag = 'DOWNLOAD-DETAIL'";
            sql += ",@user = " + FilterString(user);

            return ExecuteDataset(sql);
        }

        public DbResult MapReferral(string user, string tranId, string referralCode)
        {
            string sql = "EXEC PROC_DOWNLOAD_INFICARE_SYSTEM_TXNS ";
            sql += "@flag = 'MAP'";
            sql += ",@user = " + FilterString(user);
            sql += ",@TRAN_ID = " + FilterString(tranId);
            sql += ",@REFERRAL_CODE = " + FilterString(referralCode);

            return ParseDbResult(sql);
        }

        public DbResult UploadManualMap(string user, string xml)
        {
            string sql = "EXEC PROC_DOWNLOAD_INFICARE_SYSTEM_TXNS ";
            sql += "@flag = 'BULK-MAP'";
            sql += ",@user = " + FilterString(user);
            sql += ",@XML =  '" + xml + "'";

            return ParseDbResult(sql);
        }

        public DbResult FinalSave(string user)
        {
            string sql = "EXEC PROC_DOWNLOAD_INFICARE_SYSTEM_TXNS ";
            sql += "@flag = 'MAIN-SAVE'";
            sql += ", @user =" + FilterString(user);

            return ParseDbResult(sql);
        }

        public void ClearTempData(string user)
        {
            string sql = "EXEC PROC_DOWNLOAD_INFICARE_SYSTEM_TXNS ";
            sql += "@flag = 'DELETE'";
            sql += ",@user =" + FilterString(user);

            ExecuteDataTable(sql);
        }

        public DbResult ClearTempTranData(string user)
        {
            string sql = "EXEC PROC_DOWNLOAD_INFICARE_SYSTEM_TXNS ";
            sql += "@flag = 'DELETE-TRAN'";
            sql += ",@user =" + FilterString(user);

            return ParseDbResult(sql);
        }

        public DbResult RunVaultTransfer(string user)
        {
            string sql = "EXEC PROC_JOB_VAULT_TRANSFER_AND_EOD ";
            sql += "@USER =" + FilterString(user);

            return ParseDbResult(sql);
        }
    }
}
