using GmeKoreaPayAPI.gmePayWebRef;
using GMEPayAPI.APIService;
using Swift.DAL.BL.Helper.ThirdParty;
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Net;
using System.Text;

namespace Swift.DAL.BL.ThirdParty.GME
{
    public class GMEDao : IGMEDao
    {
        protected readonly string partnerId;
        protected readonly string userName;
        protected readonly string password;
        private StringBuilder sql;
        protected RemittanceDao _remit;
        protected IGMEPayService _gme;

        public GMEDao()
        {
            _remit = new RemittanceDao();
            _gme = new GMEPayService();
            partnerId = ReadWebConfig("gmeAgentCode", "");
            userName = ReadWebConfig("gmeusername", "");
            password = ReadWebConfig("gmepassword", "");
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
        }

        public static string ReadWebConfig(string key, string defValue)
        {
            return (ConfigurationSettings.AppSettings[key] ?? defValue);
        }

        #region cash

        public DbResult SelectByPinNo(string user, string branchId, string refNo)
        {
            string sessionId = GetAgentSession();
            var requestXml = "refNo=" + refNo + ";sessionId :" + sessionId;
            var dr = new DbResult();
            var id = ApiUtility.LogRequest(user, "GME", "SelectByPinNo", refNo, requestXml).Id;

            var drApi = _gme.SelectByPinNo(partnerId, userName, password, refNo, sessionId);
            var responseXml = ApiUtility.ObjectToXML(drApi);
            if (drApi == null)
            {
                ApiUtility.LogDataError(id, "999", "Internal Error");
                return dr;
            }
            else if (drApi.ErrorCode != "0")
            {
                dr.SetError(drApi.ErrorCode, drApi.Message, "");
                dr.Extra = "0";
                ApiUtility.LogResponse(id, responseXml, drApi.ErrorCode, drApi.Message);

                return dr;
            }
            ApiUtility.LogResponse(id, responseXml, drApi.ErrorCode, drApi.Message);
            dr = Save(user, branchId, drApi);
            dr.Extra = "2";

            return dr;
        }

        private DbResult Save(string user, string branchId, GetPaymentTransactionResult drApi)
        {
            var sql = "EXEC proc_GMERemitCashPay";
            sql += " @flag = 'i'";
            sql += ",@message =" + _remit.FilterString(drApi.Message);
            sql += ",@user = " + _remit.FilterString(user);
            sql += ",@pBranch = " + _remit.FilterString(branchId);
            sql += ",@refNo =" + _remit.FilterString(drApi.PinNo);
            //sql += ",@sendAgent =" + _remit.FilterString(drApi.SendingPartner);

            sql += ",@senderName =" + _remit.FilterString(drApi.CustomerName);
            sql += ",@SenderAddress =" + _remit.FilterString(drApi.CustomerAddress);
            sql += ",@SenderMobile =" + _remit.FilterString(drApi.CustomerContact);
            sql += ",@senderCity =" + _remit.FilterString(drApi.CustomerCity);
            sql += ",@senderCountry =" + _remit.FilterString(drApi.CustomerCountry);

            sql += ",@BenefName =" + _remit.FilterString(drApi.BeneName);
            sql += ",@BenefAddress=" + _remit.FilterString(drApi.BeneAddress);
            sql += ",@BenefMobile =" + _remit.FilterString(drApi.BenePhone);
            sql += ",@benefCity =" + _remit.FilterString(drApi.BeneCity);
            sql += ",@benefCountry =" + _remit.FilterString(drApi.BeneCountry);

            sql += ",@pAmount=" + _remit.FilterString(drApi.ReceivingAmount);
            sql += ",@sAmount=" + _remit.FilterString(drApi.SendingAmount);
            sql += ",@pCurrency =" + _remit.FilterString(drApi.ReceivingCurrency);
            sql += ",@paymentType=" + _remit.FilterString(drApi.PaymentMethod);
            sql += ",@remittanceEntryDt =" + _remit.FilterString(drApi.TransactionDate);
            sql += ",@payTokenId =" + _remit.FilterString(drApi.ReceivingTokenId);
            sql += ",@sessionId=" + _remit.FilterString(drApi.SessionId);
            sql += ",@rOccupation=" + _remit.FilterString(drApi.Occupation);
            sql += ",@incomeSource=" + _remit.FilterString(drApi.IncomeSource);
            sql += ",@relationship=" + _remit.FilterString(drApi.Relationship);
            sql += ",@purpose=" + _remit.FilterString(drApi.PurposeOfRemittance);
            //sql += ",@calculateBy=" + _remit.FilterString(drApi.CalculateBy);
            sql += ",@pCurrCostRate=" + _remit.FilterString(drApi.pCurrCostRate);
            sql += ",@sCurrCostRate=" + _remit.FilterString(drApi.sCurrCostRate);

            return _remit.ParseDbResult(sql);
        }

