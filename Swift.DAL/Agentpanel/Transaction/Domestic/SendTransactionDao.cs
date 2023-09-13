using System.Data;
using Swift.DAL.SwiftDAL;
using Swift.DAL.Domain;

namespace Swift.DAL.BL.Remit.Transaction.Domestic
{
    public class SendTransactionDao : RemittanceDao
    {
        public DataTable GetCalculate(string user, string pLocation, string pAmt, string deliveryMethod,
                string sBranch, string pBankBranch, string settlingAgent)
        {
            var sql = "EXEC proc_sendTranDomestic @flag = 'sc-v2'";
            sql += ", @pLocation = " + FilterString(pLocation);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @transferAmt = " + FilterString(pAmt);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @pBankBranch = " + FilterString(pBankBranch);
            sql += ", @settlingAgent = " + FilterString(settlingAgent);
            sql += ", @user = " + FilterString(user);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }
        public DataTable GetCalculateHo(string user, string pLocation, string pAmt, string deliveryMethod,
                string sBranch, string pBankBranch)
        {
            var sql = "EXEC proc_sendTranDomesticHo @flag = 'sc-v2'";
            sql += ", @pLocation = " + FilterString(pLocation);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @transferAmt = " + FilterString(pAmt);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @pBankBranch = " + FilterString(pBankBranch);
            sql += ", @user = " + FilterString(user);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }
        public DataRow SelectById(string user, string id)
        {
            var sql = "EXEC proc_sendTran";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #region Domestic Send Page API and Service Charge API method
        public DataSet VerifyTransaction(TranDetail tran)
        {
            var sql = "EXEC proc_sendTranAPI_v2 @flag = 'vt'";
            sql += ", @user = " + FilterString(tran.User);
            sql += ", @agentUniqueRefId = " + FilterString(tran.AgentRefId);
            sql += ", @sBranch = " + FilterString(tran.SBranch);
            sql += ", @sBranchName = " + FilterString(tran.SBranchName);
            sql += ", @sAgent = " + FilterString(tran.SAgent);
            sql += ", @sAgentName = " + FilterString(tran.SAgentName);
            sql += ", @sSuperAgent = " + FilterString(tran.SSuperAgent);
            sql += ", @sSuperAgentName = " + FilterString(tran.SSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(tran.SettlingAgent);
            sql += ", @mapCode = " + FilterString(tran.MapCodeInt);
            sql += ", @mapCodeDom = " + FilterString(tran.MapCodeDom);
            sql += ", @pLocation = " + FilterString(tran.PLocation);
            sql += ", @transferAmt = " + FilterString(tran.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(tran.ServiceCharge);
            sql += ", @cAmt = " + FilterString(tran.TotalCollection);
            sql += ", @pAmt = " + FilterString(tran.PayoutAmt);
            sql += ", @deliveryMethod = " + FilterString(tran.DeliveryMethod);
            sql += ", @senderId = " + FilterString(tran.SenderId);
            sql += ", @sMemId = " + FilterString(tran.SMemId);
            sql += ", @sFirstName = " + FilterString(tran.SFirstName);
            sql += ", @sMiddleName = " + FilterString(tran.SMiddleName);
            sql += ", @sLastName1 = " + FilterString(tran.SLastName1);
            sql += ", @sLastName2 = " + FilterString(tran.SLastName2);
            sql += ", @sAddress = " + FilterString(tran.SAddress);
            sql += ", @sContactNo = " + FilterString(tran.SContactNo);
            sql += ", @sIdType = " + FilterString(tran.SIDType);
            sql += ", @sIdNo = " + FilterString(tran.SIDNo);
            sql += ", @sEmail = " + FilterString(tran.SEmail);
            sql += ", @receiverId = " + FilterString(tran.ReceiverId);
            sql += ", @rMemId = " + FilterString(tran.RMemId);
            sql += ", @rFirstName = " + FilterString(tran.RFirstName);
            sql += ", @rMiddleName = " + FilterString(tran.RMiddleName);
            sql += ", @rLastName1 = " + FilterString(tran.RLastName1);
            sql += ", @rLastName2 = " + FilterString(tran.RLastName2);
            sql += ", @rAddress = " + FilterString(tran.RAddress);
            sql += ", @rContactNo = " + FilterString(tran.RContactNo);
            sql += ", @relationship = " + FilterString(tran.RelWithSender);
            sql += ", @rIdType = " + FilterString(tran.RIDType);
            sql += ", @rIdNo = " + FilterString(tran.RIDNo);
            sql += ", @remarks = " + FilterString(tran.PayoutMsg);
            sql += ", @sDOB = " + FilterString(tran.SDOB);
            sql += ", @sIdValidDate = " + FilterString(tran.SIDValidDate);
            sql += ", @Occupation = " + FilterString(tran.Occupation);
            sql += ", @purpose = " + FilterString(tran.PurposeOfRemit);
            sql += ", @sourceOfFund = " + FilterString(tran.SourceOfFund);
            sql += ", @sIdIssuedDate = " + FilterString(tran.SIDIssuedDate);
            sql += ", @sAmountThreshold = " + FilterString(tran.sAmountThreshold);
            sql += ", @sIdIssuedPlace = " + FilterString(tran.SIDIssuedPlace);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
        public DataRow DomesticApiInsert(string user, TranDetail tran, string fromSendTrnTime, string toSendTrnTime)
        {
            var sql = "EXEC proc_sendTranAPI @flag = 'di'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sBranch = " + FilterString(tran.SBranch);
            sql += ", @sBranchName = " + FilterString(tran.SBranchName);
            sql += ", @sAgent = " + FilterString(tran.SAgent);
            sql += ", @sAgentName = " + FilterString(tran.SAgentName);
            sql += ", @sSuperAgent = " + FilterString(tran.SSuperAgent);
            sql += ", @sSuperAgentName = " + FilterString(tran.SSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(tran.SettlingAgent);
            sql += ", @mapCode = " + FilterString(tran.MapCodeInt);
            sql += ", @mapCodeDom = " + FilterString(tran.MapCodeDom);
            sql += ", @agentUniqueRefId = " + FilterString(tran.AgentRefId);
            sql += ", @pBankBranch = " + FilterString(tran.PBankBranch);
            sql += ", @accountNo = " + FilterString(tran.AccountNo);
            sql += ", @pLocation = " + FilterString(tran.PLocation);
            sql += ", @transferAmt = " + FilterString(tran.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(tran.ServiceCharge);
            sql += ", @cAmt = " + FilterString(tran.TotalCollection);
            sql += ", @pAmt = " + FilterString(tran.PayoutAmt);
            sql += ", @deliveryMethod = " + FilterString(tran.DeliveryMethod);
            sql += ", @senderId = " + FilterString(tran.SenderId);
            sql += ", @sMemId = " + FilterString(tran.SMemId);
            sql += ", @sFirstName = " + FilterString(tran.SFirstName);
            sql += ", @sMiddleName = " + FilterString(tran.SMiddleName);
            sql += ", @sLastName1 = " + FilterString(tran.SLastName1);
            sql += ", @sLastName2 = " + FilterString(tran.SLastName2);
            sql += ", @sAddress = " + FilterString(tran.SAddress);
            sql += ", @sContactNo = " + FilterString(tran.SContactNo);
            sql += ", @sIdType = " + FilterString(tran.SIDType);
            sql += ", @sIdNo = " + FilterString(tran.SIDNo);
            sql += ", @sEmail = " + FilterString(tran.SEmail);
            sql += ", @receiverId = " + FilterString(tran.ReceiverId);
            sql += ", @rMemId = " + FilterString(tran.RMemId);
            sql += ", @rFirstName = " + FilterString(tran.RFirstName);
            sql += ", @rMiddleName = " + FilterString(tran.RMiddleName);
            sql += ", @rLastName1 = " + FilterString(tran.RLastName1);
            sql += ", @rLastName2 = " + FilterString(tran.RLastName2);
            sql += ", @rAddress = " + FilterString(tran.RAddress);
            sql += ", @rContactNo = " + FilterString(tran.RContactNo);
            sql += ", @relationship = " + FilterString(tran.RelWithSender);
            sql += ", @rIdType = " + FilterString(tran.RIDType);
            sql += ", @rIdNo = " + FilterString(tran.RIDNo);
            sql += ", @remarks = " + FilterString(tran.PayoutMsg);
            sql += ", @txnId = " + FilterString(tran.TxnId);
            sql += ", @fromSendTrnTime = " + FilterString(fromSendTrnTime);
            sql += ", @toSendTrnTime = " + FilterString(toSendTrnTime);

            return (ExecuteDataset(sql).Tables[0].Rows[0]);
        }



        public DbResult LocalInsert(string user, TranDetail tran)
        {
            var sql = "EXEC proc_sendTranAPI @flag = 'li'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(tran.ControlNo);
            sql += ", @sBranch = " + FilterString(tran.SBranch);
            sql += ", @sBranchName = " + FilterString(tran.SBranchName);
            sql += ", @sAgent = " + FilterString(tran.SAgent);
            sql += ", @sAgentName = " + FilterString(tran.SAgentName);
            sql += ", @sSuperAgent = " + FilterString(tran.SSuperAgent);
            sql += ", @sSuperAgentName = " + FilterString(tran.SSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(tran.SettlingAgent);
            sql += ", @mapCode = " + FilterString(tran.MapCodeInt);
            sql += ", @mapCodeDom = " + FilterString(tran.MapCodeDom);
            sql += ", @pBankBranch = " + FilterString(tran.PBankBranch);
            sql += ", @accountNo = " + FilterString(tran.AccountNo);
            sql += ", @pLocation = " + FilterString(tran.PLocation);
            sql += ", @transferAmt = " + FilterString(tran.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(tran.ServiceCharge);
            sql += ", @cAmt = " + FilterString(tran.TotalCollection);
            sql += ", @pAmt = " + FilterString(tran.PayoutAmt);
            sql += ", @deliveryMethod = " + FilterString(tran.DeliveryMethod);
            sql += ", @senderId = " + FilterString(tran.SenderId);
            sql += ", @sMemId = " + FilterString(tran.SMemId);
            sql += ", @sFirstName = " + FilterString(tran.SFirstName);
            sql += ", @sMiddleName = " + FilterString(tran.SMiddleName);
            sql += ", @sLastName1 = " + FilterString(tran.SLastName1);
            sql += ", @sLastName2 = " + FilterString(tran.SLastName2);
            sql += ", @sAddress = " + FilterString(tran.SAddress);
            sql += ", @sContactNo = " + FilterString(tran.SContactNo);
            sql += ", @sIdType = " + FilterString(tran.SIDType);
            sql += ", @sIdNo = " + FilterString(tran.SIDNo);
            sql += ", @sEmail = " + FilterString(tran.SEmail);
            sql += ", @receiverId = " + FilterString(tran.ReceiverId);
            sql += ", @rMemId = " + FilterString(tran.RMemId);
            sql += ", @rFirstName = " + FilterString(tran.RFirstName);
            sql += ", @rMiddleName = " + FilterString(tran.RMiddleName);
            sql += ", @rLastName1 = " + FilterString(tran.RLastName1);
            sql += ", @rLastName2 = " + FilterString(tran.RLastName2);
            sql += ", @rAddress = " + FilterString(tran.RAddress);
            sql += ", @rContactNo = " + FilterString(tran.RContactNo);
            sql += ", @relationship = " + FilterString(tran.RelWithSender);
            sql += ", @rIdType = " + FilterString(tran.RIDType);
            sql += ", @rIdNo = " + FilterString(tran.RIDNo);
            sql += ", @remarks = " + FilterString(tran.PayoutMsg);
            sql += ", @txnId = " + FilterString(tran.TxnId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult SendTranV2(string user, TranDetail tran, string fromSendTrnTime, string toSendTrnTime)
        {
            var sql = "EXEC proc_sendTranAPI_v2 @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(tran.ControlNo);
            sql += ", @sBranch = " + FilterString(tran.SBranch);
            sql += ", @agentUniqueRefId = " + FilterString(tran.AgentRefId);
            sql += ", @sBranchName = " + FilterString(tran.SBranchName);
            sql += ", @sAgent = " + FilterString(tran.SAgent);
            sql += ", @sAgentName = " + FilterString(tran.SAgentName);
            sql += ", @sSuperAgent = " + FilterString(tran.SSuperAgent);
            sql += ", @sSuperAgentName = " + FilterString(tran.SSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(tran.SettlingAgent);
            sql += ", @mapCode = " + FilterString(tran.MapCodeInt);
            sql += ", @mapCodeDom = " + FilterString(tran.MapCodeDom);
            sql += ", @pBankBranch = " + FilterString(tran.PBankBranch);
            sql += ", @accountNo = " + FilterString(tran.AccountNo);
            sql += ", @pLocation = " + FilterString(tran.PLocation);
            sql += ", @transferAmt = " + FilterString(tran.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(tran.ServiceCharge);
            sql += ", @cAmt = " + FilterString(tran.TotalCollection);
            sql += ", @pAmt = " + FilterString(tran.PayoutAmt);
            sql += ", @deliveryMethod = " + FilterString(tran.DeliveryMethod);
            sql += ", @senderId = " + FilterString(tran.SenderId);
            sql += ", @sMemId = " + FilterString(tran.SMemId);
            sql += ", @sFirstName = " + FilterString(tran.SFirstName);
            sql += ", @sMiddleName = " + FilterString(tran.SMiddleName);
            sql += ", @sLastName1 = " + FilterString(tran.SLastName1);
            sql += ", @sLastName2 = " + FilterString(tran.SLastName2);
            sql += ", @sAddress = " + FilterString(tran.SAddress);
            sql += ", @sContactNo = " + FilterString(tran.SContactNo);
            sql += ", @sIdType = " + FilterString(tran.SIDType);
            sql += ", @sIdNo = " + FilterString(tran.SIDNo);
            sql += ", @sEmail = " + FilterString(tran.SEmail);
            sql += ", @receiverId = " + FilterString(tran.ReceiverId);
            sql += ", @rMemId = " + FilterString(tran.RMemId);
            sql += ", @rFirstName = " + FilterString(tran.RFirstName);
            sql += ", @rMiddleName = " + FilterString(tran.RMiddleName);
            sql += ", @rLastName1 = " + FilterString(tran.RLastName1);
            sql += ", @rLastName2 = " + FilterString(tran.RLastName2);
            sql += ", @rAddress = " + FilterString(tran.RAddress);
            sql += ", @rContactNo = " + FilterString(tran.RContactNo);
            sql += ", @relationship = " + FilterString(tran.RelWithSender);
            sql += ", @rIdType = " + FilterString(tran.RIDType);
            sql += ", @rIdNo = " + FilterString(tran.RIDNo);
            sql += ", @remarks = " + FilterString(tran.PayoutMsg);
            sql += ", @txnId = " + FilterString(tran.TxnId);
            sql += ", @fromSendTrnTime = " + FilterString(fromSendTrnTime);
            sql += ", @toSendTrnTime = " + FilterString(toSendTrnTime);
            sql += ", @txtPass = " + FilterString(tran.txtPass);
            sql += ", @sDcInfo = " + FilterString(tran.DcInfo);
            sql += ", @sIpAddress = " + FilterString(tran.IpAddress);
            sql += ", @purpose = " + FilterString(tran.PurposeOfRemit);
            sql += ", @sourceOfFund = " + FilterString(tran.SourceOfFund);
            sql += ", @Occupation = " + FilterString(tran.Occupation);
            sql += ", @topupMobileNo = " + FilterString(tran.TopupMobileNo);
            sql += ", @complianceAction = " + FilterString(tran.ComplianceAction);
            sql += ", @compApproveRemark = " + FilterString(tran.CompApproveRemark);

            sql += ", @txnBatchId = " + FilterString(tran.txnBatchId);
            sql += ", @txnDocFolder = " + FilterString(tran.txnDocFolder);
            sql += ", @sIdIssuedPlace = " + FilterString(tran.SIDIssuedPlace);
            sql += ", @sDOB = " + FilterString(tran.SDOB);
            sql += ", @sIdIssuedDate = " + FilterString(tran.SIDIssuedDate);
            sql += ", @sIdValidDate = " + FilterString(tran.SIDValidDate);

            sql += ", @sDOBBs = " + FilterString(tran.SDOBBs);
            sql += ", @sIdIssuedDateBs = " + FilterString(tran.SIDIssuedDateBs);
            sql += ", @sIdValidDateBs = " + FilterString(tran.SIDValidDateBs);

            sql += ", @sCustCardId = " + FilterString(tran.CustCardId);
            sql += ", @sGender = " + FilterString(tran.sGender);
            sql += ", @sMotherFatherName = " + FilterString(tran.sParentSpouseName);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet SendDomesticTransactionApi(string user, string sendBy, string agentUniqueRefId, string district, string location, string transferAmt,
            string serviceCharge, string collectAmt, string pAmt, string deliveryMethod, string pBranch, string pBankBranch, string accountNo, string senderId, string sMemId, string sFirstName, string sMiddleName, string sLastName1, string sLastName2,
            string sAdd, string sContactNo, string sIdType, string sIdNo, string sEmail, string receiverId, string rMemId, string rFirstName, string rMiddleName,
            string rLastName1, string rLastName2, string rAdd, string rContactNo, string relationship, string rIdType,
            string rIdNo, string remarks)
        {
            var sql = "EXEC proc_sendTranAPI @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sBranch = " + FilterString(sendBy);
            sql += ", @agentUniqueRefId = " + FilterString(agentUniqueRefId);
            sql += ", @pDistrict = " + FilterString(district);
            sql += ", @pLocation = " + FilterString(location);
            sql += ", @transferAmt = " + FilterString(transferAmt);
            sql += ", @serviceCharge = " + FilterString(serviceCharge);
            sql += ", @cAmt = " + FilterString(collectAmt);
            sql += ", @pAmt = " + FilterString(pAmt);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @pBankBranch = " + FilterString(pBankBranch);
            sql += ", @accountNo = " + FilterString(accountNo);
            sql += ", @senderId = " + FilterString(senderId);
            sql += ", @sMemId = " + FilterString(sMemId);
            sql += ", @sFirstName = " + FilterString(sFirstName);
            sql += ", @sMiddleName = " + FilterString(sMiddleName);
            sql += ", @sLastName1 = " + FilterString(sLastName1);
            sql += ", @sLastName2 = " + FilterString(sLastName2);
            sql += ", @sAddress = " + FilterString(sAdd);
            sql += ", @sContactNo = " + FilterString(sContactNo);
            sql += ", @sIdType = " + FilterString(sIdType);
            sql += ", @sIdNo = " + FilterString(sIdNo);
            sql += ", @sEmail = " + FilterString(sEmail);
            sql += ", @receiverId = " + FilterString(receiverId);
            sql += ", @rMemId = " + FilterString(rMemId);
            sql += ", @rFirstName = " + FilterString(rFirstName);
            sql += ", @rMiddleName = " + FilterString(rMiddleName);
            sql += ", @rLastName1 = " + FilterString(rLastName1);
            sql += ", @rLastName2 = " + FilterString(rLastName2);
            sql += ", @rAddress = " + FilterString(rAdd);
            sql += ", @rContactNo = " + FilterString(rContactNo);
            sql += ", @relationship = " + FilterString(relationship);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNo = " + FilterString(rIdNo);
            sql += ", @remarks = " + FilterString(remarks);

            DataSet ds = ExecuteDataset(sql);
            return ds;
        }

        public void DeleteTransaction(string user, string controlNo)
        {
            var sql = "EXEC proc_sendTranAPI @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            ExecuteDataset(sql);
        }

        public DataRow GetServiceChargeFromApi(string pLocation, string amount, string deliveryMethod, string mode, string user)
        {
            var sql = "EXEC proc_sendTranAPI @flag = 'sc'";
            sql += ", @pLocation = " + FilterString(pLocation);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @transferAmt = " + FilterString(amount);
            sql += ", @mode = " + FilterString(mode);
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #endregion

        #region Domestic Send Transaction and Service Charge

        #region HO Send
        public DataRow HoGetAcDetail(string user, string sBranch)
        {
            var sql = "EXEC proc_sendTranDomesticHo @flag = 'acBal'";
            sql += ", @sBranch = " + FilterString(sBranch);                 //Pass NULL for Agent
            sql += ", @user = " + FilterString(user);

            return ExecuteDataRow(sql);
        }

        public DbResult HoVerifyDomesticTransaction(string user, string transferAmt, string sBranch)
        {
            var sql = "EXEC proc_sendTranDomesticHo @flag = 'v'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @transferAmt = " + FilterString(transferAmt);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet HOVerifyTransaction(TranDetail tran)
        {
            var sql = "EXEC proc_sendTranDomesticHo @flag = 'vt'";
            sql += ", @user = " + FilterString(tran.User);
            sql += ", @agentUniqueRefId = " + FilterString(tran.AgentRefId);
            sql += ", @sBranch = " + FilterString(tran.SBranch);
            sql += ", @transferAmt = " + FilterString(tran.TransferAmt);
            sql += ", @deliveryMethod = " + FilterString(tran.DeliveryMethod);
            sql += ", @senderId = " + FilterString(tran.SenderId);
            sql += ", @sMemId = " + FilterString(tran.SMemId);
            sql += ", @sFirstName = " + FilterString(tran.SFirstName);
            sql += ", @sMiddleName = " + FilterString(tran.SMiddleName);
            sql += ", @sLastName1 = " + FilterString(tran.SLastName1);
            sql += ", @sLastName2 = " + FilterString(tran.SLastName2);
            sql += ", @sAddress = " + FilterString(tran.SAddress);
            sql += ", @sContactNo = " + FilterString(tran.SContactNo);
            sql += ", @sIdType = " + FilterString(tran.SIDType);
            sql += ", @sIdNo = " + FilterString(tran.SIDNo);
            sql += ", @sEmail = " + FilterString(tran.SEmail);
            sql += ", @receiverId = " + FilterString(tran.ReceiverId);
            sql += ", @rMemId = " + FilterString(tran.RMemId);
            sql += ", @rFirstName = " + FilterString(tran.RFirstName);
            sql += ", @rMiddleName = " + FilterString(tran.RMiddleName);
            sql += ", @rLastName1 = " + FilterString(tran.RLastName1);
            sql += ", @rLastName2 = " + FilterString(tran.RLastName2);
            sql += ", @rAddress = " + FilterString(tran.RAddress);
            sql += ", @rContactNo = " + FilterString(tran.RContactNo);
            sql += ", @relationship = " + FilterString(tran.RelWithSender);
            sql += ", @rIdType = " + FilterString(tran.RIDType);
            sql += ", @rIdNo = " + FilterString(tran.RIDNo);
            sql += ", @sDOB = " + FilterString(tran.SDOB);
            sql += ", @sIdValidDate = " + FilterString(tran.SIDValidDate);
            sql += ", @Occupation = " + FilterString(tran.Occupation);
            sql += ", @purpose = " + FilterString(tran.PurposeOfRemit);
            sql += ", @sourceOfFund = " + FilterString(tran.SourceOfFund);
            sql += ", @sIdIssuedDate = " + FilterString(tran.SIDIssuedDate);
            sql += ", @sAmountThreshold = " + FilterString(tran.sAmountThreshold);
            sql += ", @sIdIssuedPlace = " + FilterString(tran.SIDIssuedPlace);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DbResult HoSendTransaction(string user, string sendBy, string district, string location, string transferAmt,
            string serviceCharge, string collectAmt, string pAmt, string deliveryMethod, string pBranch, string pBankBranch, string accountNo,
            string senderId, string sMemId, string sFirstName, string sMiddleName, string sLastName1, string sLastName2,
            string sAdd, string sContactNo, string sIdType, string sIdNo, string sEmail, string receiverId, string rMemId, string rFirstName, string rMiddleName,
            string rLastName1, string rLastName2, string rAdd, string rContactNo, string relationship, string rIdType,
            string rIdNo, string remarks, string dcInfo, string ipAddress, string sourceOfFund, string purposeOfRemit, string occupation,
            string agentRefId, string complianceAction, string compApproveRemark, string sDOB, string sIdIssuedPlace, string sIdValidDate, string sIdIssuedDate, string sDOBBs, string sIdValidDateBs,
            string sIdIssuedDateBs, string txnBatchId, string txnDocFolder, string CustCardId, string sGender, string sParentSpouseName)
        {
            var sql = "EXEC proc_sendTranDomesticHo @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentUniqueRefId = " + FilterString(agentRefId);
            sql += ", @sBranch = " + FilterString(sendBy);
            sql += ", @pDistrict = " + FilterString(district);
            sql += ", @pLocation = " + FilterString(location);
            sql += ", @transferAmt = " + FilterString(transferAmt);
            sql += ", @serviceCharge = " + FilterString(serviceCharge);
            sql += ", @cAmt = " + FilterString(collectAmt);
            sql += ", @pAmt = " + FilterString(pAmt);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @pBankBranch = " + FilterString(pBankBranch);
            sql += ", @accountNo = " + FilterString(accountNo);
            sql += ", @senderId = " + FilterString(senderId);
            sql += ", @sMemId = " + FilterString(sMemId);
            sql += ", @sFirstName = " + FilterString(sFirstName);
            sql += ", @sMiddleName = " + FilterString(sMiddleName);
            sql += ", @sLastName1 = " + FilterString(sLastName1);
            sql += ", @sLastName2 = " + FilterString(sLastName2);
            sql += ", @sAddress = " + FilterString(sAdd);
            sql += ", @sContactNo = " + FilterString(sContactNo);
            sql += ", @sIdType = " + FilterString(sIdType);
            sql += ", @sIdNo = " + FilterString(sIdNo);
            sql += ", @sEmail = " + FilterString(sEmail);
            sql += ", @receiverId = " + FilterString(receiverId);
            sql += ", @rMemId = " + FilterString(rMemId);
            sql += ", @rFirstName = " + FilterString(rFirstName);
            sql += ", @rMiddleName = " + FilterString(rMiddleName);
            sql += ", @rLastName1 = " + FilterString(rLastName1);
            sql += ", @rLastName2 = " + FilterString(rLastName2);
            sql += ", @rAddress = " + FilterString(rAdd);
            sql += ", @rContactNo = " + FilterString(rContactNo);
            sql += ", @relationship = " + FilterString(relationship);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNo = " + FilterString(rIdNo);
            sql += ", @remarks = " + FilterString(remarks);
            sql += ", @sDcInfo = " + FilterString(dcInfo);
            sql += ", @sIpAddress = " + FilterString(ipAddress);
            sql += ", @purpose = " + FilterString(purposeOfRemit);
            sql += ", @sourceOfFund = " + FilterString(sourceOfFund);
            sql += ", @Occupation = " + FilterString(occupation);

            sql += ", @complianceAction = " + FilterString(complianceAction);
            sql += ", @compApproveRemark = " + FilterString(compApproveRemark);

            sql += ", @txnBatchId = " + FilterString(txnBatchId);
            sql += ", @txnDocFolder = " + FilterString(txnDocFolder);
            sql += ", @sIdIssuedPlace = " + FilterString(sIdIssuedPlace);
            sql += ", @sDOB = " + FilterString(sDOB);
            sql += ", @sIdIssuedDate = " + FilterString(sIdIssuedDate);
            sql += ", @sIdValidDate = " + FilterString(sIdValidDate);

            sql += ", @sDOBBs = " + FilterString(sDOBBs);
            sql += ", @sIdIssuedDateBs = " + FilterString(sIdIssuedDateBs);
            sql += ", @sIdValidDateBs = " + FilterString(sIdValidDateBs);

            sql += ", @sCustCardId = " + FilterString(CustCardId);
            sql += ", @sGender = " + FilterString(sGender);
            sql += ", @sMotherFatherName = " + FilterString(sParentSpouseName);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataTable HoLoadDomesticServiceChargeTable(string pLocation,
                                                string amount, string deliveryMethod, string user, string sBranch, string pBankBranch)
        {
            var sql = "EXEC proc_sendTranDomesticHo @flag = 'scTBL'";
            sql += ", @pLocation = " + FilterString(pLocation);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @transferAmt = " + FilterString(amount);
            sql += ", @user = " + FilterString(user);
            sql += ", @sBranch= " + FilterString(sBranch);       //Pass NULL for Agent
            sql += ", @pBankBranch = " + FilterString(pBankBranch);

            DataSet ds = ExecuteDataset(sql);
            return ds.Tables[0];
        }

        public string HoGetDomesticServiceCharge(string pLocation, string amount, string deliveryMethod, string user, string sBranch, string pBankBranch)
        {
            var sql = "EXEC proc_sendTranDomesticHo @flag = 'sc'";
            sql += ", @pLocation = " + FilterString(@pLocation);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @transferAmt = " + FilterString(amount);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @pBankBranch = " + FilterString(pBankBranch);
            sql += ", @user = " + FilterString(user);

            return GetSingleResult(sql);
        }

        #endregion

        public DataRow GetAcDetail(string user, string settlingAgent)
        {
            var sql = "EXEC proc_sendTranDomestic @flag = 'acBal'";
            sql += ", @settlingAgent = " + FilterString(settlingAgent);                 //Pass NULL for Agent
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult VerifyDomesticTransaction(string user, string transferAmt, string sBranch, string sAgent, string sSuperAgent, string settlingAgent)
        {
            var sql = "EXEC proc_sendTranDomestic @flag = 'v'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sSuperAgent = " + FilterString(sSuperAgent);
            sql += ", @settlingAgent = " + FilterString(settlingAgent);
            sql += ", @transferAmt = " + FilterString(transferAmt);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult SendDomesticTransaction(string user, string sendBy, string district, string location, string transferAmt,
            string serviceCharge, string collectAmt, string pAmt, string deliveryMethod, string pBranch, string pBankBranch, string accountNo, string senderId, string sMemId, string sFirstName, string sMiddleName, string sLastName1, string sLastName2,
            string sAdd, string sContactNo, string sIdType, string sIdNo, string sEmail, string receiverId, string rMemId, string rFirstName, string rMiddleName,
            string rLastName1, string rLastName2, string rAdd, string rContactNo, string relationship, string rIdType,
            string rIdNo, string remarks, string sBranchName, string sAgent, string sAgentName, string sSuperAgent, string sSuperAgentName, string settlingAgent, string mapCodeInt, string mapCodeDom)
        {
            var sql = "EXEC proc_sendTranDomestic @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sBranch = " + FilterString(sendBy);
            sql += ", @sBranchName = " + FilterString(sBranchName);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sAgentName = " + FilterString(sAgentName);
            sql += ", @sSuperAgent = " + FilterString(sSuperAgent);
            sql += ", @sSuperAgentName = " + FilterString(sSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(settlingAgent);
            sql += ", @mapCode = " + FilterString(mapCodeInt);
            sql += ", @mapCodeDom = " + FilterString(mapCodeDom);
            sql += ", @pDistrict = " + FilterString(district);
            sql += ", @pLocation = " + FilterString(location);
            sql += ", @transferAmt = " + FilterString(transferAmt);
            sql += ", @serviceCharge = " + FilterString(serviceCharge);
            sql += ", @cAmt = " + FilterString(collectAmt);
            sql += ", @pAmt = " + FilterString(pAmt);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @pBankBranch = " + FilterString(pBankBranch);
            sql += ", @accountNo = " + FilterString(accountNo);
            sql += ", @senderId = " + FilterString(senderId);
            sql += ", @sMemId = " + FilterString(sMemId);
            sql += ", @sFirstName = " + FilterString(sFirstName);
            sql += ", @sMiddleName = " + FilterString(sMiddleName);
            sql += ", @sLastName1 = " + FilterString(sLastName1);
            sql += ", @sLastName2 = " + FilterString(sLastName2);
            sql += ", @sAddress = " + FilterString(sAdd);
            sql += ", @sContactNo = " + FilterString(sContactNo);
            sql += ", @sIdType = " + FilterString(sIdType);
            sql += ", @sIdNo = " + FilterString(sIdNo);
            sql += ", @sEmail = " + FilterString(sEmail);
            sql += ", @receiverId = " + FilterString(receiverId);
            sql += ", @rMemId = " + FilterString(rMemId);
            sql += ", @rFirstName = " + FilterString(rFirstName);
            sql += ", @rMiddleName = " + FilterString(rMiddleName);
            sql += ", @rLastName1 = " + FilterString(rLastName1);
            sql += ", @rLastName2 = " + FilterString(rLastName2);
            sql += ", @rAddress = " + FilterString(rAdd);
            sql += ", @rContactNo = " + FilterString(rContactNo);
            sql += ", @relationship = " + FilterString(relationship);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNo = " + FilterString(rIdNo);
            sql += ", @remarks = " + FilterString(remarks);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataTable LoadDomesticServiceChargeTable(string pLocation,
                                                string amount, string deliveryMethod, string user, string sBranch, string pBankBranch)
        {
            var sql = "EXEC proc_sendTranDomestic @flag = 'scTBL'";
            sql += ", @pLocation = " + FilterString(pLocation);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @transferAmt = " + FilterString(amount);
            sql += ", @user = " + FilterString(user);
            sql += ", @sBranch= " + FilterString(sBranch);       //Pass NULL for Agent
            sql += ", @pBankBranch = " + FilterString(pBankBranch);

            DataSet ds = ExecuteDataset(sql);
            return ds.Tables[0];
        }

        public string GetDomesticServiceCharge(string pLocation, string amount, string deliveryMethod, string user, string sBranch, string pBankBranch)
        {
            var sql = "EXEC proc_sendTranDomestic @flag = 'sc'";
            sql += ", @pLocation = " + FilterString(@pLocation);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @transferAmt = " + FilterString(amount);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @pBankBranch = " + FilterString(pBankBranch);
            sql += ", @user = " + FilterString(user);

            return GetSingleResult(sql);
        }
        #endregion

        public string GetInvoicePrintMethod(string user, string tAmt)
        {
            var sql = "EXEC proc_agentBusinessFunction @flag = 'invMethod'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tAmt = " + FilterString(tAmt);

            return GetSingleResult(sql);
        }

        #region customer send page
        public DataTable GetCustomer(string user, string searchValue)
        {
            var sql = "EXEC proc_customerDetail @flag = 'CS1'";
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId = " + FilterString(searchValue);
            var ds = ExecuteDataset(sql);
            return ds.Tables[0];
        }
        public DataTable GetCustomer(string user, string searchValue, string sAmountThreshold, string sAmount)
        {
            var sql = "EXEC proc_customerDetail @flag = 'CS1'";
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId = " + FilterString(searchValue);
            sql += ", @sAmountThreshold = " + FilterString(sAmountThreshold);
            sql += ", @sAmount = " + FilterString(sAmount);
            var ds = ExecuteDataset(sql);
            return ds.Tables[0];
        }

        public DataSet GetMemberFromPay(string user, string memberId)
        {
            var sql = "EXEC proc_customerDetail @flag = 'CS2'";
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId = " + FilterString(memberId);
            var ds = ExecuteDataset(sql);
            return ds;
        }
        public DataTable GetCustomerImages(string user, string customerId)
        {
            var sql = "EXEC proc_customerDetail @flag = 'LoadImages'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);
            return ExecuteDataTable(sql);
        }
        public DataTable GetCustomerImagesAgent(string user, string customerId)
        {
            var sql = "EXEC proc_customerDetail @flag = 'LoadImagesAgent'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);
            return ExecuteDataTable(sql);
        }

        public DataSet GetMember(string user, string memberId)
        {
            var sql = "EXEC proc_customerDetail @flag = 'CS'";
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId = " + FilterString(memberId);
            var ds = ExecuteDataset(sql);
            return ds;
        }
        #endregion customer send page

        public DataTable GetMemberFromPayForThirdParty(string user, string memberId)
        {
            var sql = "EXEC proc_customerDetail @flag = 'searchRecForThp'";
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId = " + FilterString(memberId);
            return ExecuteDataTable(sql);
        }
        #region new functions : domestic send transaction v2
        public DataTable GetLocation(string user, string pDistrict)
        {
            var sql = "EXEC proc_sendDomestic @flag ='pLocation'";
            sql += ", @districtId = " + FilterString(pDistrict);
            sql += ", @user = " + FilterString(user);

            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }
        public DataTable GetDistrict(string user, string pLocation)
        {
            var sql = "EXEC proc_sendDomestic @flag ='pDistrict'";
            sql += ", @pLocationId = " + FilterString(pLocation);
            sql += ", @user = " + FilterString(user);

            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }
        public DataTable GetServiceCharge(string user, string pLocation, string pAmt, string deliveryMethod,
                string sBranch, string pBankBranch, string settlingAgent)
        {
            var sql = "EXEC proc_sendDomestic @flag = 'sc'";
            sql += ", @pLocation = " + FilterString(pLocation);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @transferAmt = " + FilterString(pAmt);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @pBankBranch = " + FilterString(pBankBranch);
            sql += ", @settlingAgent = " + FilterString(settlingAgent);
            sql += ", @user = " + FilterString(user);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }
        public DataTable GetBank(string user)
        {
            var sql = "EXEC proc_sendDomestic @flag = 'bank'";
            sql += ", @user = " + FilterString(user);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }
        public DataTable GetBankBranch(string user, string bankId)
        {
            var sql = "EXEC proc_sendDomestic @flag = 'bankBranch'";
            sql += ", @bankId = " + FilterString(bankId);
            sql += ", @user = " + FilterString(user);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }
        public DbResult SendDomesticTransactionV2(string user, TranDetail tran, string fromSendTrnTime, string toSendTrnTime)
        {
            var sql = "EXEC proc_sendDomesticTransaction @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(tran.ControlNo);
            sql += ", @sBranch = " + FilterString(tran.SBranch);
            sql += ", @agentUniqueRefId = " + FilterString(tran.AgentRefId);
            sql += ", @sBranchName = " + FilterString(tran.SBranchName);
            sql += ", @sAgent = " + FilterString(tran.SAgent);
            sql += ", @sAgentName = " + FilterString(tran.SAgentName);
            sql += ", @sSuperAgent = " + FilterString(tran.SSuperAgent);
            sql += ", @sSuperAgentName = " + FilterString(tran.SSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(tran.SettlingAgent);
            sql += ", @mapCode = " + FilterString(tran.MapCodeInt);
            sql += ", @mapCodeDom = " + FilterString(tran.MapCodeDom);
            sql += ", @pBankBranch = " + FilterString(tran.PBankBranch);
            sql += ", @accountNo = " + FilterString(tran.AccountNo);
            sql += ", @pLocation = " + FilterString(tran.PLocation);
            sql += ", @transferAmt = " + FilterString(tran.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(tran.ServiceCharge);
            sql += ", @cAmt = " + FilterString(tran.TotalCollection);
            sql += ", @pAmt = " + FilterString(tran.PayoutAmt);
            sql += ", @deliveryMethod = " + FilterString(tran.DeliveryMethod);
            sql += ", @senderId = " + FilterString(tran.SenderId);
            sql += ", @sMemId = " + FilterString(tran.SMemId);
            sql += ", @sFirstName = " + FilterString(tran.SFirstName);
            sql += ", @sMiddleName = " + FilterString(tran.SMiddleName);
            sql += ", @sLastName1 = " + FilterString(tran.SLastName1);
            sql += ", @sLastName2 = " + FilterString(tran.SLastName2);
            sql += ", @sAddress = " + FilterString(tran.SAddress);
            sql += ", @sContactNo = " + FilterString(tran.SContactNo);
            sql += ", @sIdType = " + FilterString(tran.SIDType);
            sql += ", @sIdNo = " + FilterString(tran.SIDNo);
            sql += ", @sEmail = " + FilterString(tran.SEmail);
            sql += ", @receiverId = " + FilterString(tran.ReceiverId);
            sql += ", @rMemId = " + FilterString(tran.RMemId);
            sql += ", @rFirstName = " + FilterString(tran.RFirstName);
            sql += ", @rMiddleName = " + FilterString(tran.RMiddleName);
            sql += ", @rLastName1 = " + FilterString(tran.RLastName1);
            sql += ", @rLastName2 = " + FilterString(tran.RLastName2);
            sql += ", @rAddress = " + FilterString(tran.RAddress);
            sql += ", @rContactNo = " + FilterString(tran.RContactNo);
            sql += ", @relationship = " + FilterString(tran.RelWithSender);
            sql += ", @rIdType = " + FilterString(tran.RIDType);
            sql += ", @rIdNo = " + FilterString(tran.RIDNo);
            sql += ", @remarks = " + FilterString(tran.PayoutMsg);
            sql += ", @txnId = " + FilterString(tran.TxnId);
            sql += ", @fromSendTrnTime = " + FilterString(fromSendTrnTime);
            sql += ", @toSendTrnTime = " + FilterString(toSendTrnTime);
            sql += ", @txtPass = " + FilterString(tran.txtPass);
            sql += ", @sDcInfo = " + FilterString(tran.DcInfo);
            sql += ", @sIpAddress = " + FilterString(tran.IpAddress);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        #endregion

        public DbResult SendDomesticTransactionRegional(string user, TranDetail tran, string fromSendTrnTime, string toSendTrnTime)
        {
            var sql = "EXEC proc_sendTranDomesticRegional @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentUniqueRefId = " + FilterString(tran.AgentRefId);
            sql += ", @sBranch = " + FilterString(tran.SBranch);
            sql += ", @pLocation = " + FilterString(tran.PLocation);
            sql += ", @transferAmt = " + FilterString(tran.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(tran.ServiceCharge);
            sql += ", @cAmt = " + FilterString(tran.TotalCollection);
            sql += ", @pAmt = " + FilterString(tran.PayoutAmt);
            sql += ", @deliveryMethod = " + FilterString(tran.DeliveryMethod);
            sql += ", @pBankBranch = " + FilterString(tran.PBankBranch);
            sql += ", @accountNo = " + FilterString(tran.AccountNo);
            sql += ", @senderId = " + FilterString(tran.SenderId);
            sql += ", @sMemId = " + FilterString(tran.SMemId);
            sql += ", @sFirstName = " + FilterString(tran.SFirstName);
            sql += ", @sMiddleName = " + FilterString(tran.SMiddleName);
            sql += ", @sLastName1 = " + FilterString(tran.SLastName1);
            sql += ", @sLastName2 = " + FilterString(tran.SLastName2);
            sql += ", @sAddress = " + FilterString(tran.SAddress);
            sql += ", @sContactNo = " + FilterString(tran.SContactNo);
            sql += ", @sIdType = " + FilterString(tran.SIDType);
            sql += ", @sIdNo = " + FilterString(tran.SIDNo);
            sql += ", @sEmail = " + FilterString(tran.SEmail);
            sql += ", @receiverId = " + FilterString(tran.ReceiverId);
            sql += ", @rMemId = " + FilterString(tran.RMemId);
            sql += ", @rFirstName = " + FilterString(tran.RFirstName);
            sql += ", @rMiddleName = " + FilterString(tran.RMiddleName);
            sql += ", @rLastName1 = " + FilterString(tran.RLastName1);
            sql += ", @rLastName2 = " + FilterString(tran.RLastName2);
            sql += ", @rAddress = " + FilterString(tran.RAddress);
            sql += ", @rContactNo = " + FilterString(tran.RContactNo);
            sql += ", @relationship = " + FilterString(tran.RelWithSender);
            sql += ", @rIdType = " + FilterString(tran.RIDType);
            sql += ", @rIdNo = " + FilterString(tran.RIDNo);
            sql += ", @remarks = " + FilterString(tran.PayoutMsg);
            sql += ", @sDcInfo = " + FilterString(tran.DcInfo);
            sql += ", @sIpAddress = " + FilterString(tran.IpAddress);
            sql += ", @txnId = " + FilterString(tran.TxnId);
            sql += ", @fromSendTrnTime = " + FilterString(fromSendTrnTime);
            sql += ", @toSendTrnTime = " + FilterString(toSendTrnTime);
            sql += ", @txtPass = " + FilterString(tran.txtPass);
            sql += ", @sourceOfFund = " + FilterString(tran.SourceOfFund);
            sql += ", @purpose = " + FilterString(tran.PurposeOfRemit);
            sql += ", @Occupation = " + FilterString(tran.Occupation);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DataRow GetThresholdAmount(string user, string sAgent, string rCountryId)
        {
            var sql = "EXEC proc_sendingAmtThreshold @flag = 'getTA'";
            sql += ", @sAgent = " + FilterString(sAgent);                 //Pass NULL for Agent
            sql += ", @rCountryId = " + FilterString(rCountryId);
            sql += ", @user = " + FilterString(user);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet ValidateTransaction(TranDetail tran)
        {
            var sql = "EXEC proc_sendTranAPI_v2 @flag = 'validate'";
            sql += ", @user = " + FilterString(tran.User);
            sql += ", @sBranch = " + FilterString(tran.SBranch);
            sql += ", @sBranchName = " + FilterString(tran.SBranchName);
            sql += ", @sAgent = " + FilterString(tran.SAgent);
            sql += ", @sAgentName = " + FilterString(tran.SAgentName);
            sql += ", @sSuperAgent = " + FilterString(tran.SSuperAgent);
            sql += ", @sSuperAgentName = " + FilterString(tran.SSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(tran.SettlingAgent);
            sql += ", @mapCode = " + FilterString(tran.MapCodeInt);
            sql += ", @mapCodeDom = " + FilterString(tran.MapCodeDom);
            sql += ", @transferAmt = " + FilterString(tran.TransferAmt);
            sql += ", @deliveryMethod = " + FilterString(tran.DeliveryMethod);
            sql += ", @senderId = " + FilterString(tran.SenderId);
            sql += ", @sMemId = " + FilterString(tran.SMemId);
            sql += ", @sFirstName = " + FilterString(tran.SFirstName);
            sql += ", @sMiddleName = " + FilterString(tran.SMiddleName);
            sql += ", @sLastName1 = " + FilterString(tran.SLastName1);
            sql += ", @sLastName2 = " + FilterString(tran.SLastName2);
            sql += ", @sAddress = " + FilterString(tran.SAddress);
            sql += ", @sContactNo = " + FilterString(tran.SContactNo);
            sql += ", @sIdType = " + FilterString(tran.SIDType);
            sql += ", @sIdNo = " + FilterString(tran.SIDNo);
            sql += ", @sEmail = " + FilterString(tran.SEmail);
            sql += ", @receiverId = " + FilterString(tran.ReceiverId);
            sql += ", @rMemId = " + FilterString(tran.RMemId);
            sql += ", @rFirstName = " + FilterString(tran.RFirstName);
            sql += ", @rMiddleName = " + FilterString(tran.RMiddleName);
            sql += ", @rLastName1 = " + FilterString(tran.RLastName1);
            sql += ", @rLastName2 = " + FilterString(tran.RLastName2);
            sql += ", @rAddress = " + FilterString(tran.RAddress);
            sql += ", @rContactNo = " + FilterString(tran.RContactNo);
            sql += ", @relationship = " + FilterString(tran.RelWithSender);
            sql += ", @rIdType = " + FilterString(tran.RIDType);
            sql += ", @rIdNo = " + FilterString(tran.RIDNo);
            sql += ", @sDOB = " + FilterString(tran.SDOB);
            sql += ", @sIdValidDate = " + FilterString(tran.SIDValidDate);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
        public DbResult SendTranV2Co(string user, TranDetail tran, string fromSendTrnTime, string toSendTrnTime)
        {
            var sql = "EXEC proc_sendTranAPI_v2_cooperative @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(tran.ControlNo);
            sql += ", @sBranch = " + FilterString(tran.SBranch);
            sql += ", @agentUniqueRefId = " + FilterString(tran.AgentRefId);
            sql += ", @sBranchName = " + FilterString(tran.SBranchName);
            sql += ", @sAgent = " + FilterString(tran.SAgent);
            sql += ", @sAgentName = " + FilterString(tran.SAgentName);
            sql += ", @sSuperAgent = " + FilterString(tran.SSuperAgent);
            sql += ", @sSuperAgentName = " + FilterString(tran.SSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(tran.SettlingAgent);
            sql += ", @mapCode = " + FilterString(tran.MapCodeInt);
            sql += ", @mapCodeDom = " + FilterString(tran.MapCodeDom);
            sql += ", @pBankBranch = " + FilterString(tran.PBankBranch);
            sql += ", @accountNo = " + FilterString(tran.AccountNo);
            sql += ", @pLocation = " + FilterString(tran.PLocation);
            sql += ", @transferAmt = " + FilterString(tran.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(tran.ServiceCharge);
            sql += ", @cAmt = " + FilterString(tran.TotalCollection);
            sql += ", @pAmt = " + FilterString(tran.PayoutAmt);
            sql += ", @deliveryMethod = " + FilterString(tran.DeliveryMethod);
            sql += ", @senderId = " + FilterString(tran.SenderId);
            sql += ", @sMemId = " + FilterString(tran.SMemId);
            sql += ", @sFirstName = " + FilterString(tran.SFirstName);
            sql += ", @sMiddleName = " + FilterString(tran.SMiddleName);
            sql += ", @sLastName1 = " + FilterString(tran.SLastName1);
            sql += ", @sLastName2 = " + FilterString(tran.SLastName2);
            sql += ", @sAddress = " + FilterString(tran.SAddress);
            sql += ", @sContactNo = " + FilterString(tran.SContactNo);
            sql += ", @sIdType = " + FilterString(tran.SIDType);
            sql += ", @sIdNo = " + FilterString(tran.SIDNo);
            sql += ", @sEmail = " + FilterString(tran.SEmail);
            sql += ", @receiverId = " + FilterString(tran.ReceiverId);
            sql += ", @rMemId = " + FilterString(tran.RMemId);
            sql += ", @rFirstName = " + FilterString(tran.RFirstName);
            sql += ", @rMiddleName = " + FilterString(tran.RMiddleName);
            sql += ", @rLastName1 = " + FilterString(tran.RLastName1);
            sql += ", @rLastName2 = " + FilterString(tran.RLastName2);
            sql += ", @rAddress = " + FilterString(tran.RAddress);
            sql += ", @rContactNo = " + FilterString(tran.RContactNo);
            sql += ", @relationship = " + FilterString(tran.RelWithSender);
            sql += ", @rIdType = " + FilterString(tran.RIDType);
            sql += ", @rIdNo = " + FilterString(tran.RIDNo);
            sql += ", @remarks = " + FilterString(tran.PayoutMsg);
            sql += ", @txnId = " + FilterString(tran.TxnId);
            sql += ", @fromSendTrnTime = " + FilterString(fromSendTrnTime);
            sql += ", @toSendTrnTime = " + FilterString(toSendTrnTime);
            sql += ", @txtPass = " + FilterString(tran.txtPass);
            sql += ", @sDcInfo = " + FilterString(tran.DcInfo);
            sql += ", @sIpAddress = " + FilterString(tran.IpAddress);
            sql += ", @purpose = " + FilterString(tran.PurposeOfRemit);
            sql += ", @sourceOfFund = " + FilterString(tran.SourceOfFund);
            sql += ", @Occupation = " + FilterString(tran.Occupation);
            sql += ", @topupMobileNo = " + FilterString(tran.TopupMobileNo);
            sql += ", @complianceAction = " + FilterString(tran.ComplianceAction);
            sql += ", @compApproveRemark = " + FilterString(tran.CompApproveRemark);

            sql += ", @txnBatchId = " + FilterString(tran.txnBatchId);
            sql += ", @txnDocFolder = " + FilterString(tran.txnDocFolder);
            sql += ", @sIdIssuedPlace = " + FilterString(tran.SIDIssuedPlace);
            sql += ", @sDOB = " + FilterString(tran.SDOB);
            sql += ", @sIdIssuedDate = " + FilterString(tran.SIDIssuedDate);
            sql += ", @sIdValidDate = " + FilterString(tran.SIDValidDate);

            sql += ", @sDOBBs = " + FilterString(tran.SDOBBs);
            sql += ", @sIdIssuedDateBs = " + FilterString(tran.SIDIssuedDateBs);
            sql += ", @sIdValidDateBs = " + FilterString(tran.SIDValidDateBs);

            sql += ", @sCustCardId = " + FilterString(tran.CustCardId);
            sql += ", @sGender = " + FilterString(tran.sGender);
            sql += ", @sMotherFatherName = " + FilterString(tran.sParentSpouseName);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }


    }
}