using Swift.API.Common;
using Swift.API.Common.SendTxn;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.SwiftDAL;
using System;
using System.Data;
using System.Text;

namespace Swift.DAL.BL.Remit.Transaction
{
    public class ApproveTransactionDao : RemittanceDao
    {
        public DataSet SelectTransaction(string controlNo, string user)
        {
            string sql = "EXEC proc_approveTran @flag = 'details'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DbResult ApproveV2(string user, string tranId, string controlNo, string agentRefId)
        {
            string sql = "EXEC proc_approveTranAPI_v2";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public string GetAvailableBalance(string user, string tranId)
        {
            var sql = "EXEC PROC_CUSTOMER_DEPOSITS @flag = 'available-balance'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);

            return GetSingleResult(sql);
        }

        public DataRow ApproveAPI(string user, string tranId, string controlNo, string agentRefId)
        {
            string sql = "EXEC proc_approveTranAPI";
            sql += "  @flag = 'approveAPI'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult ApproveTranAPI(string user, string tranId, string controlNo, string agentRefId)
        {
            string sql = "EXEC proc_approveTranAPI";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult ApproveTran(string user, string tranId, string controlNo, string agentRefId)
        {
            string sql = "EXEC proc_approveTran";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string tranId, string remarks, string settlingAgentId)
        {
            var sql = "EXEC proc_ApproveHoldedTXN @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(tranId);
            sql += ", @remarks = " + FilterString(remarks);
            sql += ", @settlingAgentId = " + FilterString(settlingAgentId);
            return ParseDbResult(sql);
        }

        public DbResult SyncTransaction(string user, string controlno)
        {
            var sql = "EXEC PROC_STATUS_CHANGE_AFTER_PAID_OR_CANCEL @flag = 'SYNC'";
            sql += ", @user = " + FilterString(user);
            sql += ", @CONTROLNO = " + FilterString(controlno);

            return ParseDbResult(sql);
        }

        public DbResult ApproveMappingData(string user, string tranId, string customerId, string flag, string remmitTranTempId)
        {
            var sql = "EXEC PROC_CUSTOMER_DEPOSITS ";
            sql += "@flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @remmitTranTempId = " + FilterString(remmitTranTempId);

            return ParseDbResult(sql);
        }

        public DbResult VerifyForApprove(string user, string controlNo, string cAmt)
        {
            string sql = "EXEC proc_approveTran @flag = 'va'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @cAmt = " + FilterString(cAmt);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult TranViewLog(string user, string tranId, string controlNo, string remarks, string tranViewType)
        {
            string sql = "EXEC proc_tranViewHistory";
            sql += "  @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @remarks = " + FilterString(remarks);
            sql += ", @tranViewType = " + FilterString(tranViewType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet GetHoldedTXNList(string user, string branch, string id, string country, string sender, string receiver
       , string amt, string branchId, string userType, string flag,
         string txnDate, string txnUser, string ControlNo, string txnType)
        {
            string sql = "EXEC proc_ApproveHoldedTXN ";
            sql += " @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @branch = " + FilterString(branch);
            sql += ", @country = " + FilterString(country);
            sql += ", @sender = " + FilterString(sender);
            sql += ", @receiver = " + FilterString(receiver);
            sql += ", @amt = " + FilterString(amt);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @userType = " + FilterString(userType);
            sql += ", @txnDate = " + FilterString(txnDate);
            sql += ", @txncreatedBy = " + FilterString(txnUser);
            sql += ", @ControlNo = " + FilterString(ControlNo);
            sql += ", @txnType = " + FilterString(txnType);

            return ExecuteDataset(sql);
        }

        public DataSet GetHoldedTXNListAgent(string user, string id, string country, string sender, string receiver
        , string amt, string branchId, string userType, string flag,
          string txnDate, string txnUser, string controlNo, string txnType, string sendCountry
          , string settlingAgent)
        {
            string sql = "EXEC proc_ApproveHoldedTXN ";
            sql += "  @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @country = " + FilterString(country);
            sql += ", @sender = " + FilterString(sender);
            sql += ", @receiver = " + FilterString(receiver);
            sql += ", @amt = " + FilterString(amt);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @userType = " + FilterString(userType);
            sql += ", @txnDate = " + FilterString(txnDate);
            sql += ", @txncreatedBy = " + FilterString(txnUser);
            sql += ", @ControlNo = " + FilterString(controlNo);
            sql += ", @txnType = " + FilterString(txnType);
            sql += ", @sendCountry = " + FilterString(sendCountry);
            sql += ", @settlingAgentId = " + FilterString(settlingAgent);

            return ExecuteDataset(sql);
        }

        public DataSet GetHoldedTXNListAdmin(string user, string branch, string id, string country, string sender, string receiver
        , string amt, string branchId, string userType, string flag,
          string txnDate, string txnUser, string controlNo, string txnType, string sendCountry, string sendAgent, string sendBranch)
        {
            string sql = "EXEC proc_ApproveHoldedTXN ";
            sql += "  @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @branch = " + FilterString(branch);
            sql += ", @country = " + FilterString(country);
            sql += ", @sender = " + FilterString(sender);
            sql += ", @receiver = " + FilterString(receiver);
            sql += ", @amt = " + FilterString(amt);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @userType = " + FilterString(userType);
            sql += ", @txnDate = " + FilterString(txnDate);
            sql += ", @txncreatedBy = " + FilterString(txnUser);
            sql += ", @ControlNo = " + FilterString(controlNo);
            sql += ", @txnType = " + FilterString(txnType);
            sql += ", @sendCountry = " + FilterString(sendCountry);
            sql += ", @sendAgent = " + FilterString(sendAgent);
            sql += ", @sendBranch = " + FilterString(sendBranch);
            return ExecuteDataset(sql);
        }

        public DataSet GetAllTxnDataForVerifyCreatedFromSendTabPage(string sAgent, string user)
        {
            string sql = "EXEC proc_ApproveHoldedTXN  @flag = 'getTxnForVerify'";
            sql += " ,@sendAgent=" + FilterString(sAgent);
            sql += " ,@user=" + FilterString(user);
            return ExecuteDataset(sql);
        }

        public DbResult VerifyTransaction(string tranId, string username)
        {
            String sql = "Exec proc_ApproveHoldedTXN @flag='verifyTxnSendFromTabPage'";
            sql += ", @id=" + FilterString(tranId);
            sql += ", @user=" + FilterString(username);
            return ParseDbResult(sql);
        }

        public DbResult RejectHoldedTXN(string user, string id, string controlNO = "")
        {
            var sql = "EXEC proc_ApproveHoldedTXN @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @ControlNo = " + FilterString(controlNO);

            return ParseDbResult(sql);
        }

        public DbResult ApproveHoldedTXN(string user, string id)
        {
            var sql = "EXEC proc_ApproveHoldedTXN @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            var drDb = ParseDbResult(sql);
            return drDb;
        }

        public DbResult GetTxnApproveData(string user, string id)
        {
            var sql = "EXEC proc_ApproveHoldedTXN @flag = 'get-info'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            var drDb = ParseDbResult(sql);
            return drDb;
        }

        public DbResult GetTxnApproveDataCompliance(string user, string id)
        {
            var sql = "EXEC proc_ApproveHoldedTXN @flag = 'get-info-for-compliance'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            var drDb = ParseDbResult(sql);
            return drDb;
        }

        public JsonResponse GetHoldedTxnForApprovedByAdmin(string user, string id, string sessionId, string callFro = null)
        {
            var sql = "EXEC proc_GetHoldedTxnForApprovedByAdmin";
            sql += " @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(id);
            sql += ", @callFro = " + FilterString(callFro);

            var drDb = ExecuteDataRow(sql);
            if (drDb.Table.Columns.Contains("ErrorCode"))
            {
                return new JsonResponse()
                {
                    ResponseCode = Convert.ToString(drDb["ErrorCode"]),
                    Msg = Convert.ToString(drDb["msg"])
                };
            }
            string ProcessId = Guid.NewGuid().ToString().Replace("-", "") + ":" + Convert.ToString(drDb["processId"]) + ":sendTxn";

            SendTransactionRequest sendTxnRequest = new SendTransactionRequest();
            sendTxnRequest.UserName = user;
            sendTxnRequest.ProcessId = ProcessId.Substring(ProcessId.Length - 40, 40);
            sendTxnRequest.ProviderId = Convert.ToString(drDb["partnerId"]);
            sendTxnRequest.TranId = Convert.ToInt32(drDb["tranId"]);
            if (drDb.Table.Columns.Contains("IsRealtime"))
            {
                sendTxnRequest.IsRealtime = (drDb["IsRealtime"].ToString() == "Y" ? true : false);
            }
            else
            {
                sendTxnRequest.IsRealtime = false;
            }

            #region senderInformation

            TxnSender txnSender = new TxnSender();
            txnSender.CustomerId = Convert.ToInt32(drDb["customerId"]);
            txnSender.SFirstName = Convert.ToString(drDb["sfirstName"]);
            txnSender.SMiddleName = Convert.ToString(drDb["smiddleName"]);
            txnSender.SLastName1 = Convert.ToString(drDb["slastName1"]);
            txnSender.SLastName2 = Convert.ToString(drDb["slastName2"]);
            txnSender.SFullName = Convert.ToString(drDb["sfullName"]);
            txnSender.SIdIssueDate = Convert.ToString(drDb["sissuedDate"]);
            txnSender.SIdExpiryDate = Convert.ToString(drDb["svalidDate"]);
            txnSender.SOccuptionId = Convert.ToInt32(drDb["occupationId"]);
            txnSender.SOccuptionName = Convert.ToString(drDb["occupationName"]);
            txnSender.SBirthDate = Convert.ToString(drDb["sdob"]);
            txnSender.SEmail = string.IsNullOrEmpty(drDb["semail"].ToString()) ? null : Convert.ToString(drDb["semail"]);
            txnSender.SCityId = Convert.ToString(drDb["scity"]);
            if (drDb.Table.Columns.Contains("sstate"))
            {
                txnSender.SState = Convert.ToString(drDb["sstate"]);
            }
            if (drDb.Table.Columns.Contains("formOfPaymentId"))
            {
                txnSender.FormOfPaymentId = Convert.ToString(drDb["formOfPaymentId"]);
            }
            txnSender.SZipCode = Convert.ToString(drDb["szipCode"]);
            txnSender.SNativeCountry = Convert.ToString(drDb["snativeCountry"]);
            txnSender.SIdType = Convert.ToString(drDb["sidType"]);
            txnSender.SIdNo = Convert.ToString(drDb["sidNumber"]);
            txnSender.SMobile = Convert.ToString(drDb["smobile"]);
            txnSender.SAddress = Convert.ToString(drDb["saddress"]);
            txnSender.SIpAddress = Convert.ToString(drDb["ipAddress"]);
            txnSender.SCountryId = Convert.ToInt32(drDb["countryId"]);
            txnSender.SCountryName = Convert.ToString(drDb["sCountry"]);
            if (drDb.Table.Columns.Contains("IsIndividual"))
            {
                txnSender.IsIndividual = Convert.ToBoolean(drDb["IsIndividual"]);
            }
            txnSender.SourceOfFund = Convert.ToString(drDb["sourceOfFund"]);

            sendTxnRequest.Sender = txnSender;

            #endregion senderInformation

            #region receiverInformation

            TxnReceiver txnReceiver = new TxnReceiver();
            txnReceiver.ReceiverId = Convert.ToString(drDb["receiverId"]);
            txnReceiver.RFullName = Convert.ToString(drDb["rfullName"]);
            txnReceiver.RFirstName = Convert.ToString(drDb["rfirstName"]);
            txnReceiver.RMiddleName = Convert.ToString(drDb["rmiddleName"]);
            txnReceiver.RLastName = Convert.ToString(drDb["rlastName1"]);
            txnReceiver.RIdType = Convert.ToString(drDb["ridType"]);
            txnReceiver.RIdNo = Convert.ToString(drDb["ridNumber"]);
            txnReceiver.RIdValidDate = Convert.ToString(drDb["rvalidDate"]);
            txnReceiver.RDob = Convert.ToString(drDb["rdob"]);
            txnReceiver.RTel = Convert.ToString(drDb["rhomePhone"]);
            txnReceiver.RMobile = Convert.ToString(drDb["rmobile"]);
            txnReceiver.RNativeCountry = Convert.ToString(drDb["rnativeCountry"]);
            txnReceiver.RCity = Convert.ToString(drDb["rcity"]);
            txnReceiver.RAdd1 = Convert.ToString(drDb["raddress"]);
            txnReceiver.REmail = string.IsNullOrEmpty(drDb["remail"].ToString()) ? null : Convert.ToString(drDb["remail"]);
            txnReceiver.RAccountNo = Convert.ToString(drDb["raccountNo"]);
            txnReceiver.RCountry = Convert.ToString(drDb["rcountry"]);
            txnReceiver.RCityCode = Convert.ToString(drDb["rcityCode"]);
            txnReceiver.RelWithSenderName = Convert.ToString(drDb["relationName"]);
            txnReceiver.RStateId = Convert.ToString(drDb["rstate"]);
            txnReceiver.RLocation = Convert.ToString(drDb["pBankLocation"]);
            txnReceiver.UnitaryBankAccountNo = Convert.ToString(drDb["bankAccountNo"]);
            if (drDb.Table.Columns.Contains("rTownCode"))
            {
                txnReceiver.RLocation = Convert.ToString(drDb["rTownCode"]);
            }
            if (drDb.Table.Columns.Contains("payerId"))
            {
                txnReceiver.RLocationName = Convert.ToString(drDb["payerId"]);
            }

            sendTxnRequest.Receiver = txnReceiver;

            #endregion receiverInformation

            #region txnTransaction

            TxnTransaction transaction = new TxnTransaction();

            transaction.PCurr = Convert.ToString(drDb["payoutCurr"]);
            transaction.CollCurr = Convert.ToString(drDb["collCurr"]);
            transaction.CAmt = Convert.ToDecimal(drDb["cAmt"]);
            transaction.PAmt = Convert.ToDecimal(drDb["pAmt"]);
            transaction.TAmt = Convert.ToDecimal(drDb["tAmt"]);
            transaction.ServiceCharge = Convert.ToDecimal(drDb["serviceCharge"]);
            transaction.PComm = Convert.ToString(drDb["pAgentComm"]);
            transaction.PaymentType = Convert.ToString(drDb["paymentMethod"]);
            transaction.JMEControlNo = Convert.ToString(drDb["controlNo"]);
            transaction.PurposeOfRemittanceName = Convert.ToString(drDb["purposeOfRemit"]);
            if (drDb.Table.Columns.Contains("FOREX_SESSION_ID"))
            {
                transaction.FOREX_SESSION_ID = Convert.ToString(drDb["FOREX_SESSION_ID"]);
            }
            if (drDb.Table.Columns.Contains("txnDate"))
            {
                transaction.TxnDate = Convert.ToString(drDb["txnDate"]);
            }
            if (drDb.Table.Columns.Contains("ssnno"))
            {
                transaction.TpRefNo = Convert.ToString(drDb["ssnno"]);
            }
            if (drDb.Table.Columns.Contains("exRate"))
            {
                transaction.ExRate = Convert.ToDecimal(drDb["exRate"]);
            }
            if (drDb.Table.Columns.Contains("Rate"))
            {
                transaction.Rate = Convert.ToDecimal(drDb["Rate"]);
            }
            transaction.PayoutMsg = Convert.ToString(drDb["remarks"]);

            sendTxnRequest.Transaction = transaction;

            #endregion txnTransaction

            #region agentInformation

            TxnAgent txnAgent = new TxnAgent();
            txnAgent.PBranchId = Convert.ToString(drDb["branchId"]);
            txnAgent.PBranchName = Convert.ToString(drDb["branchName"]);
            txnAgent.PBranchCity = Convert.ToString(drDb["city"]);
            txnAgent.PAgentId = Convert.ToInt32(drDb["pAgent"]);
            txnAgent.PAgentName = Convert.ToString(drDb["pAgentName"]);
            txnAgent.PBankType = Convert.ToString(drDb["pBankType"]);
            txnAgent.PBankId = Convert.ToString(drDb["pBank"]);
            txnAgent.PBankName = Convert.ToString(drDb["pBankName"]);
            txnAgent.SAgentId = Convert.ToInt32(drDb["sAgent"]);
            txnAgent.SAgentName = Convert.ToString(drDb["sAgentName"]);
            txnAgent.SSuperAgentId = Convert.ToInt32(drDb["sSuperAgent"]);
            if (drDb.Table.Columns.Contains("pBankBranchId"))
            {
                txnAgent.PBankBranchId = Convert.ToString(drDb["pBankBranchId"]);
            }
            txnAgent.SBranchId = Convert.ToInt32(drDb["sBranch"]);
            if (drDb.Table.Columns.Contains("pBankBranchName"))
            {
                txnAgent.PBankBranchName = Convert.ToString(drDb["pBankBranchName"]);
            }

            sendTxnRequest.Agent = txnAgent;

            #endregion agentInformation

            if (drDb.Table.Columns.Contains("isFirstTran"))
            {
                sendTxnRequest.isTxnAlreadyCreated = Convert.ToString(drDb["isFirstTran"]) == "Y" ? true : false;
            }
            else
            {
                sendTxnRequest.isTxnAlreadyCreated = true;
            }

            sendTxnRequest.IsRealtime = Convert.ToBoolean(drDb["IsRealtime"]);
            sendTxnRequest.SessionId = Convert.ToString(Guid.NewGuid()).Replace("-", "");
            if (string.IsNullOrEmpty(sendTxnRequest.SessionId) || string.IsNullOrWhiteSpace(sendTxnRequest.SessionId))
                sendTxnRequest.SessionId = sessionId;

            SendTransactionServices _tpSend = new SendTransactionServices();
            var result = _tpSend.SendTransaction(sendTxnRequest);
            sql = "";
            sql = "EXEC proc_tran_api_call_history ";
            sql += "  @TRAN_ID				=" + FilterString(sendTxnRequest.TranId.ToString());
            sql += ", @REQUESTED_BY			=" + FilterString(user);
            sql += ", @RESPONSE_CODE		=" + FilterString(result.ResponseCode);
            sql += ", @RESPONSE_MSG			=" + FilterString(result.Msg);
            GetSingleResult(sql);
            return result;
        }

        public JsonResponse GetHoldedTxnForApprovedByAdminCompliance(string user, string id, string sessionId, string callFro = null)
        {
            var sql = "EXEC proc_GetHoldedTxnForApprovedByAdminCompliance";
            sql += " @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(id);
            sql += ", @callFro = " + FilterString(callFro);

            var drDb = ExecuteDataRow(sql);
            if (drDb.Table.Columns.Contains("ErrorCode"))
            {
                return new JsonResponse()
                {
                    ResponseCode = Convert.ToString(drDb["ErrorCode"]),
                    Msg = Convert.ToString(drDb["msg"])
                };
            }
            SendTransactionRequest sendTxnRequest = new SendTransactionRequest();
            sendTxnRequest.UserName = user;
            sendTxnRequest.ProviderId = Convert.ToString(drDb["partnerId"]);
            sendTxnRequest.TranId = Convert.ToInt32(drDb["tranId"]);
            if (drDb.Table.Columns.Contains("IsRealtime"))
            {
                sendTxnRequest.IsRealtime = (drDb["IsRealtime"].ToString() == "Y" ? true : false);
            }
            else
            {
                sendTxnRequest.IsRealtime = false;
            }

            #region senderInformation

            TxnSender txnSender = new TxnSender();
            txnSender.CustomerId = Convert.ToInt32(drDb["customerId"]);
            txnSender.SFirstName = Convert.ToString(drDb["sfirstName"]);
            txnSender.SMiddleName = Convert.ToString(drDb["smiddleName"]);
            txnSender.SLastName1 = Convert.ToString(drDb["slastName1"]);
            txnSender.SLastName2 = Convert.ToString(drDb["slastName2"]);
            txnSender.SFullName = Convert.ToString(drDb["sfullName"]);
            txnSender.SIdIssueDate = Convert.ToString(drDb["sissuedDate"]);
            txnSender.SIdExpiryDate = Convert.ToString(drDb["svalidDate"]);
            txnSender.SOccuptionId = Convert.ToInt32(drDb["occupationId"]);
            txnSender.SOccuptionName = Convert.ToString(drDb["occupationName"]);
            txnSender.SBirthDate = Convert.ToString(drDb["sdob"]);
            txnSender.SEmail = string.IsNullOrEmpty(drDb["semail"].ToString()) ? null : Convert.ToString(drDb["semail"]);
            txnSender.SCityId = Convert.ToString(drDb["scity"]);
            if (drDb.Table.Columns.Contains("sstate"))
            {
                txnSender.SState = Convert.ToString(drDb["sstate"]);
            }
            if (drDb.Table.Columns.Contains("formOfPaymentId"))
            {
                txnSender.FormOfPaymentId = Convert.ToString(drDb["formOfPaymentId"]);
            }
            txnSender.SZipCode = Convert.ToString(drDb["szipCode"]);
            txnSender.SNativeCountry = Convert.ToString(drDb["snativeCountry"]);
            txnSender.SIdType = Convert.ToString(drDb["sidType"]);
            txnSender.SIdNo = Convert.ToString(drDb["sidNumber"]);
            txnSender.SMobile = Convert.ToString(drDb["smobile"]);
            txnSender.SAddress = Convert.ToString(drDb["saddress"]);
            txnSender.SIpAddress = Convert.ToString(drDb["ipAddress"]);
            txnSender.SCountryId = Convert.ToInt32(drDb["countryId"]);
            txnSender.SCountryName = Convert.ToString(drDb["sCountry"]);
            if (drDb.Table.Columns.Contains("IsIndividual"))
            {
                txnSender.IsIndividual = Convert.ToBoolean(drDb["IsIndividual"]);
            }
            txnSender.SourceOfFund = Convert.ToString(drDb["sourceOfFund"]);

            sendTxnRequest.Sender = txnSender;

            #endregion senderInformation

            #region receiverInformation

            TxnReceiver txnReceiver = new TxnReceiver();
            txnReceiver.ReceiverId = Convert.ToString(drDb["receiverId"]);
            txnReceiver.RFullName = Convert.ToString(drDb["rfullName"]);
            txnReceiver.RFirstName = Convert.ToString(drDb["rfirstName"]);
            txnReceiver.RMiddleName = Convert.ToString(drDb["rmiddleName"]);
            txnReceiver.RLastName = Convert.ToString(drDb["rlastName1"]);
            txnReceiver.RIdType = Convert.ToString(drDb["ridType"]);
            txnReceiver.RIdNo = Convert.ToString(drDb["ridNumber"]);
            txnReceiver.RIdValidDate = Convert.ToString(drDb["rvalidDate"]);
            txnReceiver.RDob = Convert.ToString(drDb["rdob"]);
            txnReceiver.RTel = Convert.ToString(drDb["rhomePhone"]);
            txnReceiver.RMobile = Convert.ToString(drDb["rmobile"]);
            txnReceiver.RNativeCountry = Convert.ToString(drDb["rnativeCountry"]);
            txnReceiver.RCity = Convert.ToString(drDb["rcity"]);
            txnReceiver.RAdd1 = Convert.ToString(drDb["raddress"]);
            txnReceiver.REmail = Convert.ToString(drDb["remail"]);
            txnReceiver.RAccountNo = Convert.ToString(drDb["raccountNo"]);
            txnReceiver.RCountry = Convert.ToString(drDb["rcountry"]);
            txnReceiver.RCityCode = Convert.ToString(drDb["rcityCode"]);
            txnReceiver.RelWithSenderName = Convert.ToString(drDb["relationName"]);
            txnReceiver.RStateId = Convert.ToString(drDb["rstate"]);
            txnReceiver.RLocation = Convert.ToString(drDb["pBankLocation"]);
            txnReceiver.UnitaryBankAccountNo = Convert.ToString(drDb["bankAccountNo"]);
            if (drDb.Table.Columns.Contains("rTownCode"))
            {
                txnReceiver.RLocation = Convert.ToString(drDb["rTownCode"]);
            }
            if (drDb.Table.Columns.Contains("payerId"))
            {
                txnReceiver.RLocationName = Convert.ToString(drDb["payerId"]);
            }

            sendTxnRequest.Receiver = txnReceiver;

            #endregion receiverInformation

            #region txnTransaction

            TxnTransaction transaction = new TxnTransaction();

            transaction.PCurr = Convert.ToString(drDb["payoutCurr"]);
            transaction.CollCurr = Convert.ToString(drDb["collCurr"]);
            transaction.CAmt = Convert.ToDecimal(drDb["cAmt"]);
            transaction.PAmt = Convert.ToDecimal(drDb["pAmt"]);
            transaction.TAmt = Convert.ToDecimal(drDb["tAmt"]);
            transaction.ServiceCharge = Convert.ToDecimal(drDb["serviceCharge"]);
            transaction.PComm = Convert.ToString(drDb["pAgentComm"]);
            transaction.PaymentType = Convert.ToString(drDb["paymentMethod"]);
            transaction.JMEControlNo = Convert.ToString(drDb["controlNo"]);
            transaction.PurposeOfRemittanceName = Convert.ToString(drDb["purposeOfRemit"]);

            if (drDb.Table.Columns.Contains("FOREX_SESSION_ID"))
            {
                transaction.FOREX_SESSION_ID = Convert.ToString(drDb["FOREX_SESSION_ID"]);
            }
            if (drDb.Table.Columns.Contains("txnDate"))
            {
                transaction.TxnDate = Convert.ToString(drDb["txnDate"]);
            }
            if (drDb.Table.Columns.Contains("ssnno"))
            {
                transaction.TpRefNo = Convert.ToString(drDb["ssnno"]);
            }
            if (drDb.Table.Columns.Contains("exRate"))
            {
                transaction.ExRate = Convert.ToDecimal(drDb["exRate"]);
            }
            if (drDb.Table.Columns.Contains("Rate"))
            {
                transaction.Rate = Convert.ToDecimal(drDb["Rate"]);
            }
            transaction.PayoutMsg = Convert.ToString(drDb["remarks"]);

            sendTxnRequest.Transaction = transaction;

            #endregion txnTransaction

            #region agentInformation

            TxnAgent txnAgent = new TxnAgent();
            txnAgent.PBranchId = Convert.ToString(drDb["branchId"]);
            txnAgent.PBranchName = Convert.ToString(drDb["branchName"]);
            txnAgent.PBranchCity = Convert.ToString(drDb["city"]);
            txnAgent.PAgentId = Convert.ToInt32(drDb["pAgent"]);
            txnAgent.PAgentName = Convert.ToString(drDb["pAgentName"]);
            txnAgent.PBankType = Convert.ToString(drDb["pBankType"]);
            txnAgent.PBankId = Convert.ToString(drDb["pBank"]);
            txnAgent.PBankName = Convert.ToString(drDb["pBankName"]);
            txnAgent.SAgentId = Convert.ToInt32(drDb["sAgent"]);
            txnAgent.SAgentName = Convert.ToString(drDb["sAgentName"]);
            txnAgent.SSuperAgentId = Convert.ToInt32(drDb["sSuperAgent"]);
            if (drDb.Table.Columns.Contains("pBankBranchId"))
            {
                txnAgent.PBankBranchId = Convert.ToString(drDb["pBankBranchId"]);
            }
            txnAgent.SBranchId = Convert.ToInt32(drDb["sBranch"]);
            if (drDb.Table.Columns.Contains("pBankBranchName"))
            {
                txnAgent.PBankBranchName = Convert.ToString(drDb["pBankBranchName"]);
            }

            sendTxnRequest.Agent = txnAgent;

            #endregion agentInformation

            if (drDb.Table.Columns.Contains("isFirstTran"))
            {
                sendTxnRequest.isTxnAlreadyCreated = Convert.ToString(drDb["isFirstTran"]) == "Y" ? true : false;
            }
            else
            {
                sendTxnRequest.isTxnAlreadyCreated = true;
            }

            sendTxnRequest.IsRealtime = Convert.ToBoolean(drDb["IsRealtime"]);
            sendTxnRequest.SessionId = Convert.ToString(Guid.NewGuid()).Replace("-", "");
            if (string.IsNullOrEmpty(sendTxnRequest.SessionId) || string.IsNullOrWhiteSpace(sendTxnRequest.SessionId))
                sendTxnRequest.SessionId = sessionId;

            SendTransactionServices _tpSend = new SendTransactionServices();
            var result = _tpSend.SendTransaction(sendTxnRequest);
            sql = "";
            sql = "EXEC proc_tran_api_call_history ";
            sql += "  @TRAN_ID				=" + FilterString(sendTxnRequest.TranId.ToString());
            sql += ", @REQUESTED_BY			=" + FilterString(user);
            sql += ", @RESPONSE_CODE		=" + FilterString(result.ResponseCode);
            sql += ", @RESPONSE_MSG			=" + FilterString(result.Msg);
            GetSingleResult(sql);
            return result;
        }

        public DbResult ApproveAllHoldedTXN(string user, string idList)
        {
            var sb = new StringBuilder("<root>");
            var list = idList.Split(',');
            foreach (var itm in list)
            {
                sb.Append("<row id=\"" + itm.Trim() + "\" />");
            }
            sb.Append("</root>");

            var sql = "EXEC proc_ApproveHoldedTXN @flag = 'approve-all'";
            sql += ", @user = " + FilterString(user);
            sql += ", @idList = " + FilterString(sb.ToString());
            return ParseDbResult(sql);
        }

        public DataSet GetHoldTransactionSummary(string user, string branchId, string userType)
        {
            string sql = "EXEC proc_ApproveHoldedTXN ";
            sql += "  @flag = 's_txn_summary'";
            sql += ", @user = " + FilterString(user);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @userType = " + FilterString(userType);
            return ExecuteDataset(sql);
        }

        public DataSet GetHoldAdminTransactionSummary(string user, string branchId, string userType)
        {
            string sql = "EXEC proc_ApproveHoldedTXN ";
            sql += "  @flag = 's_admin_txn_summary'";
            sql += ", @user = " + FilterString(user);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @userType = " + FilterString(userType);
            return ExecuteDataset(sql);
        }

        public DataSet GetHoldAdminTransactionSummaryOnline(string user, string branchId, string userType)
        {
            string sql = "EXEC proc_ApproveHoldedTXN ";
            sql += "  @flag = 'OnlineTxn-waitingList'";
            sql += ", @user = " + FilterString(user);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @userType = " + FilterString(userType);
            return ExecuteDataset(sql);
        }

        public DbResult ReprocessBySchedular(string count, string agentCode, string user, string pass)
        {
            var dr = new DbResult();

            var sql = "EXEC proc_transactionUtility @flag = 'rpid'";
            sql += ", @count = " + FilterString(count);
            sql += ", @agentCode = " + FilterString(agentCode);
            sql += ", @user = " + FilterString(user);
            sql += ", @pass = " + FilterString(pass);

            var dt = ExecuteDataTable(sql);
            var cnt = 0;
            foreach (DataRow row in dt.Rows)
            {
                try
                {
                    Reprocess(user, row["Id"].ToString(), row["processId"].ToString());
                    cnt++;
                }
                catch
                {
                }
            }
            dr.SetError("0", cnt + " Transactions Processed Successfully.", "");
            return dr;
        }

        public DbResult Reprocess(string user, string id, string processId = "")
        {
            return new DbResult();// GlobalBankDao().Reprocess(user, id, processId);
        }

        #region approve transaction domestic

        public DataSet GetHoldTxnSummaryDomestic(string user)
        {
            string sql = "EXEC proc_approveHoldTranDomestic ";
            sql += "  @flag = 'summary'";
            sql += ", @user = " + FilterString(user);
            return ExecuteDataset(sql);
        }

        public DataSet GetHoldTxnDetailDomestic(string user, string sAgent, string sender, string receiver
        , string controlNo, string amt, string txnDate, string txnUser)
        {
            string sql = "EXEC proc_approveHoldTranDomestic @flag = 'detail'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @sender = " + FilterString(sender);
            sql += ", @receiver = " + FilterString(receiver);
            sql += ", @amt = " + FilterString(amt);
            sql += ", @txnDate = " + FilterString(txnDate);
            sql += ", @txnUser = " + FilterString(txnUser);
            return ExecuteDataset(sql);
        }

        public DbResult ApproveSingleDom(string user, string tranId)
        {
            var sql = "EXEC proc_approveHoldTranDomestic @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            var drDb = ParseDbResult(sql);
            return drDb;
        }

        #endregion approve transaction domestic

        public DataTable GetMailDetails(string user)
        {
            var sql = "EXEC proc_getEmailSendDetails @flag = 'get'";
            sql += ", @user = " + FilterString(user);

            return ExecuteDataTable(sql);
        }

        public DataTable ErrorEmail(string user, string rowId)
        {
            var sql = "EXEC proc_getEmailSendDetails @flag = 'error'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            return ExecuteDataTable(sql);
        }
    }
}