        public DbResult RestoreTransaction(string branchId, string branchName, string user, string rowId, string provider)
        {
            var sql = "EXEC proc_GMERemitCashPay @flag='restore'";
            sql += ", @user=" + _remit.FilterString(user);
            sql += ", @pBranch=" + _remit.FilterString(branchId);
            sql += ", @rowId=" + _remit.FilterString(rowId);
            sql += ", @pBranchName=" + _remit.FilterString(branchName);
            sql += ", @sBranchMapCodeInt=" + _remit.FilterString(provider);
            sql += ", @payResponseCode = " + _remit.FilterString("0");
            sql += ", @payResponseMsg = " + _remit.FilterString("Paid transaction re confirmed");
            sql += ", @payConfirmationNo = " + _remit.FilterString("00000");

            return _remit.ParseDbResult(sql);
        }

        public DbResult PayConfirm(GMEPayConfirmDetails _payConfirmDetails)
        {
            var sql = "EXEC proc_GMERemitCashPay";
            sql += " @flag = 'readyToPay'";
            sql += ",@user= " + _remit.FilterString(_payConfirmDetails.user);
            sql += ",@rowId= " + _remit.FilterString(_payConfirmDetails.rowId);
            sql += ",@pBranch = " + _remit.FilterString(_payConfirmDetails.pBranch);
            sql += ",@rIdType = " + _remit.FilterString(_payConfirmDetails.rIdType);
            sql += ",@rIdNumber = " + _remit.FilterString(_payConfirmDetails.rIdNumber);
            sql += ",@rIdPlaceOfIssue = " + _remit.FilterString(_payConfirmDetails.rIdPlaceOfIssue);
            sql += ",@rContactNo = " + _remit.FilterString(_payConfirmDetails.rContactNo);
            sql += ",@relationType = " + _remit.FilterString(_payConfirmDetails.relationType);
            sql += ",@relativeName = " + _remit.FilterString(_payConfirmDetails.relativeName);
            sql += ",@customerId = " + _remit.FilterString(_payConfirmDetails.customerId);
            sql += ",@membershipId = " + _remit.FilterString(_payConfirmDetails.membershipId);
            sql += ",@rBankName = " + _remit.FilterString(_payConfirmDetails.rBankName);
            sql += ",@rBankBranch = " + _remit.FilterString(_payConfirmDetails.rBankBranch);
            sql += ",@rCheque = " + _remit.FilterString(_payConfirmDetails.rCheque);
            sql += ",@rAccountNo = " + _remit.FilterString(_payConfirmDetails.rAccountNo);
            sql += ",@rDob = " + _remit.FilterString(_payConfirmDetails.dob);
            sql += ",@relationship = " + _remit.FilterString(_payConfirmDetails.relationship);
            sql += ",@purpose = " + _remit.FilterString(_payConfirmDetails.purposeOfRemittance);
            sql += ",@rIssuedDate = " + _remit.FilterString(_payConfirmDetails.idIssueDate);
            sql += ",@rValidDate = " + _remit.FilterString(_payConfirmDetails.idExpiryDate);

            var dr = _remit.ParseDbResult(sql);
            if (dr.ErrorCode != "0")
            {
                return dr;
            }
            try
            {
                _payConfirmDetails.rDob = "";
                string sessionId = GetAgentSession();
                var requestXml = "PinNo=" + _payConfirmDetails.refNo +
                ";ReceivingTokenId=" + _payConfirmDetails.payTokenId + ";pBranch=" + _payConfirmDetails.pBranch +
                ";RecIdType=" + _payConfirmDetails.rIdType + ";RecIdNumber=" + _payConfirmDetails.rIdNumber + ";RecIdIssuePlace=" + _payConfirmDetails.rIdNumber +
                ";RecIdIssueDate=" + _payConfirmDetails.idIssueDate + ";RecDOB=" + _payConfirmDetails.rDob + ";RecOccupation=" + _payConfirmDetails.occupation +
                ";mobileNumber=" + _payConfirmDetails.rContactNo + ";BankName=" + _payConfirmDetails.rBankName +
                ";BankBranchName=" + _payConfirmDetails.rBankBranch;

                var drApi = ApiUtility.LogRequest(_payConfirmDetails.pBranch, "GME", "PayConfirm", _payConfirmDetails.refNo, ApiUtility.ObjectToXML(requestXml));
                var id = drApi.Id;

                if (!drApi.ErrorCode.Equals("0"))
                {
                    dr.SetError(drApi.ErrorCode, "Technical Error. Please try again.", _payConfirmDetails.refNo);
                    return dr;
                }

                PayDetail payDetail = new PayDetail()
                {
                    PartnerId = partnerId,
                    UserName = userName,
                    Password = password,
                    PinNo = _payConfirmDetails.refNo,
                    SessionId = sessionId,
                    ReceivingTokenId = _payConfirmDetails.payTokenId,
                    RecIdType = _payConfirmDetails.rIdType,
                    RecIdNumber = _payConfirmDetails.rIdNumber,
                    RecIdIssuePlace = _payConfirmDetails.rIdPlaceOfIssue,
                    RecIdIssueDate = _payConfirmDetails.idIssueDate,
                    RecDOB = _payConfirmDetails.rDob,
                    RecOccupation = _payConfirmDetails.occupation
                };

                var _response = _gme.PayConfirm(payDetail);
                if (_response.ErrorCode != "0")
                {
                    dr.SetError(_response.ErrorCode, Convert.ToString(_response.Message) == null ? _response.ConfirmationId : Convert.ToString(_response.Message), null);
                    dr.Extra = _response.ConfirmationId;//Api response Code
                    ApiUtility.LogDataError(id, dr.ErrorCode, dr.Msg);
                }
                else
                {
                    var responseXml = ApiUtility.ObjectToXML(_response);
                    ApiUtility.LogResponse(id, responseXml, "0", "Success");
                    dr.SetError(_response.ErrorCode, _response.Message, "");
                    dr.Extra = _response.ConfirmationId;
                    dr.Extra2 = _response.PagentComm;
                }

                if (dr.ErrorCode != "0")
                {
                    sql = " EXEC proc_GMERemitCashPay";
                    sql += "  @flag = 'payError'";
                    sql += ", @user= " + _remit.FilterString(_payConfirmDetails.user);
                    sql += ", @rowId= " + _remit.FilterString(_payConfirmDetails.rowId);
                    sql += ", @payResponseCode = " + _remit.FilterString(dr.Extra);
                    sql += ", @payResponseMsg = " + _remit.FilterString(dr.Msg);
                    _remit.ParseDbResult(sql);
                    return dr;
                }

                sql = " EXEC proc_GMERemitCashPay";
                sql += "  @flag = 'pay'";
                sql += ", @user= " + _remit.FilterString(_payConfirmDetails.user);
                sql += ", @rowId= " + _remit.FilterString(_payConfirmDetails.rowId);
                sql += ", @sCountry= " + _remit.FilterString(_payConfirmDetails.sCountry);
                sql += ", @payResponseCode = " + _remit.FilterString(dr.ErrorCode);
                sql += ", @payResponseMsg = " + _remit.FilterString(dr.Msg);
                sql += ", @payConfirmationNo = " + _remit.FilterString(dr.Extra);
                sql += ", @pCommission = " + _remit.FilterString(dr.Extra2);
                sql += ", @sBranchMapCOdeInt=" + _remit.FilterString(_payConfirmDetails.branchMapCode);

                return _remit.ParseDbResult(sql);
            }
            catch (Exception ex)
            {
                sql = " EXEC proc_GMERemitCashPay";
                sql += "  @flag = 'payError'";
                sql += ", @user= " + _remit.FilterString(_payConfirmDetails.user);
                sql += ", @rowId= " + _remit.FilterString(_payConfirmDetails.rowId);
                sql += ", @payResponseCode = " + _remit.FilterString("999");
                sql += ", @payResponseMsg = " + _remit.FilterString(ex.Message);
                _remit.ParseDbResult(sql);
                ApiUtility.LogResponse(_payConfirmDetails.rowId, ex.StackTrace.ToString(), "999", ex.InnerException.Message);
                dr.SetError("1", "Pay error has been recorded successfully.", "");
                return dr;
            }
        }

