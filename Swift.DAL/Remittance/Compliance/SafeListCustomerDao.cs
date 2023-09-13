using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.Compliance
{
    public class SafeListCustomerDao : RemittanceDao
    {
    public DbResult Save(string user, string membershipId, string isActive,string id)
        {
            string sql = "EXEC proc_SafelistCustomer";
            sql += " @flag = " + (id == "0" || id == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId = " + FilterString(membershipId);
            sql += ", @isActive = " + FilterString(isActive);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Save(string user, string csMasterId, string sCountry, string sAgent,
                             string sState, string sZip, string sGroup, string sCustType, string rCountry,
                             string rAgent, string rState, string rZip, string rGroup, string rCustType,
                             string currency, string ruleScope)
        {
            string sql = "EXEC proc_csSafeListDetail";
            sql += " @flag = " + (csMasterId == "0" || csMasterId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @csMasterId = " + FilterString(csMasterId);

            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sState = " + FilterString(sState);
            sql += ", @sZip = " + FilterString(sZip);
            sql += ", @sGroup = " + FilterString(sGroup);
            sql += ", @sCustType = " + FilterString(sCustType);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rState = " + FilterString(rState);
            sql += ", @rZip = " + FilterString(rZip);
            sql += ", @rGroup = " + FilterString(rGroup);
            sql += ", @rCustType = " + FilterString(rCustType);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @ruleScope = " + FilterString(ruleScope);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult SaveRule(string user, string csSafeListDetailID, string csMasterId, string condition, string collMode,
                             string paymentMode, string tranCount, string amount, string period, string nextAction)
        {
            string sql = "EXEC proc_csSafeListDetail";
            sql += " @flag = " + (csSafeListDetailID == "0" || csSafeListDetailID == "" ? "'ird'" : "'urd'");
            sql += ", @user = " + FilterString(user);
            sql += ", @csSafeListDetailID = " + FilterString(csSafeListDetailID);
            sql += ", @csMasterId = " + FilterString(csMasterId);
            sql += ", @condition = " + FilterString(condition);
            sql += ", @collMode = " + FilterString(collMode);
            sql += ", @paymentMode = " + FilterString(paymentMode);
            sql += ", @tranCount = " + FilterString(tranCount);
            sql += ", @amount = " + FilterString(amount);
            sql += ", @period = " + FilterString(period);
            sql += ", @nextAction = " + FilterString(nextAction);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        //public DbResult SaveRule_v2(string user, string csSafeListDetailID, string condition, string tranCount, string amount, string period, string nextAction,string ruleScope)
        //{
        //    string sql = "EXEC proc_csSafeListDetail";
        //    sql += " @flag = " + (csSafeListDetailID == "0" || csSafeListDetailID == "" ? "'ird_v2'" : "'urd_v2'");
        //    sql += ", @user = " + FilterString(user);
        //    sql += ", @csSafeListDetailID = " + FilterString(csSafeListDetailID); // RuleId
        //    //sql += ", @condition = " + FilterString(condition);
        //    //sql += ", @tranCount = " + FilterString(tranCount);
        //    sql += ", @amount = " + FilterString(amount);
        //    sql += ", @period = " + FilterString(period);
        //    sql += ", @nextAction = " + FilterString(nextAction);
        //   // sql += ", @ruleScope = " + FilterString(ruleScope);
        //    return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        //}

        public DbResult SaveRule_v2(string user, string csSafeListDetailID,string amount, string period,string isPerTxn)
        {
            string sql = "EXEC Proc_OFACRuleSetup";
            sql += " @flag = " + (csSafeListDetailID == "0" || csSafeListDetailID == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @RuleId = " + FilterString(csSafeListDetailID);
            sql += ", @amount = " + FilterString(amount);
            sql += ", @period = " + FilterString(period);
            sql += ", @isPerTransaction = " + FilterString(isPerTxn);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DataTable GetSafeListCustomer(string user,string memId)
        {
            string sql = "EXEC proc_SafelistCustomer";
            sql += " @flag = 's' ";
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId = " + FilterString(memId);
            return ExecuteDataset(sql).Tables[0];
        }

        public DataRow RuleSelectById(string user, string csSafeListDetailID)
        {
            string sql = "EXEC proc_csSafeListDetail";
            sql += " @flag = 'rEdit'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csSafeListDetailID = " + FilterString(csSafeListDetailID);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DataRow SelectById(string user, string csMasterId)
        {
            string sql = "EXEC proc_SafelistCustomer";
            sql += " @flag = 'usl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csMasterId = " + FilterString(csMasterId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DbResult Disable(string user, string csMasterId)
        {
            string sql = "EXEC proc_csSafeListDetail";
            sql += " @flag = 'disable'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csMasterId = " + FilterString(csMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DisableRule(string user, string csSafeListDetailID)
        {
            string sql = "EXEC proc_csSafeListDetail";
            sql += " @flag = 'rDisable'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csSafeListDetailID = " + FilterString(csSafeListDetailID);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DataRow SelectRuleDetailById(string user, string csMasterId)
        {
            string sql = "EXEC proc_csSafeListDetail";
            sql += " @flag = 'ruleDetail'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csMasterId = " + FilterString(csMasterId);

            return ExecuteDataRow(sql);
        }

        public DbResult DeleteSafelistCustomer(string user, string membershipId)
        {
            string sql = "EXEC proc_SafelistCustomer";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId= " + FilterString(membershipId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult ApproveRule(string user, string csMasterId)
        {
            string sql = "EXEC proc_csSafeListDetail";
            sql += " @flag = 'ar'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csMasterId = " + FilterString(csMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult ApproveRuleDetail(string user, string csSafeListDetailID)
        {
            string sql = "EXEC proc_csSafeListDetail";
            sql += " @flag = 'a_rule'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csSafeListDetailID = " + FilterString(csSafeListDetailID);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

    }
}
