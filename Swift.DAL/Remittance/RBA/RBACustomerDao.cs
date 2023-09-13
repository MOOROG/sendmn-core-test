using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.RBA
{
    public class RBACustomerDao : RemittanceDao
    {
        public DataTable LoadRBASummary(string user)
        {
            string sql = "EXEC proc_RBAEvaluatedCustomers @flag='rba-ec'";
            sql += " ,@user = " + FilterString(user);
            return ExecuteDataTable(sql);
        }

        public ReportResult GetRBACustomerReport(string assessement, string RBAStatus, string pendingTxnGE30, string pendingTxnL30, string pageNumber)
        {
            var sql = "Exec proc_RBAEvaluatedCustomers";
            sql += " @flag = 'rba-ec-dl'";
            sql += ",@assessement = " + FilterString(assessement);
            sql += ",@RBAStatus = " + FilterString(RBAStatus);
            sql += ",@pendingTxnGE30 = " + FilterString(pendingTxnGE30);
            sql += ",@pendingTxnL30 = " + FilterString(pendingTxnL30);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            return ParseReportResult(sql);
        }

        public DbResult UpdateRBAStatusAddRemarks(string user, string cusId, string remarks, string remType)
        {
            var sql = "Exec proc_RBAEvaluatedCustomers";
            sql += " @flag = 'reviewstatus'";
            sql += ",@user = " + FilterString(user);
            sql += ",@customerId = " + FilterString(cusId);
            sql += ",@RBAStatus = " + FilterString(remType);
            sql += ",@remarks = " + FilterString(remarks);

            return ParseDbResult(sql);
        }


        public DbResult AddPendignRemarks(string user, string cusId, string remarks, string remType)
        {
            var sql = "Exec proc_RBAEvaluatedCustomers";
            sql += " @flag = 'pendingRemarks'";
            sql += ",@user = " + FilterString(user);
            sql += ",@customerId = " + FilterString(cusId);
            sql += ",@RBAStatus = " + FilterString(remType);
            sql += ",@remarks = " + FilterString(remarks);

            return ParseDbResult(sql);
        }

        public DataTable LoadRBAExceptionRpt(string user, string fromDate, string toDate, string country, string agent, string branch, string reportType)
        {
            string sql = "EXEC proc_RBAExceptionRpt @flag='rbaer'";
            sql += " ,@user = " + FilterString(user);
            sql += ",@fromDate = " + FilterString(fromDate);
            sql += ",@toDate = " + FilterString(toDate);
            sql += ",@sCountry = " + FilterString(country);
            sql += ",@sAgent = " + FilterString(agent);
            sql += ",@sbranch = " + FilterString(branch);
            sql += ",@reportType = " + FilterString(reportType);
            return ExecuteDataTable(sql);
        }
        public ReportResult GetRBAExceptionReport(string risk, string rType, string rCat, string fDate, string tDate, string country, string agent, string branch)
        {
            var sql = "Exec proc_RBAExceptionRpt";
            sql += " @flag = 'rbaer-dl'";
            sql += ",@reportType = " + FilterString(rType);
            sql += ",@risk = " + FilterString(risk);
            sql += ",@repCategory=" + FilterString(rCat);
            sql += ",@fromDate=" + FilterString(fDate);
            sql += ",@toDate=" + FilterString(tDate);
            sql += ",@sCountry=" + FilterString(country);
            sql += ",@sAgent=" + FilterString(agent);
            sql += ",@sbranch=" + FilterString(branch);
            return ParseReportResult(sql);
        }

        public DataTable RBAStatisticRpt(string user)
        {
            string sql = "EXEC proc_RBAStatisticRpt @flag='rba-s'";
            sql += " ,@user = " + FilterString(user);
            return ExecuteDataTable(sql);
        }
        public DataSet RBAStatisticRptDl(string user, string rptDrildown)
        {
            string sql = "EXEC proc_RBAStatisticRpt @flag='rba-dl'";
            sql += " ,@user = " + FilterString(user);
            sql += " ,@rptdl=" + FilterString(rptDrildown);
            return ExecuteDataset(sql);
        }

        public DataSet GetRBACalculationDetail(string user, string customerId)
        {
            string sql = "EXEC proc_RBAEvaluatedCustomers @flag='calculationDetail'";
            sql += " ,@user = " + FilterString(user);
            sql += " ,@customerId=" + FilterString(customerId);
            return ExecuteDataset(sql);
        }
        public DataSet GetTXNRBACalculationDetail(string user, string customerId, string tranid, string dt)
        {
            string sql = "EXEC proc_RBACalcDetails @flag='txnrba'";
            sql += " ,@user = " + FilterString(user);
            sql += " ,@tranid = " + FilterString(tranid);
            sql += " ,@customerId=" + FilterString(customerId);
            sql += " ,@dt=" + FilterString(dt);
            return ExecuteDataset(sql);
        }
        public DataSet GetCustomerRBACalculationDetail(string user, string customerId, string tranid, string dt)
        {
            string sql = "EXEC proc_RBACalcDetails @flag='customerRBA'";
            sql += " ,@user = " + FilterString(user);
            sql += " ,@tranid = " + FilterString(tranid);
            sql += " ,@customerId=" + FilterString(customerId);
            sql += " ,@dt=" + FilterString(dt);
            return ExecuteDataset(sql);
        }
    }
}
