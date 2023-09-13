using System.Data;
using Swift.DAL.SwiftDAL;
using System.Text;
using Swift.DAL.BL.Remit.Transaction.ThirdParty.GlobalBankCard;

namespace Swift.DAL.BL.Remit.Transaction
{
    public class PayAcDepositDao : RemittanceDao
    {
        #region VERSION- 1 PAY A/C DEPOSIT TRANSACTION 
        public DbResult PayAcDeposit(string user, string tranIds)
        {
            string sql = "EXEC proc_payAcDeposit";
            sql += "  @flag = 'u'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet ShowIntlAcUnpaidListApi(string user, string mapCodeInt, string  bankName)
        {
            var sql = "EXEC proc_DomesticUnpaidListApi @flag='intlList'";
            sql += ", @user = " + FilterString(user);
            sql += ", @mapCodeInt = " + FilterString(mapCodeInt);
            sql += ", @rBankName = " + FilterString(bankName);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DataTable ShowDomAcUnpaidListApi(string user, string rBankId)
        {
            var sql = "EXEC proc_domesticUnpaidListApi @flag = 'domList'";
            sql += ", @user = " + FilterString(user);
            sql += ", @bankId = " + rBankId;

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds.Tables[0];
        }
        public DataSet ShowAcUnpaidListApiAll(string user)
        {
            var sql = "exec proc_domesticUnpaidListApi @flag = 'ul'";
            sql += ", @user = " + FilterString(user);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DataSet ShowUnpaidListAgentPanelApi(string user, string mapCodeInt)
        {
            var sql = "EXEC proc_DomesticUnpaidListApi @flag='ulAgent'";
            sql += ", @user = " + FilterString(user);
            sql += ", @mapCodeInt = " + FilterString(mapCodeInt);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DbResult PayAcDepositApi(string user, string tranNos, string agentId)
        {
            string sql = "EXEC [proc_DomesticUnpaidListApi]";
                sql += "  @flag = 'payIntl'";
                sql += ", @user = " + FilterString(user);
                sql += ", @tranNos = " + FilterString(tranNos);
                sql += ", @agentId = " + FilterString(agentId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow PayAcDepositDomApi(string user, string tranNos)
        {
            var sql = "EXEC proc_DomesticUnpaidListApi @flag = 'payDom'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranNos = " + FilterString(tranNos);

            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow PayAcDepositIntlApi(string user, string tranNos, string agentId)
        {
            string sql = "EXEC [proc_DomesticUnpaidListApi] @flag = 'payIntl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranNos = " + FilterString(tranNos);
            sql += ", @agentId = " + FilterString(agentId);

            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult PayUnpaidAcDepositIntlLocal(string user, string tranNos)
        {
            var sql = "EXEC proc_payAcDeposit @flag = 'payIntl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranNos = " + FilterString(tranNos);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet ShowDataForPrintReport(string user, string bankId, string dateType, string fromDate, string toDate,
           string tranType, string chkSender,string chkBankComm,string chkGenerator, string chkImeRef, string fromTime, string toTime)
        {
            string sql = "EXEC [proc_acDepositPaidReport]";
            sql += "  @flag = 'report'";
            sql += ", @user = " + FilterString(user);
            sql += ", @bankId = " + FilterString(bankId);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @chkSender = " + FilterString(chkSender);
            sql += ", @chkBankComm = " + FilterString(chkBankComm);
            sql += ", @chkGenerator = " + FilterString(chkGenerator);
            sql += ", @chkIMERef = " + FilterString(chkImeRef);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
        #endregion

        #region VERSION- 2 PAY A/C DEPOSIT TRANSACTION - ADMIN PANEL

        public DataSet GetPendingList(string user, string fromDate, string toDate)
        {
            var sql = "Exec proc_PayAcDepositV2 @flag = 'pendingList'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DataSet GetPendingListCE(string user, string pAgent, string fromDate, string toDate)
        {
            var sql = "EXEC proc_PayAcDepositV2 @flag='pendingListCE'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DataSet GetPendingListIntl(string user, string pAgent, string fromDate, string toDate)
        {
            var sql = "EXEC proc_PayAcDepositV2 @flag='pendingListIntl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DataSet GetPendingListDom(string user, string pAgent, string fromDate, string toDate)
        {
            var sql = "EXEC proc_PayAcDepositV2 @flag='pendingListDom'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DbResult PayAcDepositIntl(string user, string tranIds, string pAgent)
        {
            string sql = "EXEC [proc_PayAcDepositV2] @flag = 'payIntl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @pAgent = " + FilterString(pAgent);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult PayAcDepositDom(string user, string tranIds, string pAgent)
        {
            string sql = "EXEC [proc_PayAcDepositV2] @flag = 'payDom'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @pAgent = " + FilterString(pAgent);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        #endregion

        #region VERSION- 2 PAY A/C DEPOSIT TRANSACTION - AGENT PANEL

        public DataSet GetPendingListAgent(string user, string pAgent)
        {
            var sql = "EXEC proc_PayAcDepositAgentV2 @flag = 'pendingList'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pAgent = " + FilterString(pAgent);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DbResult PayAcDepositIntlAgent(string user, string tranIds, string pAgent)
        {
            string sql = "EXEC [proc_PayAcDepositAgentV2] @flag = 'payIntl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @pAgent = " + FilterString(pAgent);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult PayAcDepositDomAgent(string user, string tranIds, string pAgent)
        {
            string sql = "EXEC [proc_PayAcDepositAgentV2] @flag = 'payDom'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @pAgent = " + FilterString(pAgent);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        #endregion

        #region VERSION- 3 POST A/C DEPOSIT TRANSACTION 
        public DataSet GetPendingUnpaid(string user, string fromDate, string toDate, string fromTime, string toTime)
        {
            var sql = "Exec proc_PostAcDepositV3 @flag = 'pending'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
        public DataSet GetPendingUnpaidIntl(string user, string pAgent, string fromDate, string toDate, string fromTime, string toTime)
        {
            var sql = "EXEC proc_PostAcDepositV3 @flag='pendingIntl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
        public DataSet GetPendingUnpaidDom(string user, string pAgent, string fromDate, string toDate, string fromTime, string toTime)
        {
            var sql = "EXEC proc_PostAcDepositV3 @flag='pendingDom'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
        public DataSet GetPendingUnpaidCooperative(string user, string pAgent, string fromDate, string toDate, string fromTime, string toTime)
        {
            var sql = "EXEC proc_PostAcDepositV3 @flag='pendingCooperative'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
       
        public DbResult PostIntl(string user, string tranIds, string pAgent)
        {
            string sql = "EXEC proc_PostAcDepositV3 @flag = 'postIntl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @pAgent = " + FilterString(pAgent);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult PostDom(string user, string tranIds, string pAgent)
        {
            string sql = "EXEC proc_PostAcDepositV3 @flag = 'postDom'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @pAgent = " + FilterString(pAgent);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult PostCop(string user, string tranIds, string pAgent)
        {
            string sql = "EXEC proc_PostAcDepositV3 @flag = 'postCop'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @pAgent = " + FilterString(pAgent);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult PostToUnpaid(string user, string controlNo, string remarks)
        {
            string sql = "EXEC proc_PostAcDepositV3 @flag = 'post-unpaid'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @remarks = " + FilterString(remarks);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
       
        #endregion

        #region VERSION- 3 PAY A/C DEPOSIT TRANSACTION
        public DataSet GetPendingPost(string user, string fromDate, string toDate, string fromTime, string toTime)
        {
            var sql = "Exec proc_PayAcDepositV3 @flag = 'pending'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
        public DataSet GetPendingPostIntl(string user, string pAgent, string fromDate, string toDate, string fromTime, string toTime)
        {
            var sql = "EXEC proc_PayAcDepositV3 @flag='pendingIntl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
        public DataSet GetPendingPostDom(string user, string pAgent, string fromDate, string toDate, string fromTime, string toTime)
        {
            var sql = "EXEC proc_PayAcDepositV3 @flag='pendingDom'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
        public DataSet GetPendingPostCooperative(string user, string pAgent, string fromDate, string toDate, string fromTime, string toTime)
        {
            var sql = "EXEC proc_PayAcDepositV3 @flag='pendingCooperative'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
        public DbResult PayIntl(string user, string tranIds, string pAgent, string IsOnBehalf)
        {
            string sql = "EXEC proc_PayAcDepositV3 @flag = 'payIntl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @isHOPaid = " + FilterString(IsOnBehalf);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        #endregion

        #region POST A/C DEPOSIT TO ISO TRANSACTION
        public DataSet GetPendingUnpaidIso(string user, string fromDate, string toDate, string fromTime, string toTime)
        {
            var sql = "Exec proc_PostAcDepositISO @flag = 'pending'";
            sql += ", @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
        public DataSet GetPendingUnpaidIntlIso(string user, string pAgent, string fromDate, string toDate, string fromTime, string toTime)
        {
            var sql = "EXEC proc_PostAcDepositISO @flag='pendingIntl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
        public DataSet GetPendingUnpaidDomIso(string user, string pAgent, string fromDate, string toDate, string fromTime, string toTime)
        {
            var sql = "EXEC proc_PostAcDepositISO @flag='pendingDom'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @fromTime = " + FilterString(fromTime);
            sql += ", @toTime = " + FilterString(toTime);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
        public DbResult PostIntlIso(string user, string tranIds, string pAgent)
        {
            string sql = "EXEC proc_PostAcDepositISO @flag = 'postIntl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @pAgent = " + FilterString(pAgent);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult PostDomIso(string user, string tranIds, string pAgent)
        {
            string sql = "EXEC proc_PostAcDepositISO @flag = 'postDom'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @pAgent = " + FilterString(pAgent);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        #endregion

        public DataSet GetPendingListCooperative(string user, string pAgent)
        {
            var sql = "EXEC proc_PayAcDepositAgentV2 @flag = 'pendingListCop'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pAgent = " + FilterString(pAgent);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }
        public DbResult PayAcDepositCooperativeAgent(string user, string tranIds, string pAgent)
        {
            string sql = "EXEC [proc_PayAcDepositAgentV2] @flag = 'payCooperative'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @pAgent = " + FilterString(pAgent);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public string GetAccountFromTranId(string user, string tranIds)
        {
            string sql = "EXEC proc_PostIsoV2 @flag = 'account'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranIds);
            var str = ExecuteDataTable(sql).Rows[0]["ACCOUNT"].ToString();
            return str;
        }
        public string GetAccountDetailFromGIBL(string user,string accountNos)       //Get from GIBL VIEW
        {
            //string sql = "EXEC proc_PostIsoV2 @flag = 'AccDetail'";
            //sql += ", @user = " + FilterString(user);
            //sql += ", @tranIds = " + FilterString(accountNos);

           // GiblDirectCbsDao _giblDao = new GiblDirectCbsDao();
           // var dt = _giblDao.GetAccountNameList(accountNos);

           //// var dt=ExecuteDataTable(sql);
           // if (dt != null && dt.Rows.Count > 0) {
           //     return GetAccountDetailAsXml(dt);
           // }
            return null;
        }        
        private string GetAccountDetailAsXml(DataTable dt)
        {
            var sb = new StringBuilder();
            sb.Append("<root>");
            foreach (DataRow dr in dt.Rows)
            {
                sb.AppendFormat("<row name=\"{0}\" Account=\"{1}\" />", dr["NAME"], dr["ACCOUNT"]);
            }
            sb.Append("</root>");
            return sb.ToString();
        }

        public DataSet ValidateAndPostTxn(string user,string tranIds,string pAgent) {

            var acc = GetAccountFromTranId(user, tranIds);
            var accDetail = GetAccountDetailFromGIBL(user, acc);
            if (accDetail == null)
            {
                DataSet db = new DataSet();
                DataTable dt = new DataTable();
                dt.Columns.Add("errorCode");
                dt.Columns.Add("msg");
                dt.Columns.Add("id");

                dt.Rows.Add("1", "INTERNAL ERROR OCCURED!", null);
                db.Tables.Add(dt);
                return db;
            }
            string sql = "EXEC proc_PostIsoV2 @flag = 'validateAndPost'";
            sql += ", @user = " + FilterString(user);
            sql += ", @accGIBLDetail = " + FilterString(accDetail);
            sql += ", @tranIds = " + FilterString(tranIds);
            sql += ", @pAgent = " + FilterString(pAgent);
            return ExecuteDataset(sql);
        }
    }
}
