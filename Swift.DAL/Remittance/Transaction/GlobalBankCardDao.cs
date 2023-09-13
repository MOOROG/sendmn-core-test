using System.Data;
using Swift.DAL.Domain;
using Swift.DAL.SwiftDAL;
using System.Text;
using System;

namespace Swift.DAL.BL.Remit.Transaction.ThirdParty.GlobalBankCard
{
    public class GlobalBankCardDao : RemittanceDao
    {
        //public DbResult CreateTransaction(string user, string id, string isKycApprove, bool pushAnyway)
        //{
        //    var row = GetTxnDetail(user, id, false);
        //    var dr = new DbResult();
        //    if (row == null) 
        //    {
        //        dr.SetError("1", "Transaction not found", null);
        //        return dr;
        //    }
        //    if (isKycApprove == "N")
        //    {
        //        return SendUnpaidUpdate(user, id, isKycApprove);
        //    }
        //    dr = PushToApi(id,user, ref row, false);
        //    if (dr.ErrorCode != "0")
        //    {
        //        var sql = " EXEC proc_ws_globalBankCard";
        //        sql += "  @flag = 'sendError'";
        //        sql += ", @user= " + FilterString(user);
        //        sql += ", @id= " + FilterString(id);
        //        sql += ", @payResponseCode = " + FilterString(dr.Extra);
        //        sql += ", @payResponseMsg = " + FilterString(dr.Msg);
        //        ParseDbResult(sql);
        //        return dr;
        //    }
        //    return SendUpdate(user, id, "Y");
        //}
        
        public DbResult SyncStatus(string user, string controlNo, string syncDate, string status)
        {
            var sql = "EXEC proc_ws_globalBankCard @flag = 'ss' ";
            sql += " , @user =" + FilterString(user);
            sql += " , @controlNo =" + FilterString(controlNo);
            sql += " , @syncDate =" + FilterString(syncDate);
            sql += " , @status =" + FilterString(status);

            return ParseDbResult(sql);
        }

        //public ReportResult GetReconcileReport(string user, string date)
        //{
        //    var dtBody = new DataTable();
        //    var dr = new GlobalBankCardAPI().GetTransactions(user, date, out dtBody);

        //    var dtResult = new DataTable();
        //    dtResult.Columns.Add("ErrorCode");
        //    dtResult.Columns.Add("Msg");
        //    dtResult.Columns.Add("Id");
        //    var row = dtResult.NewRow();
        //    row[0] = dr.ErrorCode;
        //    row[1] = dr.Msg;
        //    row[2] = dr.Id;
        //    dtResult.Rows.Add(row);

        //    var dtFilter = new DataTable();
        //    dtFilter.Columns.Add("Head");
        //    dtFilter.Columns.Add("Value");
        //    row = dtFilter.NewRow();
        //    row[0] = "Date";
        //    row[1] = date;
        //    dtFilter.Rows.Add(row);

        //    var dtTitle = new DataTable();
        //    dtTitle.Columns.Add("Title");
        //    row = dtTitle.NewRow();
        //    row[0] = "Reconcile Report - IME Remit Card";
        //    dtTitle.Rows.Add(row);

        //    var ds = new DataSet();
        //    ds.Tables.Add(dtBody);
        //    ds.Tables.Add(dtResult);
        //    ds.Tables.Add(dtFilter);
        //    ds.Tables.Add(dtTitle);
        //    return ParseReportResult(ds);
        //}
        
        public DataTable GetPinDetailByDate(string user, string date)
        {
            var sql = "EXEC proc_ws_globalBankCard @flag = 's' ";
            sql += " , @syncDate =" + FilterString(date);
            sql += " , @user =" + FilterString(user);

            return ExecuteDataTable(sql);
        }
        
