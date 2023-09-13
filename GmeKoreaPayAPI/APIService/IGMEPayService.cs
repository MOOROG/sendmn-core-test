using GmeKoreaPayAPI.gmePayWebRef;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GMEPayAPI.APIService
{    
    public interface IGMEPayService
    {
        #region Cash Pay
        GetPaymentTransactionResult SelectByPinNo(string partnerId, string userName, string password, string pinNo, string sessionId);
        ConfirmPaymentTransactionResult PayConfirm(PayDetail payDetail);
        #endregion Cash Pay

        #region Bank Deposit
        GetBankDepositTransactionResult[] AccountDepositOutStanding(string partnerId, string userName, string password, string sessionId);
        AccountDepositMarkDownloadedResult AccountDepositMarkAsDownloaded(string partnerId, string userName, string password, string sessionId, string downloadTokenId);
        MarkBankDepositAsPaidResult AccountDepositMarkAsPaid(string partnerId, string userName, string password, string sessionId, string[] pinNo);
        #endregion Bank Deposit
    }
}
