using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.Transaction
{
    public class TranReportDao1 : RemittanceDao
    {
        public DataTable GetPromotionalCampaign(string User, string startDate, string endDate, string ReferralCode)
        {
            var sql = "Exec proc_PromotionalCampaignVoucher @flag='Report' ";
            sql += " ,@User = " + FilterString(User);
            sql += " ,@sDate = " + FilterString(startDate);
            sql += " ,@tDate = " + FilterString(endDate);
            sql += " ,@referalCode = " + FilterString(ReferralCode);
            return ExecuteDataTable(sql);
        }

        public DbResult PayPromotionalCampaign(string User, string startDate, string endDate, string ReferralCode)
        {
            var sql = "Exec proc_PromotionalCampaignVoucher @flag='Pay' ";
            sql += " ,@User = " + FilterString(User);
            sql += " ,@sDate = " + FilterString(startDate);
            sql += " ,@tDate = " + FilterString(endDate);
            sql += " ,@ReferralCode = " + FilterString(ReferralCode);
            return ParseDbResult(sql);
        }
        public ReportResult IncomeExpencesReport(string user, string startDate, string endDate, string branch)
        {
            string sql = "EXEC PROC_INCOME_EXPENCES_REPORT @flag = 'income-exp-rpt'";
            sql += ",@user = " + FilterString(user);
            sql += ",@startDate = " + FilterString(startDate);
            sql += ",@endDate = " + FilterString(endDate);
            sql += ",@party = " + FilterString(branch);

            return ParseReportResult(sql);
        }
    }
}
