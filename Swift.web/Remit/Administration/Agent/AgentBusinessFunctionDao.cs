using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration.Agent {
  public class AgentBusinessFunctionDao : RemittanceDao {
    public DbResult Update(string user, string agentId
                            , string defaultDepositMode
                            , string invoicePrintMode
                            , string invoicePrintMethod
                            , string globalTRNAllowed
                            , string settlementType
                            , string dateFormat
                            , string agentOperationType
                            , string applyCoverFund
                            , string sendSMSToReceiver
                            , string sendEmailToReceiver
                            , string sendSMSToSender
                            , string sendEmailToSender
                            , string trnMinAmountForTestQuestion
                            , string birthdayAndOtherWish
                            , string enableCashCollection
                            , string agentLimitDispSendTxn
                            , string fromSendTrnTime
                            , string toSendTrnTime
                            , string fromPayTrnTime
                            , string toPayTrnTime
                            , string fromRptViewTime
                            , string toRptViewTime
                            , string isRT
                            , string agentAutoApprovalLimit
                            , string routingEnable
                            , string selfTxnApprove
                            , string hasUSDNostroAc
                            , string flcNostroAcCurr
                            , string fxGain
                            , string incomingAccount
                            , string outgoingAccount
        ) {
      string sql = "EXEC proc_agentBusinessFunction";
      sql += "  @flag = 'i'";
      sql += ", @user = " + FilterString(user);
      sql += ", @agentId = " + FilterString(agentId);
      sql += ", @defaultDepositMode = " + FilterString(defaultDepositMode);
      sql += ", @invoicePrintMode = " + FilterString(invoicePrintMode);
      sql += ", @invoicePrintMethod = " + FilterString(invoicePrintMethod);
      sql += ", @globalTRNAllowed = " + FilterString(globalTRNAllowed);
      sql += ", @settlementType = " + FilterString(settlementType);
      sql += ", @dateFormat = " + FilterString(dateFormat);
      sql += ", @agentOperationType = " + FilterString(agentOperationType);
      sql += ", @applyCoverFund = " + FilterString(applyCoverFund);
      sql += ", @sendSMSToReceiver = " + FilterString(sendSMSToReceiver);
      sql += ", @sendEmailToReceiver = " + FilterString(sendEmailToReceiver);
      sql += ", @sendSMSToSender = " + FilterString(sendSMSToSender);
      sql += ", @sendEmailToSender = " + FilterString(sendEmailToSender);
      sql += ", @trnMinAmountForTestQuestion = " + FilterString(trnMinAmountForTestQuestion);
      sql += ", @birthdayAndOtherWish = " + FilterString(birthdayAndOtherWish);
      sql += ", @enableCashCollection = " + FilterString(enableCashCollection);
      sql += ", @agentLimitDispSendTxn = " + FilterString(agentLimitDispSendTxn);
      sql += ", @fromSendTrnTime = " + FilterString(fromSendTrnTime);
      sql += ", @toSendTrnTime = " + FilterString(toSendTrnTime);
      sql += ", @fromPayTrnTime = " + FilterString(fromPayTrnTime);
      sql += ", @toPayTrnTime = " + FilterString(toPayTrnTime);
      sql += ", @fromRptViewTime = " + FilterString(fromRptViewTime);
      sql += ", @toRptViewTime = " + FilterString(toRptViewTime);
      sql += ", @isRT = " + FilterString(isRT);
      sql += ", @agentAutoApprovalLimit = " + FilterString(agentAutoApprovalLimit);
      sql += ", @routingEnable=" + FilterString(routingEnable);
      sql += ", @isSelfTxnApprove=" + FilterString(selfTxnApprove);
      sql += ", @hasUSDNostroAc=" + FilterString(hasUSDNostroAc);
      sql += ", @flcNostroAcCurr=" + FilterString(flcNostroAcCurr);
      sql += ", @fxGain=" + FilterString(fxGain);
      sql += ", @incomingAccount=" + FilterString(incomingAccount);
      sql += ", @outgoingAccount=" + FilterString(outgoingAccount);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DataRow SelectById(string user, string agentId) {
      string sql = "EXEC proc_agentBusinessFunction";
      sql += " @flag = 'a'";
      sql += ", @user = " + FilterString(user);
      sql += ", @agentId = " + FilterString(agentId);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0].Rows[0];
    }

    public DbResult UpdateRsList(string user, string agentId, string rsList, string agentType, string listType) {
      string sql = "EXEC proc_rsList";
      sql += " @flag = 'i'";
      sql += ",@user = " + FilterString(user);
      sql += ",@agentId = " + FilterString(agentId);
      sql += ",@rsList = " + FilterString(rsList);
      sql += ",@agentRole = " + FilterString(agentType);
      sql += ",@listType = " + FilterString(listType);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ParseDbResult(ds.Tables[0]);
    }

    public DbResult UpdateRbaList(string user, string agentId, string memberAgentId) {
      string sql = "EXEC proc_regionalBranchAccessSetup";
      sql += " @flag = 'i'";
      sql += ",@user = " + FilterString(user);
      sql += ",@agentId = " + FilterString(agentId);
      sql += ",@memberAgentId = " + FilterString(memberAgentId);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ParseDbResult(ds.Tables[0]);
    }

    public DbResult UpdateAstList(string user, string agentId, string serviceTypeId) {
      string sql = "EXEC proc_agentServiceType";
      sql += " @flag = 'i'";
      sql += ",@user = " + FilterString(user);
      sql += ",@agentId = " + FilterString(agentId);
      sql += ",@serviceTypeId = " + FilterString(serviceTypeId);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ParseDbResult(ds.Tables[0]);
    }

    public DbResult UpdateAdb(string user, string agentDepositBankId, string agentId, string bankName,
                              string bankAcctNum, string description) {
      string sql = "EXEC proc_agentDepositBank";
      sql += " @flag = " + (agentDepositBankId == "0" || agentDepositBankId == "" ? "'i'" : "'u'");
      sql += ",@user = " + FilterString(user);
      sql += ",@agentId = " + FilterString(agentId);
      sql += ",@bankName = " + FilterString(bankName);
      sql += ",@bankAcctNum = " + FilterString(bankAcctNum);
      sql += ",@description = " + FilterString(description);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ParseDbResult(ds.Tables[0]);
    }

    public DbResult UpdateTtl(string user, string agentTranTypeLimitId, string agentId, string serviceType,
                              string tranLimitMax, string tranLimitMin, string isDefaultDepositMode) {
      string sql = "EXEC proc_agentTranTypeLimit";
      sql += " @flag = " + (agentTranTypeLimitId == "0" || agentTranTypeLimitId == "" ? "'i'" : "'u'");
      sql += ",@user = " + FilterString(user);
      sql += ",@agentId = " + FilterString(agentId);
      sql += ",@serviceType = " + FilterString(serviceType);
      sql += ",@tranLimitMax = " + FilterString(tranLimitMax);
      sql += ",@tranLimitMin = " + FilterString(tranLimitMin);
      sql += ",@isDefaultDepositMode = " + FilterString(isDefaultDepositMode);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ParseDbResult(ds.Tables[0]);
    }

    public DbResult Delete(string user, string rsListId) {
      string sql = "EXEC proc_rsList";
      sql += " @flag = 'd'";
      sql += ",@user = " + FilterString(user);
      sql += ",@rsListId = " + FilterString(rsListId.Replace(",", ""));

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ParseDbResult(ds.Tables[0]);
    }

    public DbResult DeleteRba(string user, string regionalBranchAccessSetupId) {
      string sql = "EXEC proc_regionalBranchAccessSetup";
      sql += " @flag = 'd'";
      sql += ",@user = " + FilterString(user);
      sql += ",@regionalBranchAccessSetupId = " + FilterString(regionalBranchAccessSetupId);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ParseDbResult(ds.Tables[0]);
    }

    public DbResult DeleteAst(string user, string regionalBranchAccessSetupId) {
      string sql = "EXEC proc_agentServiceType";
      sql += " @flag = 'd'";
      sql += ",@user = " + FilterString(user);
      sql += ",@agentServiceTypeId = " + FilterString(regionalBranchAccessSetupId);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ParseDbResult(ds.Tables[0]);
    }

    public DbResult DeleteAdb(string user, string agentDepositBankId) {
      string sql = "EXEC proc_agentDepositBank";
      sql += " @flag = 'd'";
      sql += ",@user = " + FilterString(user);
      sql += ",@agentDepositBankId = " + FilterString(agentDepositBankId);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ParseDbResult(ds.Tables[0]);
    }

    public DbResult DeleteTtl(string user, string agentTranTypeLimitId) {
      string sql = "EXEC proc_agentTranTypeLimit";
      sql += " @flag = 'd'";
      sql += ",@user = " + FilterString(user);
      sql += ",@agentTranTypeLimitId = " + FilterString(agentTranTypeLimitId);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ParseDbResult(ds.Tables[0]);
    }

    public DataRow SelectAdbById(string user, string agentDepositBankId) {
      string sql = "EXEC proc_agentDepositBank";
      sql += " @flag = 'a'";
      sql += ",@user = " + FilterString(user);
      sql += ",@agentDepositBankId = " + FilterString(agentDepositBankId);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0].Rows[0];
    }

    public DataRow SelectTtlById(string user, string agentTranTypeLimitId) {
      string sql = "EXEC proc_agentTranTypeLimit";
      sql += " @flag = 'a'";
      sql += ",@user = " + FilterString(user);
      sql += ",@agentTranTypeLimitId = " + FilterString(agentTranTypeLimitId);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0].Rows[0];
    }
  }
}