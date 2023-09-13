using Swift.DAL.Library;
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.Partner
{
    public class PartnerDao : RemittanceDao
    {
        public DataRow GetPartnerDetails(string rowId, string user)
        {
            var sql = "EXEC proc_partner";
            sql += " @Flag ='partner-details'";
            sql += ",@rowId =" + FilterString(rowId);
            sql += ",@user =" + FilterString(user);
            return ExecuteDataRow(sql);
        }

        public DbResult RegisterPartner(string pName, string pAddress, string pCountry, string pContact, string isActive, string pId, string user)
        {
            var sql = "EXEC proc_partner";
            sql += " @Flag ='" + (string.IsNullOrEmpty(pId) ? "I" : "U") + "'";
            sql += ",@rowId =" + FilterString(pId);
            sql += ",@partnerName =" + FilterString(pName);
            sql += ",@partnerAddress =" + FilterString(pAddress);
            sql += ",@partnerCountryId =" + FilterString(pCountry);
            sql += ",@partnerContact =" + FilterString(pContact);
            sql += ",@isActive =" + FilterString(isActive);
            sql += ",@user =" + FilterString(user);

            return ParseDbResult(sql);
        }

        public DataSet CashStatusReportReferral(string user, string asOfDate, string flag, string agentId = "")
        {
            string sql = "EXEC  PROC_CASH_STATUS_REPORT_REFERRAL @FLAG = " + FilterString(flag);
            sql += ",@user=" + FilterString(user);
            sql += ",@DATE=" + FilterString(asOfDate);
            sql += ",@AGENT_ID=" + FilterString(agentId);

            return ExecuteDataset(sql);
        }

        public DataSet GetCashCollectList(string user, string flag, string fromDate, string toDate, string type, string agentId)
        {
            var sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".DBO.PROC_AGENT_CASH_COLLECTION";
            sql += " @FLAG ='" + flag + "'";
            sql += ",@USER =" + FilterString(user);
            sql += ",@FROM_DATE =" + FilterString(fromDate);
            sql += ",@TO_DATE =" + FilterString(toDate);
            sql += ",@AGENT_ID =" + FilterString(agentId);
            sql += ",@TYPE =" + FilterString(type);

            return ExecuteDataset(sql);
        }

        public DbResult LockUnlockPartner(string user, string rowId)
        {
            var sql = "EXEC proc_partner";
            sql += " @Flag ='block-unblock'";
            sql += ",@rowId =" + FilterString(rowId);
            sql += ",@user =" + FilterString(user);

            return ParseDbResult(sql);
        }

        public DataTable GetReferralReport(string user, string fromDate, string toDate, string referralCode)
        {
            var sql = "EXEC PROC_REFERRAL_REPORT";
            sql += " @Flag ='SUMMARY'";
            sql += ",@FROM_DATE =" + FilterString(fromDate);
            sql += ",@TO_DATE =" + FilterString(toDate);
            sql += ",@REFERRAL_CODE =" + FilterString(referralCode);
            sql += ",@user =" + FilterString(user);

            return ExecuteDataTable(sql);
        }

        public DataSet GetAgentAgeingReport(string user, string asOnDate)
        {
            string sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".DBO.PROC_AGENT_AGEING_REPORT";
            sql += " @user=" + FilterString(user);
            sql += ",@TO_DATE=" + FilterString(asOnDate);

            return ExecuteDataset(sql);
        }
    }
}