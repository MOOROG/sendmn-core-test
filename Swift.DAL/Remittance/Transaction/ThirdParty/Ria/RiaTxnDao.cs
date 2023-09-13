using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.Transaction.ThirdParty.Ria
{
    public class RiaTxnDao : RemittanceDao
    {
        public SwiftDAL.DbResult SendRiaTxn(RiaTxnDetails _txnDetails)
        {
            var sql = "EXEC PROC_RIASENDTXN @flag='i'";
            sql += ",@user=" + FilterString(_txnDetails.User) + "";
            sql += ",@txnDate=" + FilterString(_txnDetails.RemitDate) + "";
            sql += ",@cAmt=" + FilterString(_txnDetails.CollectAmount) + "";
            sql += ",@pAmt=" + FilterString(_txnDetails.PayoutAmount) + "";
            sql += ",@exRate=" + FilterString(_txnDetails.USDExRate) + "";
            sql += ",@sCharge=" + FilterString(_txnDetails.ServiceCharge) + "";
            sql += ",@senderName=" + FilterString(_txnDetails.SenderName) + "";
            sql += ",@sIdNumber=" + FilterString(_txnDetails.SenderIdNumber) + "";
            sql += ",@pCurr=" + FilterString(_txnDetails.PayoutCurrency) + "";
            sql += ",@sCountry=" + FilterString(_txnDetails.SenderCountry) + "";
            sql += ",@sCountryId=" + FilterString(_txnDetails.SenderCountryId) + "";
            sql += ",@controlNumber=" + FilterString(_txnDetails.ControlNumber) + "";
            sql += ",@receiverName=" + FilterString(_txnDetails.ReceiverName) + "";
            sql += ",@receiverCountry=" + FilterString(_txnDetails.ReceiverCountry) + "";
            sql += ",@receiverCountryId=" + FilterString(_txnDetails.ReceiverCountryId) + "";
            sql += ",@orderNumber=" + FilterString(_txnDetails.OrderNumber) + "";
            sql += ",@sequenceNumber=" + FilterString(_txnDetails.SequenceNumber) + "";
            sql += ",@paymentMethod=" + FilterString(_txnDetails.PaymentMethod) + "";
            sql += ",@branchId=" + FilterString(_txnDetails.BranchCode) + "";
            sql += ",@sIdType=" + FilterString(_txnDetails.sIdType) + "";
            sql += ",@sIdTypeText=" + FilterString(_txnDetails.sIdTypeText) + "";
            sql += ",@sMobile=" + FilterString(_txnDetails.sMobile) + "";
            sql += ",@sEmail=" + FilterString(_txnDetails.sEmail) + "";

            return ParseDbResult(sql);
        }

        public DataTable LoadPCurrency(string user, string PayoutCoutry)
        {
            var sql = "EXEC proc_sendPageLoadData @flag = 'pcurr'";
            sql += ", @countryId = " + FilterString(PayoutCoutry);

            return ExecuteDataTable(sql);
        }

        public string GetExchangeRate()
        {
            var sql = "EXEC PROC_RIASENDTXN @flag = 'exrate'";

            return GetSingleResult(sql);
        }
    }
}
