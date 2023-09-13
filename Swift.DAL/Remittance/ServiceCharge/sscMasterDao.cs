using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ServiceCharge {
  public class SscMasterDao : RemittanceDao {
    public DbResult Update(string user
                           , string sscMasterId
                           , string code
                           , string description
                           , string isActive
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
                           , string ve
                           , string veType
                           , string ne
                           , string neType
                           , string effectiveFrom
                           , string effectiveTo) {
      string sql = "EXEC proc_sscMaster";
      sql += "  @flag = " + (sscMasterId == "0" || sscMasterId == "" ? "'i'" : "'u'");
      sql += ", @user = " + FilterString(user);
      sql += ", @sscMasterId = " + FilterString(sscMasterId);
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
      sql += ", @ve = " + FilterString(ve);
      sql += ", @veType = " + FilterString(veType);
      sql += ", @ne = " + FilterString(ne);
      sql += ", @neType = " + FilterString(neType);
      sql += ", @effectiveFrom = " + FilterString(effectiveFrom);
      sql += ", @effectiveTo = " + FilterString(effectiveTo);
      sql += ", @isActive = " + FilterString(isActive);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DbResult Delete(string user, string sscMasterId) {
      string sql = "EXEC proc_sscMaster";
      sql += " @flag = 'd'";
      sql += ", @user = " + FilterString(user);
      sql += ", @sscMasterId = " + FilterString(sscMasterId);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DataRow SelectById(string user, string sscMasterId) {
      string sql = "EXEC proc_sscMaster";
      sql += " @flag = 'a'";
      sql += ", @user = " + FilterString(user);
      sql += ", @sscMasterId = " + FilterString(sscMasterId);

      DataSet ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0].Rows[0];
    }

    public DbResult Approve(string user, string sscMasterId) {
      string sql = "EXEC proc_sscMaster";
      sql += "  @flag = 'approve'";
      sql += ", @user = " + FilterString(user);
      sql += ", @sscMasterId = " + FilterString(sscMasterId);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DbResult Reject(string user, string sscMasterId) {
      string sql = "EXEC proc_sscMaster";
      sql += "  @flag = 'reject'";
      sql += ", @user = " + FilterString(user);
      sql += ", @sscMasterId = " + FilterString(sscMasterId);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DataTable GetCountryList() {
      string sql = "EXEC proc_sscMaster @flag='scl'";
      return ExecuteDataset(sql).Tables[0];
    }

    public DataTable GetDetail(string dscMasterId, string user) {
      string sql = "EXEC ttt ";
      return ExecuteDataset(sql).Tables[0];
    }

    // for copy & save portion
    public DataRow SelectSearchById(string user, string agentId, string sessionId) {
      string sql = "EXEC proc_sscCopyMaster";
      sql += " @flag = 'a'";
      sql += ", @user = " + FilterString(user);
      sql += ", @sAgent = " + FilterString(agentId);
      sql += ", @sessionId = " + FilterString(sessionId);

      DataSet ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0].Rows[0];
    }
    public DbResult CopySave(string user
                   , string sscMasterId
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
                   , string ve
                   , string veType
                   , string ne
                   , string neType
                   , string effectiveFrom
                   , string effectiveTo
                   , string sscCopyMasterId
                   , string sessionId) {
      string sql = "EXEC proc_sscCopyMaster";
      sql += "  @flag = " + (sscMasterId == "0" || sscMasterId == "" ? "'i'" : "'u'");
      sql += ", @user = " + FilterString(user);
      sql += ", @sscMasterId = " + FilterString(sscMasterId);
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
      sql += ", @ve = " + FilterString(ve);
      sql += ", @veType = " + FilterString(veType);
      sql += ", @ne = " + FilterString(ne);
      sql += ", @neType = " + FilterString(neType);
      sql += ", @effectiveFrom = " + FilterString(effectiveFrom);
      sql += ", @effectiveTo = " + FilterString(effectiveTo);
      sql += ", @copySscMasterId = " + FilterString(sscCopyMasterId);
      sql += ", @sessionId = " + FilterString(sessionId);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    //Pay Commission report
    public DataTable GetPayCommissionMaster(string user, string sCountry, string sAgent, string sBranch, string rCountry, string rAgent, string rBranch) {
      var sql = "EXEC proc_payCommissionReport @flag = 'master'";
      sql += ", @user = " + FilterString(user);
      sql += ", @sCountry = " + FilterString(sCountry);
      sql += ", @sAgent = " + FilterString(sAgent);
      sql += ", @sBranch = " + FilterString(sBranch);
      sql += ", @rCountry = " + FilterString(rCountry);
      sql += ", @rAgent = " + FilterString(rAgent);
      sql += ", @rBranch = " + FilterString(rBranch);

      return ExecuteDataTable(sql);
    }

    public DataTable GetPayCommissionDetail(string user, string ruleId) {
      var sql = "EXEC proc_payCommissionReport @flag = 'detail'";
      sql += ", @user = " + FilterString(user);
      sql += ", @ruleId = " + FilterString(ruleId);

      return ExecuteDataTable(sql);
    }
    //Send Commission report
    public DataTable GetSendCommissionMaster(string user, string sCountry, string sAgent, string rCountry, string rAgent) {
      var sql = "EXEC proc_sendCommissionRpt @flag = 'master'";
      sql += ", @user = " + FilterString(user);
      sql += ", @sCountryId = " + FilterString(sCountry);
      sql += ", @sAgent = " + FilterString(sAgent);
      sql += ", @rCountryId = " + FilterString(rCountry);
      sql += ", @rAgent = " + FilterString(rAgent);

      return ExecuteDataTable(sql);
    }

    public DataTable GetSendCommissionDetail(string user, string ruleId) {
      var sql = "EXEC proc_sendCommissionRpt @flag = 'detail'";
      sql += ", @user = " + FilterString(user);
      sql += ", @ruleId = " + FilterString(ruleId);

      return ExecuteDataTable(sql);
    }
    //service chargae report
    public DataTable GetScRuleMaster(string user, string sCountry, string agent, string branch, string pCountry) {
      var sql = "EXEC proc_serviceChargeReport @flag = 'master'";
      sql += ", @user = " + FilterString(user);
      sql += ", @agent = " + FilterString(agent);
      sql += ", @branch = " + FilterString(branch);
      sql += ", @pCountry = " + FilterString(pCountry);
      sql += ", @sCountry = " + FilterString(sCountry);

      return ExecuteDataTable(sql);
    }

    public DataTable GetScRuleDetail(string user, string ruleId) {
      var sql = "EXEC proc_serviceChargeReport @flag = 'detail'";
      sql += ", @user = " + FilterString(user);
      sql += ", @ruleId = " + FilterString(ruleId);

      return ExecuteDataTable(sql);
    }
  }
}