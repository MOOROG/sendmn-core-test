
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.SwiftSystem
{

    public class TranReportDao : RemittanceDao
    {
        public ReportResult GetBankGauranteeReport(string user, string date, string agentGroup, string ignoreBlockedAgent)
        {
            string sql = "EXEC proc_bankGauranteeReport @flag = 'rpt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @date = " + FilterString(date);
            sql += ", @agentGroup = " + FilterString(agentGroup);
            sql += ", @ignoreBlockedAgent = " + FilterString(ignoreBlockedAgent);
            return ParseReportResult(sql);
        }

        public ReportResult GetCustomerReconcileRpt(string user, string rptType, string fromDate, string toDate, string agentId,
            string memId, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_reconcileCustomer @flag='rpt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rptType = " + FilterString(rptType);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @memId = " + FilterString(memId);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }
        public ReportResult GetThrasholdTransIntlReport(string user, string fromDate, string toDate, string txnAmt, string rptType, string rptNature)
        {
            string sql = "EXEC proc_thrasholdTransIntlReport ";
            sql += " @flag = " + FilterString(rptType);
            sql += ",@user = " + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@txnAmt = " + FilterString(txnAmt);
            sql += ",@rptNature = " + FilterString(rptNature);
            return ParseReportResult(sql);
        }

        public ReportResult GetZoneTargetRpt(string user, string zone, string yr, string pageNumber, string pageSize)
        {
            string sql = "EXEC [proc_zoneWiseTargetReport] @flag = 'rpt'";
            sql += ",@user=" + FilterString(user);
            sql += ",@zone = " + FilterString(zone);
            sql += ",@yr = " + FilterString(yr);
            sql += ",@pageNumber = " + FilterString(pageNumber);
            sql += ",@pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }

        public ReportResult StockCardDetails(string user, string searchBy, string cardBy, string zone, string agent, string membershipId)
        {
            string sql = "EXEC proc_cardStockReport @flag = " + FilterString(searchBy);
            sql += ", @user = " + FilterString(user);
            sql += ", @cardBy = " + FilterString(cardBy);
            sql += ", @szone = " + FilterString(zone);
            sql += ", @sagent = " + FilterString(agent);
            sql += ", @remitCardNo = " + FilterString(membershipId);
            return ParseReportResult(sql);
        }
        public ReportResult GetCreditLimitRpt(string user, string fromDate, string toDate,
            string agentId, string userName)
        {
            string sql = "EXEC  proc_creditLimitRpt";
            sql += " @flag = 'rpt'";
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@agentId = " + FilterString(agentId);
            sql += ",@userName = " + FilterString(userName);
            return ParseReportResult(sql);
        }
        public ReportResult GetTranAnalysisIntl_20162310(string user, string flag, string fromDate, string toDate, string dateType, string sendingAgent,
                                                string sendingCountry, string sendingBranch, string receivingCountry, string reecivingAgent,
                                                string receivingBranch, string groupBy, string reportType, string id, string status,
                                                string controlNo, string rLocation, string rZone, string rDistrict,
                                                string pageNumber, string pageSize, string groupById, string tranType, string searchBy,
                                                string searchByText, string fromTime, string toTime, string isExportFull, string sAgentGrp,
                                                string rAgentGrp)
        {
            string sql = "EXEC proc_tranAnalysisIntl_20162310 ";
            sql += "  @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @SendingAgent = " + FilterString(sendingAgent);
            sql += ", @SendingCountry = " + FilterString(sendingCountry);
            sql += ", @SendingBranch = " + FilterString(sendingBranch);
            sql += ", @ReceivingCountry = " + FilterString(receivingCountry);
            sql += ", @ReecivingAgent = " + FilterString(reecivingAgent);
            sql += ", @ReceivingBranch = " + FilterString(receivingBranch);
            sql += ", @groupBy = " + FilterString(groupBy);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @ReportType = " + FilterString(reportType);
            sql += ", @Id = " + FilterString(id);
            sql += ", @status = " + FilterString(status);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @rZone = " + FilterString(rZone);
            sql += ", @rDistrict = " + FilterString(rDistrict);
            sql += ", @rLocation = " + FilterString(rLocation);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber =" + FilterString(pageNumber);
            sql += ", @groupById =" + FilterString(groupById);
            sql += ", @tranType =" + FilterString(tranType);
            sql += ", @searchBy =" + FilterString(searchBy);
            sql += ", @searchByText =" + FilterString(searchByText);
            sql += ", @fromTime =" + FilterString(fromTime);
            sql += ", @toTime =" + FilterString(toTime);
            sql += ", @isExportFull =" + FilterString(isExportFull);
            sql += ", @sAgentGrp =" + FilterString(sAgentGrp);
            sql += ", @rAgentGrp =" + FilterString(rAgentGrp);

            return ParseReportResult(sql);
        }
        public ReportResult GetAgentwiseCustomerApproval(string user, string fromDate, string toDate, string cardType)
        {
            string sql = "EXEC proc_customerApprovalRpt @flag = 'approve'";
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@cardType = " + FilterString(cardType);
            return ParseReportResult(sql);
        }

        public ReportResult AgentDebitBalance(string user, string agentId, string agentName, string agentGroup, string date, string closingBalType)
        {
            string sql = "EXEC  proc_agentDebitBalanceRpt @flag = 'rpt'";
            sql += ",@user=" + FilterString(user);
            sql += ",@mapCodeInt = " + FilterString(agentId);
            sql += ",@agentName = " + FilterString(agentName);
            sql += ",@agentGroup =" + FilterString(agentGroup);
            sql += ",@date =" + FilterString(date);
            sql += ",@closingBalType =" + FilterString(closingBalType);
            return ParseReportResult(sql);
        }

        public ReportResult GetBankBranchList(string user, string bankId)
        {
            string sql = "EXEC proc_MapCodeReport @flag='rpt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @bankId = " + FilterString(bankId);
            return ParseReportResult(sql);
        }

        public ReportResult GetHoUserTxn(string user, string fromDate, string toDate)
        {
            string sql = "EXEC proc_HoUserTxn @flag='rpt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            return ParseReportResult(sql);
        }

        public ReportResult SlabWiseConsolidatedReport(string user, string flag, string fromDate, string toDate)
        {
            string sql = "EXEC " + (flag == "c" ? "proc_consolidatedRpt @flag='rpt'" : "proc_slabwiseRpt @flag='rpt'");
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            return ParseReportResult(sql);
        }
        public ReportResult GetKycTxnReport(string user, string fromDate, string toDate, string sZone, string sAgent, string rptType, string remitCardNo)
        {
            string sql = "EXEC proc_kycTxnReport";
            sql += "  @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @sZone = " + FilterString(sZone);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @rptType = " + FilterString(rptType);
            sql += ", @remitCardNo = " + FilterString(remitCardNo);
            return ParseReportResult(sql);
        }

        public ReportResult GetKycEnrollmentReport(string user, string fromDate, string toDate, string sZone, string sDistrict, string sAgent, string rptType, string remitCardNo)
        {
            string sql = "EXEC proc_kycEnrollmentReport";
            sql += "  @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @sZone = " + FilterString(sZone);
            sql += ", @sDistrict = " + FilterString(sDistrict);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @rptType = " + FilterString(rptType);
            sql += ", @remitCardNo = " + FilterString(remitCardNo);
            return ParseReportResult(sql);
        }

        public ReportResult GetCreditSecurityRpt(string user, string zone, string district, string location, string agent, string securitytype, string groupby, string isexpiry, string date)
        {
            string sql = "EXEC proc_agentSecurityReport @flag='rpt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @zoneName = " + FilterString(zone);
            sql += ", @districtName = " + FilterString(district);
            sql += ", @locationId = " + FilterString(location);
            sql += ", @agentId = " + FilterString(agent);
            sql += ", @securityType = " + FilterString(securitytype);
            sql += ", @isExpiry = " + FilterString(isexpiry);
            sql += ", @groupBy = " + FilterString(groupby);
            sql += ", @date = " + FilterString(date);
            return ParseReportResult(sql);
        }
        public ReportResult GetAgentProfileUpdateRpt(string user, string fromDate, string toDate, string rptType, string agentId)
        {
            string sql = "exec proc_agentProfileUpdate";
            sql += "  @flag= 'rpt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @rptType = " + FilterString(rptType);
            sql += ", @agentId = " + FilterString(agentId);
            return ParseReportResult(sql);
        }
        public ReportResult GetReport(string user, string fromDate, string toDate, string reportType, string pageNumber, string pageSize, string sessionId)
        {
            string sql = "EXEC proc_tranReport @flag = 'r'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @reportType = " + FilterString(reportType);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sessionId = " + FilterString(sessionId);
            return ParseReportResult(sql);
        }

        public ReportResult GetCommReport(string flag, string user, string fromDate, string toDate, string agentId, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_commissionReport @flag =" + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @AgentId = " + FilterString(agentId);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetEnrollRpt(string user, string fromDate, string toDate, string agentId, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_enrollCommReport @flag = 'ECR'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @AgentId = " + FilterString(agentId);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetTranAnalysisIntRpt(string user, string flag, string fromDate, string toDate, string dateType, string sendingAgent,
                                                string sendingCountry, string sendingBranch, string receivingCountry, string reecivingAgent,
                                                string receivingBranch, string groupBy, string reportType, string id, string status,
                                                string controlNo, string rLocation, string rZone, string rDistrict,
                                                string pageNumber, string pageSize, string groupById, string tranType, string searchBy,
                                                string searchByText, string fromTime, string toTime, string isExportFull)
        {
            string sql = "EXEC Proc_TranAnalysisReportIntl ";
            sql += " @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @SendingAgent = " + FilterString(sendingAgent);
            sql += ", @SendingCountry = " + FilterString(sendingCountry);
            sql += ", @SendingBranch = " + FilterString(sendingBranch);
            sql += ", @ReceivingCountry = " + FilterString(receivingCountry);
            sql += ", @ReecivingAgent = " + FilterString(reecivingAgent);
            sql += ", @ReceivingBranch = " + FilterString(receivingBranch);
            sql += ", @groupBy = " + FilterString(groupBy);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @ReportType = " + FilterString(reportType);
            sql += ", @Id = " + FilterString(id);
            sql += ", @status = " + FilterString(status);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @rZone = " + FilterString(rZone);
            sql += ", @rDistrict = " + FilterString(rDistrict);
            sql += ", @rLocation = " + FilterString(rLocation);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber =" + FilterString(pageNumber);
            sql += ", @groupById =" + FilterString(groupById);
            sql += ", @tranType =" + FilterString(tranType);
            sql += ", @searchBy =" + FilterString(searchBy);
            sql += ", @searchByText =" + FilterString(searchByText);
            sql += ", @fromTime =" + FilterString(fromTime);
            sql += ", @toTime =" + FilterString(toTime);
            sql += ", @isExportFull =" + FilterString(isExportFull);


            return ParseReportResult(sql);
        }
        public ReportResult GetTranAnalysisRpt(string user, string flag, string fromDate, string toDate, string dateType, string sendingAgent,
                                                string sendingCountry, string sendingBranch, string receivingCountry, string reecivingAgent,
                                                string receivingBranch, string groupBy, string reportType, string id, string status,
                                                string controlNo, string sLocation, string rLocation, string rZone, string rDistrict, string sZone, string sDistrict,
                                                string pageNumber, string pageSize, string groupById, string tranType, string searchBy, string searchByText,
                                                string fromTime, string toTime, string isExportFull, string remitProduct)
        {
            string sql = "EXEC Proc_TranAnalysisReprot ";
            sql += " @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @SendingAgent = " + FilterString(sendingAgent);
            sql += ", @SendingCountry = " + FilterString(sendingCountry);
            sql += ", @SendingBranch = " + FilterString(sendingBranch);
            sql += ", @ReceivingCountry = " + FilterString(receivingCountry);
            sql += ", @ReecivingAgent = " + FilterString(reecivingAgent);
            sql += ", @ReceivingBranch = " + FilterString(receivingBranch);
            sql += ", @groupBy = " + FilterString(groupBy);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @ReportType = " + FilterString(reportType);
            sql += ", @Id = " + FilterString(id);
            sql += ", @status = " + FilterString(status);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @rZone = " + FilterString(rZone);
            sql += ", @rDistrict = " + FilterString(rDistrict);
            sql += ", @sZone = " + FilterString(sZone);
            sql += ", @sDistrict = " + FilterString(sDistrict);
            sql += ", @sLocation = " + FilterString(sLocation);
            sql += ", @rLocation = " + FilterString(rLocation);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber =" + FilterString(pageNumber);
            sql += ", @groupById =" + FilterString(groupById);
            sql += ", @tranType =" + FilterString(tranType);
            sql += ", @searchBy =" + FilterString(searchBy);
            sql += ", @searchByText =" + FilterString(searchByText);
            sql += ", @fromTime =" + FilterString(fromTime);
            sql += ", @toTime =" + FilterString(toTime);
            sql += ", @isExportFull =" + FilterString(isExportFull);
            sql += ", @remitProduct =" + FilterString(remitProduct);

            return ParseReportResult(sql);
        }

        public ReportResult GetTransactionRptCooperative(string user, string flag, string fromDate, string toDate, string dateType, string sendingAgent,
                                               string sendingCountry, string sendingBranch, string receivingCountry, string reecivingAgent,
                                               string receivingBranch, string groupBy, string reportType, string id, string status,
                                               string controlNo, string sLocation, string rLocation, string rZone, string rDistrict, string sZone, string sDistrict,
                                               string pageNumber, string pageSize, string groupById, string tranType, string searchBy, string searchByText,
                                               string fromTime, string toTime)
        {
            string sql = "EXEC proc_transactionRptCooperative ";
            sql += " @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @SendingAgent = " + FilterString(sendingAgent);
            sql += ", @SendingCountry = " + FilterString(sendingCountry);
            sql += ", @SendingBranch = " + FilterString(sendingBranch);
            sql += ", @ReceivingCountry = " + FilterString(receivingCountry);
            sql += ", @ReecivingAgent = " + FilterString(reecivingAgent);
            sql += ", @ReceivingBranch = " + FilterString(receivingBranch);
            sql += ", @groupBy = " + FilterString(groupBy);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @ReportType = " + FilterString(reportType);
            sql += ", @Id = " + FilterString(id);
            sql += ", @status = " + FilterString(status);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @rZone = " + FilterString(rZone);
            sql += ", @rDistrict = " + FilterString(rDistrict);
            sql += ", @sZone = " + FilterString(sZone);
            sql += ", @sDistrict = " + FilterString(sDistrict);
            sql += ", @sLocation = " + FilterString(sLocation);
            sql += ", @rLocation = " + FilterString(rLocation);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber =" + FilterString(pageNumber);
            sql += ", @groupById =" + FilterString(groupById);
            sql += ", @tranType =" + FilterString(tranType);
            sql += ", @searchBy =" + FilterString(searchBy);
            sql += ", @searchByText =" + FilterString(searchByText);
            sql += ", @fromTime =" + FilterString(fromTime);
            sql += ", @toTime =" + FilterString(toTime);


            return ParseReportResult(sql);
        }
        public ReportResult GetEnrollDetailRpt(string user, string fromDate, string toDate, string agentId, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_enrollCommReport @flag = 'ECDR'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @AgentId = " + FilterString(agentId);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetFeeCollectionRpt(string user, string fromDate, string toDate, string level, string controlNo
                    , string agentId, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_feeCollectionReport @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @level = " + FilterString(level);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @AgentId = " + FilterString(agentId);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }
        public ReportResult GetFeeCollectionAdminRpt(string user, string fromDate, string toDate, string sAgent, string agentId, string level, string controlNo
                    , string status, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_feeCollectionReport @flag = 'b'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @level = " + FilterString(level);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @status = " + FilterString(status);
            sql += ", @sAgentId = " + FilterString(sAgent);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }
        public ReportResult GetCommSendReport(string user, string date, string agentId, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_commissionReport @flag = 'drs'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(date);
            sql += ", @toDate = " + FilterString(date);
            sql += ", @date = " + FilterString(date);
            sql += ", @AgentId = " + FilterString(agentId);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetCommPayReport(string user, string date, string agentId)
        {
            string sql = "EXEC proc_commissionReport @flag = 'drp'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(date);
            sql += ", @toDate = " + FilterString(date);
            sql += ", @date = " + FilterString(date);
            sql += ", @AgentId = " + FilterString(agentId);

            return ParseReportResult(sql);
        }

        public DataRow GetTranReportDetail(string user, string tranId)
        {
            string sql = "EXEC proc_tranReportDetail @flag = 'details'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public ReportResult GetMasterReport(string user, string sHub, string ssAgent, string sCountry, string sAgent,
                                            string sBranch, string sUser, string sZone, string sDistrict,
                                            string sLocation, string sFirstName, string sMiddleName, string sLastName1,
                                            string sLastName2, string sMobile, string sEmail, string sIDNumber,
                                            string rHub, string rsAgent, string rCountry, string rAgent, string rBranch,
                                            string rUser, string rZone, string rDistrict, string rLocation,
                                            string rFirstName, string rMiddleName, string rLastName1, string rLastName2,
                                            string rMobile, string rEmail, string rIDNumber, string controlNumber,
                                            string tranType, string orderBy,
                                            string sendDateFrom, string sendDateTo, string paidDateFrom,
                                            string paidDateTo, string cancelledDateFrom, string cancelledDateTo,
                                            string approvedDateFrom, string approvedDateTo, string collectionAmountFrom,
                                            string collectionAmountTo, string payoutAmountFrom, string payoutAmountTo,
                                            string tranStatus, string tranSend, string sender, string tranPay,
                                            string receiver, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_tranMasterReport @flag = 'r'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sHub = " + FilterString(sHub);
            sql += ", @ssAgent = " + FilterString(ssAgent);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @sUser = " + FilterString(sUser);
            sql += ", @sZone = " + FilterString(sZone);
            sql += ", @sDistrict = " + FilterString(sDistrict);
            sql += ", @sLocation = " + FilterString(sLocation);
            sql += ", @sFirstName = " + FilterString(sFirstName);
            sql += ", @sMiddleName = " + FilterString(sMiddleName);
            sql += ", @sLastName1 = " + FilterString(sLastName1);
            sql += ", @sLastName2 = " + FilterString(sLastName2);
            sql += ", @sMobile = " + FilterString(sMobile);
            sql += ", @sEmail = " + FilterString(sEmail);
            sql += ", @sIDNumber = " + FilterString(sIDNumber);

            sql += ", @rHub = " + FilterString(rHub);
            sql += ", @rsAgent = " + FilterString(rsAgent);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rBranch = " + FilterString(rBranch);
            sql += ", @rUser = " + FilterString(rUser);
            sql += ", @rZone = " + FilterString(rZone);
            sql += ", @rDistrict = " + FilterString(rDistrict);
            sql += ", @rLocation = " + FilterString(rLocation);
            sql += ", @rFirstName = " + FilterString(rFirstName);
            sql += ", @rMiddleName = " + FilterString(rMiddleName);
            sql += ", @rLastName1 = " + FilterString(rLastName1);
            sql += ", @rLastName2 = " + FilterString(rLastName2);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @rEmail = " + FilterString(rEmail);
            sql += ", @rIDNumber = " + FilterString(rIDNumber);

            sql += ", @controlNumber = " + FilterString(controlNumber);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @orderBy = " + FilterString(orderBy);
            sql += ", @sendDateFrom = " + FilterString(sendDateFrom);
            sql += ", @sendDateTo = " + FilterString(sendDateTo);
            sql += ", @paidDateFrom = " + FilterString(paidDateFrom);
            sql += ", @paidDateTo = " + FilterString(paidDateTo);
            sql += ", @cancelledDateFrom = " + FilterString(cancelledDateFrom);
            sql += ", @cancelledDateTo = " + FilterString(cancelledDateTo);
            sql += ", @approvedDateFrom = " + FilterString(approvedDateFrom);
            sql += ", @approvedDateTo = " + FilterString(approvedDateTo);
            sql += ", @collectionAmountFrom = " + FilterString(collectionAmountFrom);
            sql += ", @collectionAmountTo = " + FilterString(collectionAmountTo);
            sql += ", @payoutAmountFrom = " + FilterString(payoutAmountFrom);

            sql += ", @payoutAmountTo = " + FilterString(payoutAmountTo);
            sql += ", @tranStatus = " + FilterString(tranStatus);
            sql += ", @tranSendList = " + FilterString(tranSend);
            sql += ", @senderList = " + FilterString(sender);
            sql += ", @tranPayList = " + FilterString(tranPay);
            sql += ", @receiverList = " + FilterString(receiver);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber =" + FilterString(pageNumber);

            return ParseReportResult(sql);
        }

        public DataSet GetFieldList(string user)
        {
            string sql = "EXEC proc_tranMasterReport @flag = 'l'";
            sql += ", @user = " + FilterString(user);

            return ExecuteDataset(sql);
        }

        public ReportResult GetDummyResult(string user, string agentId, string issuedDateFrom, string issuedDateTo)
        {
            string sql = "EXEC proc_bankGuaranteeReport";
            sql += " @user = " + FilterString(user);
            sql += " ,@agentId = " + FilterString(agentId);
            sql += " ,@issuedDateFrom = " + FilterString(issuedDateFrom);
            sql += " ,@issuedDateTo = " + FilterString(issuedDateTo);

            return ParseReportResult(sql);
        }

        public ReportResult GetAgentStmtResult(string agentId, string issuedDateFrom, string issuedDateTo, string pageSize, string pageNumber, string user)
        {
            string sql = "EXEC proc_agentStatement_Principal";
            sql += " @agentId = " + FilterString(agentId);
            sql += " ,@fromDate = " + FilterString(issuedDateFrom);
            sql += " ,@toDate = " + FilterString(issuedDateTo);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber =" + FilterString(pageNumber);
            sql += ", @user =" + FilterString(user);

            return ParseReportResult(sql);
        }

        public ReportResult GetAgentBalResult(string agentId, string issuedDateFrom, string issuedDateTo, string pageSize, string pageNumber, string user)
        {
            string sql = "EXEC proc_AgentBalance_Report1";
            sql += " @user = " + FilterString(user);
            sql += " ,@agentId = " + FilterString(agentId);
            sql += " ,@fromDate = " + FilterString(issuedDateFrom);
            sql += " ,@toDate = " + FilterString(issuedDateTo);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber =" + FilterString(pageNumber);

            return ParseReportResult(sql);
        }
        public ReportResult GetAgentBalDrillDownResult(string agentId, string issuedDateFrom, string tranId, string flag)
        {
            string sql = "EXEC proc_AgentTranReport1";
            sql += " @agentId = " + FilterString(agentId);
            sql += " ,@fromDate = " + FilterString(issuedDateFrom);
            sql += " ,@tranId = " + FilterString(tranId);
            sql += " ,@flag = " + FilterString(flag);

            return ParseReportResult(sql);
        }

        public ReportResult GetAgentSOAReport(string user, string reportType, string fromDate, string toDate, string agentId,
                                              string pageNumber, string pageSize, string sessionId)
        {
            string sql = "EXEC Proc_StatementOfAC";
            sql += "  @REPORTTYPE = " + FilterString(reportType);
            sql += ", @FROMDATE = " + FilterString(fromDate);
            sql += ", @TODATE = " + FilterString(toDate);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @user = " + FilterString(user);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber =" + FilterString(pageNumber);
            sql += ", @sessionId =" + FilterString(sessionId);

            return ParseReportResult(sql);
        }
        public ReportResult GetAgentSoaDrilldownReport(string user, string reportType, string fromDate, string toDate, string agentId,
                                              string voucherType, string pageNumber, string pageSize)
        {
            string sql = "EXEC Proc_StatementOfACDrilldown";
            sql += "  @REPORTTYPE = " + FilterString(reportType);
            sql += ", @FROMDATE = " + FilterString(fromDate);
            sql += ", @TODATE = " + FilterString(toDate);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @VOUCHERTYPE = " + FilterString(voucherType);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber =" + FilterString(pageNumber);

            return ParseReportResult(sql);
        }

        public ReportResult GetCreditDetailReport(string flag, string user, string agentId, string issuedDateFrom,
                                                  string issuedDateTo)
        {
            string sql = "EXEC proc_creditDetailReport";
            sql += " @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            return ParseReportResult(sql);
        }

        public ReportResult GetAppViewLogByTranId(string user, string tranId, string controlNo)
        {
            string sql = "EXEC proc_tranLogViewRpt @flag = 'tranId'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ParseReportResult(sql);
        }

        public ReportResult GetAppViewLogByDate(string user, string fromDate, string toDate, string searchBy)
        {
            string sql = "EXEC proc_tranLogViewRpt @flag = 'ByDate'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @searchBy = " + FilterString(searchBy);

            return ParseReportResult(sql);
        }
        public ReportResult GetTroubleTicketRpt(string user, string fromDate, string toDate, string searchBy,
                    string msgType, string txnType, string paymentMethod, string status)
        {
            string sql = "EXEC proc_tranComplainRpt @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @searchBy = " + FilterString(searchBy);
            sql += ", @msgType = " + FilterString(msgType);
            sql += ", @txnType = " + FilterString(txnType);
            sql += ", @status = " + FilterString(status);
            sql += ", @paymentMethod = " + FilterString(paymentMethod);

            return ParseReportResult(sql);
        }

        public ReportResult GetTranAccessReport(string user, string fromDate, string toDate, string reportType)
        {
            string sql = "EXEC proc_tranComplainRpt @flag = 'tranAccessRpt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @reportType = " + FilterString(reportType);

            return ParseReportResult(sql);
        }


        //public DataSet UserWiseReport(string flag ,string user, string userName, string fromDate, string toDate, string userType)
        //{
        //    var sql = "EXEC proc_userWiseTranRpt @flag = "+FilterString(flag)+"";
        //    sql += ", @user = " + FilterString(user);
        //    sql += ", @userName = " + FilterString(userName);
        //    sql += ", @fromDate = " + FilterString(fromDate);
        //    sql += ", @toDate = " + FilterString(toDate);
        //    sql += ", @userType = " + FilterString(userType);

        //    var ds = ExecuteDataset(sql);

        //    return ds;
        //}

        public DataSet UserWiseReport(string flag, string countryName, string agentId, string branchId,
                  string userName, string fromDate, string toDate, string rCountry, string user)
        {
            var sql = "EXEC proc_userWiseTranRpt_New @flag = " + FilterString(flag) + "";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryName = " + FilterString(countryName);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @userName = " + FilterString(userName);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @rCountry = " + FilterString(rCountry);
            var ds = ExecuteDataset(sql);
            return ds;
        }

        public DataSet GetUserWiseTransactionReport(string flag, string user, string fromDate, string toDate, string agentId, string userName)
        {
            var sql = "EXEC proc_userWiseTranRptAgent @flag = '" + flag + "'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @userName = " + FilterString(userName);

            var ds = ExecuteDataset(sql);

            return ds;
        }

        public DataSet UserWiseReportModifyHistory(string flag, string branchId, string userName, string fromDate, string toDate, string user)
        {
            var sql = "EXEC proc_userWiseTranRpt_New @flag = " + FilterString(flag) + "";
            sql += ", @user = " + FilterString(user);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @userName = " + FilterString(userName);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            var ds = ExecuteDataset(sql);
            return ds;
        }

        public DataSet PaidTranReport(
                                            string flag, string user,
                                            string fromDate, string toDate, string sCountry, string sZone, string sDistrict, string sLocation,
                                            string sAgent, string sBranch, string rCountry, string rZone, string rDistrict, string rLocation, string rAgent, string rBranch
                                    )
        {
            var sql = "EXEC proc_paidTranReport @flag = " + FilterString(flag) + "";
            sql += ", @user = " + FilterString(user);

            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @sZone = " + FilterString(sZone);
            sql += ", @sDistrict = " + FilterString(sDistrict);
            sql += ", @sLocation = " + FilterString(sLocation);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);

            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rZone = " + FilterString(rZone);
            sql += ", @rDistrict = " + FilterString(rDistrict);
            sql += ", @rLocation = " + FilterString(rLocation);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rBranch = " + FilterString(rBranch);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);

            var ds = ExecuteDataset(sql);
            return ds;
        }
        //paid tran list detail
        public DataSet PaidTranDetailReport(string flag, string user,
                                            string fromDate, string toDate, string sAgent, string orderBy, string rCountry, string rAgent, string rBranch)
        {
            var sql = "EXEC proc_PaidTranListInt @flag = " + FilterString(flag) + "";
            sql += ", @user = " + FilterString(user);

            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @payAgent = " + FilterString(rAgent);
            sql += ", @PBranch = " + FilterString(rBranch);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);

            var ds = ExecuteDataset(sql);
            return ds;
        }

        public DataSet PaidTranReportInt(
                                             string flag, string user,
                                             string fromDate, string toDate, string sCountry, string sZone, string sDistrict, string sLocation,
                                             string sAgent, string sBranch, string rCountry, string rZone, string rDistrict, string rLocation,
                                             string rAgent, string rBranch
                                     )
        {
            var sql = "EXEC proc_paidTranReportInternational @flag = " + FilterString(flag) + "";
            sql += ", @user = " + FilterString(user);

            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @sZone = " + FilterString(sZone);
            sql += ", @sDistrict = " + FilterString(sDistrict);
            sql += ", @sLocation = " + FilterString(sLocation);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);

            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rZone = " + FilterString(rZone);
            sql += ", @rDistrict = " + FilterString(rDistrict);
            sql += ", @rLocation = " + FilterString(rLocation);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rBranch = " + FilterString(rBranch);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);

            var ds = ExecuteDataset(sql);
            return ds;
        }

        public ReportResult GetUserLoginAgingRpt(string user, string agentType, string days, string chkInactiveAgent, string agingFor, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_userLoginAgingRpt @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentType = " + FilterString(agentType);
            sql += ", @days = " + FilterString(days);
            sql += ", @chkInactiveAgent = " + FilterString(chkInactiveAgent);
            sql += ", @agingFor = " + FilterString(agingFor);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }

        public ReportResult GetErroneouslyPaidRpt(string user, string fromDate, string toDate, string controlNo, string paymentMethod, string tranType,
            string reportFor, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_erroneouslyPaidRpt @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @paymentMethod = " + FilterString(paymentMethod);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @reportFor = " + FilterString(reportFor);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetAcDepositPaidDetailRpt(string user, string sendingAgent, string beneficiaryCountry, string bankId,
            string tranType, string fromDate, string toDate, string dateType, string fromTime, string toTime, string redownload,
            string paidUser, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_acDepositPaidReport @flag = 'detail'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sendingAgent = " + FilterString(sendingAgent);
            sql += ", @beneficiaryCountry = " + FilterString(beneficiaryCountry);
            sql += ", @bankId = " + FilterString(bankId);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);
            sql += ", @paidUser = " + FilterString(paidUser);
            sql += ", @redownload = " + FilterString(redownload);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }
        public ReportResult GetAcDepositPaidSummaryRpt(string user, string sendingAgent, string beneficiaryCountry, string bankId,
                string tranType, string fromDate, string toDate, string dateType, string fromTime, string toTime, string redownload,
                string paidUser, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_acDepositPaidReport @flag = 'summary'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sendingAgent = " + FilterString(sendingAgent);
            sql += ", @beneficiaryCountry = " + FilterString(beneficiaryCountry);
            sql += ", @bankId = " + FilterString(bankId);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);
            sql += ", @redownload = " + FilterString(redownload);
            sql += ", @paidUser = " + FilterString(paidUser);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }
        public ReportResult GetNcellFreeSimReport(string user, string fromDate, string toDate, string agentId, string pageNumber, string pageSize)
        {
            string sql = "EXEC [proc_ncellFreeSimCampaign] @flag = 'report'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetNcellSimSummaryReport(string user, string fromDate, string toDate, string agentId, string pageNumber, string pageSize)
        {
            string sql = "EXEC [proc_ncellFreeSimCampaign] @flag = 'rptSummary'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetCancelreport(string user, string fromDate, string toDate, string sCountry, string sAgent, string sBranch, string rCountry, string rAgent
          , string ctype, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_CancelReport_Admin ";
            sql += "@user = " + FilterString(user);
            sql += ",@fromDate=" + FilterString(fromDate);
            sql += ",@toDate=" + FilterString(toDate);
            sql += ",@sCountry=" + FilterString(sCountry);
            sql += ",@sAgent=" + FilterString(sAgent);
            sql += ",@sBranch=" + FilterString(sBranch);
            sql += ",@pCountry=" + FilterString(rCountry);
            sql += ",@rAgent=" + FilterString(rAgent);
            sql += ",@cancelType=" + FilterString(ctype);
            sql += ",@pageNumber=" + FilterString(pageNumber);
            sql += ",@pageSize=" + FilterString(pageSize);
            return ParseReportResult(sql);

        }

        public ReportResult GetSettlementInternational(string user, string pCountry, string sAgent, string sBranch, string fromDate, string toDate, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_settlement_v2 ";
            sql += "  @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetSettlementDomRpt(string user, string flag, string country, string agent, string branch, string fromDate, string toDate, string pageNumber, string pageSize)
        {
            string sql = "EXEC IMEKL.dbo.PROC_SETTLEMENT_REPORT_V2 ";
            sql += "  @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @COUNTRY = " + FilterString(country);
            sql += ", @AGENT = " + FilterString(agent);
            sql += ", @BRANCH = " + FilterString(branch);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetSettlementInternationalDdl(string user, string pCoutry, string sAgent, string sBranch, string fromDate, string toDate, string pageNumber, string pageSize, string flag)
        {
            string sql = "EXEC proc_settlementDdl ";
            sql += "  @user = " + FilterString(user);
            sql += ", @flag = " + FilterString(flag);
            sql += ", @pCountry = " + FilterString(pCoutry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }

        public DbResult MakeTransactionTemplate(string user, string tranInfo, string tranInfoAlias, string templateName)
        {
            string sql = "EXEC proc_manageTranRptTemplete ";
            sql += "  @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranInfo = " + FilterString(tranInfo);
            sql += ", @tranInfoAlias = " + FilterString(tranInfoAlias);
            sql += ", @templateName = " + FilterString(templateName);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteTemplateRpt(string user, string tempId)
        {
            string sql = "EXEC proc_manageTranRptTemplete ";
            sql += "  @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(tempId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public ReportResult GetTransactionReport(string user
                                                , string sCountry
                                                , string rCountry
                                                , string sAgent
                                                , string rAgent
                                                , string sBranch
                                                , string rBranch
                                                , string sFirstName
                                                , string rFirstName
                                                , string sMiddleName
                                                , string rMiddleName
                                                , string sLastName
                                                , string rLastName
                                                , string sSecondLastName
                                                , string rSecondLastName
                                                , string sMobile
                                                , string rMobile
                                                , string sEmail
                                                , string rEmail
                                                , string sIdNumber
                                                , string rIdNumber
                                                , string sState
                                                , string rState
                                                , string sCity
                                                , string rCity
                                                , string sZip
                                                , string rZip
                                                , string tranNo
                                                , string icn
                                                , string senderCompany
                                                , string cAmtFrom
                                                , string cAmtTo
                                                , string pAmtFrom
                                                , string pAmtTo
                                                , string localDateFrom
                                                , string localDateTo
                                                , string confirmDateFrom
                                                , string confirmDateTo
                                                , string paidDateFrom
                                                , string paidDateTo
                                                , string cancelledDateFrom
                                                , string cancelledDateTo
                                                , string receivingMode
                                                , string status
                                                , string reportIn
                                                , string rptTemplate
                                                , string fromDate
                                                , string toDate
                                                , string dateType
                                                , string isAdvanceSearch
                                                , string pageNumber
                                                , string pageSize
                                                , string isExportMode
                                                , string tranType
            )
        {
            string sql = "EXEC proc_transactionRpt @flag = 'rpt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @rBranch = " + FilterString(rBranch);
            sql += ", @sFirstName = " + FilterString(sFirstName);
            sql += ", @rFirstName = " + FilterString(rFirstName);
            sql += ", @sMiddleName = " + FilterString(sMiddleName);
            sql += ", @rMiddleName = " + FilterString(rMiddleName);
            sql += ", @sLastName = " + FilterString(sLastName);
            sql += ", @rLastName = " + FilterString(rLastName);
            sql += ", @sSecondLastName = " + FilterString(sSecondLastName);
            sql += ", @rSecondLastName = " + FilterString(rSecondLastName);
            sql += ", @sMobile = " + FilterString(sMobile);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @sEmail = " + FilterString(sEmail);
            sql += ", @rEmail = " + FilterString(rEmail);
            sql += ", @sIdNumber = " + FilterString(sIdNumber);
            sql += ", @rIdNumber = " + FilterString(rIdNumber);
            sql += ", @sState = " + FilterString(sState);
            sql += ", @rState = " + FilterString(rState);
            sql += ", @sCity = " + FilterString(sCity);
            sql += ", @rCity = " + FilterString(rCity);
            sql += ", @sZip	= " + FilterString(sZip);
            sql += ", @rZip	= " + FilterString(rZip);
            sql += ", @tranNo = " + FilterString(tranNo);
            sql += ", @icn = " + FilterString(icn);
            sql += ", @senderCompany = " + FilterString(senderCompany);
            sql += ", @cAmtFrom	= " + FilterString(cAmtFrom);
            sql += ", @cAmtTo = " + FilterString(cAmtTo);
            sql += ", @pAmtFrom	= " + FilterString(pAmtFrom);
            sql += ", @pAmtTo = " + FilterString(pAmtTo);
            sql += ", @localDateFrom = " + FilterString(localDateFrom);
            sql += ", @localDateTo = " + FilterString(localDateTo);
            sql += ", @confirmDateFrom = " + FilterString(confirmDateFrom);
            sql += ", @confirmDateTo = " + FilterString(confirmDateTo);
            sql += ", @paidDateFrom	= " + FilterString(paidDateFrom);
            sql += ", @paidDateTo = " + FilterString(paidDateTo);
            sql += ", @cancelledDateFrom = " + FilterString(cancelledDateFrom);
            sql += ", @cancelledDateTo = " + FilterString(cancelledDateTo);
            sql += ", @receivingMode = " + FilterString(receivingMode);
            sql += ", @status = " + FilterString(status);
            sql += ", @reportIn	= " + FilterString(reportIn);
            sql += ", @rptTemplate = " + FilterString(rptTemplate);
            sql += ", @fromDate	= " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @dateType	= " + FilterString(dateType);
            sql += ", @isAdvanceSearch = " + FilterString(isAdvanceSearch);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize	= " + FilterString(pageSize);
            sql += ", @isExportMode	= " + FilterString(isExportMode);
            sql += ", @tranType	= " + FilterString(tranType);
            return ParseReportResult(sql);
        }

        public DataSet UserWiseReport_old(string flag, string user, string userName, string fromDate, string toDate, string userType)
        {
            var sql = "EXEC proc_userWiseTranRpt @flag = " + FilterString(flag) + "";
            sql += ", @user = " + FilterString(user);
            sql += ", @userName = " + FilterString(userName);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @userType = " + FilterString(userType);
            var ds = ExecuteDataset(sql);
            return ds;
        }

        public ReportResult GetCooperativeReport(string user, string fromDate, string toDate, string agentGrp, string agent, string branch, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_cooperativeReport @flag ='rpt' ";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentGrp = " + FilterString(agentGrp);
            sql += ", @agent = " + FilterString(agent);
            sql += ", @branch = " + FilterString(branch);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }

        public ReportResult GetTranAnalysisRptCH(string user, string flag, string fromDate, string toDate, string dateType, string sendingAgent,
                                                string sendingCountry, string sendingBranch, string receivingCountry, string reecivingAgent,
                                                string receivingBranch, string groupBy, string reportType, string id, string status,
                                                string controlNo, string rLocation, string rZone, string rDistrict,
                                                string pageNumber, string pageSize, string groupById, string tranType, string searchBy,
                                                string searchByText, string fromTime, string toTime, string isExportFull)
        {
            string sql = "EXEC proc_tranAnalysisRptCH ";
            sql += " @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @SendingAgent = " + FilterString(sendingAgent);
            sql += ", @SendingCountry = " + FilterString(sendingCountry);
            sql += ", @SendingBranch = " + FilterString(sendingBranch);
            sql += ", @ReceivingCountry = " + FilterString(receivingCountry);
            sql += ", @ReecivingAgent = " + FilterString(reecivingAgent);
            sql += ", @ReceivingBranch = " + FilterString(receivingBranch);
            sql += ", @groupBy = " + FilterString(groupBy);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @ReportType = " + FilterString(reportType);
            sql += ", @Id = " + FilterString(id);
            sql += ", @status = " + FilterString(status);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @rZone = " + FilterString(rZone);
            sql += ", @rDistrict = " + FilterString(rDistrict);
            sql += ", @rLocation = " + FilterString(rLocation);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber =" + FilterString(pageNumber);
            sql += ", @groupById =" + FilterString(groupById);
            sql += ", @tranType =" + FilterString(tranType);
            sql += ", @searchBy =" + FilterString(searchBy);
            sql += ", @searchByText =" + FilterString(searchByText);
            sql += ", @fromTime =" + FilterString(fromTime);
            sql += ", @toTime =" + FilterString(toTime);
            sql += ", @isExportFull =" + FilterString(isExportFull);
            return ParseReportResult(sql);
        }

        public ReportResult GetCustomerTxnReport(string user, string fromDate, string toDate, string memId, string pageNumber, string pageSize)
        {
            string sql = "EXEC [proc_customerEnrollmentRpt] @flag = 'detail'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @memId = " + FilterString(memId);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetCustomerEnrollReport(string user, string rptFlag, string fromDate, string toDate, string agentId, string branchId,
            string memId, string pageNumber, string pageSize)
        {
            if (rptFlag == "")
                rptFlag = "main";
            string sql = "EXEC [proc_customerEnrollmentRpt] @flag = " + FilterString(rptFlag);
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @memId = " + FilterString(memId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetSMSRpt(string user, string rptType, string fromDate, string toDate, string country, string pageNumber, string pageSize)
        {
            string sql = "EXEC [proc_SMSRpt]";
            sql += "  @flag = " + FilterString(rptType);
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @country = " + FilterString(country);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetFraudTxn(string flag, string user, string sCountry, string rCountry, string fromDate, string toDate, string operators, string count, string UserName, string agentName, string agentUser)
        {
            var sql = "EXEC proc_fraudAnalysisTxn ";
            sql += "@flag=" + FilterString(flag);
            sql += ",@User=" + FilterString(user);
            sql += ",@sCountry=" + FilterString(sCountry);
            sql += ",@rCountry=" + FilterString(rCountry);
            sql += ",@fromDate=" + FilterString(fromDate);
            sql += ",@toDate=" + FilterString(toDate);
            sql += ",@operator=" + FilterString(operators);
            sql += ",@count=" + FilterString(count);
            sql += ",@userName=" + FilterString(UserName);
            sql += ",@agent=" + FilterString(agentName);
            sql += ",@agentUser=" + FilterString(agentUser);
            return ParseReportResult(sql);
        }
        public ReportResult GetFraudAnalysisLoginReport(string @flag, string agentCountry, string fromDate, string toDate, string Operator, string count, string user, string UserName, string agentId, string agentCountryName)
        {
            string sql = "EXEC [proc_fraudAnalysisLogin]";
            sql += "@flag=" + FilterString(flag);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @count = " + FilterString(count);
            sql += ", @sCountry = " + FilterString(agentCountry);
            sql += ", @operator = '" + Operator + "'";
            sql += ", @user = " + FilterString(user);
            sql += ", @UserName = " + FilterString(UserName);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @agentConName=" + FilterString(agentCountryName);
            return ParseReportResult(sql);
        }

        public ReportResult GetThirdpartytxnReport(string user, string dateType, string fromDate, string toDate, string tAgent, string status,
           string rptType, string groupBy, string pCountry, string charge, string isExportFull, string sCountry, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_ThirdpartyTXN_report";
            sql += "  @user=" + FilterString(user);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @dateFrom = " + FilterString(fromDate);
            sql += ", @dateTo = " + FilterString(toDate);
            sql += ", @tAgent = " + FilterString(tAgent);
            sql += ", @status = " + FilterString(status);
            sql += ", @reportType = " + FilterString(rptType);
            sql += ", @groupBy = " + FilterString(groupBy);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @scharge = " + FilterString(charge);
            sql += ", @isExportFull = " + FilterString(isExportFull);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }

        #region soa report
        public DataTable AgentSoaReport(string fromDate, string toDate, string agentId, string trnType, string rptType)
        {
            string sql = "";

            if (rptType == "soa")
            {
                sql = "EXEC IMEKL.[dbo].[PROC_AGENT_SOA_V2] @flag = 'SOA'";
                sql += ", @AGENT = " + FilterString(agentId);
                sql += ", @DATE1 = " + FilterString(fromDate);
                sql += ", @DATE2 = " + FilterString(toDate);
                sql += ", @TRN_TYPE = " + FilterString(trnType);
            }
            else if (rptType == "dcom")
            {
                sql = "EXEC IMEKL.[dbo].[PROC_AGENT_SOA_DOMESTIC_COMM_V2] @flag = 'SOA'";
                sql += ", @AGENT = " + FilterString(agentId);
                sql += ", @DATE1 = " + FilterString(fromDate);
                sql += ", @DATE2 = " + FilterString(toDate);
                sql += ", @TRN_TYPE = " + FilterString(trnType);
            }
            else if (rptType == "icom")
            {
                sql = "EXEC IMEKL.[dbo].[PROC_AGENT_SOA_INTERNATIONAL_COMM_V2] @flag = 'SOA'";
                sql += ", @AGENT = " + FilterString(agentId);
                sql += ", @DATE1 = " + FilterString(fromDate);
                sql += ", @DATE2 = " + FilterString(toDate);
                sql += ", @TRN_TYPE = " + FilterString(trnType);
            }

            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable AgentSoaDrilldownReport(string fromDate, string toDate, string agentId, string flag, string trnType)
        {
            string sql = "EXEC IMEKL.[dbo].[PROC_AGENT_SOA_V2] ";
            sql += "  @AGENT = " + FilterString(agentId);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(flag);
            sql += ", @TRN_TYPE = " + FilterString(trnType);

            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable AgentSoaDrilldownUserReport(string fromDate, string toDate, string agentId, string branchId, string agentId2, string flag, string trnType)
        {
            string sql = "EXEC IMEKL.[dbo].[PROC_AGENT_SOA_V2] ";
            sql += "  @AGENT = " + FilterString(agentId);
            sql += ", @BRANCH = " + FilterString(branchId);
            sql += ", @AGENT2 = " + FilterString(agentId2);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(flag);
            sql += ", @TRN_TYPE = " + FilterString(trnType);

            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable AgentSoaDrilldownReportDComm(string fromDate, string toDate, string agentId, string flag, string trnType)
        {
            string sql = "EXEC IMEKL.[dbo].[PROC_AGENT_SOA_DOMESTIC_COMM_V2] ";
            sql += "  @AGENT = " + FilterString(agentId);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(flag);
            sql += ", @TRN_TYPE = " + FilterString(trnType);

            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable AgentSoaDrilldownUserDCommReport(string fromDate, string toDate, string agentId, string agentId2, string flag, string trnType)
        {
            string sql = "EXEC IMEKL.[dbo].[PROC_AGENT_SOA_DOMESTIC_COMM_V2] ";
            sql += "  @AGENT = " + FilterString(agentId);
            sql += ", @AGENT2 = " + FilterString(agentId2);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(flag);
            sql += ", @TRN_TYPE = " + FilterString(trnType);

            return ExecuteDataset(sql).Tables[0];
        }
        public DataTable AgentSoaDrilldownReportIntComm(string fromDate, string toDate, string agentId, string flag, string trnType)
        {
            string sql = "EXEC IMEKL.[dbo].[PROC_AGENT_SOA_INTERNATIONAL_COMM_V2] ";
            sql += "  @AGENT = " + FilterString(agentId);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(flag);
            sql += ", @TRN_TYPE = " + FilterString(trnType);

            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable AgentSoaDrilldownUserIntCommReport(string fromDate, string toDate, string agentId, string branchId, string agentId2, string flag, string trnType)
        {
            string sql = "EXEC IMEKL.[dbo].[PROC_AGENT_SOA_INTERNATIONAL_COMM_V2] ";
            sql += "  @AGENT = " + FilterString(agentId);
            sql += ", @BRANCH = " + FilterString(branchId);
            sql += ", @AGENT2 = " + FilterString(agentId2);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(flag);
            sql += ", @TRN_TYPE = " + FilterString(trnType);

            return ExecuteDataset(sql).Tables[0];
        }

        public ReportResult SoaExportToExcel(string user, string rptType, string fromDate, string toDate, string mapCode)
        {
            string sql = "EXEC IMEKL.[dbo].[PROC_AGENT_SOA_V2] ";
            sql += "  @AGENT = " + FilterString(mapCode);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(rptType);
            sql += ", @user = " + FilterString(user);
            return ParseReportResult(sql);
        }
        #endregion soa report
        public ReportResult GetBonusReport(string user, string flag, string fromDate, string toDate, string mFrom, string mTo,
            string membershipId, string orderBy, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_bonusRpt @flag = " + FilterString(flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@mFrom = " + FilterString(mFrom);
            sql += ",@mTo = " + FilterString(mTo);
            sql += ",@orderBy = " + FilterString(orderBy);
            sql += ",@membershipId = " + FilterString(membershipId);
            sql += ",@pageNumber = " + FilterString(pageNumber);
            sql += ",@pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }
        //user, flag, fromDate, toDate, membershipId,pageNumber, GetStatic.GetReportPagesize()
        public ReportResult GetBonusTxnDetail(string user, string flag, string fromDate, string toDate, string membershipId,
                string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_bonusRpt @flag = " + FilterString(flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@membershipId = " + FilterString(membershipId);
            sql += ",@pageNumber = " + FilterString(pageNumber);
            sql += ",@pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }
        /*
        public ReportResult GetBonusPointReport(string user, string flag, string branchId, string from, string to, string orderBy, string senderId, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_bonusRpt @flag = " + FilterString(flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@branchId = " + FilterString(branchId);
            sql += ",@mFrom = " + FilterString(from);
            sql += ",@mTo = " + FilterString(to);
            sql += ",@orderBy = " + FilterString(orderBy);
            sql += ",@membershipId = " + FilterString(senderId);
            sql += ",@pageNumber = " + FilterString(pageNumber);
            sql += ",@pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);

        }
        public ReportResult GetBonusRedeemedReport(string user, string flag, string branchId, string from, string to, string orderBy, string senderId, string giftItem, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_bonusRpt @flag = " + FilterString(flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@branchId = " + FilterString(branchId);
            sql += ",@fromDate = " + FilterString(from);
            sql += ",@toDate = " + FilterString(to);
            sql += ",@orderBy = " + FilterString(orderBy);
            sql += ",@membershipId = " + FilterString(senderId);
            sql += ",@prizeId = " + FilterString(giftItem);
            sql += ",@pageNumber = " + FilterString(pageNumber);
            sql += ",@pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }
        
        
        */
        public ReportResult GetAgentTargetRpt(string user, string agentId, string year, string month, string pageNumber, string pageSize)
        {
            string sql = "EXEC [proc_agentTargetRpt] @flag = 'rpt'";
            sql += ",@user=" + FilterString(user);
            sql += ",@agentId = " + FilterString(agentId);
            sql += ",@year = " + FilterString(year);
            sql += ",@month = " + FilterString(month);
            sql += ",@pageNumber = " + FilterString(pageNumber);
            sql += ",@pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }

        public ReportResult GetMultipleTxnAnalysisReport(string user, string flag, string fromDate, string toDate, string tranType, string reportBy, string customer,
               string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_MultipleTxnAnalysisReport @flag = " + FilterString(string.IsNullOrWhiteSpace(flag) ? "s" : flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@tranType = " + FilterString(tranType);
            sql += ",@reportBy = " + FilterString(reportBy);
            sql += ",@customer = " + FilterString(customer);
            sql += ",@pageNumber = " + FilterString(pageNumber);
            sql += ",@pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }


        public ReportResult AgentSummaryBalance(string user, string agentMapCode, string agentName, string agentGroup)
        {
            string sql = "EXEC  proc_agentSummaryBalanceReport @flag = " + FilterString("s");
            sql += ",@user=" + FilterString(user);
            sql += ",@mapCodeInt = " + FilterString(agentMapCode);
            sql += ",@agentName = " + FilterString(agentName);
            sql += ",@agentGroup =" + FilterString(agentGroup);
            return ParseReportResult(sql);
        }

        public ReportResult UnpaidTransactionReport(string user, string flag, string tranType, string agentId, string agentName)
        {
            string sql = "EXEC  proc_UnpaidTxnReport @flag = " + FilterString(flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@tranType = " + FilterString(tranType);
            sql += ",@agentId = " + FilterString(agentId);
            sql += ",@agentName = " + FilterString(agentName);
            return ParseReportResult(sql);
        }

        public ReportResult ReconcilationReport(string user, string flag, string agentId, string fromDate, string toDate, string isDocUpload)
        {
            string sql = "EXEC  proc_reconciliationReport @flag = " + FilterString(flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@agentId = " + FilterString(agentId);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@isDocUpload = " + FilterString(isDocUpload);
            return ParseReportResult(sql);
        }

        public ReportResult ReconcilationReport2(string user, string fromDate, string toDate, string userName, string box)
        {
            string sql = "EXEC  proc_reconciliationReport @flag = 'box-wise'";
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@userName = " + FilterString(userName);
            sql += ",@box = " + FilterString(box);
            return ParseReportResult(sql);
        }

        public ReportResult ReconcileUserWiseReport(string user, string fromDate, string toDate, string userName, string rptType)
        {
            string sql = "EXEC  proc_reconciliationReport";
            sql += " @flag=" + FilterString(rptType);
            sql += ",@user=" + FilterString(user);
            sql += ",@userName = " + FilterString(userName);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            return ParseReportResult(sql);
        }

        public ReportResult GetTranAnalysisDom(string user, string flag, string fromDate, string toDate, string dateType, string sendingAgent,
                                                string sendingCountry, string sendingBranch, string receivingCountry, string reecivingAgent,
                                                string receivingBranch, string groupBy, string reportType, string id, string status,
                                                string controlNo, string sLocation, string rLocation, string rZone, string rDistrict, string sZone, string sDistrict,
                                                string pageNumber, string pageSize, string groupById, string tranType, string searchBy, string searchByText,
                                                string fromTime, string toTime, string isExportFull, string remitProduct, string sAgentGrp, string rAgentGrp)
        {
            string sql = "EXEC proc_tranAnalysisDom ";
            sql += " @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @SendingAgent = " + FilterString(sendingAgent);
            sql += ", @SendingCountry = " + FilterString(sendingCountry);
            sql += ", @SendingBranch = " + FilterString(sendingBranch);
            sql += ", @ReceivingCountry = " + FilterString(receivingCountry);
            sql += ", @ReecivingAgent = " + FilterString(reecivingAgent);
            sql += ", @ReceivingBranch = " + FilterString(receivingBranch);
            sql += ", @groupBy = " + FilterString(groupBy);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @ReportType = " + FilterString(reportType);
            sql += ", @Id = " + FilterString(id);
            sql += ", @status = " + FilterString(status);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @rZone = " + FilterString(rZone);
            sql += ", @rDistrict = " + FilterString(rDistrict);
            sql += ", @sZone = " + FilterString(sZone);
            sql += ", @sDistrict = " + FilterString(sDistrict);
            sql += ", @sLocation = " + FilterString(sLocation);
            sql += ", @rLocation = " + FilterString(rLocation);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber =" + FilterString(pageNumber);
            sql += ", @groupById =" + FilterString(groupById);
            sql += ", @tranType =" + FilterString(tranType);
            sql += ", @searchBy =" + FilterString(searchBy);
            sql += ", @searchByText =" + FilterString(searchByText);
            sql += ", @fromTime =" + FilterString(fromTime);
            sql += ", @toTime =" + FilterString(toTime);
            sql += ", @isExportFull =" + FilterString(isExportFull);
            sql += ", @remitProduct =" + FilterString(remitProduct);
            sql += ", @sAgentGrp =" + FilterString(sAgentGrp);
            sql += ", @rAgentGrp =" + FilterString(rAgentGrp);
            return ParseReportResult(sql);
        }




        public ReportResult GetTranAnalysisIntl(string user, string flag, string fromDate, string toDate, string dateType, string sendingAgent,
                                                string sendingCountry, string sendingBranch, string receivingCountry, string reecivingAgent,
                                                string receivingBranch, string groupBy, string reportType, string id, string status,
                                                string controlNo, string rLocation, string rZone, string rDistrict,
                                                string pageNumber, string pageSize, string groupById, string tranType, string searchBy,
                                                string searchByText, string fromTime, string toTime, string isExportFull, string sAgentGrp, string rAgentGrp)
        {
            string sql = "EXEC proc_tranAnalysisIntl ";
            sql += " @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @SendingAgent = " + FilterString(sendingAgent);
            sql += ", @SendingCountry = " + FilterString(sendingCountry);
            sql += ", @SendingBranch = " + FilterString(sendingBranch);
            sql += ", @ReceivingCountry = " + FilterString(receivingCountry);
            sql += ", @ReecivingAgent = " + FilterString(reecivingAgent);
            sql += ", @ReceivingBranch = " + FilterString(receivingBranch);
            sql += ", @groupBy = " + FilterString(groupBy);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @ReportType = " + FilterString(reportType);
            sql += ", @Id = " + FilterString(id);
            sql += ", @status = " + FilterString(status);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @rZone = " + FilterString(rZone);
            sql += ", @rDistrict = " + FilterString(rDistrict);
            sql += ", @rLocation = " + FilterString(rLocation);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber =" + FilterString(pageNumber);
            sql += ", @groupById =" + FilterString(groupById);
            sql += ", @tranType =" + FilterString(tranType);
            sql += ", @searchBy =" + FilterString(searchBy);
            sql += ", @searchByText =" + FilterString(searchByText);
            sql += ", @fromTime =" + FilterString(fromTime);
            sql += ", @toTime =" + FilterString(toTime);
            sql += ", @isExportFull =" + FilterString(isExportFull);
            sql += ", @sAgentGrp =" + FilterString(sAgentGrp);
            sql += ", @rAgentGrp =" + FilterString(rAgentGrp);

            return ParseReportResult(sql);
        }

        public ReportResult QuickUnpaidReport(string user, string flag, string agentId, string searchBy, string searchText, string tranId)
        {
            string sql = "EXEC  proc_quickUnpaidReport @flag = " + FilterString(flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@sAgent = " + FilterString(agentId);
            sql += ",@searchBy = " + FilterString(searchBy);
            sql += ",@searchText = " + FilterString(searchText);
            sql += ",@tranId = " + FilterString(tranId);
            return ParseReportResult(sql);
        }

        public ReportResult DomesticTxtreport(string user, string flag, string fromDate, string toDate)
        {
            string sql = "EXEC  proc_domesticTxnRpt @flag = " + FilterString(flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate=" + FilterString(fromDate);
            sql += ",@toDate=" + FilterString(toDate);

            return ParseReportResult(sql);
        }

        public ReportResult GetCustomerEnrollmentReport(string user, string searchBy, string fromDate, string toDate, string zone,
            string agent, string membershipId, string ageGrp, string agentGrp)
        {
            string sql = "EXEC  proc_customerEnrollmentRptV2 @flag = " + FilterString(searchBy);
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@sZone = " + FilterString(zone);
            sql += ",@sAgent = " + FilterString(agent);
            sql += ",@memberShipId = " + FilterString(membershipId);
            sql += ",@ageGrp = " + FilterString(ageGrp);
            sql += ",@agentGrp = " + FilterString(agentGrp);
            return ParseReportResult(sql);
        }

        public ReportResult GetSoaMonthlyLogs(string user, string fromDate, string toDate, string year, string month, string agentId, string mc)
        {
            string sql = "EXEC proc_soaMonthlyLog @flag = 'rpt'";
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@npYear = " + FilterString(year);
            sql += ",@npMonth = " + FilterString(month);
            sql += ",@agentId = " + FilterString(agentId);
            sql += ",@mc = " + FilterString(mc);
            return ParseReportResult(sql);
        }

        public ReportResult GetPayableReport(string user, string fromDate, string toDate, string sAgent, string rptType)
        {
            string sql = "EXEC  IMEKL.DBO.Proc_Remittance_Payable_v2";
            sql += " @rptType = " + FilterString(rptType);
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@sAgent = " + FilterString(sAgent);

            return ParseReportResult(sql);
        }

        public ReportResult GetCertificateExpiryReport(string user, string fromDate, string toDate, string agentId)
        {
            string sql = "EXEC proc_certificateExpiryReport @flag = 'rpt'";
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@agentId = " + FilterString(agentId);
            return ParseReportResult(sql);
        }

        public ReportResult GetUserwiseCustomerApproval(string user, string fromDate, string toDate, string userName, string rptType, string cardType)
        {
            string sql = "EXEC proc_customerApprovalRpt";
            sql += " @flag=" + FilterString(rptType);
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@userName = " + FilterString(userName);
            sql += ",@cardType = " + FilterString(cardType);
            return ParseReportResult(sql);
        }

        public ReportResult GetCustomerTxnReport(string user, string searchBy, string fromDate, string toDate,
            string zone, string agent, string membershipId, string slab, string agentGrp)
        {
            string sql = "EXEC proc_customerTxnRpt @flag = " + FilterString(searchBy);
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@sZone = " + FilterString(zone);
            sql += ",@sAgent = " + FilterString(agent);
            sql += ",@memberShipId = " + FilterString(membershipId);
            sql += ",@slab = " + FilterString(slab);
            sql += ",@agentGrp = " + FilterString(agentGrp);
            return ParseReportResult(sql);
        }

        public ReportResult GetCustomerBonusReport(string user, string searchBy, string fromDate, string toDate,
            string zone, string agent, string membershipId, string slab)
        {
            string sql = "EXEC  proc_customerBonusRpt @flag = " + FilterString(searchBy);
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@sZone = " + FilterString(zone);
            sql += ",@sAgent = " + FilterString(agent);
            sql += ",@memberShipId = " + FilterString(membershipId);
            sql += ",@slab = " + FilterString(slab);
            return ParseReportResult(sql);
        }

        public DbResult MakeAgentTemplate(string user, string tranInfo, string tranInfoAlias, string templateName)
        {
            string sql = "EXEC proc_agentMasterRptTemplete ";
            sql += "  @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentInfo = " + FilterString(tranInfo);
            sql += ", @agentInfoAlias = " + FilterString(tranInfoAlias);
            sql += ", @templateName = " + FilterString(templateName);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public ReportResult GetThrasholdTransReport(string user, string fromDate, string toDate, string txnAmt, string rptType, string rptNature)
        {
            string sql = "EXEC proc_thrasholdTransReport ";
            sql += " @flag = " + FilterString(rptType);
            sql += ",@user = " + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@txnAmt = " + FilterString(txnAmt);
            sql += ",@rptNature = " + FilterString(rptNature);
            return ParseReportResult(sql);
        }

        public ReportResult GetTxnReport(string user, string fromDate, string toDate, string rptType, string dateType)
        {
            string sql = "exec proc_domesticTransactionReport";
            sql += " @flag= 'TXNR'";
            sql += " ,@user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @rptType = " + FilterString(rptType);
            sql += ", @dateType = " + FilterString(dateType);
            return ParseReportResult(sql);
        }

        public ReportResult GetTxnDetailReport(string user, string fromDate, string toDate, string rptType, string agent, string dateType)
        {
            string sql = "exec proc_domesticTransactionReport";
            sql += " @flag= 'domtxndetail'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @rptType = " + FilterString(rptType);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @agent = " + FilterString(agent);
            return ParseReportResult(sql);
        }

        public ReportResult GetGiblSearchTransaction(string user, string fromDate, string toDate, string searchBy, string searchValue)
        {
            string sql = "EXEC proc_gbilSearchTxn @flag='rpt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @searchBy = " + FilterString(searchBy);
            sql += ", @searchValue = " + FilterString(searchValue);
            return ParseReportResult(sql);
        }
        public ReportResult GetOverseasTxnSummaryReport(string user, string sBranch, string sAgent, string pCountry, string pAgent, string status, string dateType
           , string fromDate, string toDate, string rptType, string countryBankId, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_GetOverseasTxnSummaryRpt ";
            sql += "  @user = " + FilterString(user);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgentId = " + FilterString(pAgent);
            sql += ", @status = " + FilterString(status);
            sql += ", @DateType = " + FilterString(dateType);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(rptType);
            sql += ", @countryBankId = " + FilterString(countryBankId);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }

        public ReportResult GetCustomerRecordAnalysis(string user, string flag, string fromDate, string toDate, string dateType, string sendingAgent,
                                                string sendingCountry, string sendingBranch, string receivingCountry, string reecivingAgent,
                                                string receivingBranch, string groupBy, string reportType, string id, string status,
                                                string controlNo, string rLocation, string rZone, string rDistrict,
                                                string pageNumber, string pageSize, string groupById, string tranType, string searchBy,
                                                string searchByText, string fromTime, string toTime, string isExportFull, string sAgentGrp, string rAgentGrp)
        {
            string sql = "EXEC proc_customersUpload_Rpt ";
            sql += " @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @SendingAgent = " + FilterString(sendingAgent);
            sql += ", @SendingCountry = " + FilterString(sendingCountry);
            sql += ", @SendingBranch = " + FilterString(sendingBranch);
            sql += ", @ReceivingCountry = " + FilterString(receivingCountry);
            sql += ", @ReecivingAgent = " + FilterString(reecivingAgent);
            sql += ", @ReceivingBranch = " + FilterString(receivingBranch);
            sql += ", @groupBy = " + FilterString(groupBy);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @ReportType = " + FilterString(reportType);
            sql += ", @Id = " + FilterString(id);
            sql += ", @status = " + FilterString(status);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @rZone = " + FilterString(rZone);
            sql += ", @rDistrict = " + FilterString(rDistrict);
            sql += ", @rLocation = " + FilterString(rLocation);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber =" + FilterString(pageNumber);
            sql += ", @groupById =" + FilterString(groupById);
            sql += ", @tranType =" + FilterString(tranType);
            sql += ", @searchBy =" + FilterString(searchBy);
            sql += ", @searchByText =" + FilterString(searchByText);
            sql += ", @fromTime =" + FilterString(fromTime);
            sql += ", @toTime =" + FilterString(toTime);
            sql += ", @isExportFull =" + FilterString(isExportFull);
            sql += ", @sAgentGrp =" + FilterString(sAgentGrp);
            sql += ", @rAgentGrp =" + FilterString(rAgentGrp);

            return ParseReportResult(sql);
        }
        public ReportResult GetApproveCustomerSearch(string flag, string user, string fromDate, string toDate, string status, string zone, string district,
         string agentGrp, string agent, string isDocUploaded, string membershipId)
        {
            string sql = "EXEC proc_approveCustomerRpt";
            sql += " @flag=" + FilterString(flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@status = " + FilterString(status);
            sql += ",@zone = " + FilterString(zone);
            sql += ",@district = " + FilterString(district);
            sql += ",@agentGrp = " + FilterString(agentGrp);
            sql += ",@agentId = " + FilterString(agent);
            sql += ",@isDoc = " + FilterString(isDocUploaded);
            sql += ",@membershipId = " + FilterString(membershipId);
            return ParseReportResult(sql);
        }


        public ReportResult GetCustomerCardExpiryRpt(string user, string asOnDate, string zone, string district, string agentGrp, string agent, string reportType, string idType)
        {
            string sql = "EXEC proc_CustomerCardExpiryRpt";
            sql += "  @flag = " + FilterString(reportType);
            sql += ", @user = " + FilterString(user);
            sql += ", @asOnDate = " + FilterString(asOnDate);
            sql += ", @zone = " + FilterString(zone);
            sql += ", @district = " + FilterString(district);
            sql += ", @agentGrp = " + FilterString(agentGrp);
            sql += ", @agent = " + FilterString(agent);
            sql += ", @idType = " + FilterString(idType);
            return ParseReportResult(sql);
        }

        public ReportResult GetAgentwiseCustomerActivation(string user, string fromDate, string toDate, string cardType, string flag, string agent, string zone)
        {
            string sql = "EXEC proc_customerApprovalRpt @flag = " + FilterString(flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@cardType = " + FilterString(cardType);
            sql += ",@agentState = " + FilterString(zone);
            sql += ",@agentId = " + FilterString(agent);
            return ParseReportResult(sql);
        }

        public ReportResult GetCreditSecurityRptForRegional(string user, string zone, string district, string location, string agent, string securitytype, string groupby, string isexpiry, string date)
        {
            string sql = "EXEC proc_agentSecurityRegionalReport @flag='rpt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @zoneName = " + FilterString(zone);
            sql += ", @districtName = " + FilterString(district);
            sql += ", @locationId = " + FilterString(location);
            sql += ", @agentId = " + FilterString(agent);
            sql += ", @securityType = " + FilterString(securitytype);
            sql += ", @isExpiry = " + FilterString(isexpiry);
            sql += ", @groupBy = " + FilterString(groupby);
            sql += ", @date = " + FilterString(date);
            return ParseReportResult(sql);
        }
        public ReportResult GetAgentwiseCustomerDcUpload(string user, string fromDate, string toDate, string cardType, string flag, string agent, string zone)
        {
            string sql = "EXEC proc_customerApprovalRpt @flag = " + FilterString(flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@cardType = " + FilterString(cardType);
            sql += ",@agentState = " + FilterString(zone);
            sql += ",@agentId = " + FilterString(agent);
            return ParseReportResult(sql);
        }
        public ReportResult GetAcDepositPaidIsoRpt(string user, string rptType, string sendingAgent, string beneficiaryCountry, string bankId,
            string tranType, string fromDate, string toDate, string dateType, string fromTime, string toTime, string logStatus,
            string paidUser, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_acDepositPaidISOReport @flag=" + FilterString(rptType);
            sql += ", @user = " + FilterString(user);
            sql += ", @sendingAgent = " + FilterString(sendingAgent);
            sql += ", @beneficiaryCountry = " + FilterString(beneficiaryCountry);
            sql += ", @bankId = " + FilterString(bankId);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);
            sql += ", @paidUser = " + FilterString(paidUser);
            sql += ", @logStatus = " + FilterString(logStatus);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }

        public ReportResult DepositVoucherReport(string user, string fromDate, string toDate, string agent, string bank)
        {
            string sql = "EXEC  proc_fundDeposit @flag = 'rpt'";
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@agentId = " + FilterString(agent);
            sql += ",@bankId = " + FilterString(bank);
            return ParseReportResult(sql);
        }
        public ReportResult ReconcilationReportForAgent(string user, string flag, string agentId, string fromDate, string toDate, string isDocUpload, string icn)
        {
            string sql = "EXEC  proc_reconciliationReportAgent @flag = " + FilterString(flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@agentId = " + FilterString(agentId);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@isDocUpload = " + FilterString(isDocUpload);
            sql += ",@icn = " + FilterString(icn);
            return ParseReportResult(sql);
        }
    }
}