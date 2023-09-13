using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.Administration.AgentSetup.Functions {
  public partial class BusinessFunction : Page {
    private readonly StaticDataDdl _sl = new StaticDataDdl();
    private readonly AgentBusinessFunctionDao obj = new AgentBusinessFunctionDao();
    private readonly RemittanceLibrary sl = new RemittanceLibrary();
    private readonly SwiftTab _tab = new SwiftTab();
    private const string ViewFunctionId = "20111000";

    protected void Page_Load(object sender, EventArgs e) {
      // MakeNumericTextbox();

      if(!IsPostBack) {
        Authenticate();
        GetStatic.AlertMessage(Page);
        LoadTab();
        PopulateDdl(null);
        PopulateDataById();
        Misc.MakeNumericTextbox(ref autoApprovalLimit);
      }

      var doShowNostroFlc = GetAgentType().Equals(2903);
      hasUSDNostroAc.Visible = doShowNostroFlc;
      flcNostroAcCurr.Visible = doShowNostroFlc;
      lblFlcNostroAcCurr.Visible = doShowNostroFlc;
      lblHasUSDNostro.Visible = doShowNostroFlc;
    }

    private void Authenticate() {
      _sl.CheckAuthentication(ViewFunctionId);
    }

    protected void btnSubmit_Click(object sender, EventArgs e) {
      onSave();
    }

    #region method

    protected void PopulateDdl(DataRow dr) {
      _sl.SetStaticDdl(ref dateFormat, "3000", GetStatic.GetRowData(dr, "dateFormat"), "Select");
      _sl.SetStaticDdl(ref defaultDepositMode, "2200", GetStatic.GetRowData(dr, "defaultDepositMode"), "Any");
      _sl.SetStaticDdl(ref settlementType, "1100", GetStatic.GetRowData(dr, "settlementType"), "Select");
      var sql = "EXEC proc_dropDownLists @flag='currListByAgent',@param1='abf',@param=" + _sl.FilterString(GetAgentId().ToString());
      _sl.SetDDL(ref flcNostroAcCurr, sql, "currencyId", "currencyCode", GetStatic.GetRowData(dr, "flcNostroAcCurr"), "None");
      sql = "EXEC proc_dropDownLists @flag='agentAccount',@param=" + _sl.FilterString(GetAgentId().ToString());
      _sl.SetDDL(ref incomingList, sql, "acct_num", "acct_name", GetStatic.GetRowData(dr, "incomingList"), "None");
      _sl.SetDDL(ref outgoingList, sql, "acct_num", "acct_name", GetStatic.GetRowData(dr, "outgoingList"), "None");
    }

    protected void PopulateDataById() {
      DataRow dr = obj.SelectById(GetStatic.GetUser(), GetAgentId().ToString());
      if(dr == null)
        return;

      defaultDepositMode.Text = dr["defaultDepositMode"].ToString();
      invoicePrintMode.Text = dr["invoicePrintMode"].ToString();
      invoicePrintMethod.Text = dr["invoicePrintMethod"].ToString();
      globalTRNAllowed.SelectedValue = dr["globalTRNAllowed"].ToString();
      settlementType.Text = dr["settlementType"].ToString();
      dateFormat.Text = dr["dateFormat"].ToString();
      agentOperationType.Text = dr["agentOperationType"].ToString();
      applyCoverFund.Text = dr["applyCoverFund"].ToString();

      sendSMSToReceiver.SelectedValue = dr["sendSMSToReceiver"].ToString();
      sendEmailToReceiver.SelectedValue = dr["sendEmailToReceiver"].ToString();
      sendSMSToSender.SelectedValue = dr["sendSMSToSender"].ToString();
      sendEmailToSender.SelectedValue = dr["sendEmailToSender"].ToString();

      birthdayAndOtherWish.SelectedValue = dr["birthdayAndOtherWish"].ToString();
      agentLimitdispSendTxn.SelectedValue = dr["agentLimitDispSendTxn"].ToString();

      fromSendTrnTime.Text = dr["fromSendTrnTime"].ToString();
      toSendTrnTime.Text = dr["toSendTrnTime"].ToString();
      fromPayTrnTime.Text = dr["fromPayTrnTime"].ToString();
      toPayTrnTime.Text = dr["toPayTrnTime"].ToString();
      fromRptViewTime.Text = dr["fromRptViewTime"].ToString();
      toRptViewTime.Text = dr["toRptViewTime"].ToString();
      isRTUser.SelectedValue = dr["isRT"].ToString();
      autoApprovalLimit.Text = dr["agentAutoApprovalLimit"].ToString();
      routingEnable.Text = dr["routingEnable"].ToString();
      selfTxnApprove.Text = dr["isSelfTxnApprove"].ToString();
      hasUSDNostroAc.Text = dr["hasUSDNostroAc"].ToString();
      fxGain.SelectedValue = dr["fxGain"].ToString();
      incomingList.SelectedValue = dr["incoming"].ToString();
      outgoingList.SelectedValue = dr["outgoing"].ToString();
    }

    private void onSave() {
      DbResult dbResult = obj.Update(GetStatic.GetUser()
                    , GetAgentId().ToString()
                    , defaultDepositMode.Text
                    , invoicePrintMode.Text
                    , invoicePrintMethod.Text
                    , globalTRNAllowed.Text
                    , settlementType.Text
                    , dateFormat.Text
                    , agentOperationType.Text
                    , applyCoverFund.Text
                    , sendSMSToReceiver.Text
                    , sendEmailToReceiver.Text
                    , sendSMSToSender.Text
                    , sendEmailToSender.Text
                    , ""
                    , birthdayAndOtherWish.Text
                    , ""
                    , agentLimitdispSendTxn.Text
                    , fromSendTrnTime.Text
                    , toSendTrnTime.Text
                    , fromPayTrnTime.Text
                    , toPayTrnTime.Text
                    , fromRptViewTime.Text
                    , toRptViewTime.Text
                    , isRTUser.Text
                    , autoApprovalLimit.Text
                    , routingEnable.Text
                    , selfTxnApprove.Text
                    , hasUSDNostroAc.Text
                    , flcNostroAcCurr.Text
                    , fxGain.Text
                    ,incomingList.SelectedValue
                    ,outgoingList.SelectedValue
                    );
      ManageMessage(dbResult);
    }

    private void ManageMessage(DbResult dbResult) {
      GetStatic.SetMessage(dbResult);
      if(dbResult.ErrorCode == "0") {
        Response.Redirect("BusinessFunction.aspx?agentId=" + GetAgentId() + "&aType=" + GetAgentType() +
                          "&enCash=" + null);
      } else {
        GetStatic.AlertMessage(Page);
      }
    }

    #endregion method

    #region showhidetab

    private void LoadTab() {
      divTab.Visible = true;
      var agentId = GetAgentId();
      var mode = GetMode();
      var parentId = GetParentId();
      var sParentId = GetParentId();
      var aType = GetAgentType();
      var actAsBranch = GetActAsBranchFlag();

      var queryStrings = "?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" +
                               sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch;
      _tab.NoOfTabPerRow = 8;

      _tab.TabList = new List<TabField>
                         {
                                   new TabField("Business Function", "", true),
                                   new TabField("Agent Group", "AgentGroupMapping.aspx" + queryStrings)
                               };
      string enCashColl = GetEnableCashCollection();
      string agentRole = GetAgentRole();
      if(enCashColl == "Y") {
        _tab.TabList.Add(new TabField("Deposit Bank List", "AgentDepositBank/List.aspx" + queryStrings));
      }

      //if(aType == 2902 || aType == 2903 || aType == 2904 || actAsBranch == "Y")
      //{
      //    if(aType == 2904 || actAsBranch == "Y")
      //    {
      //        _tab.TabList.Add(new TabField("Regional Access Setup", "RegionalBranchAccessSetup.aspx" + queryStrings));
      //    }
      //}

      divTab.InnerHtml = _tab.CreateTab();
    }

    #endregion showhidetab

    #region QueryString

    protected long GetMode() {
      return GetStatic.ReadNumericDataFromQueryString("mode");
    }

    protected long GetParentId() {
      return GetStatic.ReadNumericDataFromQueryString("parent_id");
    }

    protected string GetActAsBranchFlag() {
      return GetStatic.ReadQueryString("actAsBranch", "").ToString();
    }

    protected string GetAgentPageTab() {
      return "Agent Name : " + sl.GetAgentName(GetAgentId().ToString());
    }

    protected string GetEnableCashCollection() {
      return sl.GetEnableCashCollection(GetAgentId().ToString());
    }

    protected string GetAgentRole() {
      return sl.GetAgentRole(GetAgentId().ToString());
    }

    protected long GetAgentId() {
      return GetStatic.ReadNumericDataFromQueryString("agentId");
    }

    protected long GetAgentType() {
      return GetStatic.ReadNumericDataFromQueryString("aType");
    }

    protected string EnableCashCollection() {
      return GetStatic.ReadQueryString("enCash", "N");
    }

    #endregion QueryString
  }
}