using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.BL.Remit.Transaction.ThirdParty.Reprocess
{
    public class ReprocessTransactionDao : RemittanceDao
    {
        public DataRow CheckTransactionStatus(string riaOrderId, string tranId)
        {
            var sql = "EXEC proc_CheckCollModeType  @orderId = " + FilterString(riaOrderId);
            sql += ", @tranId = " + FilterString(tranId);
            return ExecuteDataRow(sql);
        }

        public DbResult UpdateOnlineTxnSofo(string user, string sofoTxnId, string id, string detailVal, string paymentType, string amount, string statusSofort)
        {
            var sql = "EXEC [proc_Online_SendApprove] @flag = 'SofoResponse'";
            sql += ", @user = " + FilterString(user);
            sql += ", @SofoTxnId = " + FilterString(sofoTxnId);
            sql += ", @id = " + FilterString(id);
            sql += ", @detailVal = " + FilterString(detailVal);
            sql += ", @strPaymentType = " + FilterString(paymentType);
            sql += ", @fltAmount = " + FilterString(amount);
            sql += ", @statusSofort = " + FilterString(statusSofort);
            return ParseDbResult(sql);
        }

        public DbResult UpdateRealexTxn(string user, string id, string mrn, string strPaymentType, string detailVal, string fltAmount, string intStatus, string statusSofort, string statusReason, string merchantSig, string sofoTxnId, string bankName, string tranId)
        {
            var sql = "EXEC [proc_Online_SendApprove] @flag = 'updateRealexTxn'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @mrn = " + FilterString(mrn);
            sql += ", @detailVal = " + FilterString(detailVal);
            sql += ", @strPaymentType = " + FilterString(strPaymentType);
            sql += ", @fltAmount = " + FilterString(fltAmount);
            sql += ", @intStatus = " + FilterString(intStatus);
            sql += ", @statusSofort =" + FilterString(statusSofort);
            sql += ", @statusReason =" + FilterString(statusReason);
            sql += ", @merchantSig =" + FilterString(merchantSig);
            sql += ", @SofoTxnId  =" + FilterString(sofoTxnId);
            sql += ", @BankName  =" + FilterString(bankName);
            sql += ", @tranId  =" + FilterString(tranId);
            return ParseDbResult(sql);
        }
    }
}