        public DataTable GetCardHolderInfo(string user, string remitCardNo)
        {
            var sql = "EXEC proc_ws_globalBankCard";
            sql += "  @flag = 'selectByRemitCardNo'";
            sql += ", @user = " + FilterString(user);
            sql += ", @remitCardNo = " + FilterString(remitCardNo);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable GetServiceCharge(string user, string sBranch, string settlingAgent, string tAmt)
        {
            var sql = "EXEC proc_ws_globalBankCard @flag = 'sc'";
            sql += ", @tAmt = " + FilterString(tAmt);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @settlingAgent = " + FilterString(settlingAgent);
            sql += ", @user = " + FilterString(user);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        //public DbResult SendGlobalCardTxn(string user, GblBankCardTran tran, string fromSendTrnTime, string toSendTrnTime)
        //{
        //    var sql = "EXEC proc_ws_globalBankCard @flag = 'i'";
        //    sql += ", @user = " + FilterString(user);
        //    sql += ", @sBranch = " + FilterString(tran.SBranch);
        //    sql += ", @agentUniqueRefId = " + FilterString(tran.AgentRefId);
        //    sql += ", @sBranchName = " + FilterString(tran.SBranchName);
        //    sql += ", @sAgent = " + FilterString(tran.SAgent);
        //    sql += ", @sAgentName = " + FilterString(tran.SAgentName);
        //    sql += ", @sSuperAgent = " + FilterString(tran.SSuperAgent);
        //    sql += ", @sSuperAgentName = " + FilterString(tran.SSuperAgentName);
        //    sql += ", @settlingAgent = " + FilterString(tran.SettlingAgent);
        //    sql += ", @mapCode = " + FilterString(tran.MapCodeInt);
        //    sql += ", @mapCodeDom = " + FilterString(tran.MapCodeDom);

        //    sql += ", @remitCardNo = " + FilterString(tran.RemitCardNo);
        //    sql += ", @benefName = " + FilterString(tran.BenefName);
        //    sql += ", @benefAddress = " + FilterString(tran.BenefAddress);
        //    sql += ", @benefMobile = " + FilterString(tran.BenefMobile);
        //    sql += ", @benefIdType = " + FilterString(tran.BenefIdType);
        //    sql += ", @benefIdNo = " + FilterString(tran.BenefIdNo);

        //    sql += ", @senderName = " + FilterString(tran.SenderName);
        //    sql += ", @senderAddress = " + FilterString(tran.SenderAddress);
        //    sql += ", @senderMobile = " + FilterString(tran.SenderMobile);
        //    sql += ", @senderIdType = " + FilterString(tran.SenderIdType);
        //    sql += ", @senderIdNo = " + FilterString(tran.SenderIdNo);
        //    sql += ", @senderRemitCardNo = " + FilterString(tran.SenderRemitCardNo);

        //    sql += ", @tAmt = " + FilterString(tran.TransferAmount);
        //    sql += ", @serviceCharge = " + FilterString(tran.ServiceCharge);
        //    sql += ", @cAmt = " + FilterString(tran.CollectionAmount);
        //    sql += ", @pAmt = " + FilterString(tran.TransferAmount);

        //    sql += ", @purposeOfRemit = " + FilterString(tran.PurposeOfRemittance);
        //    sql += ", @sourceOfFund = " + FilterString(tran.SourceOfFund);
        //    sql += ", @remarks = " + FilterString(tran.Remarks);

        //    sql += ", @fromSendTrnTime = " + FilterString(fromSendTrnTime);
        //    sql += ", @toSendTrnTime = " + FilterString(toSendTrnTime);
        //    sql += ", @txtPass = " + FilterString(tran.TxtPass);
        //    sql += ", @sDcInfo = " + FilterString(tran.DcInfo);
        //    sql += ", @sIpAddress = " + FilterString(tran.IpAddress);

        //    return ParseDbResult(sql);
        //}

        public DataSet GetSendReceipt(string controlNo, string user)
        {
            string sql = "EXEC proc_ws_globalBankCard @flag = 'receipt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            return ExecuteDataset(sql);
        }

        //private DbResult PushToApi(string rowId, string user, ref DataRow row, bool pushAnyway)
        //{
        //    var dr = new DbResult();
        //    dr.SetError("0", "Success", "");

        //    if (row == null)
        //    {
        //        dr.SetError("1", "Transaction not found", null);
        //        return dr;
        //    }
        //    var requestXml = "rowId=" + rowId;
        //    var id = ApiUtility.LogRequest(user, "IME Remit Card Number", "send txn", rowId, requestXml).Id;
        //    try
        //    {
        //        if (row["HitApi"].ToString().Equals("1") || pushAnyway)
        //        {
        //            var sendTxn = new GlobalTxn
        //            {
        //                ControlNo = row["controlNo"].ToString(),
        //                BenefName = row["benefName"].ToString(),
        //                BenefAddress = row["benefAddress"].ToString(),
        //                BenefMobile = row["benefMobile"].ToString(),
        //                BenefIdType = row["benefIdType"].ToString(),
        //                BenefIdNo = row["benefIdNo"].ToString(),
        //                BenefAccNo = row["benefAccNo"].ToString(),

        //                SenderName = row["senderName"].ToString(),
        //                SenderAddress = row["senderAddress"].ToString(),
        //                SenderMobile = row["senderMobile"].ToString(),
        //                SenderIdType = row["senderIdType"].ToString(),
        //                SenderIdNo = row["senderIdNo"].ToString(),

        //                Purpose = row["purpose"].ToString(),
        //                RemitType = row["remitType"].ToString(),
        //                PayingBankBranchCd = row["PayingBankBranchCd"].ToString(),
        //                RCurrency = row["rCurrency"].ToString(),
        //                LocalAmount = row["localAmount"].ToString(),
        //                Amount = row["amount"].ToString(),
        //                ServiceCharge = row["serviceCharge"].ToString(),
        //                PCommission = row["pCommission"].ToString(),
        //                DollarRate = row["dollarRate"].ToString(),
        //                RefNo = row["refNo"].ToString(),
        //                Remarks = row["remarks"].ToString(),
        //                Source = row["source"].ToString(),
        //                TxnType = row["txnType"].ToString()
        //            };

        //            var drApi = new GlobalBankCardAPI().CreateTransaction(user, sendTxn);
        //            dr.SetError(drApi.ErrorCode, drApi.Msg, drApi.Id);
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        ApiUtility.LogResponse(id, ex.Message, "999", "Internal Error");
        //        dr.SetError("1", ex.Message, "");
        //    }
        //    return dr;
        //}

        private DataRow GetTxnDetail(string user, string id, bool reprocessMode)
        {
            var sql = "EXEC proc_ws_globalBankCard ";
            if (reprocessMode)
                sql += " @flag='txnDetail-rp'";
            else
                sql += " @flag='txnDetail'";

            sql += ",@user=" + FilterString(user);
            sql += ",@id=" + FilterString(id);

            return ExecuteDataRow(sql);
        }

        private DbResult SendUpdate(string user, string rowId, string isKycApprove)
        {
            var sql = "EXEC proc_ws_globalBankCard ";
            sql += "  @flag='send'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(rowId);
            sql += ", @isKycApprove = " + FilterString(isKycApprove);
            return ParseDbResult(sql);
        }

        private DbResult SendUnpaidUpdate(string user, string rowId, string isKycApprove)
        {
            var sql = "EXEC proc_ws_globalBankCard ";
            sql += "  @flag='send-unpaid'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(rowId);
            sql += ", @isKycApprove = " + FilterString(isKycApprove);
            return ParseDbResult(sql);
        }

        #region Send Transaction -HO
        public DataTable GetServiceChargeAdmin(string user, string sBranch, string tAmt)
        {
            var sql = "EXEC proc_ws_globalBankCardHo @flag = 'sc'";
            sql += ", @tAmt = " + FilterString(tAmt);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @user = " + FilterString(user);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        //public DbResult CreateTransactionHo(string user, string id, string isKycApprove)
        //{
        //    var row = GetTxnDetailHo(user, id);
        //    var dr = new DbResult();
        //    if (row == null)
        //    {
        //        dr.SetError("1", "Transaction not found", null);
        //        return dr;
        //    }
        //    if (isKycApprove == "N")
        //    {
        //        return SendUnpaidUpdateHo(user, id, isKycApprove);
        //    }
        //    dr = PushToApi(id, user, ref row, false);
        //    if (dr.ErrorCode != "0")
        //    {
        //        var sql = " EXEC proc_ws_globalBankCardHo";
        //        sql += "  @flag = 'sendError'";
        //        sql += ", @user= " + FilterString(user);
        //        sql += ", @id= " + FilterString(id);
        //        sql += ", @payResponseCode = " + FilterString(dr.Extra);
        //        sql += ", @payResponseMsg = " + FilterString(dr.Msg);
        //        ParseDbResult(sql);
        //        return dr;
        //    }
        //    return SendUpdateHo(user, id, "Y");
        //}
        
        private DataRow GetTxnDetailHo(string user, string id)
        {
            var sql = "EXEC proc_ws_globalBankCardHo ";
            sql += " @flag='txnDetail'";
            sql += ",@user=" + FilterString(user);
            sql += ",@id=" + FilterString(id);
            return ExecuteDataRow(sql);
        }

        //public DbResult SendGlobalCardTxnHo(string user, GblBankCardTran tran)
        //{
        //    var sql = "EXEC proc_ws_globalBankCardHo @flag = 'i'";
        //    sql += ", @user = " + FilterString(user);
        //    sql += ", @sBranch = " + FilterString(tran.SBranch);
        //    sql += ", @agentUniqueRefId = " + FilterString(tran.AgentRefId);
        //    sql += ", @sBranchName = " + FilterString(tran.SBranchName);
           
        //    sql += ", @remitCardNo = " + FilterString(tran.RemitCardNo);
        //    sql += ", @benefName = " + FilterString(tran.BenefName);
        //    sql += ", @benefAddress = " + FilterString(tran.BenefAddress);
        //    sql += ", @benefMobile = " + FilterString(tran.BenefMobile);
        //    sql += ", @benefIdType = " + FilterString(tran.BenefIdType);
        //    sql += ", @benefIdNo = " + FilterString(tran.BenefIdNo);

        //    sql += ", @senderName = " + FilterString(tran.SenderName);
        //    sql += ", @senderAddress = " + FilterString(tran.SenderAddress);
        //    sql += ", @senderMobile = " + FilterString(tran.SenderMobile);
        //    sql += ", @senderIdType = " + FilterString(tran.SenderIdType);
        //    sql += ", @senderIdNo = " + FilterString(tran.SenderIdNo);
        //    sql += ", @senderRemitCardNo = " + FilterString(tran.SenderRemitCardNo);

        //    sql += ", @tAmt = " + FilterString(tran.TransferAmount);
        //    sql += ", @serviceCharge = " + FilterString(tran.ServiceCharge);
        //    sql += ", @cAmt = " + FilterString(tran.CollectionAmount);
        //    sql += ", @pAmt = " + FilterString(tran.TransferAmount);

        //    sql += ", @purposeOfRemit = " + FilterString(tran.PurposeOfRemittance);
        //    sql += ", @sourceOfFund = " + FilterString(tran.SourceOfFund);
        //    sql += ", @remarks = " + FilterString(tran.Remarks);

        //    sql += ", @txtPass = " + FilterString(tran.TxtPass);
        //    sql += ", @sDcInfo = " + FilterString(tran.DcInfo);
        //    sql += ", @sIpAddress = " + FilterString(tran.IpAddress);

        //    return ParseDbResult(sql);
        //}

        private DbResult SendUnpaidUpdateHo(string user, string rowId, string isKycApprove)
        {
            var sql = "EXEC proc_ws_globalBankCardHo ";
            sql += "  @flag='send-unpaid'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(rowId);
            sql += ", @isKycApprove = " + FilterString(isKycApprove);
            return ParseDbResult(sql);
        }

        private DbResult SendUpdateHo(string user, string rowId, string isKycApprove)
        {
            var sql = "EXEC proc_ws_globalBankCardHo ";
            sql += "  @flag='send'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(rowId);
            sql += ", @isKycApprove = " + FilterString(isKycApprove);
            return ParseDbResult(sql);
        }

        #endregion Send Transaction -HO

        //public DbResult ReProcessToApi(string user, string tranId)
        //{
        //    var row = GetTxnInfoForReSendApi(user, tranId);
        //    var dr = new DbResult();
        //    if (row == null)
        //    {
        //        dr.SetError("1", "Transaction not found", null);
        //        return dr;
        //    }
        //    dr = PushToApi(tranId, user, ref row, false);
        //    if (dr.ErrorCode != "0")
        //    {
        //        var sql = " EXEC proc_ws_globalBankCardReSend";
        //        sql += "  @flag = 'sendError'";
        //        sql += ", @user= " + FilterString(user);
        //        sql += ", @tranId= " + FilterString(tranId);
        //        sql += ", @payResponseCode = " + FilterString(dr.Extra);
        //        sql += ", @payResponseMsg = " + FilterString(dr.Msg);
        //        ParseDbResult(sql);
        //        return dr;
        //    }
        //    return SendUpdateReSend(user, tranId);
        //}

        private DataRow GetTxnInfoForReSendApi(string user, string id)
        {
            var sql = "EXEC proc_ws_globalBankCardReSend ";
            sql += " @flag='txn-detail'";
            sql += ",@user=" + FilterString(user);
            sql += ",@tranId=" + FilterString(id);
            return ExecuteDataRow(sql);
        }

        private DbResult SendUpdateReSend(string user, string rowId)
        {
            var sql = "EXEC proc_ws_globalBankCardReSend ";
            sql += "  @flag='send'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(rowId);
            return ParseDbResult(sql);
        }

        #region Partial Cash Load
        public DataRow GetStarter(string user, string controlNo)
        {
            var sql = "EXEC proc_loadCashRemitCard @flag = 'ls'";
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        //public DbResult SaveTxnHistory(string user, GblBankCardTran tran)
        //{
        //    var sql = "EXEC proc_loadCashRemitCard @flag = 'sh'";
        //    sql += ", @user = " + FilterString(user);
        //    sql += ", @sBranch = " + FilterString(tran.SBranch);
        //    sql += ", @agentUniqueRefId = " + FilterString(tran.AgentRefId);
        //    sql += ", @sBranchName = " + FilterString(tran.SBranchName);

        //    sql += ", @remitCardNo = " + FilterString(tran.RemitCardNo);
        //    sql += ", @benefName = " + FilterString(tran.BenefName);
        //    sql += ", @benefAddress = " + FilterString(tran.BenefAddress);
        //    sql += ", @benefMobile = " + FilterString(tran.BenefMobile);
        //    sql += ", @benefIdType = " + FilterString(tran.BenefIdType);
        //    sql += ", @benefIdNo = " + FilterString(tran.BenefIdNo);

        //    sql += ", @senderName = " + FilterString(tran.SenderName);
        //    sql += ", @senderAddress = " + FilterString(tran.SenderAddress);
        //    sql += ", @senderMobile = " + FilterString(tran.SenderMobile);
        //    sql += ", @senderIdType = " + FilterString(tran.SenderIdType);
        //    sql += ", @senderIdNo = " + FilterString(tran.SenderIdNo);
        //    sql += ", @senderRemitCardNo = " + FilterString(tran.SenderRemitCardNo);

        //    sql += ", @tAmt = " + FilterString(tran.TransferAmount);
        //    sql += ", @serviceCharge = " + FilterString(tran.ServiceCharge);
        //    sql += ", @cAmt = " + FilterString(tran.CollectionAmount);
        //    sql += ", @pAmt = " + FilterString(tran.TransferAmount);

        //    sql += ", @purposeOfRemit = " + FilterString(tran.PurposeOfRemittance);
        //    sql += ", @sourceOfFund = " + FilterString(tran.SourceOfFund);
        //    sql += ", @remarks = " + FilterString(tran.Remarks);

        //    sql += ", @txtPass = " + FilterString(tran.TxtPass);
        //    sql += ", @sDcInfo = " + FilterString(tran.DcInfo);
        //    sql += ", @sIpAddress = " + FilterString(tran.IpAddress);
        //    sql += ", @refNo = " + FilterString(tran.RefNo);

        //    return ParseDbResult(sql);
        //}
        //public DbResult CreateTxn(string user, string id, string isKycApprove)
        //{
        //    var row = GetTxnHistory(user, id);
        //    var dr = new DbResult();
        //    if (row == null)
        //    {
        //        dr.SetError("1", "Transaction not found", null);
        //        return dr;
        //    }
        //    if (isKycApprove == "N")
        //    {
        //        return SendUnpaid(user, id, isKycApprove);
        //    }
        //    dr = PushToApi(id, user, ref row, false); // API calling existing function
        //    if (dr.ErrorCode != "0")
        //    {
        //        var sql = " EXEC proc_loadCashRemitCard";
        //        sql += "  @flag = 'ae'";
        //        sql += ", @user= " + FilterString(user);
        //        sql += ", @id= " + FilterString(id);
        //        sql += ", @payResponseCode = " + FilterString(dr.Extra);
        //        sql += ", @payResponseMsg = " + FilterString(dr.Msg);
        //        ParseDbResult(sql);
        //        return dr;
        //    }
        //    return SendPay(user, id, "Y");
        //}
        private DataRow GetTxnHistory(string user, string id)
        {
            var sql = "EXEC proc_loadCashRemitCard ";
            sql += " @flag='td'";
            sql += ",@user=" + FilterString(user);
            sql += ",@id=" + FilterString(id);
            return ExecuteDataRow(sql);
        }
        private DbResult SendUnpaid(string user, string rowId, string isKycApprove)
        {
            var sql = "EXEC proc_loadCashRemitCard ";
            sql += "  @flag='su'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(rowId);
            sql += ", @isKycApprove = " + FilterString(isKycApprove);
            return ParseDbResult(sql);
        }
        private DbResult SendPay(string user, string rowId, string isKycApprove)
        {
            var sql = "EXEC proc_loadCashRemitCard ";
            sql += "  @flag='sp'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(rowId);
            sql += ", @isKycApprove = " + FilterString(isKycApprove);
            return ParseDbResult(sql);
        }
        #endregion 
    }
}