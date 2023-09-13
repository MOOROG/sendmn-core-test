using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.Compliance
{
    public class PayComplianceDao : RemittanceDao
    {
        public DataSet GetSummaryDashboard(string user)
        {
            string sql = "EXEC proc_payOfacCompliance ";
            sql += "  @flag = 's_summary'";
            sql += ", @user = " + FilterString(user);
            return ExecuteDataset(sql);
        }
        public DataSet GetOfacComplianceTxn(string user, string rowId)
        {
            var sql = "EXEC proc_payOfacCompliance";
            sql += "  @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(rowId);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DataSet DisplayOfac(string user, string rowId)
        {
            var sql = "EXEC proc_payOfacCompliance @flag = 'ofac'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(rowId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DbResult ReleaseOfacCompliance(string user, string rowId, string remarks)
        {
            var sql = "EXEC proc_payOfacCompliance @flag = 'release'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(rowId);
            sql += ", @remarks = " + FilterString(remarks);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DataSet GetCompliancePayTxn(string user, string rowId)
        {
            var sql = "EXEC proc_payCompliance";
            sql += "  @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(rowId);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
        public DataSet DisplayCompliance(string user, string rowId)
        {
            var sql = "EXEC proc_payCompliance @flag = 'compliance'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(rowId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
        public DbResult ReleaseCompliancePay(string user, string rowId, string remarks)
        {
            var sql = "EXEC proc_payCompliance @flag = 'release'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(rowId);
            sql += ", @remarks = " + FilterString(remarks);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}