        #endregion cash

        #region Bank Deposit

        public DbResult DownloadAcDepositTxn(string user)
        {
            string session = GetAgentSession();
            var requestXml = "user=" + user +
                ";userSessionId=" + session;

            var id = ApiUtility.LogRequest(user, "GME", "GetBankDepositTransaction", "", requestXml).Id;
            var dr = new DbResult();
            try
            {
                var drApi = _gme.AccountDepositOutStanding(partnerId, userName, password, session);

                if (drApi == null)
                {
                    dr.SetError("999", "Technical Error", "");
                    ApiUtility.LogResponse(id, "Exception: Null", dr.ErrorCode, dr.Msg);

                    return dr;
                }
                string xmlData = ApiUtility.ObjectToXML(drApi);
                ApiUtility.LogResponse(id, xmlData, drApi[0].ErrorCode, drApi[0].Message);
                if (drApi[0].ErrorCode.Equals("0"))
                {
                    //string xmlForSave = xmlForFinalSave(xmlData);
                    dr = SaveBankDeposit(user, xmlData);
                    if (dr.ErrorCode == "0")
                    {
                        AccountDepositMarkAsDownloaded(user, dr.Id);
                    }
                    return dr;
                }
                else
                {
                    dr.SetError(drApi[0].ErrorCode, drApi[0].Message, drApi[0].PinNo);

                    return dr;
                }
            }
            catch (Exception ex)
            {
                ApiUtility.LogRequest(user, "GME", "GetBankDepositTransaction", "", "Exception : " + ex.Message);
                dr.SetError("999", ex.Message, null);
            }
            return dr;
        }

