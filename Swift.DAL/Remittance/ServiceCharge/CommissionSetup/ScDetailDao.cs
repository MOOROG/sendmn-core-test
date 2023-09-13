using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.DomesticOperation.CommissionSetup
{
    public class ScDetailDao : RemittanceDao
    {
        public DbResult Update(string user, string scDetailId, string scMasterId, string fromAmt, string toAmt,
                               string serviceChargePcnt, string serviceChargeMinAmt, string serviceChargeMaxAmt,
                               string sAgentCommPcnt, string sAgentCommMinAmt, string sAgentCommMaxAmt,
                               string ssAgentCommPcnt, string ssAgentCommMinAmt, string ssAgentCommMaxAmt,
                               string pAgentCommPcnt, string pAgentCommMinAmt, string pAgentCommMaxAmt,
                               string psAgentCommPcnt, string psAgentCommMinAmt, string psAgentCommMaxAmt,
                               string bankCommPcnt, string bankCommMinAmt, string bankCommMaxAmt)
        {
            string sql = "EXEC proc_scDetail";
            sql += "  @flag = " + (scDetailId == "0" || scDetailId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @scDetailId = " + FilterString(scDetailId);
            sql += ", @scMasterId = " + FilterString(scMasterId);
            sql += ", @fromAmt = " + FilterString(fromAmt);
            sql += ", @toAmt = " + FilterString(toAmt);
            sql += ", @serviceChargePcnt = " + FilterString(serviceChargePcnt);
            sql += ", @serviceChargeMinAmt = " + FilterString(serviceChargeMinAmt);
            sql += ", @serviceChargeMaxAmt = " + FilterString(serviceChargeMaxAmt);
            sql += ", @sAgentCommPcnt = " + FilterString(sAgentCommPcnt);
            sql += ", @sAgentCommMinAmt = " + FilterString(sAgentCommMinAmt);
            sql += ", @sAgentCommMaxAmt = " + FilterString(sAgentCommMaxAmt);
            sql += ", @ssAgentCommPcnt = " + FilterString(ssAgentCommPcnt);
            sql += ", @ssAgentCommMinAmt = " + FilterString(ssAgentCommMinAmt);
            sql += ", @ssAgentCommMaxAmt = " + FilterString(ssAgentCommMaxAmt);
            sql += ", @pAgentCommPcnt = " + FilterString(pAgentCommPcnt);
            sql += ", @pAgentCommMinAmt = " + FilterString(pAgentCommMinAmt);
            sql += ", @pAgentCommMaxAmt = " + FilterString(pAgentCommMaxAmt);
            sql += ", @psAgentCommPcnt = " + FilterString(psAgentCommPcnt);
            sql += ", @psAgentCommMinAmt = " + FilterString(psAgentCommMinAmt);
            sql += ", @psAgentCommMaxAmt = " + FilterString(psAgentCommMaxAmt);
            sql += ", @bankCommPcnt = " + FilterString(bankCommPcnt);
            sql += ", @bankCommMinAmt = " + FilterString(bankCommMinAmt);
            sql += ", @bankCommMaxAmt = " + FilterString(bankCommMaxAmt);
            return ParseDbResult(sql);
        }

        public DbResult Delete(string user, string scDetailId)
        {
            string sql = "EXEC proc_scDetail";
            sql += "  @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scDetailId = " + FilterString(scDetailId);

            return ParseDbResult(sql);
        }

        public DataRow SelectById(string user, string scDetailId)
        {
            string sql = "EXEC proc_scDetail";
            sql += "  @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scDetailId = " + FilterString(scDetailId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet PopulateCommissionDetail(string user, string scMasterId)
        {
            var sql = "EXEC proc_scDetail @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scMasterId = " + FilterString(scMasterId);
            sql += ", @pageNumber = '1', @pageSize='100', @sortBy='scDetailId', @sortOrder='ASC'";
            return ExecuteDataset(sql);
        }

        public DbResult CopySlab(string user, string oldScMasterId, string newScMasterId)
        {
            string sql = "EXEC proc_scDetail";
            sql += " @flag = 'cs'";
            sql += ", @user = " + FilterString(user);
            sql += ", @oldScMasterId = " + FilterString(oldScMasterId);
            sql += ", @scMasterId = " + FilterString(newScMasterId);

            return ParseDbResult(sql);
        }
    }
}
