using System.Data;
using Swift.DAL.SwiftDAL;
#pragma warning disable CS0234 // The type or namespace name 'PayTransaction' does not exist in the namespace 'Swift.API.Common' (are you missing an assembly reference?)
using Swift.API.Common.PayTransaction;
#pragma warning restore CS0234 // The type or namespace name 'PayTransaction' does not exist in the namespace 'Swift.API.Common' (are you missing an assembly reference?)

namespace Swift.DAL.BL.Remit.Transaction
{
    public class PayTransactionDao : RemittanceDao
    {
        public DataRow SelectTransaction(string controlNo, string user)
        {
            string sql = "EXEC proc_payTran @flag = 'details'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #region API Method
        public DataSet HoSearchDomesticTranV2(string user, string pBranch, string controlNo)
        {
            var sql = "EXEC proc_payTranHoAPI_v2 @flag = 'paySearchDom'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @controlNo = " + FilterString(controlNo);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DataSet HoSearchTransactionAPI(string user, string pBranch, string controlNo, string agentRefId)
        {
            string sql = "EXEC proc_payTranHoAPI @flag = 'dap'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);

            DataSet ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DbResult HoPayDomesticTranV2(string user, string pBranch, string controlNo, string agentRefId,
                                string rIdType, string rIdNumber, string rPlaceOfIssue, string rMobile,
                                string rRelationType, string rRelativeName)
        {
            var sql = "EXEC proc_payTranHoAPI_v2";
            sql += "  @flag = 'payDom'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNumber = " + FilterString(rIdNumber);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @rRelationType = " + FilterString(rRelationType);
            sql += ", @rRelativeName = " + FilterString(rRelativeName);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow HoPayAPI(string user, string pBranch, string sBranchCode, string controlNo, string agentRefId,
                                string paymentType, string sCountry, string rIdType, string rIdNumber, string rPlaceOfIssue,
                                string rRelativeName, string rMobile, string cAmt, string payoutAmt, string serviceCharge,
                                string pLocation)
        {
            string sql = "EXEC proc_payTranHoAPI";
            sql += "  @flag = 'payAPI'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @sBranchCode = " + FilterString(sBranchCode);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            sql += ", @paymentType = " + FilterString(paymentType);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNumber = " + FilterString(rIdNumber);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @rRelativeName = " + FilterString(rRelativeName);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @cAmt = " + FilterString(cAmt);
            sql += ", @payoutAmt = " + FilterString(payoutAmt);
            sql += ", @serviceCharge = " + FilterString(serviceCharge);
            sql += ", @pLocation = " + FilterString(pLocation);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult HoPay(string user
                            , string tranId
                            , string controlNo
                            , string pBranch
                            , string payTokenId
                            , string sBranchCode
                            , string sBranchName
                            , string txnDate
                            , string sFirstName
                            , string sMiddleName
                            , string sLastName1
                            , string sLastName2
                            , string sAddress
                            , string sMobile
                            , string sCity
                            , string sCountry
                            , string rFirstName
                            , string rMiddleName
                            , string rLastName1
                            , string rLastName2
                            , string rAddress
                            , string rMobile
                            , string rContactNo
                            , string rCity
                            , string rCountry
                            , string rIdType
                            , string rIdNumber
                            , string rPlaceOfIssue
                            , string rIssuedDate
                            , string rValidDate
                            , string payoutAmt
                            , string payoutCurr
                            , string paymentType
                            , string sLocation
                            , string pLocation
                            , string tAmt
                            , string collCurr
                            , string serviceCharge
                            , string cAmt
                            , string sAgentComm
                            , string custRate
                            , string sendUser
                            , string sIdType
                            , string sIdNo
                            , string sIdValidDate
                            , string sAddress1
                            , string sAddress2
                            , string sqlScript
                            , string extCustomerId)
        {
            string sql = "EXEC proc_payTranHoAPI";
            sql += "  @flag = 'pay'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @payTokenId = " + FilterString(payTokenId);

            sql += ", @sBranchCode = " + FilterString(sBranchCode);
            sql += ", @sBranchName = " + FilterString(sBranchName);
            sql += ", @txnDate = " + FilterString(txnDate);
            sql += ", @sFirstName = " + FilterString(sFirstName);
            sql += ", @sMiddleName = " + FilterString(sMiddleName);
            sql += ", @sLastName1 = " + FilterString(sLastName1);
            sql += ", @sLastName2 = " + FilterString(sLastName2);
            sql += ", @sAddress = " + FilterString(sAddress);
            sql += ", @sMobile = " + FilterString(sMobile);
            sql += ", @sCity = " + FilterString(sCity);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rFirstName = " + FilterString(rFirstName);
            sql += ", @rMiddleName = " + FilterString(rMiddleName);
            sql += ", @rLastName1 = " + FilterString(rLastName1);
            sql += ", @rLastName2 = " + FilterString(rLastName2);
            sql += ", @rAddress = " + FilterString(rAddress);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @rContactNo = " + FilterString(rContactNo);
            sql += ", @rCity = " + FilterString(rCity);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNumber = " + FilterString(rIdNumber);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @rIssuedDate = " + FilterString(rIssuedDate);
            sql += ", @rValidDate = " + FilterString(rValidDate);
            sql += ", @payoutAmt = " + FilterString(payoutAmt);
            sql += ", @payoutCurr = " + FilterString(payoutCurr);
            sql += ", @paymentType = " + FilterString(paymentType);
            sql += ", @sLocation = " + FilterString(sLocation);
            sql += ", @pLocation = " + FilterString(pLocation);
            sql += ", @tAmt = " + FilterString(tAmt);
            sql += ", @collCurr = " + FilterString(collCurr);
            sql += ", @serviceCharge = " + FilterString(serviceCharge);
            sql += ", @cAmt = " + FilterString(cAmt);
            sql += ", @sAgentComm = " + FilterString(sAgentComm);
            sql += ", @custRate = " + FilterString(custRate);
            sql += ", @sendUser = " + FilterString(sendUser);
            sql += ", @sIdType = " + FilterString(sIdType);
            sql += ", @sIdNo = " + FilterString(sIdType);
            sql += ", @sIdValidDate = " + FilterString(sIdValidDate);
            sql += ", @sAddress1 = " + FilterString(sAddress1);
            sql += ", @sAddress2 = " + FilterString(sAddress2);
            sql += ", @sql = '" + sqlScript + "'";
            sql += ", @extCustomerId = " + FilterString(extCustomerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult HoPayIntl(string user
                            , string tranId
                            , string controlNo
                            , string pBranch
                            , string payTokenId
                            , string sBranchCode
                            , string sBranchName
                            , string txnDate
                            , string sFirstName
                            , string sMiddleName
                            , string sLastName1
                            , string sLastName2
                            , string sAddress
                            , string sMobile
                            , string sCity
                            , string sCountry
                            , string rFirstName
                            , string rMiddleName
                            , string rLastName1
                            , string rLastName2
                            , string rAddress
                            , string rMobile
                            , string rContactNo
                            , string rCity
                            , string rCountry
                            , string rIdType
                            , string rIdNumber
                            , string rPlaceOfIssue
                            , string rIssuedDate
                            , string rValidDate
                            , string payoutAmt
                            , string payoutCurr
                            , string paymentType
                            , string sLocation
                            , string pLocation
                            , string tAmt
                            , string collCurr
                            , string serviceCharge
                            , string cAmt
                            , string sAgentComm
                            , string custRate
                            , string sendUser
                            , string sIdType
                            , string sIdNo
                            , string sIdValidDate
                            , string sAddress1
                            , string sAddress2
                            , string sqlScript
                            , string extCustomerId)
        {
            string sql = "EXEC proc_payTranHoAPI";
            sql += "  @flag = 'payIntl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @payTokenId = " + FilterString(payTokenId);
            sql += ", @sBranchCode = " + FilterString(sBranchCode);
            sql += ", @sBranchName = " + FilterString(sBranchName);
            sql += ", @txnDate = " + FilterString(txnDate);
            sql += ", @sFirstName = " + FilterString(sFirstName);
            sql += ", @sMiddleName = " + FilterString(sMiddleName);
            sql += ", @sLastName1 = " + FilterString(sLastName1);
            sql += ", @sLastName2 = " + FilterString(sLastName2);
            sql += ", @sAddress = " + FilterString(sAddress);
            sql += ", @sMobile = " + FilterString(sMobile);
            sql += ", @sCity = " + FilterString(sCity);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rFirstName = " + FilterString(rFirstName);
            sql += ", @rMiddleName = " + FilterString(rMiddleName);
            sql += ", @rLastName1 = " + FilterString(rLastName1);
            sql += ", @rLastName2 = " + FilterString(rLastName2);
            sql += ", @rAddress = " + FilterString(rAddress);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @rContactNo = " + FilterString(rContactNo);
            sql += ", @rCity = " + FilterString(rCity);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNumber = " + FilterString(rIdNumber);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @rIssuedDate = " + FilterString(rIssuedDate);
            sql += ", @rValidDate = " + FilterString(rValidDate);
            sql += ", @payoutAmt = " + FilterString(payoutAmt);
            sql += ", @payoutCurr = " + FilterString(payoutCurr);
            sql += ", @paymentType = " + FilterString(paymentType);
            sql += ", @sLocation = " + FilterString(sLocation);
            sql += ", @pLocation = " + FilterString(pLocation);
            sql += ", @tAmt = " + FilterString(tAmt);
            sql += ", @collCurr = " + FilterString(collCurr);
            sql += ", @serviceCharge = " + FilterString(serviceCharge);
            sql += ", @cAmt = " + FilterString(cAmt);
            sql += ", @sAgentComm = " + FilterString(sAgentComm);
            sql += ", @custRate = " + FilterString(custRate);
            sql += ", @sendUser = " + FilterString(sendUser);
            sql += ", @sIdType = " + FilterString(sIdType);
            sql += ", @sIdNo = " + FilterString(sIdType);
            sql += ", @sIdValidDate = " + FilterString(sIdValidDate);
            sql += ", @sAddress1 = " + FilterString(sAddress1);
            sql += ", @sAddress2 = " + FilterString(sAddress2);
            sql += ", @sql = '" + sqlScript + "'";
            sql += ", @extCustomerId = " + FilterString(extCustomerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet SearchTransactionAPI(string user, string pBranch, string controlNo, string agentRefId, string pAgent, string mapCode, string fromPayTrnTime, string toPayTrnTime)
        {
            string sql = "EXEC proc_payTranAPI @flag = 'dap'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @mapCode = " + FilterString(mapCode);
            sql += ", @fromPayTrnTime = " + FilterString(fromPayTrnTime);
            sql += ", @toPayTrnTime = " + FilterString(toPayTrnTime);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DataSet SearchDomesticTranV2(string user, string pBranch, string controlNo, string pAgent, string fromPayTrnTime, string toPayTrnTime)
        {
            var sql = "EXEC proc_payTranAPI_v2 @flag = 'paySearchDom'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromPayTrnTime = " + FilterString(fromPayTrnTime);
            sql += ", @toPayTrnTime = " + FilterString(toPayTrnTime);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds; 
        }

        public DbResult PayDomesticV2(string user, string controlNo, string agentRefId, string rIdType, string rIdNumber, string rPlaceOfIssue,
            string rMobile, string rRelaiveType, string rRelativeName, 
            string pBranch, string pBranchName, string pAgent, string pAgentName, string pSuperAgent, string pSuperAgentName, string settlingAgent, string mapCode, string mapCodeDom)
        {
            var sql = "EXEC proc_payTranAPI_v2 @flag ='payDom'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNumber = " + FilterString(rIdNumber);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @rRelationType = " + FilterString(rRelaiveType);
            sql += ", @rRelativeName = " + FilterString(rRelativeName);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @pBranchName = " + FilterString(pBranchName);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pAgentName = " + FilterString(pAgentName);
            sql += ", @pSuperAgent = " + FilterString(pSuperAgent);
            sql += ", @pSuperAgentName = " + FilterString(pSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(settlingAgent);
            sql += ", @mapCode = " + FilterString(mapCode);
            sql += ", @mapCodeDom = " + FilterString(mapCodeDom);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DataRow PayAPI(string user, string pBranch, string sBranchCode, string controlNo, string agentRefId, 
                                string paymentType, string sCountry, string rIdType, string rIdNumber, string rPlaceOfIssue, 
                                string rRelativeName, string rMobile, string cAmt, string payoutAmt, string serviceCharge,
                                string pLocation,
                                string pBranchName, string pAgent, string pAgentName, string pSuperAgent, string pSuperAgentName, string settlingAgent, string mapCode, string mapCodeDom)
        {
            string sql = "EXEC proc_payTranAPI";
            sql += "  @flag = 'payAPI'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @sBranchCode = " + FilterString(sBranchCode);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            sql += ", @paymentType = " + FilterString(paymentType);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNumber = " + FilterString(rIdNumber);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @rRelativeName = " + FilterString(rRelativeName);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @cAmt = " + FilterString(cAmt);
            sql += ", @payoutAmt = " + FilterString(payoutAmt);
            sql += ", @serviceCharge = " + FilterString(serviceCharge);
            sql += ", @pLocation = " + FilterString(pLocation);
            sql += ", @pBranchName = " + FilterString(pBranchName);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pAgentName = " + FilterString(pAgentName);
            sql += ", @pSuperAgent = " + FilterString(pSuperAgent);
            sql += ", @pSuperAgentName = " + FilterString(pSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(settlingAgent);
            sql += ", @mapCode = " + FilterString(mapCode);
            sql += ", @mapCodeDom = " + FilterString(mapCodeDom);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Pay(string user
                            , string tranId
                            , string controlNo
                            , string pBranch
                            , string payTokenId
                            , string sBranchCode
                            , string sBranchName
                            , string txnDate
                            , string sFirstName
                            , string sMiddleName
                            , string sLastName1
                            , string sLastName2
                            , string sAddress
                            , string sMobile
                            , string sCity
                            , string sCountry
                            , string rFirstName
                            , string rMiddleName
                            , string rLastName1
                            , string rLastName2
                            , string rAddress
                            , string rMobile
                            , string rContactNo
                            , string rCity
                            , string rCountry
                            , string rIdType
                            , string rIdNumber
                            , string rPlaceOfIssue
                            , string rIssuedDate
                            , string rValidDate
                            , string payoutAmt
                            , string payoutCurr
                            , string paymentType
                            , string sLocation
                            , string pLocation
                            , string tAmt
                            , string collCurr
                            , string serviceCharge
                            , string cAmt
                            , string sAgentComm
                            , string custRate
                            , string sendUser
                            , string sIdType
                            , string sIdNo
                            , string sIdValidDate
                            , string sAddress1
                            , string sAddress2
                            , string sqlScript
                            , string pBranchName, string pAgent, string pAgentName, string pSuperAgent, string pSuperAgentName, string settlingAgent, string mapCode, string mapCodeDom
                            , string customerId)
        {
            string sql = "EXEC proc_payTranAPI";
            sql += "  @flag = 'pay'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @payTokenId = " + FilterString(payTokenId);

            sql += ", @sBranchCode = " + FilterString(sBranchCode);
            sql += ", @sBranchName = " + FilterString(sBranchName);
            sql += ", @txnDate = " + FilterString(txnDate);
            sql += ", @sFirstName = " + FilterString(sFirstName);
            sql += ", @sMiddleName = " + FilterString(sMiddleName);
            sql += ", @sLastName1 = " + FilterString(sLastName1);
            sql += ", @sLastName2 = " + FilterString(sLastName2);
            sql += ", @sAddress = " + FilterString(sAddress);
            sql += ", @sMobile = " + FilterString(sMobile);
            sql += ", @sCity = " + FilterString(sCity);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rFirstName = " + FilterString(rFirstName);
            sql += ", @rMiddleName = " + FilterString(rMiddleName);
            sql += ", @rLastName1 = " + FilterString(rLastName1);
            sql += ", @rLastName2 = " + FilterString(rLastName2);
            sql += ", @rAddress = " + FilterString(rAddress);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @rContactNo = " + FilterString(rContactNo);
            sql += ", @rCity = " + FilterString(rCity);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNumber = " + FilterString(rIdNumber);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @rIssuedDate = " + FilterString(rIssuedDate);
            sql += ", @rValidDate = " + FilterString(rValidDate);
            sql += ", @payoutAmt = " + FilterString(payoutAmt);
            sql += ", @payoutCurr = " + FilterString(payoutCurr);
            sql += ", @paymentType = " + FilterString(paymentType);
            sql += ", @sLocation = " + FilterString(sLocation);
            sql += ", @pLocation = " + FilterString(pLocation);
            sql += ", @tAmt = " + FilterString(tAmt);
            sql += ", @collCurr = " + FilterString(collCurr);
            sql += ", @serviceCharge = " + FilterString(serviceCharge);
            sql += ", @cAmt = " + FilterString(cAmt);
            sql += ", @sAgentComm = " + FilterString(sAgentComm);
            sql += ", @custRate = " + FilterString(custRate);
            sql += ", @sendUser = " + FilterString(sendUser);
            sql += ", @sIdType = " + FilterString(sIdType);
            sql += ", @sIdNo = " + FilterString(sIdNo);
            sql += ", @sIdValidDate = " + FilterString(sIdValidDate);
            sql += ", @sAddress1 = " + FilterString(sAddress1);
            sql += ", @sAddress2 = " + FilterString(sAddress2);
            sql += ", @sql = " + FilterString(sqlScript);
            sql += ", @pBranchName = " + FilterString(pBranchName);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pAgentName = " + FilterString(pAgentName);
            sql += ", @pSuperAgent = " + FilterString(pSuperAgent);
            sql += ", @pSuperAgentName = " + FilterString(pSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(settlingAgent);
            sql += ", @mapCode = " + FilterString(mapCode);
            sql += ", @mapCodeDom = " + FilterString(mapCodeDom);
            sql += ", @extCustomerId = " + FilterString(customerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult PayIntl(string user
                            , string tranId
                            , string controlNo
                            , string pBranch
                            , string payTokenId
                            , string sBranchCode
                            , string sBranchName
                            , string txnDate
                            , string sFirstName
                            , string sMiddleName
                            , string sLastName1
                            , string sLastName2
                            , string sAddress
                            , string sMobile
                            , string sCity
                            , string sCountry
                            , string rFirstName
                            , string rMiddleName
                            , string rLastName1
                            , string rLastName2
                            , string rAddress
                            , string rMobile
                            , string rContactNo
                            , string rCity
                            , string rCountry
                            , string rIdType
                            , string rIdNumber
                            , string rPlaceOfIssue
                            , string rIssuedDate
                            , string rValidDate
                            , string payoutAmt
                            , string payoutCurr
                            , string paymentType
                            , string sLocation
                            , string pLocation
                            , string tAmt
                            , string collCurr
                            , string serviceCharge
                            , string cAmt
                            , string sAgentComm
                            , string custRate
                            , string sendUser
                            , string sIdType
                            , string sIdNo
                            , string sIdValidDate
                            , string sAddress1
                            , string sAddress2
                            , string sqlScript
                            , string pBranchName, string pAgent, string pAgentName, string pSuperAgent, string pSuperAgentName, string settlingAgent, string mapCode, string mapCodeDom
                            , string customerId)
        {
            string sql = "EXEC proc_payTranAPI";
            sql += "  @flag = 'payIntl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @payTokenId = " + FilterString(payTokenId);
            sql += ", @sBranchCode = " + FilterString(sBranchCode);
            sql += ", @sBranchName = " + FilterString(sBranchName);
            sql += ", @txnDate = " + FilterString(txnDate);
            sql += ", @sFirstName = " + FilterString(sFirstName);
            sql += ", @sMiddleName = " + FilterString(sMiddleName);
            sql += ", @sLastName1 = " + FilterString(sLastName1);
            sql += ", @sLastName2 = " + FilterString(sLastName2);
            sql += ", @sAddress = " + FilterString(sAddress);
            sql += ", @sMobile = " + FilterString(sMobile);
            sql += ", @sCity = " + FilterString(sCity);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rFirstName = " + FilterString(rFirstName);
            sql += ", @rMiddleName = " + FilterString(rMiddleName);
            sql += ", @rLastName1 = " + FilterString(rLastName1);
            sql += ", @rLastName2 = " + FilterString(rLastName2);
            sql += ", @rAddress = " + FilterString(rAddress);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @rContactNo = " + FilterString(rContactNo);
            sql += ", @rCity = " + FilterString(rCity);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNumber = " + FilterString(rIdNumber);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @rIssuedDate = " + FilterString(rIssuedDate);
            sql += ", @rValidDate = " + FilterString(rValidDate);
            sql += ", @payoutAmt = " + FilterString(payoutAmt);
            sql += ", @payoutCurr = " + FilterString(payoutCurr);
            sql += ", @paymentType = " + FilterString(paymentType);
            sql += ", @sLocation = " + FilterString(sLocation);
            sql += ", @pLocation = " + FilterString(pLocation);
            sql += ", @tAmt = " + FilterString(tAmt);
            sql += ", @collCurr = " + FilterString(collCurr);
            sql += ", @serviceCharge = " + FilterString(serviceCharge);
            sql += ", @cAmt = " + FilterString(cAmt);
            sql += ", @sAgentComm = " + FilterString(sAgentComm);
            sql += ", @custRate = " + FilterString(custRate);
            sql += ", @sendUser = " + FilterString(sendUser);
            sql += ", @sIdType = " + FilterString(sIdType);
            sql += ", @sIdNo = " + FilterString(sIdNo);
            sql += ", @sIdValidDate = " + FilterString(sIdValidDate);
            sql += ", @sAddress1 = " + FilterString(sAddress1);
            sql += ", @sAddress2 = " + FilterString(sAddress2);
            sql += ", @sql = " + FilterString(sqlScript);
            sql += ", @pBranchName = " + FilterString(pBranchName);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pAgentName = " + FilterString(pAgentName);
            sql += ", @pSuperAgent = " + FilterString(pSuperAgent);
            sql += ", @pSuperAgentName = " + FilterString(pSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(settlingAgent);
            sql += ", @mapCode = " + FilterString(mapCode);
            sql += ", @mapCodeDom = " + FilterString(mapCodeDom);
            sql += ", @extCustomerId = " + FilterString(customerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        #endregion

        public DataSet HoSearchTransactionLocal(string user, string controlNo, string agentRefId, string payingAgent)
        {
            var sql = "EXEC proc_payTranHo @flag = 'paySearch'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            sql += ", @pBranch = " + FilterString(payingAgent);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DataSet SearchTransactionLocal(string user, string controlNo, string agentRefId, string pBranch, string pAgent)
        {
            var sql = "EXEC proc_payTran @flag = 'paySearch'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @pAgent = " + FilterString(pAgent);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DataSet SearchPayOrder(string user, string controlNo, string agentId) //agent pay order
        {
            var sql = "EXEC [proc_payOrderTran] @flag = 'payOrder'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DbResult HoPayLocal(string user, string controlNo, string payTokenId, string agentRefId, string payingAgent
                                , string idType, string idNumber, string issuedDate, string validDate, string placeOfIssue
                                , string mobileNo, string relationType, string relationName)
        {
            string sql = "EXEC proc_payTranHo";
            sql += "  @flag = 'payUpdate'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @payTokenId = " + FilterString(payTokenId);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            sql += ", @pBranch = " + FilterString(payingAgent);
            sql += ", @rIdType = " + FilterString(idType);
            sql += ", @rIdNumber = " + FilterString(idNumber);
            sql += ", @rIssuedDate = " + FilterString(issuedDate);
            sql += ", @rValidDate = " + FilterString(validDate);
            sql += ", @rPlaceOfIssue = " + FilterString(placeOfIssue);
            sql += ", @rMobile = " + FilterString(mobileNo);
            sql += ", @rRelationType = " + FilterString(relationType);
            sql += ", @rRelativeName = " + FilterString(relationName);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult PayLocal(string user, string controlNo, string payTokenId, string agentRefId, string payingAgent
                                , string idType, string idNumber, string issuedDate, string validDate, string placeOfIssue
                                , string mobileNo, string relationType, string relationName
                                , string pBranchName, string pAgent, string pAgentName, string pSuperAgent, string pSuperAgentName
                                , string settlingAgent, string mapCode, string mapCodeDom)
        {
            string sql = "EXEC proc_payTran";
            sql += "  @flag = 'payUpdate'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @payTokenId = " + FilterString(payTokenId);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            sql += ", @pBranch = " + FilterString(payingAgent);
            sql += ", @rIdType = " + FilterString(idType);
            sql += ", @rIdNumber = " + FilterString(idNumber);
            sql += ", @rIssuedDate = " + FilterString(issuedDate);
            sql += ", @rValidDate = " + FilterString(validDate);
            sql += ", @rPlaceOfIssue = " + FilterString(placeOfIssue);
            sql += ", @rMobile = " + FilterString(mobileNo);
            sql += ", @rRelationType = " + FilterString(relationType);
            sql += ", @rRelativeName = " + FilterString(relationName);
            sql += ", @pBranchName = " + FilterString(pBranchName);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pAgentName = " + FilterString(pAgentName);
            sql += ", @pSuperAgent = " + FilterString(pSuperAgent);
            sql += ", @pSuperAgentName = " + FilterString(pSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(settlingAgent);
            sql += ", @mapCode = " + FilterString(mapCode);
            sql += ", @mapCodeDom = " + FilterString(mapCodeDom);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow GetMessage(string user, string msgType)
        {
            string sql = "EXEC proc_payTran @flag = 'msg'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgType = " + FilterString(msgType);

            return ExecuteDataset(sql).Tables[0].Rows[0];
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

        public void SavePayResponse(string user, string controlNo, string response)
        {
            var sql = "EXEC proc_payTranAPI @flag = 'spr'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @payResponse = " + FilterString(response);

            ExecuteDataset(sql);
        }

        #region new pay module Head Office

        public DataSet SearchDomesticTransactionHo(string user, string pBranch, string controlNo)
        {
            var sql = "EXEC proc_payDomTransactionHo @flag = 'paySearch'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @controlNo = " + FilterString(controlNo);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DataSet SearchInternationalTransactionHo(string user, string pBranch, string controlNo)
        {
            string sql = "EXEC proc_payIntTransactionHo @flag = 'paySearch'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @controlNo = " + FilterString(controlNo);

            DataSet ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DbResult PayDomesticTransactionHo(string user, string pBranch, string controlNo, string agentRefId,
                                string rIdType, string rIdNumber, string rPlaceOfIssue, string rMobile,
                                string rRelationType, string rRelativeName, string membershipId, string customerId,
                                string rBankName, string rBankBranch, string rCheque, string rAccountNo, string dob, string relationship, string purposeOfRemittance,
                                string idIssueDate, string idExpiryDate)
        {
            var sql = "EXEC proc_payDomTransactionHo";
            sql += "  @flag = 'payTran'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNumber = " + FilterString(rIdNumber);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @rRelationType = " + FilterString(rRelationType);
            sql += ", @rRelativeName = " + FilterString(rRelativeName);
            sql += ", @membershipId = " + FilterString(membershipId);
            sql += ", @customerId = " + FilterString(customerId);

            sql += ", @rBankName = " + FilterString(rBankName);
            sql += ", @rBankBranch = " + FilterString(rBankBranch);
            sql += ", @rCheque = " + FilterString(rCheque);
            sql += ", @rAccountNo = " + FilterString(rAccountNo);

            sql += ", @dob = " + FilterString(dob);
            sql += ", @relationship = " + FilterString(relationship);
            sql += ", @purpose = " + FilterString(purposeOfRemittance);
            sql += ", @rIssuedDate = " + FilterString(idIssueDate);
            sql += ", @rValidDate = " + FilterString(idExpiryDate);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult PayInternationalTransactionHo(string user, string pBranch, string controlNo, string agentRefId,
                                string rIdType, string rIdNumber, string rPlaceOfIssue, string rMobile,
                                string rRelationType, string rRelativeName, string membershipId, string customerId,
                                string rBankName, string rBankBranch, string rCheque, string rAccountNo, string dob, string relationship, string purposeOfRemittance,
                                string idIssueDate, string idExpiryDate, string txnCompliance)
        {
            var sql = "EXEC proc_payIntTransactionHo";
            sql += "  @flag = 'payTran'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNumber = " + FilterString(rIdNumber);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @rRelationType = " + FilterString(rRelationType);
            sql += ", @rRelativeName = " + FilterString(rRelativeName);
            sql += ", @membershipId = " + FilterString(membershipId);
            sql += ", @customerId = " + FilterString(customerId);

            sql += ", @rBankName = " + FilterString(rBankName);
            sql += ", @rBankBranch = " + FilterString(rBankBranch);
            sql += ", @rCheque = " + FilterString(rCheque);
            sql += ", @rAccountNo = " + FilterString(rAccountNo);

            sql += ", @dob = " + FilterString(dob);
            sql += ", @relationship = " + FilterString(relationship);
            sql += ", @purpose = " + FilterString(purposeOfRemittance);
            sql += ", @rIssuedDate = " + FilterString(idIssueDate);
            sql += ", @rValidDate = " + FilterString(idExpiryDate);
            sql += ", @complianceQuestion = " + FilterString(txnCompliance);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        #endregion

        #region new pay module Agent

        public DataSet SearchDomesticTransaction(string user, string pBranch, string controlNo, string pAgent, string fromPayTrnTime, string toPayTrnTime)
        {
            var sql = "EXEC proc_payDomTransaction @flag = 'paySearch'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromPayTrnTime = " + FilterString(fromPayTrnTime);
            sql += ", @toPayTrnTime = " + FilterString(toPayTrnTime);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DataSet SearchInternationalTransaction(string user, string pBranch, string controlNo, string pAgent, string fromPayTrnTime, string toPayTrnTime)
        {
            var sql = "EXEC proc_payIntTransaction @flag = 'paySearch'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromPayTrnTime = " + FilterString(fromPayTrnTime);
            sql += ", @toPayTrnTime = " + FilterString(toPayTrnTime);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DbResult PayDomesticTransaction(string user, string controlNo, string agentRefId, string rIdType, string rIdNumber, string rPlaceOfIssue,
                        string rMobile, string rRelaiveType, string rRelativeName, string pBranch, string pBranchName, string pAgent, string pAgentName,
                        string pSuperAgent, string pSuperAgentName, string settlingAgent, string mapCodeInt, string mapCodeDom, string customerId, string membershipId,
                        string rBankName, string rBankBranch, string rCheque, string rAccountNo, string topupMobileNo, string dob, string relationship,
                        string purposeOfRemittance, string idIssueDate, string idExpiryDate)
        {
            var sql = "EXEC proc_payDomTransaction @flag ='payTran'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNumber = " + FilterString(rIdNumber);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @rRelationType = " + FilterString(rRelaiveType);
            sql += ", @rRelativeName = " + FilterString(rRelativeName);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @pBranchName = " + FilterString(pBranchName);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pAgentName = " + FilterString(pAgentName);
            sql += ", @pSuperAgent = " + FilterString(pSuperAgent);
            sql += ", @pSuperAgentName = " + FilterString(pSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(settlingAgent);
            sql += ", @mapCodeInt = " + FilterString(mapCodeInt);
            sql += ", @mapCodeDom = " + FilterString(mapCodeDom);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @membershipId = " + FilterString(membershipId);

            sql += ", @rBankName = " + FilterString(rBankName);
            sql += ", @rBankBranch = " + FilterString(rBankBranch);
            sql += ", @rCheque = " + FilterString(rCheque);
            sql += ", @rAccountNo = " + FilterString(rAccountNo);
            sql += ", @TopupMobileNo = " + FilterString(topupMobileNo);

            sql += ", @dob = " + FilterString(dob);
            sql += ", @relationship = " + FilterString(relationship);
            sql += ", @purpose = " + FilterString(purposeOfRemittance);

            sql += ", @rIssuedDate = " + FilterString(idIssueDate);
            sql += ", @rValidDate = " + FilterString(idExpiryDate);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult PayInternationalTransaction(string user, string controlNo, string agentRefId, string rIdType, string rIdNumber, string rPlaceOfIssue,
                        string rMobile, string rRelaiveType, string rRelativeName, string pBranch, string pBranchName, string pAgent, string pAgentName,
                        string pSuperAgent, string pSuperAgentName, string settlingAgent, string mapCodeInt, string mapCodeDom, string customerId, string membershipId,
                        string rBankName, string rBankBranch, string rCheque, string rAccountNo, string topupMobileNo, string dob, string relationship, 
                        string purposeOfRemittance, string idIssueDate, string idExpiryDate, string txnCompliance)
        {
            var sql = "EXEC proc_payIntTransaction @flag ='payTran'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentRefId = " + FilterString(agentRefId);
            sql += ", @rIdType = " + FilterString(rIdType);
            sql += ", @rIdNumber = " + FilterString(rIdNumber);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @rMobile = " + FilterString(rMobile);
            sql += ", @rRelationType = " + FilterString(rRelaiveType);
            sql += ", @rRelativeName = " + FilterString(rRelativeName);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @pBranchName = " + FilterString(pBranchName);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pAgentName = " + FilterString(pAgentName);
            sql += ", @pSuperAgent = " + FilterString(pSuperAgent);
            sql += ", @pSuperAgentName = " + FilterString(pSuperAgentName);
            sql += ", @settlingAgent = " + FilterString(settlingAgent);
            sql += ", @mapCodeInt = " + FilterString(mapCodeInt);
            sql += ", @mapCodeDom = " + FilterString(mapCodeDom);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @membershipId = " + FilterString(membershipId);

            sql += ", @rBankName = " + FilterString(rBankName);
            sql += ", @rBankBranch = " + FilterString(rBankBranch);
            sql += ", @rCheque = " + FilterString(rCheque);
            sql += ", @rAccountNo = " + FilterString(rAccountNo);
            sql += ", @topupMobileNo = " + FilterString(topupMobileNo);

            sql += ", @dob = " + FilterString(dob);
            sql += ", @relationship = " + FilterString(relationship);
            sql += ", @purpose = " + FilterString(purposeOfRemittance);
            sql += ", @rIssuedDate = " + FilterString(idIssueDate);
            sql += ", @rValidDate = " + FilterString(idExpiryDate);
            sql += ", @complianceQuestion = " + FilterString(txnCompliance);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        #endregion
    }
}