        public DbResult AccountDepositMarkAsDownloaded(string user, string tokenId)
        {
            string session = GetAgentSession();

            var requestXml = "downloadTokenId=" + tokenId +
                ";userSessionId=" + session;

            var id = ApiUtility.LogRequest(user, "GME", "MarkBankDepositAsDownloaded", "", requestXml).Id;
            var drApi = _gme.AccountDepositMarkAsDownloaded(partnerId, userName, password, session, tokenId);

            var dr = new DbResult();
            string xmlData = ApiUtility.ObjectToXML(drApi);
            ApiUtility.LogResponse(id, xmlData, drApi.ErrorCode, drApi.Message);
            if (drApi == null)
            {
                dr.SetError("999", "Technical Error", "");
                return dr;
            }
            if (drApi.ErrorCode.Equals("0"))
            {
                dr.SetError("0", "", null);
                return dr;
            }
            else
            {
                dr.SetError("999", "Error marking the bank deposit transactions!", null);
                return dr;
            }
        }

        public DbResult PayConfirmProcess(string user)
        {
            var dr = new DbResult() { ErrorCode = "0", Msg = "Process completed" };
            try
            {
                string sql = "EXEC proc_GMERemitBankDepositPay @flag='GET-LIST', @user = 'admin'";
                var dt = _remit.ExecuteDataTable(sql);

                if (dt.Rows.Count == 0 || null == dt)
                {
                    dr.SetError("1", "No Transactions to sync!", null);
                    return dr;
                }
                dr = PayConfirmBankDeposit(user, dt);
            }
            catch (Exception e)
            {
                dr.ErrorCode = "1";
                dr.Msg = e.Message.ToString();
            }
            return dr;
        }

