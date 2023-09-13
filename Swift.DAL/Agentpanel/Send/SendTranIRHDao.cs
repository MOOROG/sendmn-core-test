using Swift.DAL.Common;
using Swift.DAL.Domain;
using Swift.DAL.Library;
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace Swift.DAL.BL.AgentPanel.Send
{
    public class SendTranIRHDao : RemittanceDao
    {
        #region Data population Part

        public DataTable LoadSchemeByRCountry(string sCountry, string sAgent, string sBranch, string pCountry, string rAgent, string sCustomerId)
        {
            var sql = "EXEC proc_sendPageLoadData @flag ='schemeBySCountryRCountry'";
            //sql += ", @countryName = " + FilterString(sCountry);
            //sql += ", @pCountryName = " + FilterString(pCountry);

            sql += ", @country = " + FilterString(sCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @pCountryId = " + FilterString(pCountry);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @sCustomerId = " + FilterString(sCustomerId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable LoadCustomerDataNew(string user, string customerId, string flag, string sCountryId, string settlementAgent)
        {
            var sql = "EXEC proc_searchCustomerIRH @flag =" + FilterString(flag);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountryId = " + FilterString(sCountryId);
            sql += ", @settlementAgent = " + FilterString(settlementAgent);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable LoadCustomerData(string searchType, string searchValue, string flag, string sCountryId, string settlementAgent)
        {
            var sql = "EXEC proc_searchCustomerIRH @flag =" + FilterString(flag);
            sql += ", @searchType = " + FilterString(searchType);
            sql += ", @searchValue = " + FilterString(searchValue);
            sql += ", @sCountryId = " + FilterString(sCountryId);
            sql += ", @settlementAgent = " + FilterString(settlementAgent);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable LoadCustomerDataNew(string user, string searchType, string searchValue, string flag, string sCountryId, string settlementAgent)
        {
            var sql = "EXEC proc_searchCustomerIRH @flag =" + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @searchType = " + FilterString(searchType);
            sql += ", @searchValue = " + FilterString(searchValue);
            sql += ", @sCountryId = " + FilterString(sCountryId);
            sql += ", @settlementAgent = " + FilterString(settlementAgent);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable LoadBranchByAgent(string searchType, string searchValue, string pAgent, string pAgentType)
        {
            var sql = "EXEC proc_searchCustomerIRH @flag ='branchByAgent'";
            sql += ", @searchType = " + FilterString(searchType);
            sql += ", @searchValue = " + FilterString(searchValue);
            sql += ", @senderId = " + FilterString(pAgent);
            sql += ", @agentType = " + FilterString(pAgentType);

            return ExecuteDataTable(sql);
        }

        public DataTable LoadLocationByAgent(string searchValue, string pAgent)
        {
            var sql = "EXEC proc_searchCustomerIRH @flag ='locationByAgent'";
            sql += ", @searchValue = " + FilterString(searchValue);
            sql += ", @senderId = " + FilterString(pAgent);

            return ExecuteDataTable(sql);
        }

        public DataTable GetAgentSetting(string user, string countryId, string agentId, string deliveryMethodId, string pBankType)
        {
            var sql = "EXEC proc_sendPageLoadData @flag = 'agentsetting'";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @deliveryMethodId = " + FilterString(deliveryMethodId);
            sql += ", @pBankType = " + FilterString(pBankType);

            return ExecuteDataTable(sql);
        }

        public DataTable LoadDataFromDdl(string sCountryid, string pCountry, string collMode, string agentId, string flag, string user)
        {
            //var sql = "EXEC proc_dropDownLists @flag = 'collModeByCountry'";
            //sql += ", @param = " + FilterString(pCountry);

            var sql = "EXEC proc_sendPageLoadData @flag =" + FilterString(flag);
            sql += ", @countryId = " + FilterString(sCountryid);
            sql += ", @pCountryId = " + FilterString(pCountry);
            sql += ", @param = " + FilterString(collMode);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @user = " + FilterString(user);

            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable GetPayoutPartner(string user, string pCountry, string pMode)
        {
            string sql = "EXEC PROC_API_ROUTE_PARTNERS @flag='payout-partner'";
            sql += " , @CountryId = " + FilterString(pCountry);
            sql += " , @PaymentMethod = " + FilterString(pMode);
            sql += " , @user = " + FilterString(user);

            return ExecuteDataTable(sql);
        }

        public DataTable PopulateReceiverDDL(string user, string customerId)
        {
            string sql = "EXEC proc_online_dropDownList @flag='receiver-list'";
            sql += " , @customerId = " + FilterString(customerId);
            sql += " , @user = " + FilterString(user);

            return ExecuteDataTable(sql);
        }

        public DataTable GetAdditionalCDDIInfo(string user, string customerId)
        {
            string sql = "EXEC proc_sendPageLoadData @flag='additional-cddi'";
            sql += " , @user = " + FilterString(user);
            sql += " , @sCustomerId = " + FilterString(customerId);

            return ExecuteDataTable(sql);
        }

        public DataTable LoadReceiverData(string user, string tranId)
        {
            var sql = "EXEC proc_sendPageLoadData @flag = 'receiverDataBySender'";
            sql += ", @user = " + FilterString(user);
            sql += ", @RECEIVERID = " + FilterString(tranId);

            return ExecuteDataTable(sql);
        }

        public IList<BranchModel> LoadBranchByAgent(BankSearchModel bankSearchModel)
        {
            var sql = "EXEC proc_sendPageLoadData @flag = 'branchByBank'";
            sql += ", @user = " + FilterString(bankSearchModel.User);
            sql += ", @param = " + FilterString(bankSearchModel.SearchValue);
            sql += ", @agentId = " + FilterString(bankSearchModel.PAgent);
            sql += ", @countryId = " + FilterString(bankSearchModel.PCountryName);
            sql += ", @partnerId = " + FilterString(bankSearchModel.PayoutPartner);
            sql += ", @deliveryMethodId = " + FilterString(bankSearchModel.PaymentMode);

            DataTable dt = ExecuteDataTable(sql);

            return Mapper.DataTableToClass<BranchModel>(dt);
        }

        public DataTable LoadAgentByExtAgent(string user, string extBankId)
        {
            var sql = "EXEC proc_sendPageLoadData @flag = 'agentByExtAgent'";
            sql += ", @user = " + FilterString(user);
            sql += ", @param = " + FilterString(extBankId);

            return ExecuteDataTable(sql);
        }

        public DataTable LoadAgentByExtBranch(string user, string extBranchId)
        {
            var sql = "EXEC proc_sendPageLoadData @flag = 'agentByExtBranch'";
            sql += ", @user = " + FilterString(user);
            sql += ", @param = " + FilterString(extBranchId);

            return ExecuteDataTable(sql);
        }

        public DataTable GetPayoutLimitInfo(string user, string sCountry, string pCountry, string pAgent, string pMode)
        {
            var sql = "EXEC proc_sendPageLoadData @flag = 'payoutLimitInfo'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pMode = " + FilterString(pMode);

            return ExecuteDataTable(sql);
        }

        public DataTable LoadPayCurr(string pCountry, string pMode = "", string pAgent = "")
        {
            var sql = "EXEC proc_sendPageLoadData @flag = 'pcurr'";
            sql += ", @countryId = " + FilterString(pCountry);
            sql += ", @pMode = " + FilterString(pMode);
            sql += ", @pAgent = " + FilterString(pAgent);
            var ds = ExecuteDataset(sql);
            return ds.Tables[0];
        }

        public DataTable PopulateReceiverBySender(string senderId, string searchValue, string recId)
        {
            //var sql = "EXEC proc_searchCustomerIRH @flag = 'r'";
            var sql = "EXEC proc_searchCustomerIRH @flag = 'ASN'";
            sql += ", @senderId = " + FilterString(senderId);
            sql += ", @searchValue = " + FilterString(searchValue);
            sql += ", @recId = " + FilterString(recId);
            var ds = ExecuteDataset(sql);
            if (ds.Tables[0] == null || ds.Tables.Count == 0)
            {
                return null;
            }
            return ds.Tables[0];
        }

        public DataTable SenderTXNHistory(string senderId)
        {
            var sql = "EXEC proc_searchCustomerIRH @flag = 'sth'";
            sql += ", @senderId = " + FilterString(senderId);
            return ExecuteDataTable(sql);
        }

        public DataTable SenderRecentRecList(string senderId, string searchValue)
        {
            var sql = "EXEC proc_searchCustomerIRH @flag = 'srr'";
            sql += ", @senderId = " + FilterString(senderId);
            sql += ", @searchValue = " + FilterString(searchValue);
            return ExecuteDataTable(sql);
        }

        #endregion Data population Part

        #region for calculation part

        public DataRow GetPayoutAmtRounding(string user, string payoutCurr, string deliveryMethod)
        {
            var sql = "EXEC proc_currencyPayoutRound @flag = 'p'";
            sql += ", @user = " + FilterString(user);
            sql += ", @currency = " + FilterString(payoutCurr);
            sql += ", @tranType = " + FilterString(deliveryMethod);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataTable GetExRate(string user, string sCountryId, string sSuperAgent, string sAgent, string sBranch, string collCurr,
                                        string pCountryId, string pAgent, string pCurr, string deliveryMethod, string cAmt, string pAmt,
                                        string schemeCode, string senderId, string sessionId, string couponId, string isManualSc = "", string sc = "")
        {
            var sql = "EXEC proc_sendIRH @flag = 'exRate'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountryId = " + FilterString(sCountryId);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sSuperAgent = " + FilterString(sSuperAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @collCurr = " + FilterString(collCurr);
            sql += ", @pCountryId = " + FilterString(pCountryId);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pCurr = " + FilterString(pCurr);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @cAmt = " + FilterString(cAmt);
            sql += ", @pAmt = " + FilterString(pAmt);
            sql += ", @schemeCode = " + FilterString(schemeCode);
            sql += ", @senderId = " + FilterString(senderId);
            sql += ", @sessionId = " + FilterString(sessionId);
            sql += ", @couponTranNo = " + FilterString(couponId);
            sql += ", @isManualSc = " + FilterString(isManualSc);
            sql += ", @manualSc = " + FilterString(sc);

            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable GetExRateNew(string user, string sCountryId, string sSuperAgent, string sAgent, string sBranch, string collCurr,
                                      string pCountryId, string pAgent, string pCurr, string deliveryMethod, string cAmt, string pAmt,
                                      string schemeCode, string senderId, string sessionId, string couponId, string isManualSc = "", string sc = "")
        {
            var sql = "EXEC proc_sendIRHNew @flag = 'exRate'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountryId = " + FilterString(sCountryId);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sSuperAgent = " + FilterString(sSuperAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @collCurr = " + FilterString(collCurr);
            sql += ", @pCountryId = " + FilterString(pCountryId);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pCurr = " + FilterString(pCurr);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @cAmt = " + FilterString(cAmt);
            sql += ", @pAmt = " + FilterString(pAmt);
            sql += ", @schemeCode = " + FilterString(schemeCode);
            sql += ", @senderId = " + FilterString(senderId);
            sql += ", @sessionId = " + FilterString(sessionId);
            sql += ", @couponTranNo = " + FilterString(couponId);
            sql += ", @isManualSc = " + FilterString(isManualSc);
            sql += ", @manualSc = " + FilterString(sc);

            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable GetExRateTP(string user, string sCountryId, string sSuperAgent, string sAgent, string sBranch, string collCurr,
                                        string pCountryId, string pAgent, string pCurr, string deliveryMethod, string cAmt, string pAmt,
                                        string schemeCode, string senderId, string sessionId, string couponId
                                        , string isManualSc, string sc
                                        , string exRateTp, string pCurrTp)
        {
            var sql = "EXEC proc_sendIRHTP @flag = 'exRate'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountryId = " + FilterString(sCountryId);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sSuperAgent = " + FilterString(sSuperAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @collCurr = " + FilterString(collCurr);
            sql += ", @pCountryId = " + FilterString(pCountryId);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pCurr = " + FilterString(pCurr);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @cAmt = " + FilterString(cAmt);
            sql += ", @pAmt = " + FilterString(pAmt);
            sql += ", @schemeCode = " + FilterString(schemeCode);
            sql += ", @senderId = " + FilterString(senderId);
            sql += ", @sessionId = " + FilterString(sessionId);
            sql += ", @couponTranNo = " + FilterString(couponId);
            sql += ", @tpExRate = " + FilterString(exRateTp);
            sql += ", @tpPCurr = " + FilterString(pCurrTp);
            sql += ", @isManualSc = " + FilterString(isManualSc);
            sql += ", @manualSc = " + FilterString(sc);

            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable LoadCustomerRate(string user, string sCountryId, string sSuperAgent, string sAgent, string sBranch, string collCurr,
                                         string pCountryId, string pAgent, string pCurr, string deliveryMethod)
        {
            var sql = "EXEC proc_sendIRH @flag = 'customerRate'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountryId = " + FilterString(sCountryId);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sSuperAgent = " + FilterString(sSuperAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @collCurr = " + FilterString(collCurr);
            sql += ", @pCountryId = " + FilterString(pCountryId);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pCurr = " + FilterString(pCurr);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);

            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable CheckSenderIdNumber(string user, string sIdType, string sIdNo)
        {
            var sql = "EXEC proc_sendIRH @flag = 'chkSenderIdNo'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sIdType = " + FilterString(sIdType);
            sql += ", @sIdNo = " + FilterString(sIdNo);

            return ExecuteDataTable(sql);
        }

        //public double GetExRate(string user, string pBranch, string pCountry, string collCurr, string payoutCurr, string deliveryMethod)
        // {
        //     var sql = "EXEC proc_sendIRH @flag = 'exRate'";
        //     sql += ", @user = " + FilterString(user);
        //     sql += ", @pBranch = " + FilterString(pBranch);
        //     sql += ", @pCountry = " + FilterString(pCountry);
        //     sql += ", @collCurr = " + FilterString(collCurr);
        //     sql += ", @pCurr = " + FilterString(payoutCurr);
        //     sql += ", @deliveryMethod = " + FilterString(deliveryMethod);

        // var value = ""; var ds = ExecuteDataset(sql);

        // if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0) { //do nothing }
        // else { value = ds.Tables[0].Rows[0][0].ToString(); }

        // double tmp; double.TryParse(value, out tmp); return tmp; }

        public DataRow CheckCustDayLimit(string user, string senderId, string sCountryId)
        {
            var sql = "EXEC proc_sendIRH @flag = 'CustdayLimit'";
            sql += ", @user = " + FilterString(user);
            sql += ", @senderId = " + FilterString(senderId);
            sql += ", @sCountryId = " + FilterString(sCountryId);

            return ExecuteDataRow(sql);
        }

        public Double GetServiceCharge(string user, string sAgentId, string rsAgentid, string rCountryId, string rBranch, string deliveryMethod, string tranAmt, string collCurr)
        {
            var sql = "EXEC proc_sendIRH @flag = 'sc'";
            sql += ", @sBranch = " + FilterString(sAgentId);
            sql += ", @pCountryId = " + FilterString(rCountryId);
            sql += ", @deliveryMethodId = " + FilterString(deliveryMethod);
            sql += ", @collCurr = " + FilterString(collCurr);
            sql += ", @tAmt = " + FilterString(tranAmt);
            sql += ", @user = " + FilterString(user);

            var value = "";
            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            {
                //do nothing
            }
            else
            {
                value = ds.Tables[0].Rows[0][0].ToString();
            }
            if (value == "")
                return -1;
            double tmp;
            double.TryParse(value, out tmp);
            return tmp;
        }

        #endregion for calculation part

        public DataSet GetRequiredField(string countryId, string agentId)
        {
            var sql = "EXEC proc_sendPageLoadData @flag = 'pageField'";
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @agentId = " + FilterString(agentId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DataTable GetCollModeData(string countryId, string agentId)
        {
            var sql = "EXEC proc_sendPageLoadData @flag = 'COLLMODE-AG'";
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @agentId = " + FilterString(agentId);

            return ExecuteDataTable(sql);
        }

        public DataRow GetAcDetail(string user)
        {
            var sql = "EXEC proc_sendIRH @flag = 'acBal'";
            sql += ", @user = " + FilterString(user);

            return ExecuteDataRow(sql);
        }

        public DataRow GetAcDetailByBranchId(string user, string agentId)
        {
            var sql = "EXEC proc_sendIRH @flag = 'acBalByAgentId'";
            sql += ", @user = ''";
            sql += ", @sBranch = " + FilterString(agentId);
            return ExecuteDataRow(sql);
        }

        public DataTable GetAcDetailByBranchIdNew(string user, string agentId)
        {
            var sql = "EXEC proc_sendIRH @flag = 'acBalByAgentId'";
            sql += ", @user = '" + user + "'";
            sql += ", @sBranch = " + FilterString(agentId);

            return ExecuteDataTable(sql);
        }

        public DataTable GetReferralBal(string user, string referralCode)
        {
            var sql = "EXEC proc_sendIRH @flag = 'getReferralBal'";
            sql += ", @user = '" + user + "'";
            sql += ", @referralCode = " + FilterString(referralCode);

            return ExecuteDataTable(sql);
        }

        public DataTable ValidateReferral(string user, string referralCode)
        {
            var sql = "EXEC proc_sendIRH @flag = 'v-referral'";
            sql += ", @user = " + FilterString(user);
            sql += ", @introducer = " + FilterString(referralCode);

            return ExecuteDataTable(sql);
        }

        public DataTable CheckBalanceExceed(string user)
        {
            var sql = "EXEC proc_sendIRH @flag = 'balcheck'";
            sql += ", @user = " + FilterString(user);

            return ExecuteDataTable(sql);
        }

        #region Transaction Validation and Send Part

        public DataSet ValidateTransaction(IRHTranDetail trn)
        {
            var sql = "EXEC proc_sendIRH @flag = 'v'";

            sql += ", @user = " + FilterString(trn.User);
            sql += ", @agentRefId = " + FilterString(trn.AgentRefId);
            sql += ", @senderId = " + FilterString(trn.SenderId);
            sql += ", @sfName = " + FilterString(trn.SenFirstName);
            sql += ", @smName = " + FilterString(trn.SenMiddleName);
            sql += ", @slName = " + FilterString(trn.SenLastName);
            sql += ", @slName2 = " + FilterString(trn.SenLastName2);
            sql += ", @sIdType = " + FilterString(trn.SenIdType);
            sql += ", @sIdNo = " + FilterString(trn.SenIdNo);
            sql += ", @sIdValid = " + FilterString(trn.SenIdValid);
            sql += ", @sdob = " + FilterString(trn.SenDob);
            sql += ", @sTel = " + FilterString(trn.SenTel);
            sql += ", @sMobile = " + FilterString(trn.SenMobile);
            sql += ", @sNaCountry = " + FilterString(trn.SenNaCountry);
            sql += ", @scity = " + FilterString(trn.SenCity);
            sql += ", @sPostCode = " + FilterString(trn.SenPostCode);
            sql += ", @sAdd1 = " + FilterString(trn.SenAdd1);
            sql += ", @sAdd2 = " + FilterString(trn.SenAdd2);
            sql += ", @sEmail = " + FilterString(trn.SenEmail);
            sql += ", @smsSend = " + FilterString(trn.SmsSend);
            sql += ", @sgender = " + FilterString(trn.SenGender);
            sql += ", @memberCode = " + FilterString(trn.MemberCode);

            sql += ", @benId = " + FilterString(trn.ReceiverId);
            sql += ", @rfName = " + FilterString(trn.RecFirstName);
            sql += ", @rmName = " + FilterString(trn.RecMiddleName);
            sql += ", @rlName = " + FilterString(trn.RecLastName);
            sql += ", @rlName2 = " + FilterString(trn.RecLastName2);
            sql += ", @rIdType = " + FilterString(trn.RecIdType);
            sql += ", @rIdNo = " + FilterString(trn.RecIdNo);
            sql += ", @rIdValid = " + FilterString(trn.RecIdValid);
            sql += ", @rdob = " + FilterString(trn.RecDob);
            sql += ", @rTel = " + FilterString(trn.RecTel);
            sql += ", @rMobile = " + FilterString(trn.RecMobile);
            sql += ", @rNaCountry = " + FilterString(trn.RecNaCountry);
            sql += ", @rcity = " + FilterString(trn.RecCity);
            sql += ", @rPostCode = " + FilterString(trn.RecPostCode);
            sql += ", @rAdd1 = " + FilterString(trn.RecAdd1);
            sql += ", @rAdd2 = " + FilterString(trn.RecAdd2);
            sql += ", @rEmail = " + FilterString(trn.RecEmail);
            sql += ", @raccountNo = " + FilterString(trn.RecAccountNo);

            sql += ", @sCountryId = " + FilterString(trn.SCountryId);
            sql += ", @pCountry = " + FilterString(trn.RecCountry);
            sql += ", @pCountryId = " + FilterString(trn.RecCountryId);
            sql += ", @deliveryMethod = " + FilterString(trn.DeliveryMethod);
            sql += ", @deliveryMethodId = " + FilterString(trn.DeliveryMethodId);
            sql += ", @pBank = " + FilterString(trn.PBank);
            sql += ", @pBankName = " + FilterString(trn.PBankName);
            sql += ", @pBankBranch = " + FilterString(trn.PBankBranch);
            sql += ", @pBankBranchName = " + FilterString(trn.PBankBranchName);
            sql += ", @pAgent = " + FilterString(trn.PAgent);
            sql += ", @pAgentName = " + FilterString(trn.PAgentName);
            sql += ", @pBankType = " + FilterString(trn.PBankType);
            sql += ", @pCurr = " + FilterString(trn.PCurr);
            sql += ", @collCurr = " + FilterString(trn.CollCurr);
            sql += ", @cAmt = " + FilterString(trn.CollAmt);
            sql += ", @pAmt = " + FilterString(trn.PayoutAmt);
            sql += ", @tAmt = " + FilterString(trn.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(trn.ServiceCharge);
            sql += ", @discount = " + FilterString(trn.Discount);
            sql += ", @exRate = " + FilterString(trn.ExRate);
            sql += ", @schemeCode = " + FilterString(trn.SchemeCode);
            sql += ", @couponTranNo = " + FilterString(trn.CouponTranNo);

            sql += ", @purpose = '" + trn.PurposeOfRemittance + "'";
            sql += ", @sourceOfFund = '" + trn.SourceOfFund + "'";
            sql += ", @relationship = '" + trn.RelWithSender + "'";

            sql += ", @occupation = " + FilterString(trn.Occupation);
            sql += ", @payMsg = " + FilterString(trn.PayoutMsg);
            sql += ", @company = " + FilterString(trn.Company);
            sql += ", @nCust = " + FilterString(trn.NCustomer);
            sql += ", @enrollCust = " + FilterString(trn.ECustomer);

            sql += ", @sBranch = " + FilterString(trn.SBranch);
            sql += ", @sAgent = " + FilterString(trn.SAgent);
            sql += ", @sSuperAgent = " + FilterString(trn.SSuperAgent);
            sql += ", @settlingAgent = " + FilterString(trn.SettlingAgent);

            //sql += ", @cwPwd = " + FilterString(trn.CwPwd);
            //sql += ", @ttName = " + FilterString(trn.TtName.Replace(";", "|")).Replace("|", ";");

            sql += ", @isManualSc = " + FilterString(trn.isManualSC);
            sql += ", @collMode = " + FilterString(trn.cashCollMode);
            sql += ", @manualSC = " + FilterString(trn.manualSC);
            sql += ", @payoutPartner = " + FilterString(trn.payoutPartner);
            sql += ", @sCustStreet = " + FilterString(trn.sCustStreet);
            sql += ", @sCustLocation = " + FilterString(trn.sCustLocation);
            sql += ", @sCustomerType = " + FilterString(trn.sCustomerType);
            sql += ", @sCustBusinessType = " + FilterString(trn.sCustBusinessType);
            sql += ", @sCustIdIssuedCountry = " + FilterString(trn.sCustIdIssuedCountry);
            sql += ", @sCustIdIssuedDate = " + FilterString(trn.sCustIdIssuedDate);
            sql += ", @receiverId = " + FilterString(trn.receiverId);
            sql += ", @introducer = " + FilterString(trn.introducer);
            sql += ", @isAdditionalCDDI = " + FilterString(trn.isAdditionalCDDI);
            sql += ", @calcBy = " + FilterString(trn.calcBy);
            sql += ", @additionalCDDIXml = '" + trn.CDDIXml + "'";

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DataSet ValidateTransactionNew(IRHTranDetail trn)
        {
            var sql = "EXEC proc_sendIRHNew @flag = 'v'";

            sql += ", @user = " + FilterString(trn.User);
            sql += ", @agentRefId = " + FilterString(trn.AgentRefId);
            sql += ", @senderId = " + FilterString(trn.SenderId);
            sql += ", @sfName = " + FilterString(trn.SenFirstName);
            sql += ", @smName = " + FilterString(trn.SenMiddleName);
            sql += ", @slName = " + FilterString(trn.SenLastName);
            sql += ", @slName2 = " + FilterString(trn.SenLastName2);
            sql += ", @sIdType = " + FilterString(trn.SenIdType);
            sql += ", @sIdNo = " + FilterString(trn.SenIdNo);
            sql += ", @sIdValid = " + FilterString(trn.SenIdValid);
            sql += ", @sdob = " + FilterString(trn.SenDob);
            sql += ", @sTel = " + FilterString(trn.SenTel);
            sql += ", @sMobile = " + FilterString(trn.SenMobile);
            sql += ", @sNaCountry = " + FilterString(trn.SenNaCountry);
            sql += ", @scity = " + FilterString(trn.SenCity);
            sql += ", @sPostCode = " + FilterString(trn.SenPostCode);
            sql += ", @sAdd1 = " + FilterString(trn.SenAdd1);
            sql += ", @sAdd2 = " + FilterString(trn.SenAdd2);
            sql += ", @sEmail = " + FilterString(trn.SenEmail);
            sql += ", @smsSend = " + FilterString(trn.SmsSend);
            sql += ", @sgender = " + FilterString(trn.SenGender);
            sql += ", @memberCode = " + FilterString(trn.MemberCode);

            sql += ", @benId = " + FilterString(trn.ReceiverId);
            sql += ", @rfName = " + FilterString(trn.RecFirstName);
            sql += ", @rmName = " + FilterString(trn.RecMiddleName);
            sql += ", @rlName = " + FilterString(trn.RecLastName);
            sql += ", @rlName2 = " + FilterString(trn.RecLastName2);
            sql += ", @rIdType = " + FilterString(trn.RecIdType);
            sql += ", @rIdNo = " + FilterString(trn.RecIdNo);
            sql += ", @rIdValid = " + FilterString(trn.RecIdValid);
            sql += ", @rdob = " + FilterString(trn.RecDob);
            sql += ", @rTel = " + FilterString(trn.RecTel);
            sql += ", @rMobile = " + FilterString(trn.RecMobile);
            sql += ", @rNaCountry = " + FilterString(trn.RecNaCountry);
            sql += ", @rcity = " + FilterString(trn.RecCity);
            sql += ", @rPostCode = " + FilterString(trn.RecPostCode);
            sql += ", @rAdd1 = " + FilterString(trn.RecAdd1);
            sql += ", @rAdd2 = " + FilterString(trn.RecAdd2);
            sql += ", @rEmail = " + FilterString(trn.RecEmail);
            sql += ", @raccountNo = " + FilterString(trn.RecAccountNo);

            sql += ", @sCountryId = " + FilterString(trn.SCountryId);
            sql += ", @pCountry = " + FilterString(trn.RecCountry);
            sql += ", @pCountryId = " + FilterString(trn.RecCountryId);
            sql += ", @deliveryMethod = " + FilterString(trn.DeliveryMethod);
            sql += ", @deliveryMethodId = " + FilterString(trn.DeliveryMethodId);
            sql += ", @pBank = " + FilterString(trn.PBank);
            sql += ", @pBankName = " + FilterString(trn.PBankName);
            sql += ", @pBankBranch = " + FilterString(trn.PBankBranch);
            sql += ", @pBankBranchName = " + FilterString(trn.PBankBranchName);
            sql += ", @pAgent = " + FilterString(trn.PAgent);
            sql += ", @pAgentName = " + FilterString(trn.PAgentName);
            sql += ", @pBankType = " + FilterString(trn.PBankType);
            sql += ", @pCurr = " + FilterString(trn.PCurr);
            sql += ", @collCurr = " + FilterString(trn.CollCurr);
            sql += ", @cAmt = " + FilterString(trn.CollAmt);
            sql += ", @pAmt = " + FilterString(trn.PayoutAmt);
            sql += ", @tAmt = " + FilterString(trn.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(trn.ServiceCharge);
            sql += ", @discount = " + FilterString(trn.Discount);
            sql += ", @exRate = " + FilterString(trn.ExRate);
            sql += ", @schemeCode = " + FilterString(trn.SchemeCode);
            sql += ", @couponTranNo = " + FilterString(trn.CouponTranNo);
            sql += ", @purpose = " + FilterString(trn.PurposeOfRemittance);
            sql += ", @sourceOfFund = " + FilterString(trn.SourceOfFund);
            sql += ", @relationship = " + FilterString(trn.RelWithSender);
            sql += ", @occupation = " + FilterString(trn.Occupation);
            sql += ", @payMsg = " + FilterString(trn.PayoutMsg);
            sql += ", @company = " + FilterString(trn.Company);
            sql += ", @nCust = " + FilterString(trn.NCustomer);
            sql += ", @enrollCust = " + FilterString(trn.ECustomer);

            sql += ", @sBranch = " + FilterString(trn.SBranch);
            sql += ", @sAgent = " + FilterString(trn.SAgent);
            sql += ", @sSuperAgent = " + FilterString(trn.SSuperAgent);
            sql += ", @settlingAgent = " + FilterString(trn.SettlingAgent);

            //sql += ", @cwPwd = " + FilterString(trn.CwPwd);
            //sql += ", @ttName = " + FilterString(trn.TtName.Replace(";", "|")).Replace("|", ";");

            sql += ", @isManualSc = " + FilterString(trn.isManualSC);
            sql += ", @collMode = " + FilterString(trn.cashCollMode);
            sql += ", @manualSC = " + FilterString(trn.manualSC);
            sql += ", @payoutPartner = " + FilterString(trn.payoutPartner);
            sql += ", @sCustStreet = " + FilterString(trn.sCustStreet);
            sql += ", @sCustLocation = " + FilterString(trn.sCustLocation);
            sql += ", @sCustomerType = " + FilterString(trn.sCustomerType);
            sql += ", @sCustBusinessType = " + FilterString(trn.sCustBusinessType);
            sql += ", @sCustIdIssuedCountry = " + FilterString(trn.sCustIdIssuedCountry);
            sql += ", @sCustIdIssuedDate = " + FilterString(trn.sCustIdIssuedDate);
            sql += ", @receiverId = " + FilterString(trn.receiverId);
            sql += ", @introducer = " + FilterString(trn.introducer);
            sql += ", @controlNumber = " + FilterString(trn.controlNumber);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DataSet ValidateTransactionTP(IRHTranDetail trn)
        {
            var sql = "EXEC proc_sendIRHTP @flag = 'v'";

            sql += ", @user = " + FilterString(trn.User);
            sql += ", @agentRefId = " + FilterString(trn.AgentRefId);
            sql += ", @senderId = " + FilterString(trn.SenderId);
            sql += ", @sfName = " + FilterString(trn.SenFirstName);
            sql += ", @smName = " + FilterString(trn.SenMiddleName);
            sql += ", @slName = " + FilterString(trn.SenLastName);
            sql += ", @slName2 = " + FilterString(trn.SenLastName2);
            sql += ", @sIdType = " + FilterString(trn.SenIdType);
            sql += ", @sIdNo = " + FilterString(trn.SenIdNo);
            sql += ", @sIdValid = " + FilterString(trn.SenIdValid);
            sql += ", @sdob = " + FilterString(trn.SenDob);
            sql += ", @sTel = " + FilterString(trn.SenTel);
            sql += ", @sMobile = " + FilterString(trn.SenMobile);
            sql += ", @sNaCountry = " + FilterString(trn.SenNaCountry);
            sql += ", @scity = " + FilterString(trn.SenCity);
            sql += ", @sPostCode = " + FilterString(trn.SenPostCode);
            sql += ", @sAdd1 = " + FilterString(trn.SenAdd1);
            sql += ", @sAdd2 = " + FilterString(trn.SenAdd2);
            sql += ", @sEmail = " + FilterString(trn.SenEmail);
            sql += ", @smsSend = " + FilterString(trn.SmsSend);
            sql += ", @sgender = " + FilterString(trn.SenGender);
            sql += ", @memberCode = " + FilterString(trn.MemberCode);

            sql += ", @benId = " + FilterString(trn.ReceiverId);
            sql += ", @rfName = " + FilterString(trn.RecFirstName);
            sql += ", @rmName = " + FilterString(trn.RecMiddleName);
            sql += ", @rlName = " + FilterString(trn.RecLastName);
            sql += ", @rlName2 = " + FilterString(trn.RecLastName2);
            sql += ", @rIdType = " + FilterString(trn.RecIdType);
            sql += ", @rIdNo = " + FilterString(trn.RecIdNo);
            sql += ", @rIdValid = " + FilterString(trn.RecIdValid);
            sql += ", @rdob = " + FilterString(trn.RecDob);
            sql += ", @rTel = " + FilterString(trn.RecTel);
            sql += ", @rMobile = " + FilterString(trn.RecMobile);
            sql += ", @rNaCountry = " + FilterString(trn.RecNaCountry);
            sql += ", @rcity = " + FilterString(trn.RecCity);
            sql += ", @rPostCode = " + FilterString(trn.RecPostCode);
            sql += ", @rAdd1 = " + FilterString(trn.RecAdd1);
            sql += ", @rAdd2 = " + FilterString(trn.RecAdd2);
            sql += ", @rEmail = " + FilterString(trn.RecEmail);
            sql += ", @raccountNo = " + FilterString(trn.RecAccountNo);

            sql += ", @sCountryId = " + FilterString(trn.SCountryId);
            sql += ", @pCountry = " + FilterString(trn.RecCountry);
            sql += ", @pCountryId = " + FilterString(trn.RecCountryId);
            sql += ", @deliveryMethod = " + FilterString(trn.DeliveryMethod);
            sql += ", @deliveryMethodId = " + FilterString(trn.DeliveryMethodId);
            sql += ", @pBank = " + FilterString(trn.PBank);
            sql += ", @pBankName = " + FilterString(trn.PBankName);
            sql += ", @pBankBranch = " + FilterString(trn.PBankBranch);
            sql += ", @pBankBranchName = " + FilterString(trn.PBankBranchName);
            sql += ", @pAgent = " + FilterString(trn.PAgent);
            sql += ", @pAgentName = " + FilterString(trn.PAgentName);
            sql += ", @pBankType = " + FilterString(trn.PBankType);
            sql += ", @pCurr = " + FilterString(trn.PCurr);
            sql += ", @collCurr = " + FilterString(trn.CollCurr);
            sql += ", @cAmt = " + FilterString(trn.CollAmt);
            sql += ", @pAmt = " + FilterString(trn.PayoutAmt);
            sql += ", @tAmt = " + FilterString(trn.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(trn.ServiceCharge);
            sql += ", @discount = " + FilterString(trn.Discount);
            sql += ", @exRate = " + FilterString(trn.ExRate);
            sql += ", @schemeCode = " + FilterString(trn.SchemeCode);
            sql += ", @couponTranNo = " + FilterString(trn.CouponTranNo);
            sql += ", @purpose = '" + trn.PurposeOfRemittance + "'";
            sql += ", @sourceOfFund = '" + trn.SourceOfFund + "'";
            sql += ", @relationship = '" + trn.RelWithSender + "'";
            sql += ", @occupation = " + FilterString(trn.Occupation);
            sql += ", @payMsg = " + FilterString(trn.PayoutMsg);
            sql += ", @company = " + FilterString(trn.Company);
            sql += ", @nCust = " + FilterString(trn.NCustomer);
            sql += ", @enrollCust = " + FilterString(trn.ECustomer);

            sql += ", @sBranch = " + FilterString(trn.SBranch);
            sql += ", @sAgent = " + FilterString(trn.SAgent);
            sql += ", @sSuperAgent = " + FilterString(trn.SSuperAgent);
            sql += ", @settlingAgent = " + FilterString(trn.SettlingAgent);

            //sql += ", @cwPwd = " + FilterString(trn.CwPwd);
            //sql += ", @ttName = " + FilterString(trn.TtName.Replace(";", "|")).Replace("|", ";");
            sql += ", @calcBy = " + FilterString(trn.isAdditionalCDDI);

            sql += ", @isManualSc = " + FilterString(trn.isManualSC);
            sql += ", @collMode = " + FilterString(trn.cashCollMode);
            sql += ", @manualSC = " + FilterString(trn.manualSC);
            sql += ", @payoutPartner = " + FilterString(trn.payoutPartner);
            sql += ", @sCustStreet = " + FilterString(trn.sCustStreet);
            sql += ", @sCustLocation = " + FilterString(trn.sCustLocation);
            sql += ", @sCustomerType = " + FilterString(trn.sCustomerType);
            sql += ", @sCustBusinessType = " + FilterString(trn.sCustBusinessType);
            sql += ", @sCustIdIssuedCountry = " + FilterString(trn.sCustIdIssuedCountry);
            sql += ", @sCustIdIssuedDate = " + FilterString(trn.sCustIdIssuedDate);
            sql += ", @receiverId = " + FilterString(trn.receiverId);
            sql += ", @introducer = " + FilterString(trn.introducer);
            sql += ", @isAdditionalCDDI = " + FilterString(trn.calcBy);
            sql += ", @additionalCDDIXml = '" + trn.CDDIXml + "'";

            sql += ", @tpExRate = " + FilterString(trn.tpExRate);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DbResult SendTransaction(IRHTranDetail trn)
        {
            var sql = "EXEC proc_sendIRH @flag = 'i'";

            sql += ", @user = " + FilterString(trn.User);
            sql += ", @txnPWD = " + FilterString(trn.TxnPassword);
            sql += ", @agentRefId = " + FilterString(trn.AgentRefId);
            sql += ", @sBranch = " + FilterString(trn.SBranch);
            sql += ", @senderId = " + FilterString(trn.SenderId);
            sql += ", @sfName = " + FilterString(trn.SenFirstName);
            sql += ", @smName = " + FilterString(trn.SenMiddleName);
            sql += ", @slName = " + FilterString(trn.SenLastName);
            sql += ", @slName2 = " + FilterString(trn.SenLastName2);
            sql += ", @sIdType = " + FilterString(trn.SenIdType);
            sql += ", @sIdNo = " + FilterString(trn.SenIdNo);
            sql += ", @sIdValid = " + FilterString(trn.SenIdValid);
            sql += ", @sdob = " + FilterString(trn.SenDob);
            sql += ", @sTel = " + FilterString(trn.SenTel);
            sql += ", @sMobile = " + FilterString(trn.SenMobile);
            sql += ", @sNaCountry = " + FilterString(trn.SenNaCountry);
            sql += ", @scity = " + FilterString(trn.SenCity);
            sql += ", @sPostCode = " + FilterString(trn.SenPostCode);
            sql += ", @sAdd1 = " + FilterString(trn.SenAdd1);
            sql += ", @sAdd2 = " + FilterString(trn.SenAdd2);
            sql += ", @sEmail = " + FilterString(trn.SenEmail);
            sql += ", @smsSend = " + FilterString(trn.SmsSend);
            sql += ", @sgender = " + FilterString(trn.SenGender);
            sql += ", @memberCode = " + FilterString(trn.MemberCode);
            sql += ", @sCompany = " + FilterString(trn.SenCompany);

            sql += ", @benId = " + FilterString(trn.ReceiverId);
            sql += ", @rfName = " + FilterString(trn.RecFirstName);
            sql += ", @rmName = " + FilterString(trn.RecMiddleName);
            sql += ", @rlName = " + FilterString(trn.RecLastName);
            sql += ", @rlName2 = " + FilterString(trn.RecLastName2);
            sql += ", @rIdType = " + FilterString(trn.RecIdType);
            sql += ", @rIdNo = " + FilterString(trn.RecIdNo);
            sql += ", @rIdValid = " + FilterString(trn.RecIdValid);
            sql += ", @rdob = " + FilterString(trn.RecDob);
            sql += ", @rTel = " + FilterString(trn.RecTel);
            sql += ", @rMobile = " + FilterString(trn.RecMobile);
            sql += ", @rNaCountry = " + FilterString(trn.RecNaCountry);
            sql += ", @rcity = " + FilterString(trn.RecCity);
            sql += ", @rPostCode = " + FilterString(trn.RecPostCode);
            sql += ", @rAdd1 = " + FilterString(trn.RecAdd1);
            sql += ", @rAdd2 = " + FilterString(trn.RecAdd2);
            sql += ", @rEmail = " + FilterString(trn.RecEmail);
            sql += ", @raccountNo = " + FilterString(trn.RecAccountNo);
            sql += ", @rGender = " + FilterString(trn.RecGender);

            sql += ", @pCountry = " + FilterString(trn.RecCountry);
            sql += ", @pCountryId = " + FilterString(trn.RecCountryId);
            sql += ", @deliveryMethod = " + FilterString(trn.DeliveryMethod);
            sql += ", @deliveryMethodId = " + FilterString(trn.DeliveryMethodId);
            sql += ", @pBank = " + FilterString(trn.PBank);
            sql += ", @pBankName = " + FilterString(trn.PBankName);
            sql += ", @pBankBranch = " + FilterString(trn.PBankBranch);
            sql += ", @pBankBranchName = " + FilterString(trn.PBankBranchName);

            sql += ", @pAgent = " + FilterString(trn.PAgent);
            sql += ", @pAgentName = " + FilterString(trn.PAgentName);
            sql += ", @pBankType = " + FilterString(trn.PBankType);

            sql += ", @pCurr = " + FilterString(trn.PCurr);
            sql += ", @collCurr = " + FilterString(trn.CollCurr);
            sql += ", @cAmt = " + FilterString(trn.CollAmt);
            sql += ", @pAmt = " + FilterString(trn.PayoutAmt);
            sql += ", @tAmt = " + FilterString(trn.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(trn.ServiceCharge);
            sql += ", @discount = " + FilterString(trn.Discount);
            sql += ", @exRate = " + FilterString(trn.ExRate);
            sql += ", @schemeCode = " + FilterString(trn.SchemeCode);
            sql += ", @couponTranNo = " + FilterString(trn.CouponTranNo);
            sql += ", @purpose = " + FilterString(trn.PurposeOfRemittance);
            sql += ", @sourceOfFund = " + FilterString(trn.SourceOfFund);
            sql += ", @relationship = " + FilterString(trn.RelWithSender);
            sql += ", @occupation = " + FilterString(trn.Occupation);
            sql += ", @payMsg = " + FilterString(trn.PayoutMsg);
            sql += ", @company = " + FilterString(trn.Company);
            sql += ", @nCust = " + FilterString(trn.NCustomer);
            sql += ", @enrollCust = " + FilterString(trn.ECustomer);

            sql += ", @salaryRange = " + FilterString(trn.Salary);
            sql += ", @salary = " + FilterString(trn.Salary);

            sql += ", @sBranchName = " + FilterString(trn.SBranchName);
            sql += ", @sAgent = " + FilterString(trn.SAgent);
            sql += ", @sAgentName = " + FilterString(trn.SAgentName);
            sql += ", @sSuperAgent = " + FilterString(trn.SSuperAgent);
            sql += ", @sSuperAgentName = " + FilterString(trn.SSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(trn.SettlingAgent);
            sql += ", @sCountry = " + FilterString(trn.SCountry);
            sql += ", @sCountryId = " + FilterString(trn.SCountryId);
            sql += ", @sessionId = " + FilterString(trn.SessionId);
            sql += ", @cancelrequestId = " + FilterString(trn.CancelRequestId);

            sql += ", @cwPwd = " + FilterString(trn.CwPwd);
            sql += ", @ttName = " + FilterString(trn.TtName.Replace(";", "|")).Replace("|", ";");

            sql += ", @ofacRes = " + FilterString(trn.OfacRes);
            sql += ", @sDcInfo = " + FilterString(trn.DcInfo);
            sql += ", @sIpAddress = " + FilterString(trn.IpAddress);

            return ParseDbResult(sql);
        }

        public DataSet GetAllTranInformation(string senderId, string benId, string agentId, string pCountry, string user)
        {
            var sql = "EXEC proc_sendIRH @flag = 'cti'";
            sql += ", @user = " + FilterString(user);
            sql += ", @senderId = " + FilterString(senderId);
            sql += ", @benId = " + FilterString(benId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @pCountry = " + FilterString(pCountry);

            return ExecuteDataset(sql);
        }

        public DataTable RBAScreening(string customerId, string cAmt, string user, string sNativeCountry, string agentRefId)
        {
            var sql = "EXEC proc_RBA @flag = 'rba'";
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @cAmt = " + FilterString(cAmt);
            sql += ", @countryName = " + FilterString(sNativeCountry);
            sql += ", @user = " + FilterString(user);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            return ExecuteDataTable(sql);
        }

        public DbResult SendTransactionIRHNew(IRHTranDetail trn)
        {
            var sql = "EXEC proc_sendIRHTP @flag = 'i'";

            sql += ", @user = " + FilterString(trn.User);
            sql += ", @txnPWD = " + FilterString(trn.TxnPassword);
            sql += ", @agentRefId = " + FilterString(trn.AgentRefId);
            sql += ", @sBranch = " + FilterString(trn.SBranch);
            sql += ", @senderId = " + FilterString(trn.SenderId);
            sql += ", @sfName = " + FilterString(trn.SenFirstName);
            sql += ", @smName = " + FilterString(trn.SenMiddleName);
            sql += ", @slName = " + FilterString(trn.SenLastName);
            sql += ", @slName2 = " + FilterString(trn.SenLastName2);
            sql += ", @sIdType = " + FilterString(trn.SenIdType);
            sql += ", @sIdNo = " + FilterString(trn.SenIdNo);
            sql += ", @sIdValid = " + FilterString(trn.SenIdValid);
            sql += ", @sdob = " + FilterString(trn.SenDob);
            sql += ", @sTel = " + FilterString(trn.SenTel);
            sql += ", @sMobile = " + FilterString(trn.SenMobile);
            sql += ", @sNaCountry = " + FilterString(trn.SenNaCountry);
            sql += ", @scity = " + FilterString(trn.SenCity);
            sql += ", @sPostCode = " + FilterString(trn.SenPostCode);
            sql += ", @sAdd1 = " + FilterString(trn.SenAdd1);
            sql += ", @sAdd2 = " + FilterString(trn.SenAdd2);
            sql += ", @sEmail = " + FilterString(trn.SenEmail);
            sql += ", @smsSend = " + FilterString(trn.SmsSend);
            sql += ", @sgender = " + FilterString(trn.SenGender);
            sql += ", @memberCode = " + FilterString(trn.MemberCode);
            sql += ", @sCompany = " + FilterString(trn.SenCompany);
            sql += ", @calcBy = " + FilterString(trn.calcBy);

            sql += ", @benId = " + FilterString(trn.ReceiverId);
            sql += ", @rfName = " + FilterString(trn.RecFirstName);
            sql += ", @rmName = " + FilterString(trn.RecMiddleName);
            sql += ", @rlName = " + FilterString(trn.RecLastName);
            sql += ", @rlName2 = " + FilterString(trn.RecLastName2);
            sql += ", @rIdType = " + FilterString(trn.RecIdType);
            sql += ", @rIdNo = " + FilterString(trn.RecIdNo);
            sql += ", @rIdValid = " + FilterString(trn.RecIdValid);
            sql += ", @rdob = " + FilterString(trn.RecDob);
            sql += ", @rTel = " + FilterString(trn.RecTel);
            sql += ", @rMobile = " + FilterString(trn.RecMobile);
            sql += ", @rNaCountry = " + FilterString(trn.RecNaCountry);
            sql += ", @rcity = " + FilterString(trn.RecCity);
            sql += ", @rPostCode = " + FilterString(trn.RecPostCode);
            sql += ", @rAdd1 = " + FilterString(trn.RecAdd1);
            sql += ", @rAdd2 = " + FilterString(trn.RecAdd2);
            sql += ", @rEmail = " + FilterString(trn.RecEmail);
            sql += ", @raccountNo = " + FilterString(trn.RecAccountNo);
            sql += ", @rGender = " + FilterString(trn.RecGender);

            sql += ", @pCountry = " + FilterString(trn.RecCountry);
            sql += ", @pCountryId = " + FilterString(trn.RecCountryId);
            sql += ", @deliveryMethod = " + FilterString(trn.DeliveryMethod);
            sql += ", @deliveryMethodId = " + FilterString(trn.DeliveryMethodId);
            sql += ", @pBank = " + FilterString(trn.PBank);
            sql += ", @pBankName = " + FilterString(trn.PBankName);
            sql += ", @pBankBranch = " + FilterString(trn.PBankBranch);
            sql += ", @pBankBranchName = " + FilterString(trn.PBankBranchName);

            sql += ", @pAgent = " + FilterString(trn.PAgent);
            sql += ", @pAgentName = " + FilterString(trn.PAgentName);
            sql += ", @pBankType = " + FilterString(trn.PBankType);

            sql += ", @pCurr = " + FilterString(trn.PCurr);
            sql += ", @collCurr = " + FilterString(trn.CollCurr);
            sql += ", @cAmt = " + FilterString(trn.CollAmt);
            sql += ", @pAmt = " + FilterString(trn.PayoutAmt);
            sql += ", @tAmt = " + FilterString(trn.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(trn.ServiceCharge);
            sql += ", @discount = " + FilterString(trn.Discount);
            sql += ", @exRate = " + FilterString(trn.ExRate);
            sql += ", @schemeCode = " + FilterString(trn.SchemeCode);
            sql += ", @couponTranNo = " + FilterString(trn.CouponTranNo);

            sql += ", @purpose = '" + trn.PurposeOfRemittance + "'";
            sql += ", @sourceOfFund = '" + trn.SourceOfFund + "'";
            sql += ", @relationship = '" + trn.RelWithSender + "'";

            sql += ", @occupation = " + FilterString(trn.Occupation);
            sql += ", @payMsg = " + FilterString(trn.PayoutMsg);
            sql += ", @company = " + FilterString(trn.Company);
            sql += ", @nCust = " + FilterString(trn.NCustomer);
            sql += ", @enrollCust = " + FilterString(trn.ECustomer);

            sql += ", @salaryRange = " + FilterString(trn.Salary);
            sql += ", @salary = " + FilterString(trn.Salary);

            sql += ", @RBATxnRisk = " + FilterString(trn.RBATxnRisk);
            sql += ", @RBACustomerRisk = " + FilterString(trn.RBACustomerRisk);
            sql += ", @RBACustomerRiskValue = " + FilterString(trn.RBACustomerRiskValue);

            sql += ", @sBranchName = " + FilterString(trn.SBranchName);
            sql += ", @sAgent = " + FilterString(trn.SAgent);
            sql += ", @sAgentName = " + FilterString(trn.SAgentName);
            sql += ", @sSuperAgent = " + FilterString(trn.SSuperAgent);
            sql += ", @sSuperAgentName = " + FilterString(trn.SSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(trn.SettlingAgent);
            sql += ", @sCountry = " + FilterString(trn.SCountry);
            sql += ", @sCountryId = " + FilterString(trn.SCountryId);
            sql += ", @sessionId = " + FilterString(trn.SessionId);
            sql += ", @cancelrequestId = " + FilterString(trn.CancelRequestId);

            sql += ", @ofacRes = " + FilterString(trn.OfacRes);
            sql += ", @sDcInfo = " + FilterString(trn.DcInfo);
            sql += ", @sIpAddress = " + FilterString(trn.IpAddress);
            //sql += ", @voucherDetails = '" + trn.VoucherDetail + "'";

            sql += ", @pLocation = '" + trn.pStateId + "'";
            sql += ", @pLocationText = '" + trn.pStateName + "'";
            sql += ", @pSubLocation = '" + trn.pCityId + "'";
            sql += ", @pSubLocationText = '" + trn.pCityName + "'";
            sql += ", @pTownId = '" + trn.pTownId + "'";

            sql += ", @isManualSC = " + FilterString(trn.isManualSC);
            sql += ", @manualSC = " + FilterString(trn.manualSC);
            sql += ", @sCustStreet = " + FilterString(trn.sCustStreet);
            sql += ", @sCustLocation = " + FilterString(trn.sCustLocation);
            sql += ", @sCustomerType = " + FilterString(trn.sCustomerType);
            sql += ", @sCustBusinessType = " + FilterString(trn.sCustBusinessType);
            sql += ", @sCustIdIssuedCountry = " + FilterString(trn.sCustIdIssuedCountry);
            sql += ", @sCustIdIssuedDate = " + FilterString(trn.sCustIdIssuedDate);
            sql += ", @receiverId = " + FilterString(trn.receiverId);
            sql += ", @payoutPartner = " + FilterString(trn.payoutPartner);
            sql += ", @collMode = " + FilterString(trn.cashCollMode);
            sql += ", @customerDepositedBank = " + FilterString(trn.customerDepositedBank);
            sql += ", @introducer = " + FilterString(trn.introducer);
            sql += ", @isOnbehalf = " + FilterString(trn.IsOnBehalf);
            sql += ", @payerId = " + FilterString(trn.PayerId);
            sql += ", @payerBranchId = " + FilterString(trn.PayerBranchId);
            sql += ", @IsFromTabPage = " + FilterString(trn.IsFromTabPage);
            sql += ", @customerPassword = " + FilterString(trn.CustomerPassword);
            sql += ", @isAdditionalCDDI = " + FilterString(trn.isAdditionalCDDI);
            sql += ", @additionalCDDIXml = '" + trn.CDDIXml + "'";

            sql += ", @tpRefNo = " + FilterString(trn.tpRefNo) + "";
            sql += ", @tpTranId = " + FilterString(trn.tpTranId) + "";
            sql += ", @tpRefNo2 = " + FilterString(trn.tpRefNo2) + "";
            sql += ", @promotionCode = " + FilterString(trn.promotionCode);
            sql += ", @promotionAmount = " + FilterString(trn.promotionAmount);

            sql += ", @tpExRate = " + FilterString(trn.tpExRate);

            return ParseDbResultV2(sql);
        }

        public DbResult SendTransactionIRH(IRHTranDetail trn)
        {
            var sql = "EXEC proc_sendIRH @flag = 'i'";

            sql += ", @user = " + FilterString(trn.User);
            sql += ", @txnPWD = " + FilterString(trn.TxnPassword);
            sql += ", @agentRefId = " + FilterString(trn.AgentRefId);
            sql += ", @sBranch = " + FilterString(trn.SBranch);
            sql += ", @senderId = " + FilterString(trn.SenderId);
            sql += ", @sfName = " + FilterString(trn.SenFirstName);
            sql += ", @smName = " + FilterString(trn.SenMiddleName);
            sql += ", @slName = " + FilterString(trn.SenLastName);
            sql += ", @slName2 = " + FilterString(trn.SenLastName2);
            sql += ", @sIdType = " + FilterString(trn.SenIdType);
            sql += ", @sIdNo = " + FilterString(trn.SenIdNo);
            sql += ", @sIdValid = " + FilterString(trn.SenIdValid);
            sql += ", @sdob = " + FilterString(trn.SenDob);
            sql += ", @sTel = " + FilterString(trn.SenTel);
            sql += ", @sMobile = " + FilterString(trn.SenMobile);
            sql += ", @sNaCountry = " + FilterString(trn.SenNaCountry);
            sql += ", @scity = " + FilterString(trn.SenCity);
            sql += ", @sPostCode = " + FilterString(trn.SenPostCode);
            sql += ", @sAdd1 = " + FilterString(trn.SenAdd1);
            sql += ", @sAdd2 = " + FilterString(trn.SenAdd2);
            sql += ", @sEmail = " + FilterString(trn.SenEmail);
            sql += ", @smsSend = " + FilterString(trn.SmsSend);
            sql += ", @sgender = " + FilterString(trn.SenGender);
            sql += ", @memberCode = " + FilterString(trn.MemberCode);
            sql += ", @sCompany = " + FilterString(trn.SenCompany);
            sql += ", @calcBy = " + FilterString(trn.calcBy);
            sql += ", @benId = " + FilterString(trn.ReceiverId);
            sql += ", @rfName = " + FilterString(trn.RecFirstName);
            sql += ", @rmName = " + FilterString(trn.RecMiddleName);
            sql += ", @rlName = " + FilterString(trn.RecLastName);
            sql += ", @rlName2 = " + FilterString(trn.RecLastName2);
            sql += ", @rIdType = " + FilterString(trn.RecIdType);
            sql += ", @rIdNo = " + FilterString(trn.RecIdNo);
            sql += ", @rIdValid = " + FilterString(trn.RecIdValid);
            sql += ", @rdob = " + FilterString(trn.RecDob);
            sql += ", @rTel = " + FilterString(trn.RecTel);
            sql += ", @rMobile = " + FilterString(trn.RecMobile);
            sql += ", @rNaCountry = " + FilterString(trn.RecNaCountry);
            sql += ", @rcity = " + FilterString(trn.RecCity);
            sql += ", @rPostCode = " + FilterString(trn.RecPostCode);
            sql += ", @rAdd1 = " + FilterString(trn.RecAdd1);
            sql += ", @rAdd2 = " + FilterString(trn.RecAdd2);
            sql += ", @rEmail = " + FilterString(trn.RecEmail);
            sql += ", @raccountNo = " + FilterString(trn.RecAccountNo);
            sql += ", @rGender = " + FilterString(trn.RecGender);

            sql += ", @pCountry = " + FilterString(trn.RecCountry);
            sql += ", @pCountryId = " + FilterString(trn.RecCountryId);
            sql += ", @deliveryMethod = " + FilterString(trn.DeliveryMethod);
            sql += ", @deliveryMethodId = " + FilterString(trn.DeliveryMethodId);
            sql += ", @pBank = " + FilterString(trn.PBank);
            sql += ", @pBankName = " + FilterString(trn.PBankName);
            sql += ", @pBankBranch = " + FilterString(trn.PBankBranch);
            sql += ", @pBankBranchName = " + FilterString(trn.PBankBranchName);

            sql += ", @pAgent = " + FilterString(trn.PAgent);
            sql += ", @pAgentName = " + FilterString(trn.PAgentName);
            sql += ", @pBankType = " + FilterString(trn.PBankType);

            sql += ", @pCurr = " + FilterString(trn.PCurr);
            sql += ", @collCurr = " + FilterString(trn.CollCurr);
            sql += ", @cAmt = " + FilterString(trn.CollAmt);
            sql += ", @pAmt = " + FilterString(trn.PayoutAmt);
            sql += ", @tAmt = " + FilterString(trn.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(trn.ServiceCharge);
            sql += ", @discount = " + FilterString(trn.Discount);
            sql += ", @exRate = " + FilterString(trn.ExRate);
            sql += ", @schemeCode = " + FilterString(trn.SchemeCode);
            sql += ", @couponTranNo = " + FilterString(trn.CouponTranNo);

            sql += ", @purpose = '" + trn.PurposeOfRemittance + "'";
            sql += ", @sourceOfFund = '" + trn.SourceOfFund + "'";
            sql += ", @relationship = '" + trn.RelWithSender + "'";

            sql += ", @occupation = " + FilterString(trn.Occupation);
            sql += ", @payMsg = " + FilterString(trn.PayoutMsg);
            sql += ", @company = " + FilterString(trn.Company);
            sql += ", @nCust = " + FilterString(trn.NCustomer);
            sql += ", @enrollCust = " + FilterString(trn.ECustomer);

            sql += ", @salaryRange = " + FilterString(trn.Salary);
            sql += ", @salary = " + FilterString(trn.Salary);

            sql += ", @RBATxnRisk = " + FilterString(trn.RBATxnRisk);
            sql += ", @RBACustomerRisk = " + FilterString(trn.RBACustomerRisk);
            sql += ", @RBACustomerRiskValue = " + FilterString(trn.RBACustomerRiskValue);

            sql += ", @sBranchName = " + FilterString(trn.SBranchName);
            sql += ", @sAgent = " + FilterString(trn.SAgent);
            sql += ", @sAgentName = " + FilterString(trn.SAgentName);
            sql += ", @sSuperAgent = " + FilterString(trn.SSuperAgent);
            sql += ", @sSuperAgentName = " + FilterString(trn.SSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(trn.SettlingAgent);
            sql += ", @sCountry = " + FilterString(trn.SCountry);
            sql += ", @sCountryId = " + FilterString(trn.SCountryId);
            sql += ", @sessionId = " + FilterString(trn.SessionId);
            sql += ", @cancelrequestId = " + FilterString(trn.CancelRequestId);

            sql += ", @ofacRes = " + FilterString(trn.OfacRes);
            sql += ", @sDcInfo = " + FilterString(trn.DcInfo);
            sql += ", @sIpAddress = " + FilterString(trn.IpAddress);
            //sql += ", @voucherDetails = '" + trn.VoucherDetail + "'";

            sql += ", @pLocation = '" + trn.pStateId + "'";
            sql += ", @pLocationText = '" + trn.pStateName + "'";
            sql += ", @pSubLocation = '" + trn.pCityId + "'";
            sql += ", @pSubLocationText = '" + trn.pCityName + "'";
            sql += ", @pTownId = '" + trn.pTownId + "'";

            sql += ", @isManualSC = " + FilterString(trn.isManualSC);
            sql += ", @manualSC = " + FilterString(trn.manualSC);
            sql += ", @sCustStreet = " + FilterString(trn.sCustStreet);
            sql += ", @sCustLocation = " + FilterString(trn.sCustLocation);
            sql += ", @sCustomerType = " + FilterString(trn.sCustomerType);
            sql += ", @sCustBusinessType = " + FilterString(trn.sCustBusinessType);
            sql += ", @sCustIdIssuedCountry = " + FilterString(trn.sCustIdIssuedCountry);
            sql += ", @sCustIdIssuedDate = " + FilterString(trn.sCustIdIssuedDate);
            sql += ", @receiverId = " + FilterString(trn.receiverId);
            sql += ", @payoutPartner = " + FilterString(trn.payoutPartner);
            sql += ", @collMode = " + FilterString(trn.cashCollMode);
            sql += ", @customerDepositedBank = " + FilterString(trn.customerDepositedBank);
            sql += ", @introducer = " + FilterString(trn.introducer);
            sql += ", @isOnbehalf = " + FilterString(trn.IsOnBehalf);
            sql += ", @payerId = " + FilterString(trn.PayerId);
            sql += ", @payerBranchId = " + FilterString(trn.PayerBranchId);
            sql += ", @IsFromTabPage = " + FilterString(trn.IsFromTabPage);
            sql += ", @customerPassword = " + FilterString(trn.CustomerPassword);
            sql += ", @isAdditionalCDDI = " + FilterString(trn.isAdditionalCDDI);
            sql += ", @promotionCode = " + FilterString(trn.promotionCode);
            sql += ", @promotionAmount = " + FilterString(trn.promotionAmount);
            sql += ", @complianceQuestion='" + trn.ComplaincrDataStr + "'";
            sql += ", @additionalCDDIXml = '" + trn.CDDIXml + "'";

            return ParseDbResult(sql);
        }

        public DbResult SendTransactionIRHNew1(IRHTranDetail trn)
        {
            var sql = "EXEC proc_sendIRHNew @flag = 'i'";

            sql += ", @user = " + FilterString(trn.User);
            sql += ", @txnPWD = " + FilterString(trn.TxnPassword);
            sql += ", @agentRefId = " + FilterString(trn.AgentRefId);
            sql += ", @sBranch = " + FilterString(trn.SBranch);
            sql += ", @senderId = " + FilterString(trn.SenderId);
            sql += ", @sfName = " + FilterString(trn.SenFirstName);
            sql += ", @smName = " + FilterString(trn.SenMiddleName);
            sql += ", @slName = " + FilterString(trn.SenLastName);
            sql += ", @slName2 = " + FilterString(trn.SenLastName2);
            sql += ", @sIdType = " + FilterString(trn.SenIdType);
            sql += ", @sIdNo = " + FilterString(trn.SenIdNo);
            sql += ", @sIdValid = " + FilterString(trn.SenIdValid);
            sql += ", @sdob = " + FilterString(trn.SenDob);
            sql += ", @sTel = " + FilterString(trn.SenTel);
            sql += ", @sMobile = " + FilterString(trn.SenMobile);
            sql += ", @sNaCountry = " + FilterString(trn.SenNaCountry);
            sql += ", @scity = " + FilterString(trn.SenCity);
            sql += ", @sPostCode = " + FilterString(trn.SenPostCode);
            sql += ", @sAdd1 = " + FilterString(trn.SenAdd1);
            sql += ", @sAdd2 = " + FilterString(trn.SenAdd2);
            sql += ", @sEmail = " + FilterString(trn.SenEmail);
            sql += ", @smsSend = " + FilterString(trn.SmsSend);
            sql += ", @sgender = " + FilterString(trn.SenGender);
            sql += ", @memberCode = " + FilterString(trn.MemberCode);
            sql += ", @sCompany = " + FilterString(trn.SenCompany);

            sql += ", @benId = " + FilterString(trn.ReceiverId);
            sql += ", @rfName = " + FilterString(trn.RecFirstName);
            sql += ", @rmName = " + FilterString(trn.RecMiddleName);
            sql += ", @rlName = " + FilterString(trn.RecLastName);
            sql += ", @rlName2 = " + FilterString(trn.RecLastName2);
            sql += ", @rIdType = " + FilterString(trn.RecIdType);
            sql += ", @rIdNo = " + FilterString(trn.RecIdNo);
            sql += ", @rIdValid = " + FilterString(trn.RecIdValid);
            sql += ", @rdob = " + FilterString(trn.RecDob);
            sql += ", @rTel = " + FilterString(trn.RecTel);
            sql += ", @rMobile = " + FilterString(trn.RecMobile);
            sql += ", @rNaCountry = " + FilterString(trn.RecNaCountry);
            sql += ", @rcity = " + FilterString(trn.RecCity);
            sql += ", @rPostCode = " + FilterString(trn.RecPostCode);
            sql += ", @rAdd1 = " + FilterString(trn.RecAdd1);
            sql += ", @rAdd2 = " + FilterString(trn.RecAdd2);
            sql += ", @rEmail = " + FilterString(trn.RecEmail);
            sql += ", @raccountNo = " + FilterString(trn.RecAccountNo);
            sql += ", @rGender = " + FilterString(trn.RecGender);

            sql += ", @pCountry = " + FilterString(trn.RecCountry);
            sql += ", @pCountryId = " + FilterString(trn.RecCountryId);
            sql += ", @deliveryMethod = " + FilterString(trn.DeliveryMethod);
            sql += ", @deliveryMethodId = " + FilterString(trn.DeliveryMethodId);
            sql += ", @pBank = " + FilterString(trn.PBank);
            sql += ", @pBankName = " + FilterString(trn.PBankName);
            sql += ", @pBankBranch = " + FilterString(trn.PBankBranch);
            sql += ", @pBankBranchName = " + FilterString(trn.PBankBranchName);

            sql += ", @pAgent = " + FilterString(trn.PAgent);
            sql += ", @pAgentName = " + FilterString(trn.PAgentName);
            sql += ", @pBankType = " + FilterString(trn.PBankType);

            sql += ", @pCurr = " + FilterString(trn.PCurr);
            sql += ", @collCurr = " + FilterString(trn.CollCurr);
            sql += ", @cAmt = " + FilterString(trn.CollAmt);
            sql += ", @pAmt = " + FilterString(trn.PayoutAmt);
            sql += ", @tAmt = " + FilterString(trn.TransferAmt);
            sql += ", @serviceCharge = " + FilterString(trn.ServiceCharge);
            sql += ", @discount = " + FilterString(trn.Discount);
            sql += ", @exRate = " + FilterString(trn.ExRate);
            sql += ", @schemeCode = " + FilterString(trn.SchemeCode);
            sql += ", @couponTranNo = " + FilterString(trn.CouponTranNo);
            sql += ", @purpose = " + FilterString(trn.PurposeOfRemittance);
            sql += ", @sourceOfFund = " + FilterString(trn.SourceOfFund);
            sql += ", @relationship = " + FilterString(trn.RelWithSender);
            sql += ", @occupation = " + FilterString(trn.Occupation);
            sql += ", @payMsg = " + FilterString(trn.PayoutMsg);
            sql += ", @company = " + FilterString(trn.Company);
            sql += ", @nCust = " + FilterString(trn.NCustomer);
            sql += ", @enrollCust = " + FilterString(trn.ECustomer);

            sql += ", @salaryRange = " + FilterString(trn.Salary);
            sql += ", @salary = " + FilterString(trn.Salary);

            sql += ", @RBATxnRisk = " + FilterString(trn.RBATxnRisk);
            sql += ", @RBACustomerRisk = " + FilterString(trn.RBACustomerRisk);
            sql += ", @RBACustomerRiskValue = " + FilterString(trn.RBACustomerRiskValue);

            sql += ", @sBranchName = " + FilterString(trn.SBranchName);
            sql += ", @sAgent = " + FilterString(trn.SAgent);
            sql += ", @sAgentName = " + FilterString(trn.SAgentName);
            sql += ", @sSuperAgent = " + FilterString(trn.SSuperAgent);
            sql += ", @sSuperAgentName = " + FilterString(trn.SSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(trn.SettlingAgent);
            sql += ", @sCountry = " + FilterString(trn.SCountry);
            sql += ", @sCountryId = " + FilterString(trn.SCountryId);
            sql += ", @sessionId = " + FilterString(trn.SessionId);
            sql += ", @cancelrequestId = " + FilterString(trn.CancelRequestId);

            sql += ", @ofacRes = " + FilterString(trn.OfacRes);
            sql += ", @sDcInfo = " + FilterString(trn.DcInfo);
            sql += ", @sIpAddress = " + FilterString(trn.IpAddress);
            //sql += ", @voucherDetails = '" + trn.VoucherDetail + "'";

            sql += ", @pLocation = '" + trn.pStateId + "'";
            sql += ", @pLocationText = '" + trn.pStateName + "'";
            sql += ", @pSubLocation = '" + trn.pCityId + "'";
            sql += ", @pSubLocationText = '" + trn.pCityName + "'";
            sql += ", @pTownId = '" + trn.pTownId + "'";

            sql += ", @isManualSC = " + FilterString(trn.isManualSC);
            sql += ", @manualSC = " + FilterString(trn.manualSC);
            sql += ", @sCustStreet = " + FilterString(trn.sCustStreet);
            sql += ", @sCustLocation = " + FilterString(trn.sCustLocation);
            sql += ", @sCustomerType = " + FilterString(trn.sCustomerType);
            sql += ", @sCustBusinessType = " + FilterString(trn.sCustBusinessType);
            sql += ", @sCustIdIssuedCountry = " + FilterString(trn.sCustIdIssuedCountry);
            sql += ", @sCustIdIssuedDate = " + FilterString(trn.sCustIdIssuedDate);
            sql += ", @receiverId = " + FilterString(trn.receiverId);
            sql += ", @payoutPartner = " + FilterString(trn.payoutPartner);
            sql += ", @collMode = " + FilterString(trn.cashCollMode);
            sql += ", @customerDepositedBank = " + FilterString(trn.customerDepositedBank);
            sql += ", @introducer = " + FilterString(trn.introducer);
            sql += ", @isOnbehalf = " + FilterString(trn.IsOnBehalf);
            sql += ", @payerId = " + FilterString(trn.PayerId);
            sql += ", @payerBranchId = " + FilterString(trn.PayerBranchId);
            sql += ", @IsFromTabPage = " + FilterString(trn.IsFromTabPage);
            sql += ", @customerPassword = " + FilterString(trn.CustomerPassword);
            sql += ", @controlNumber = " + FilterString(trn.controlNumber);
            sql += ", @isAdditionalCDDI = " + FilterString(trn.isAdditionalCDDI);
            sql += ", @additionalCDDIXml = '" + trn.CDDIXml + "'";

            return ParseDbResult(sql);
        }

        #endregion Transaction Validation and Send Part

        public DataTable GetPayoutLocation(string pCountry, string pMode, string PartnerId)
        {
            var sql = "EXEC proc_sendPageLoadData @flag = 'state'";
            sql += ", @pCountryName = " + FilterString(pCountry);
            sql += ", @partnerId = " + FilterString(PartnerId);
            sql += ", @pMode = " + FilterString(pMode);

            return ExecuteDataTable(sql);
        }

        public DataTable GetPayoutSubLocation(string pLocation)
        {
            var sql = "EXEC proc_sendPageLoadData @flag = 'city'";
            sql += ", @pLocation = " + FilterString(pLocation);

            return ExecuteDataTable(sql);
        }

        public DataSet LoadQuestionaries(string user)
        {
            var sql = "EXEC PROC_COMPLIANCE_QUESTION @flag='0'";
            sql += ", @user = " + FilterString(user);
            sql += ", @requestFrom ='core' ";

            return ExecuteDataset(sql);
        }

        public DataTable GetPayoutTownLocation(string subLocation)
        {
            var sql = "EXEC proc_sendPageLoadData @flag = 'town'";
            sql += ", @subLocation = " + FilterString(subLocation);

            return ExecuteDataTable(sql);
        }

        public DbResult UpdateTPTxns(IRHTranDetail trn, string controlNo, string user)
        {
            var sql = "EXEC proc_sendIRHTP @flag = 'success'";
            sql += ", @tpRefNo = " + FilterString(trn.tpRefNo) + "";
            sql += ", @tpTranId = " + FilterString(trn.tpTranId) + "";
            sql += ", @controlNo = " + FilterString(controlNo) + "";
            sql += ", @tpExRate = " + FilterString(trn.tpExRate);
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(sql);
        }

        public DbResult RevertTPTxns(string controlNo, string user)
        {
            var sql = "EXEC proc_sendIRHTP @flag = 'revertTxn'";
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(sql);
        }

        public DataTable CheckAvailableBanalce(string username, string customerId, string payoutMethod, string branchId)
        {
            var sql = "EXEC proc_checkUserAvailableBalance";
            sql += " @username = " + FilterString(username);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @paymentMethod = " + FilterString(payoutMethod);
            sql += ", @branchId = " + FilterString(branchId);

            return ExecuteDataTable(sql);
        }

        public DataTable CheckAvailableBanalceBranchWise(string branchId, string customerId, string payoutMethod)
        {
            var sql = "EXEC proc_checkUserAvailableBalance";
            sql += "  @branchId = " + FilterString(branchId);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @paymentMethod = " + FilterString(payoutMethod);
            return ExecuteDataTable(sql);
        }

        public DataTable GetPayerBranchDataByPayerAndCityId(string payerId, string cityId, string partnerId)
        {
            string sql = "EXEC PROC_API_PAYER_BRANCH_SETUP @FLAG= 'getPayoutBranchByPayoutAndCityId'";
            sql += ", @PAYERID=" + FilterString(payerId);
            sql += ", @CityId=" + FilterString(cityId);
            sql += ", @API_PARTNER_ID=" + FilterString(partnerId);
            return ExecuteDataTable(sql);
        }

        public DataTable GetPayersByAgent(string agentId, string partnerId, string pMode = "", string pCountry = "", string xml = "")
        {
            string sql = "EXEC PROC_API_PAYER_BRANCH_SETUP @FLAG= 'getPayerDataByAgent'";
            sql += ", @BANK_CODE=" + FilterString(agentId);
            sql += ", @API_PARTNER_ID=" + FilterString(partnerId);
            sql += ", @pMode=" + FilterString(pMode);
            sql += ", @pCountry=" + FilterString(pCountry);
            sql += ", @xml=" + FilterString(xml);
            return ExecuteDataTable(sql);
        }

        public DataTable GetAgentBranchByAgentId(string agentId, string pMode)
        {
            string sql = "EXEC PROC_API_BANK_BRANCH_SETUP @FLAG='getBranchByAgentIdForDDL'";
            sql += " , @bankId=" + FilterString(agentId);
            sql += " , @PAYMENT_TYPE=" + FilterString(pMode);
            return ExecuteDataTable(sql);
        }

    public DbResult CreateTransactionFromMobileOROnline(IRHTranDetail txn, string fxsessionid) {
      try {
        StringBuilder sql = new StringBuilder("EXEC proc_SendTransaction @flag ='send'");
        sql.AppendLine(", @User = " + FilterString(txn.User));
        sql.AppendLine(", @SenderId = " + FilterString(txn.SenderId));
        //sql.AppendLine(", @sIpAddress = " + FilterString(txn.SIpAddress));
        sql.AppendLine(", @ReceiverId = " + FilterString(txn.ReceiverId));
        sql.AppendLine(", @rFirstName = " + FilterString(txn.RecFirstName));
        sql.AppendLine(", @rMiddleName = " + FilterString(txn.RecMiddleName));
        sql.AppendLine(", @rLastName = " + FilterString(txn.RecLastName));
        sql.AppendLine(", @rIdType = " + FilterString(txn.ReceiverId));
        sql.AppendLine(", @rIdNo = " + FilterString(txn.RecIdNo));
        //sql.AppendLine(", @rIdIssue = " + FilterString(txn.recis));
        //sql.AppendLine(", @rIdExpiry = " + FilterString(txn.rec));
        sql.AppendLine(", @rDob = " + FilterString(txn.RecDob));
        sql.AppendLine(", @rMobileNo = " + FilterString(txn.RecMobile));
        sql.AppendLine(", @rNativeCountry = " + FilterString(txn.RecCountryId));
        //sql.AppendLine(", @rStateId = " + FilterString(txn.rec));
        //sql.AppendLine(", @rDistrictId = " + FilterString(txn.Receiver.DistrictId.ToString()));
        sql.AppendLine(", @rAddress = " + FilterString(txn.RecAdd1));
        sql.AppendLine(", @rCity = " + FilterString(txn.RecCity));
        sql.AppendLine(", @rEmail = " + FilterString(txn.RecEmail));
        sql.AppendLine(", @rAccountNo = " + FilterString(txn.RecAccountNo));
        sql.AppendLine(", @sCountryId = " + FilterString(txn.SCountryId));
        sql.AppendLine(", @pCountryId = " + 151);// FilterString(txn.PCountryId.ToString()));
        sql.AppendLine(", @deliveryMethodId = " + FilterString(txn.DeliveryMethodId.ToString()));
        sql.AppendLine(", @pBranchId = " + FilterString(txn.PayerBranchId));
        sql.AppendLine(", @pBankId = " + FilterString(txn.PBank));
        sql.AppendLine(", @collCurr = " + FilterString(txn.CollCurr));
        sql.AppendLine(", @payoutCurr = " + FilterString(txn.PCurr));
        sql.AppendLine(", @collAmt = " + FilterString(txn.CollAmt));
        sql.AppendLine(", @payoutAmt = " + FilterString(txn.PayoutAmt));
        sql.AppendLine(", @transferAmt = " + FilterString(txn.TransferAmt));
        sql.AppendLine(", @exRate = " + FilterString(txn.ExRate));
        sql.AppendLine(", @calBy = " + FilterString(txn.calcBy));
        sql.AppendLine(", @tpExRate = " + FilterString(txn.tpExRate));
        sql.AppendLine(", @payOutPartnerId = " + FilterString(txn.payoutPartner));
        sql.AppendLine(", @forexSessionId = " + FilterString(fxsessionid));
        sql.AppendLine(", @paymentType = " + FilterString("wallet"));
        sql.AppendLine(", @PurposeOfRemittance = " + FilterString(txn.PurposeOfRemittance));
        sql.AppendLine(", @SourceOfFund = " + FilterString(txn.SourceOfFund));
        sql.AppendLine(", @RelWithSender = " + FilterString(txn.RelWithSender));
        //sql.AppendLine(", @SourceType = " + FilterString(txn.SourceType));
        sql.AppendLine(", @scDiscount = " + FilterString(txn.Discount));
        //sql.AppendLine(", @ProcessId = " + FilterString(txn.ProcessId));
        sql.AppendLine(", @schemeId = " + FilterString(txn.SchemeCode));
        sql.AppendLine(",@complianceQuestion=N'" + (txn.ComplaincrDataStr) + "'");

        //// new 4 fields
        //sql.AppendLine(", @bankAccountType = " + FilterString(txn.bankAccountType));
        //sql.AppendLine(", @bankRoutingCode = " + FilterString(txn.bankRoutingCode));
        //sql.AppendLine(", @bicSwift = " + FilterString(txn.bicSwift));
        //sql.AppendLine(", @beneZipCode = " + FilterString(txn.beneZipCode));
        // new 4 fields

        return ParseDbResultV2(sql.ToString());
      } catch (Exception ex) {
        return null;
      }
    }
  }
}