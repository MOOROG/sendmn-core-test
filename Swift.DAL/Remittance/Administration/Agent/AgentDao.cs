using System;
using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration.Agent
{
    public class AgentDao : SwiftDao
    {
        #region Agent

        public DbResult Update(string user
                               , string agentId
                               , string parentId
                               , string agentName
                               , string agentAddress
                               , string agentCity
                               , string agentCountryId
                               , string agentCountry
                               , string agentState
                               , string agentDistrict
                               , string agentZip
                               , string agentLocation
                               , string agentPhone1
                               , string agentPhone2
                               , string agentFax1
                               , string agentFax2
                               , string agentMobile1
                               , string agentMobile2
                               , string agentEmail1
                               , string agentEmail2
                               , string businessOrgType
                               , string businessType
                               , string agentRole
                               , string agentType
                               , string allowAccountDeposit
                               , string actAsBranch
                               , string contractExpiryDate
                               , string renewalFollowupDate
                               , string isSettlingAgent
                               , string agentGroup
                               , string businessLicense
                               , string agentBlock
                               , string agentCompanyName
                               , string companyAddress
                               , string companyCity
                               , string companyCountry
                               , string companyState
                               , string companyDistrict
                               , string companyZip
                               , string companyPhone1
                               , string companyPhone2
                               , string companyFax1
                               , string companyFax2
                               , string companyEmail1
                               , string companyEmail2
                               , string localTime
                               , string agentDetails
                               , string isActive
                               , string headMessage
                               , string mapCodeInt
                               , string mapCodeDom
                               , string commCodeInt
                               , string commCodeDom
                               , string mapCodeIntAc
                               , string mapCodeDomAc
                               , string payOption
                               , string agentSettCurr
                               , string contactPerson1
                               , string contactPerson2
                               , string isHeadOffice
                               , string extCode
                                )
        {
            string sql = "EXEC proc_agentMaster";
            sql += " @flag = " + (agentId == "0" || agentId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @parentId = " + FilterString(parentId);
            sql += ", @agentName = " + FilterString(agentName);
            sql += ", @agentAddress = " + FilterString(agentAddress);
            sql += ", @agentCity = " + FilterString(agentCity);
            sql += ", @agentCountryId = " + FilterString(agentCountryId);
            sql += ", @agentCountry = " + FilterString(agentCountry);
            sql += ", @agentState = " + FilterString(agentState);
            sql += ", @agentDistrict = " + FilterString(agentDistrict);
            sql += ", @agentZip = " + FilterString(agentZip);
            sql += ", @agentLocation = " + FilterString(agentLocation);
            sql += ", @agentPhone1 = " + FilterString(agentPhone1);
            sql += ", @agentPhone2 = " + FilterString(agentPhone2);
            sql += ", @agentFax1 = " + FilterString(agentFax1);
            sql += ", @agentFax2 = " + FilterString(agentFax2);
            sql += ", @agentMobile1 = " + FilterString(agentMobile1);
            sql += ", @agentMobile2 = " + FilterString(agentMobile2);
            sql += ", @agentEmail1 = " + FilterString(agentEmail1);
            sql += ", @agentEmail2 = " + FilterString(agentEmail2);
            sql += ", @businessOrgType = " + FilterString(businessOrgType);
            sql += ", @businessType = " + FilterString(businessType);
            sql += ", @agentRole = " + FilterString(agentRole);
            sql += ", @agentType = " + FilterString(agentType);
            sql += ", @allowAccountDeposit = " + FilterString(allowAccountDeposit);
            sql += ", @actAsBranch = " + FilterString(actAsBranch);
            sql += ", @contractExpiryDate = " + FilterString(contractExpiryDate);
            sql += ", @renewalFollowupDate = " + FilterString(renewalFollowupDate);
            sql += ", @isSettlingAgent = " + FilterString(isSettlingAgent);
            sql += ", @agentGroup = " + FilterString(agentGroup);
            sql += ", @businessLicense = " + FilterString(businessLicense);
            sql += ", @agentBlock = " + FilterString(agentBlock);
            sql += ", @agentCompanyName = " + FilterString(agentCompanyName);
            sql += ", @companyAddress = " + FilterString(companyAddress);
            sql += ", @companyCity = " + FilterString(companyCity);
            sql += ", @companyCountry = " + FilterString(companyCountry);
            sql += ", @companyState = " + FilterString(companyState);
            sql += ", @companyDistrict = " + FilterString(companyDistrict);
            sql += ", @companyZip = " + FilterString(companyZip);
            sql += ", @companyPhone1 = " + FilterString(companyPhone1);
            sql += ", @companyPhone2 = " + FilterString(companyPhone2);
            sql += ", @companyFax1 = " + FilterString(companyFax1);
            sql += ", @companyFax2 = " + FilterString(companyFax2);
            sql += ", @companyEmail1 = " + FilterString(companyEmail1);
            sql += ", @companyEmail2 = " + FilterString(companyEmail2);
            sql += ", @localTime = " + FilterString(localTime);
            sql += ", @agentDetails = " + FilterString(agentDetails);
            sql += ", @isActive = " + FilterString(isActive);
            sql += ", @headMessage = " + FilterString(headMessage);
            sql += ", @mapCodeInt = " + FilterString(mapCodeInt);
            sql += ", @mapCodeDom = " + FilterString(mapCodeDom);
            sql += ", @commCodeInt = " + FilterString(commCodeInt);
            sql += ", @commCodeDom = " + FilterString(commCodeDom);
            sql += ", @mapCodeIntAc = " + FilterString(mapCodeIntAc);
            sql += ", @mapCodeDomAc = " + FilterString(mapCodeDomAc);
            sql += ", @payOption = " + FilterString(payOption);
            sql += ", @agentSettCurr=" + FilterString(agentSettCurr);
            sql += ", @contactPerson1=" + FilterString(contactPerson1);
            sql += ", @contactPerson2=" + FilterString(contactPerson2);
            sql += ", @isHeadOffice=" + FilterString(isHeadOffice);
            sql += ", @extCode=" + FilterString(extCode);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string agentId)
        {
            string sql = "EXEC proc_agentMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string agentId)
        {
            string sql = "EXEC proc_agentMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SelectByUser(string user)
        {
            string sql = "EXEC proc_agentMaster";
            sql += " @flag = 'au'";
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string agentId)
        {
            string sql = "EXEC proc_agentMaster";
            sql += " @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string agentId)
        {
            string sql = "EXEC proc_agentMaster";
            sql += " @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        #endregion

        #region Agent Limit

        public DbResult UpdateLimit(string user, string agentId, string AC_ID, string DR_LIMIT, string LIMIT_EXPIRY)
        {
            string sql = "EXEC proc_agentLimit";
            sql += " @flag = " + (agentId == "0" || agentId == "" ? "" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            sql += ", @AC_ID = " + FilterString(AC_ID);
            sql += ", @DR_LIMIT = " + FilterString(DR_LIMIT);
            sql += ", @LIMIT_EXPIRY = " + FilterString(LIMIT_EXPIRY);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        //public DbResult DeleteLimit(string user, string ROWID)
        //{
        //    var sql = "EXEC proc_agentLimit";
        //    sql += " @flag = 'd'";
        //    sql += ", @user = " + FilterString(user);
        //    sql += ", @ROWID = " + FilterString(ROWID);

        //    return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        //}

        public DataRow SelectByIdLimit(string user, string agentId)
        {
            string sql = "EXEC proc_agentLimit";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #endregion

        #region Agent Functions

        public DbResult UpdateAgentFunction(string user, string FUN_ID, string agentId, string SERVICE_TYPE,
                                            string TRANSACTION_FEES, string DEFAULT_DEPOSIT_MODE,
                                            string INVOICE_PRINT_MODE, string CURRENCY, string COMM_SCHEME_CODE,
                                            string RECEIVING_AGENTS, string RECEIVINGCountry, string GLOBAL_TRN,
                                            string TRANSACTION_MODE, string SEND_TO_RECEIVER, string SEND_TO_SENDER,
                                            string TRN_QUESTION, string MOBILE_FORMAT, string TIME_ZONE,
                                            string ENABLE_WISHES)
        {
            string sql = "EXEC proc_AGENT_FUNCTION";
            sql += " @flag = " + (FUN_ID == "0" || FUN_ID == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @FUN_ID = " + FilterString(FUN_ID);

            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @SERVICE_TYPE = " + FilterString(SERVICE_TYPE);
            sql += ", @TRANSACTION_FEES = " + FilterString(TRANSACTION_FEES);
            sql += ", @DEFAULT_DEPOSIT_MODE = " + FilterString(DEFAULT_DEPOSIT_MODE);
            sql += ", @INVOICE_PRINT_MODE = " + FilterString(INVOICE_PRINT_MODE);
            sql += ", @CURRENCY = " + FilterString(CURRENCY);
            sql += ", @COMM_SCHEME_CODE = " + FilterString(COMM_SCHEME_CODE);
            sql += ", @RECEIVING_AGENTS = " + FilterString(RECEIVING_AGENTS);
            sql += ", @RECEIVINGCountry = " + FilterString(RECEIVINGCountry);
            sql += ", @GLOBAL_TRN = " + FilterString(GLOBAL_TRN);
            sql += ", @TRANSACTION_MODE = " + FilterString(TRANSACTION_MODE);
            sql += ", @SEND_TO_RECEIVER = " + FilterString(SEND_TO_RECEIVER);
            sql += ", @SEND_TO_SENDER = " + FilterString(SEND_TO_SENDER);
            sql += ", @TRN_QUESTION = " + FilterString(TRN_QUESTION);
            sql += ", @MOBILE_FORMAT = " + FilterString(MOBILE_FORMAT);
            sql += ", @TIME_ZONE = " + FilterString(TIME_ZONE);
            sql += ", @ENABLE_WISHES = " + FilterString(ENABLE_WISHES);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteAgentFunction(string user, string FUN_ID)
        {
            string sql = "EXEC proc_AGENT_FUNCTION";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @FUN_ID = " + FilterString(FUN_ID);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectByIdAgentFunction(string user, string FUN_ID)
        {
            string sql = "EXEC proc_AGENT_FUNCTION";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @FUN_ID = " + FilterString(FUN_ID);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #endregion

        public string SelectAgentById(string id)
        {
            string sql =
                "SELECT agentName = am.agentName + '|' + CAST(am.agentId AS VARCHAR) FROM agentMaster am WITH(NOLOCK) WHERE am.agentId=" +
                FilterString(id);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables[0] == null)
                return "";
            return ds.Tables[0].Rows[0][0].ToString();
        }

        public DataRow PullDefaultValueById(string user, string parentAgentId)
        {
            string sql = "EXEC proc_agentMaster";
            sql += " @flag = 'pullDefault'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(parentAgentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public string SelectAgent(string id)
        {
            string sql =
                "SELECT agentName = am.agentName + '|' + CAST(am.agentId AS VARCHAR) + '|' + CAST(am.agentType AS VARCHAR) FROM agentMaster am WITH(NOLOCK) WHERE am.agentId=" +
                FilterString(id);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables[0] == null || ds.Tables[0].Rows.Count == 0)
                return "";
            return ds.Tables[0].Rows[0][0].ToString();
        }

        public DataTable PopulateNode(string user, string parentId)
        {
            string sql = "EXEC proc_agentMaster";
            sql += " @flag = 't'";
            sql += ", @user = " + FilterString(user);
            sql += ", @parentId = " + FilterString(parentId);
            return ExecuteDataset(sql).Tables[0];
        }

        public string CheckAgentType(string pid)
        {
            string sql = "SELECT agentType FROM agentMaster a WITH(NOLOCK) WHERE agentId=" + FilterString(pid);
            return GetSingleResult(sql);
        }

        public string GetParentAgentSettlementStatus(string agentId)
        {
            string sql = "SELECT isSettlingAgent FROM agentMaster WITH(NOLOCK) WHERE agentId = " + FilterString(agentId);
            return GetSingleResult(sql);
        }

        public int GetTotalNoOfAgents()
        {
            var sql = "EXEC proc_agentMaster @flag = 'n'";
            return Convert.ToInt32(GetSingleResult(sql));
        }

        #region AgentBusinessHistory

        public DataTable PopulateGridData(string qry)
        {
            string sql = qry;

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DbResult UpdateABH(string user, string agentId, string remitCompany, string fromDate, string toDate)
        {
            string sql = "EXEC proc_agentBusinessHistory";
            //sql += " @flag = " + (CURR_ID == "0" || CURR_ID == "" ? "'i'" : "'u'");
            sql += " @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @remitCompany = " + FilterString(remitCompany);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteABH(string user, string abhId)
        {
            string sql = "EXEC proc_agentBusinessHistory";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @abhID = " + FilterString(abhId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        #endregion

        #region AgentFinancialService

        public DbResult UpdateAFSList(string user, string agentId, string serviceList)
        {
            string sql = "EXEC proc_agentFinancialService";
            sql += " @flag = 'i'";
            sql += ",@user = " + FilterString(user);
            sql += ",@agentId = " + FilterString(agentId);
            sql += ",@serviceList = " + FilterString(serviceList);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ParseDbResult(ds.Tables[0]);
        }

        public DbResult DeleteAFS(string user, string afsId)
        {
            string sql = "EXEC proc_agentFinancialService";
            sql += " @flag = 'd'";
            sql += ",@user = " + FilterString(user);
            sql += ",@afsId = " + FilterString(afsId);


            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ParseDbResult(ds.Tables[0]);
        }

        #endregion



        public DataSet DisplayMatchAgent(string user, string district)
        {
            var sql = "EXEC proc_agentMaster @flag = 'findAgent'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentDistrict = " + FilterString(district);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
        public DataSet DisplayMatchAgentWithDisLoc(string user, string district, string locationCode)
        {
            var sql = "EXEC proc_agentMaster @flag = 'agentDisLoc'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentDistrict = " + FilterString(district);
            sql += ", @locationCode = " + FilterString(locationCode);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
    }
}