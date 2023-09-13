using GmeKoreaPayAPI.gmePayWebRef;
using System;
using System.Net;

namespace GMEPayAPI.APIService
{
    public class GMEPayService : IGMEPayService
    {
        protected GMEWebService _gmeRemit;
        public GMEPayService()
        {
            _gmeRemit = new GMEWebService();
        }

        #region Cash Pay
        public GetPaymentTransactionResult SelectByPinNo(string partnerId, string userName, string password, string pinNo, string sessionId)
        {
            var _res = new GetPaymentTransactionResult();
            try
            {
                _res = _gmeRemit.GetPaymentTransaction(partnerId, userName, password, pinNo, sessionId);
            }
            catch (Exception ex)
            {
                _res.ErrorCode = "999";
                _res.Message = ex.Message;
            }
            return _res;
        }

        public ConfirmPaymentTransactionResult PayConfirm(PayDetail payDetail)
        {
            var _res = new ConfirmPaymentTransactionResult();
            try
            {
                _res = _gmeRemit.ConfirmPaymentTransaction(payDetail.PartnerId, payDetail.UserName, payDetail.Password, payDetail.PinNo, payDetail.SessionId, payDetail.ReceivingTokenId, payDetail.RecIdType, payDetail.RecIdNumber,
                        payDetail.RecIdIssuePlace, payDetail.RecIdIssueDate, payDetail.RecDOB, payDetail.RecOccupation);

            }
            catch (Exception ex)
            {
                _res.ErrorCode = "999";
                _res.Message = ex.Message;
            }
            return _res;
        }

        #endregion Cash Pay


        #region Bank Deposit
        public GetBankDepositTransactionResult[] AccountDepositOutStanding(string partnerId, string userName, string password, string sessionId)
        {
            return _gmeRemit.GetBankDepositTransaction(partnerId, userName, password, sessionId);
        }

        public AccountDepositMarkDownloadedResult AccountDepositMarkAsDownloaded(string partnerId, string userName, string password, string sessionId, string downloadTokenId)
        {
            var _res = new AccountDepositMarkDownloadedResult();
            try
            {
                _res = _gmeRemit.MarkBankDepositAsDownloaded(partnerId, userName, password, sessionId, downloadTokenId);
            }
            catch (Exception ex)
            {
                _res.ErrorCode = "999";
                _res.Message = ex.Message;
            }
            return _res;
        }

        public MarkBankDepositAsPaidResult AccountDepositMarkAsPaid(string partnerId, string userName, string password, string sessionId, string[] pinNo)
        {
            var _res = new MarkBankDepositAsPaidResult();
            try
            {
                _res = _gmeRemit.MarkBankDepositAsPaid(partnerId, userName, password, sessionId, pinNo);
            }
            catch (Exception ex)
            {
                _res.ErrorCode = "999";
                _res.Message = ex.Message;
            }
            return _res;
        }
        #endregion Bank Deposit
    }
}
