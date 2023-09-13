using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Commission.Send
{
    public class ScSendMasterDao : RemittanceDao
    {
        public DbResult Update(string user
                               , string scSendMasterId
                               , string code
                               , string description
                               , string sCountry
                               , string ssAgent
                               , string sAgent
                               , string sBranch
                               , string rCountry
                               , string rsAgent
                               , string rAgent
                               , string rBranch
                               , string state
                               , string zip
                               , string agentGroup
                               , string rState
                               , string rZip
                               , string rAgentGroup
                               , string baseCurrency
                               , string tranType
                               , string commissionBase
                               , string effectiveFrom
                               , string effectiveTo
                               , string isEnable)
        {
            string sql = "EXEC proc_scSendMaster";
            sql += "  @flag = " + (scSendMasterId == "0" || scSendMasterId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @scSendMasterId = " + FilterString(scSendMasterId);
            sql += ", @code = " + FilterString(code);
            sql += ", @description = " + FilterString(description);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @ssAgent = " + FilterString(ssAgent);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rsAgent = " + FilterString(rsAgent);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rBranch = " + FilterString(rBranch);
            sql += ", @state = " + FilterString(state);
            sql += ", @zip = " + FilterString(zip);
            sql += ", @agentGroup = " + FilterString(agentGroup);
            sql += ", @rState = " + FilterString(rState);
            sql += ", @rZip = " + FilterString(rZip);
            sql += ", @rAgentGroup = " + FilterString(rAgentGroup);
            sql += ", @baseCurrency = " + FilterString(baseCurrency);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @commissionBase = " + FilterString(commissionBase);
            sql += ", @effectiveFrom = " + FilterString(effectiveFrom);
            sql += ", @effectiveTo = " + FilterString(effectiveTo);
            sql += ", @isEnable = " + FilterString(isEnable);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string scSendMasterId)
        {
            string sql = "EXEC proc_scSendMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scSendMasterId = " + FilterString(scSendMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string scSendMasterId)
        {
            string sql = "EXEC proc_scSendMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scSendMasterId = " + FilterString(scSendMasterId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string scSendMasterId)
        {
            string sql = "EXEC proc_scSendMaster";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scSendMasterId = " + FilterString(scSendMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string scSendMasterId)
        {
            string sql = "EXEC proc_scSendMaster";
            sql += "  @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scSendMasterId = " + FilterString(scSendMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}