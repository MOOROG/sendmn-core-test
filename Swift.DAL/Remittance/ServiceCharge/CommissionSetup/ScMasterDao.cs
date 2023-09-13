using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.DomesticOperation.CommissionSetup
{
    public class ScMasterDao : RemittanceDao
    {
        public DbResult Update(string user, string scMasterId, string code, string description,
                               string sAgent, string sBranch, string sState, string sGroup, 
                               string rAgent, string rBranch, string rState, string rGroup,
                               string tranType, string commissionBase, string effectiveFrom, string effectiveTo, string isEnable)
        {
            string sql = "EXEC proc_scMaster";
            sql += "  @flag = " + (scMasterId == "0" || scMasterId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @scMasterId = " + FilterString(scMasterId);
            sql += ", @code = " + FilterString(code);
            sql += ", @description = " + FilterString(description);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @sState = " + FilterString(sState);
            sql += ", @sGroup = " + FilterString(sGroup);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rBranch = " + FilterString(rBranch);
            sql += ", @rState = " + FilterString(rState);
            sql += ", @rGroup = " + FilterString(rGroup);
            sql += ", @commissionBase = " + FilterString(commissionBase);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @effectiveFrom = " + FilterString(effectiveFrom);
            sql += ", @effectiveTo = " + FilterString(effectiveTo);
            sql += ", @isEnable = " + FilterString(isEnable);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string scMasterId)
        {
            string sql = "EXEC proc_scMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scMasterId = " + FilterString(scMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string scMasterId)
        {
            string sql = "EXEC proc_scMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scMasterId = " + FilterString(scMasterId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}