        protected DbResult PayConfirmBankDeposit(string user, DataTable _controlNoList)
        {
            string session = GetAgentSession();
            string[] controlNoToArray = GetControlNoAsArray(_controlNoList);
            var controlNoXML = GetControlNoAsXML(_controlNoList);

            var requestXml = "controlNoList=" + controlNoXML.Replace("row", "controlNumber").ToString() +
                ";userSessionId=" + session;

            var id = ApiUtility.LogRequest(user, "GME", "MarkBankDepositAsPaid", "", requestXml).Id;
            var drApi = _gme.AccountDepositMarkAsPaid(partnerId, userName, password, session, controlNoToArray);

            var dr = new DbResult();
            string xmlData = ApiUtility.ObjectToXML(drApi);
            ApiUtility.LogResponse(id, xmlData, drApi.ErrorCode, drApi.Message);

            if (drApi == null)
            {
                sql = new StringBuilder(" EXEC proc_GMERemitBankDepositPay  @flag = 'PAY-ERROR'");
                sql.Append(string.Format(", @user= {0}, @XML2={1},@payResponseCode ={2}, @payResponseMsg ={3} ",
                                            _remit.FilterString(user), _remit.FilterString(controlNoXML), _remit.FilterString(drApi.ErrorCode),
                                            _remit.FilterString(drApi.Message)));
                dr.SetError(drApi.ErrorCode, drApi.Message, "");

                return _remit.ParseDbResult(sql.ToString());
            }

            if (drApi.ErrorCode.Equals("0"))
            {
                sql = new StringBuilder(" EXEC proc_GMERemitBankDepositPay  @flag = 'PAY-SUCCESS'");
                sql.Append(string.Format(", @user= {0}, @XML2={1},@payResponseCode ={2}, @payResponseMsg ={3} ",
                                            _remit.FilterString(user), _remit.FilterString(controlNoXML),
                                            _remit.FilterString(drApi.ErrorCode),
                                            _remit.FilterString(drApi.Message)));
                dr.SetError(drApi.ErrorCode, drApi.Message, "");

                return _remit.ParseDbResult(sql.ToString());
            }
            else
            {
                sql = new StringBuilder(" EXEC proc_GMERemitBankDepositPay  @flag = 'PAY-ERROR'");
                sql.Append(string.Format(", @user= {0}, @XML2={1},@payResponseCode ={2}, @payResponseMsg ={3} ",
                                            _remit.FilterString(user), _remit.FilterString(controlNoXML), _remit.FilterString(drApi.ErrorCode),
                                            _remit.FilterString(drApi.Message)));
                dr.SetError(drApi.ErrorCode, drApi.Message, "");

                return _remit.ParseDbResult(sql.ToString());
            }
        }

        protected string[] GetControlNoAsArray(DataTable _controlNoList)
        {
            List<string> controlNo = new List<string>();
            foreach (DataRow item in _controlNoList.Rows)
            {
                controlNo.Add(item["controlNo"].ToString());
            }
            return controlNo.ToArray();
        }

        private string GetControlNoAsXML(DataTable _controlNoList)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<root>");
            foreach (DataRow item in _controlNoList.Rows)
            {
                sb.AppendLine("<row>" + item["controlNo"].ToString() + "</row>");
            }
            sb.AppendLine("</root>");
            return sb.ToString();
        }

        #endregion Bank Deposit

        #region Bank Deposit SQL

        public DbResult SaveBankDeposit(string user, string xmlData)
        {
            sql = new StringBuilder("EXEC proc_GMERemitBankDepositPay @flag='download'");
            sql.Append(string.Format(",@XML='{0}',@user={1}", xmlData, _remit.FilterString(user)));

            return _remit.ParseDbResult(sql.ToString());
        }

        public DataSet ShowAcAllList(string user)
        {
            sql = new StringBuilder("EXEC proc_GMERemitBankDepositPay @flag='all-list'");
            sql.Append(string.Format(",@user={0}", _remit.FilterString(user)));
            return _remit.ExecuteDataset(sql.ToString());
        }

        public DataTable ShowFilterTxnList(string filterType)
        {
            sql = new StringBuilder("EXEC proc_GMERemitBankDepositPay @flag='all-list'");
            sql.Append(string.Format(",@filterType = {0}", _remit.FilterString(filterType)));
            return _remit.ExecuteDataTable(sql.ToString());
        }

        public DataRow SelectByRowId(string rowId)
        {
            sql = new StringBuilder("EXEC proc_GMERemitBankDepositPay @flag='a'");
            sql.Append(string.Format(",@rowId={0}", _remit.FilterString(rowId)));
            return _remit.ExecuteDataRow(sql.ToString());
        }

        public DataRow SelectByPinNo(string controlNo)
        {
            sql = new StringBuilder("EXEC proc_GMERemitBankDepositPay @flag='select'");
            sql.Append(string.Format(",@ceNumber={0}", _remit.FilterString(controlNo)));
            return _remit.ExecuteDataRow(sql.ToString());
        }

        public DbResult UpdateBeneficiaryBank(string user, string rowId, string rBankId, string rBankBranchId, string pBankType)
        {
            sql = new StringBuilder("EXEC proc_GMERemitBankDepositPay @flag='updateBank'");
            sql.Append(string.Format(",@user={0},@rowId = {1},@pBank = {2},@pBankBranch={3},@pBankType={4}"
                , _remit.FilterString(user), _remit.FilterString(rowId), _remit.FilterString(rBankId), _remit.FilterString(rBankBranchId), _remit.FilterString(pBankType)));
            return _remit.ParseDbResult(sql.ToString());
        }

        public DbResult Delete(string user, string rowId)
        {
            var sql = "EXEC proc_GMERemitBankDepositPay @flag='d',@rowId=" + _remit.FilterString(rowId);
            return _remit.ParseDbResult(sql.ToString());
        }

        public DbResult UpdateReceiverName(string user, string rowId, string receiverName)
        {
            sql = new StringBuilder("EXEC proc_GMERemitBankDepositPay @flag='updateRecName'");
            sql.Append(string.Format(",@user={0},@rowId = {1},@receiverName={2}"
                , _remit.FilterString(user), _remit.FilterString(rowId), _remit.FilterString(receiverName)));
            return _remit.ParseDbResult(sql.ToString());
        }

        public DbResult UpdateBankDetails(string user, string rowId, string rBankName, string rBankBranchName, string receiverAccountNumber)
        {
            sql = new StringBuilder("EXEC proc_GMERemitBankDepositPay @flag='updateBankDetails'");
            sql.Append(string.Format(",@user={0},@rowId = {1},@bankName = {2},@bankBranchName = {3},@receiverAccountNumber={4}"
                , _remit.FilterString(user), _remit.FilterString(rowId), _remit.FilterString(rBankName), _remit.FilterString(rBankBranchName), _remit.FilterString(receiverAccountNumber)));
            return _remit.ParseDbResult(sql.ToString());
        }

        #endregion Bank Deposit SQL

        private string GetAgentSession()
        {
            return (DateTime.Now.Ticks + DateTime.Now.Millisecond).ToString();
        }

        public DataTable GetDataForPaidSyncToPartner(string provider)
        {
            string sql = "EXEC Proc_SyncData @flag='Mark-Paid-Partner'";
            sql += ",@PROVIDER = " + _remit.FilterString(provider);
            return _remit.ExecuteDataTable(sql);
        }
    }
}