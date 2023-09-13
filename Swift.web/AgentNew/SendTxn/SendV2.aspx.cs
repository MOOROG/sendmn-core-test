using Newtonsoft.Json;
using Swift.API.Common;
using Swift.API.Common.ExRate;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.AgentPanel.Send;
using Swift.DAL.Common;
using Swift.DAL.Remittance.CustomerDeposits;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.SendTxn {
  public partial class SendV2 : System.Web.UI.Page {
    private SendTranIRHDao st = new SendTranIRHDao();
    private readonly CustomerDepositDao _dao = new CustomerDepositDao();
    private readonly StaticDataDdl _sdd = new StaticDataDdl();
    private const string ViewFunctionId = "40101400";
    private const string ManualEditServiceCharge = "40101440";
    private const string NewReceiverId = "20213000";
    private const string AllowOnBehalf = "40101420";
    private const string EnableCustomerSignature = "40101430";
    private readonly ExchangeRateAPIService _exrateService = new ExchangeRateAPIService();

    protected string IsAllowOnBehalf = "N";
    protected string LogginBranch = "";

    protected void Page_Load(object sender, EventArgs e) {
      txtSendIdValidDate_err.Visible = false;
      if (_sdd.HasRight(AllowOnBehalf)) {
        IsAllowOnBehalf = "Y";
      } else {
        LogginBranch = GetStatic.GetSettlingAgent() + "|" + GetStatic.ReadSession("isActAsBranch", "N");
      }
      _sdd.CheckSession();
      GetStatic.PrintMessage(Page);
      txtCollAmt.Attributes.Add("onkeyup", "return CalcOnEnter((event?event:evt));");
      string reqMethod = Request.Form["MethodName"];
      if (!string.IsNullOrEmpty(reqMethod)) {
        if (GetStatic.GetUser() == "") {
          Response.ContentType = "text/plain";
          Response.Write("[{\"session_end\":\"1\"}]");
          Response.End();
          return;
        }
      }
      Authenticate();
      if (String.IsNullOrEmpty(reqMethod)) {
        //GetCurrentBalance();
        Misc.MakeNumericTextbox(ref txtCollAmt);
        Misc.MakeNumericTextbox(ref txtPayAmt);
      }

      if (!Page.IsPostBack) {
        #region Ajax methods

        switch (reqMethod) {
          case "SearchCustomer":
            CustomerSearchLoadData();
            break;

          case "getPayoutPartner":
            GetPayoutPartner();
            break;

          case "SearchReceiver":
            SearchReceiverDetails();
            break;

          case "PopulateReceiverDDL":
            PopulateReceiverDDL();
            break;

          case "getLocation":
            GetLocationData();
            break;

          case "getSubLocation":
            GetSubLocationData();
            break;

          case "getTownLocation":
            GetTownLocation();
            break;

          case "SearchRateScData":
            SearchRateScData();
            break;

          case "PaymentModePcountry":
            LoadDataFromDdl("pMode");
            break;

          case "PCurrPcountry":
            PCurrPcountry();
            break;

          case "CalculateTxn":
            Calculate();
            break;

          case "ReceiverDetailBySender":
            PopulateReceiverBySender();
            break;

          case "loadAgentBank":
            LoadDataFromDdl("agentByPmode");
            break;

          case "PAgentChange":
            GetAgentSetting();
            break;

          case "PBranchChange":
            LoadAgentByExtBranch();
            break;

          case "LoadAgentByExtAgent":
            LoadAgentByExtAgent();
            break;

          case "LoadSchemeByRcountry":
            LoadSchemeByRCountry();
            break;

          case "LoadCustomerRate":
            LoadCustomerRate();
            break;

          case "CheckSenderIdNumber":
            CheckSenderIdNumber();
            break;

          case "CheckAvialableBalance":
            CheckAvialableBalance();
            break;

          case "getPayerDataByBankId":
            GetPayerDataByBankId();
            break;

          case "getAvailableBalance":
            GetCurrentBalance();
            break;

          case "validateReferral":
            ValidateReferral();
            break;

          case "getPayerBranchDataByPayerAndCityId":
            GetPayerDataByPayerAndCityId();
            break;

          case "getReferralBalance":
            //GetReferralBalance();
            break;

          case "getListData":
            PopulateData();
            break;

          case "MapData":
            ProceedMapData();
            break;

          case "getAdditionalCDDI":
            GetAdditionalCDDI();
            break;

          case "PopulateBranch":
            GetBankBranch();
            break;

          case "UnMapData":
            UnMapData();
            break;

          case "UpdateVisaStatus":
            UpdateVisaStatus();
            break;
        }

        #endregion Ajax methods

        PopulateDdl();
        GetRequiredField();
        PopulateQuestionaries();
      }
    }

    public void PopulateQuestionaries() {
      var sb = new StringBuilder("");
      DataSet ds = st.LoadQuestionaries(GetStatic.GetUser());

      sb.AppendLine("<table class=\"table\" id=\"tblQuestionnarieQsn\">");

      if (ds == null || ds.Tables.Count < 2 || ds.Tables[0].Rows.Count <= 0 || ds.Tables[1].Rows.Count <= 0) {
        sb.AppendLine("<tr><td colspan='6'><strong>Questionaries Data Not Available!!!</strong></td></tr></table>");
        Div_Questionaries.InnerHtml = sb.ToString();
        return;
      }

      // var sendPage = ds.Tables[0].Select("appliedfor = 'sendpage'");
      int rowCount = 1;

      sb.AppendLine("<tr>");
      foreach (DataRow dr in ds.Tables[0].Rows) {
        var QuestionId = ds.Tables[1].Select("QUESTION_ID ='" + dr["QUESTION_ID"].ToString() + "'");

        if (rowCount == 4) {
          sb.AppendLine("<tr>");
          rowCount = 1;
        }

        sb.AppendLine("<td style=\"width: 12 %; \">" + dr["QUESTION_TEXT"].ToString() + "</td>");
        sb.AppendLine(" <td style=\"width: 17 %; \">");
        sb.AppendLine("<select id=\"questionnarie_" + dr["QUESTION_ID"].ToString() + "\" class=\"form-control" + dr["IS_REQUIRED"].ToString() + "\">");
        sb.AppendLine("<Option value = ''>Select...</Option>");

        foreach (DataRow val in QuestionId) {
          if (QuestionId == null || QuestionId.Length == 0)
            break;

          sb.AppendLine("<Option value = '" + val["OPTION_VALUE"].ToString() + "'>" + val["OPTION_TEXT"].ToString() + "</Option>");
        }

        sb.AppendLine("</select>");
        sb.AppendLine("</td>");

        if (rowCount == 3) {
          sb.AppendLine("</tr>");
        }

        rowCount++;
      }
      if (rowCount != 3) {
        sb.AppendLine("</tr>");
      }
      sb.AppendLine("</table>");

      Div_Questionaries.InnerHtml = sb.ToString();
      return;
    }

    protected void GetBankBranch() {
      string bank = Request.Form["Bank"];
      string Country = Request.Form["Country"];
      string searchText = Request.Form["searchText"];
      string page = Request.Form["page"];
      if (string.IsNullOrWhiteSpace(bank)) {
        GetStatic.JsonResponse("", this);
      }

      BankSearchModel bankSearchModel = new BankSearchModel() {
        SearchType = "",
        SearchValue = searchText,
        PAgent = bank,
        PAgentType = "I",
        PCountryName = Country,
        PayoutPartner = Request.Form["payoutPartner"],
        PaymentMode = Request.Form["PayMode"]
      };

      IList<BranchModel> bankModelList = st.LoadBranchByAgent(bankSearchModel);

      GetStatic.JsonResponse(bankModelList, this);
      //JsonSerialize(bankModelList);
    }

    protected void GetAdditionalCDDI() {
      string customerId = Request.Form["customerId"];
      //var dt = st.LoadCustomerData(searchType, searchValue, "s", GetStatic.GetCountryId(), GetStatic.GetSettlingAgent());
      var dt = st.GetAdditionalCDDIInfo(GetStatic.GetUser(), customerId);
      if (dt == null) {
        Response.Write("");
        Response.End();
        return;
      }
      Response.ContentType = "text/plain";
      string json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    protected string GetCustomerId() {
      return GetStatic.ReadQueryString("customerId", "");
    }

    private void GetPayoutPartner() {
      string pCountry = Request.Form["pCountry"];
      string pMode = Request.Form["pMode"];

      //var dt = st.LoadCustomerData(searchType, searchValue, "s", GetStatic.GetCountryId(), GetStatic.GetSettlingAgent());
      var dt = st.GetPayoutPartner(GetStatic.GetUser(), pCountry, pMode);
      if (dt == null) {
        Response.Write("");
        Response.End();
        return;
      }
      Response.ContentType = "text/plain";
      string json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void SearchReceiverDetails() {
      string customerId = Request.Form["customerId"];

      //var dt = st.LoadCustomerData(searchType, searchValue, "s", GetStatic.GetCountryId(), GetStatic.GetSettlingAgent());
      var dt = st.LoadReceiverData(GetStatic.GetUser(), customerId);
      if (dt == null) {
        Response.Write("");
        Response.End();
        return;
      }
      Response.ContentType = "text/plain";
      string json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void PopulateReceiverDDL() {
      string customerId = Request.Form["customerId"];

      //var dt = st.LoadCustomerData(searchType, searchValue, "s", GetStatic.GetCountryId(), GetStatic.GetSettlingAgent());

      var dt = st.PopulateReceiverDDL(GetStatic.GetUser(), customerId);

      if (dt == null) {
        Response.Write("");
        Response.End();
        return;
      }
      Response.ContentType = "text/plain";
      string json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void GetSubLocationData() {
      string pLocation = Request.Form["PLocation"];
      DataTable dt = st.GetPayoutSubLocation(pLocation);

      Response.ContentType = "text/plain";
      var json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void GetTownLocation() {
      string subLocation = Request.Form["subLocation"];
      DataTable dt = st.GetPayoutTownLocation(subLocation);

      Response.ContentType = "text/plain";
      var json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void GetLocationData() {
      string pCountry = Request.Form["PCountry"];
      string pMode = Request.Form["PMode"];
      string partnerId = Request.Form["PartnerId"];
      DataTable dt = st.GetPayoutLocation(pCountry, pMode, partnerId);

      Response.ContentType = "text/plain";
      var json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    protected string sb = "";

    private void Authenticate() {
      _sdd.CheckAuthentication(ViewFunctionId);
      if (_sdd.HasRight(ManualEditServiceCharge)) {
        editServiceCharge.Disabled = false;
        allowEditSC.Value = "Y";
      } else {
        allowEditSC.Value = "N";
        editServiceCharge.Disabled = true;
        lblServiceChargeAmt.Attributes.Add("readonly", "readonly");
      }
    }

    private void GetRequiredField() {
      var ds = st.GetRequiredField(GetStatic.GetCountryId(), GetStatic.GetAgent());
      if (ds == null)
        return;
      var dr = ds.Tables[0].Rows[0];
      if (null != ds.Tables[1]) {
        ManageCollMode(ds.Tables[1]);
      }
      //Sender ID
      ddSenIdType_err.Visible = false;
      txtSendIdNo_err.Visible = false;
      switch (dr["id"].ToString()) {
        case "H":
          trSenId.Attributes.Add("style", "display: none;");
          break;

        case "M":
          ddSenIdType.Attributes.Add("Class", "required");
          txtSendIdNo.Attributes.Add("Class", "required");
          ddSenIdType_err.Visible = true;
          txtSendIdNo_err.Visible = true;
          break;
      }

      //Sender ID Expiry Date
      //txtSendIdValidDate_err.Visible = false;
      switch (dr["iDValidDate"].ToString()) {
        case "H":
          tdSenExpDateLbl.Attributes.Add("style", "display: none;");
          tdSenExpDateTxt.Attributes.Add("style", "display: none;");

          //Sender DOB
          txtSendDOB_err.Visible = false;
          switch (dr["dob"].ToString()) {
            case "H":
              tdSenDobLbl.Attributes.Add("style", "display: none;");
              tdSenDobTxt.Attributes.Add("style", "display: none;");
              break;

            case "M":
              lblSDOB.Visible = true;
              txtSendDOB.Attributes.Add("Class", "required");
              txtSendDOB_err.Visible = true;
              break;
          }
          break;

        case "M":
          txtSendIdValidDate.Attributes.Add("Class", "required");
          //Sender DOB
          txtSendDOB_err.Visible = false;
          switch (dr["dob"].ToString()) {
            case "H":
              tdSenDobLbl.Attributes.Add("style", "display: none;");
              tdSenDobTxt.Attributes.Add("style", "display: none;");
              break;

            case "M":
              lblSDOB.Visible = true;
              txtSendDOB.Attributes.Add("Class", "required");
              txtSendDOB_err.Visible = true;
              break;
          }
          break;

        default:
          //Sender DOB
          txtSendDOB_err.Visible = false;
          switch (dr["dob"].ToString()) {
            case "H":
              tdSenDobLbl.Attributes.Add("style", "display: none;");
              tdSenDobTxt.Attributes.Add("style", "display: none;");
              break;

            case "M":
              lblSDOB.Visible = true;
              txtSendDOB.Attributes.Add("Class", "required");
              txtSendDOB_err.Visible = true;
              break;
          }
          break;
      }

      //Sender Mobile
      txtSendMobile_err.Visible = false;
      switch (dr["contact"].ToString()) {
        case "H":
          trSenContactNo.Attributes.Add("style", "display: none;");
          break;

        case "M":
          txtSendMobile.Attributes.Add("Class", "required");
          txtSendMobile_err.Visible = true;
          break;
      }

      //Sender City
      txtSendCity_err.Visible = false;
      switch (dr["city"].ToString()) {
        case "H":
          tdSenCityLbl.Attributes.Add("style", "display: none;");
          tdSenCityTxt.Attributes.Add("style", "display: none;");
          break;

        case "M":
          lblsCity.Visible = true;
          txtSendCity.Attributes.Add("Class", "required");
          txtSendCity_err.Visible = true;
          break;
      }

      //Sender Address1
      txtSendAdd1_err.Visible = false;
      switch (dr["address"].ToString()) {
        case "H":
          trSenAddress1.Attributes.Add("style", "display: none;");
          trSenAddress2.Attributes.Add("style", "display: none;");
          break;

        case "M":
          txtSendAdd1.Attributes.Add("class", "required");
          txtSendAdd1_err.Visible = true;
          break;
      }

      occupation_err.Visible = false;
      switch (dr["occupation"].ToString()) {
        case "H":
          trOccupation.Attributes.Add("style", "display: none;");
          break;

        case "M":
          lblOccupation.Visible = true;
          occupation.Attributes.Add("Class", "required");
          occupation_err.Visible = true;
          break;
      }

      companyName_err.Visible = false;
      switch (dr["company"].ToString()) {
        case "H":
          trSenCompany.Attributes.Add("style", "display: none;");
          break;

        case "M":
          companyName.Attributes.Add("Class", "required");
          lblCompName.Visible = true;
          companyName_err.Visible = true;
          break;
      }

      //Sender Salary
      ddlSalary_err.Visible = false;
      switch (dr["salaryRange"].ToString()) {
        case "M":
          lblSalaryRange.Visible = true;
          ddlSalary.Attributes.Add("Class", "required");
          ddlSalary_err.Visible = true;
          break;

        case "H":
          ddlSalary.Attributes.Add("Class", "HideControl");
          lblSalaryRange.Visible = false;
          trSalaryRange.Visible = false;
          break;
      }

      purpose_err.Visible = false;
      switch (dr["purposeofRemittance"].ToString()) {
        case "H":
          trPurposeOfRemittance.Attributes.Add("style", "display: none;");
          break;

        case "M":
          purpose.Attributes.Add("Class", "required");
          purpose_err.Visible = true;
          break;
      }

      sourceOfFund_err.Visible = false;
      //switch (dr["sourceofFund"].ToString())
      //{
      //    case "H":
      //        trSourceOfFund.Attributes.Add("style", "display: none;");
      //        break;

      //    case "M":
      //        lblSof.Visible = true;
      //        sourceOfFund.Attributes.Add("Class", "required");
      //        sourceOfFund_err.Visible = true;
      //        break;
      //}

      //Receiver ID
      ddlRecIdType_err.Attributes.Add("style", "display: none;");
      txtRecIdNo_err.Attributes.Add("style", "display: none;");
      switch (dr["rId"].ToString()) {
        case "H":
          trRecId.Attributes.Add("style", "display: none;");
          trRecId1.Attributes.Add("style", "display: none;");
          break;

        case "M":
          ddlRecIdType.Attributes.Add("Class", "required");
          txtRecIdNo.Attributes.Add("Class", "required");
          ddlRecIdType_err.Attributes.Add("style", "display: block;");
          txtRecIdNo_err.Attributes.Add("style", "display: block;");
          break;
      }

      //Receiver Mobile
      txtRecMobile_err.Attributes.Add("style", "display: none;");
      switch (dr["rContact"].ToString()) {
        case "H":
          trRecContactNo.Attributes.Add("style", "display: none;");
          break;

        case "M":
          txtRecMobile.Attributes.Add("Class", "required");
          txtRecMobile_err.Attributes.Remove("style");
          break;
      }

      //Receiver City
      txtRecCity_err.Visible = false;
      switch (dr["rcity"].ToString()) {
        case "H":
          tdRecCityLbl.Attributes.Add("style", "display: none;");
          tdRecCityTxt.Attributes.Add("style", "display: none;");
          break;

        case "M":
          txtRecCity.Attributes.Add("Class", "required");
          txtRecCity_err.Visible = true;
          break;
      }

      //Receiver Address
      txtRecAdd1_err.Visible = false;
      switch (dr["raddress"].ToString()) {
        case "H":
          trRecAddress1.Attributes.Add("style", "display: none;");
          trRecAddress2.Attributes.Add("style", "display: none;");
          break;

        case "M":
          txtRecAdd1.Attributes.Add("class", "required");
          txtRecAdd1_err.Visible = true;
          break;
      }

      relationship_err.Visible = false;
      switch (dr["rRelationShip"].ToString()) {
        //case "H":
        //    trRelWithRec.Attributes.Add("style", "display: none;");
        //    break;

        //case "M":
        //    relationship.Attributes.Add("Class", "required");
        //    relationship_err.Visible = true;
        //    break;
      }

      hdnBeneficiaryIdReq.Value = dr["rId"].ToString();
      hdnBeneficiaryContactReq.Value = dr["rContact"].ToString();
      hdnRelationshipReq.Value = dr["rRelationShip"].ToString();
    }

    private void ManageCollMode(DataTable dt) {
      StringBuilder sb = new StringBuilder();
      foreach (DataRow item in dt.Rows) {
        string checkedOrNot = item["ISDEFAULT"].ToString() == "1" ? "checked=\"checked\"" : "";
        sb.AppendLine("<input " + checkedOrNot + " type=\"checkbox\" id=\"" + item["COLLMODE"] + "\" name=\"chkCollMode\" value=\"" + item["detailTitle"] + "\" class=\"collMode-chk\">&nbsp;<label for=\"" + item["COLLMODE"] + "\">" + item["detailDesc"] + "</label>&nbsp;&nbsp;");
      }
      sb.AppendLine("<input type=\"checkbox\" id=\"11064\" name=\"chkCollMode\" value=\"Existing Balance\" class=\"collMode-chk\">&nbsp;<label for=\"11064\">Existing Balance</label>&nbsp;&nbsp;");
      sb.AppendLine("<span style='background-color: yellow; font-weight: 600;padding: 4px; display:none;' id='availableBalSpan'> Available Bal: <label id=\"availableBal\" style=\"font-size: 14px;font-weight: 800;\"></label>&nbsp;JPY</span>");
      collModeTd.InnerHtml = sb.ToString();
    }

    private void LoadSchemeByRCountry() {
      string pCountryFv = Request.Form["pCountry"];
      string pAgentFv = Request.Form["pAgent"];
      string sCustomerId = Request.Form["sCustomerId"];

      var dt = st.LoadSchemeByRCountry(GetStatic.GetCountryId(), GetStatic.GetAgent(), GetStatic.GetBranch(), pCountryFv, pAgentFv, sCustomerId);
      Response.ContentType = "text/plain";
      var json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    //private void GetCurrentBalance()
    //{
    //    var dr = st.GetAcDetail(GetStatic.GetUser());
    //    if (dr == null)
    //    {
    //        availableAmt.Text = "N/A";
    //        return;
    //    }
    //    availableAmt.Text = GetStatic.FormatData(dr["availableBal"].ToString(), "M");
    //    lblPerDayLimit.Text = GetStatic.FormatData(dr["txnPerDayCustomerLimit"].ToString(), "M");
    //    lblPerDayCustomerCurr.Text = dr["sCurr"].ToString();
    //    lblCollCurr.Text = dr["sCurr"].ToString();
    //    lblSendCurr.Text = dr["sCurr"].ToString();
    //    lblServiceChargeCurr.Text = dr["sCurr"].ToString();
    //    txnPerDayCustomerLimit.Value = dr["txnPerDayCustomerLimit"].ToString();
    //    balCurrency.Text = dr["balCurrency"].ToString();
    //    hdnLimitAmount.Value = dr["sCountryLimit"].ToString();
    //}

    protected long GetResendId() {
      return GetStatic.ReadNumericDataFromQueryString("resendId");
    }

    private void LoadAgentByExtAgent() {
      var pAgentFv = Request.Form["pAgent"];
      var dt = st.LoadAgentByExtAgent(GetStatic.GetUser(), pAgentFv);
      Response.ContentType = "text/plain";
      var json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void LoadAgentByExtBranch() {
      var pBranchFv = Request.Form["pBranch"];
      var dt = st.LoadAgentByExtBranch(GetStatic.GetUser(), pBranchFv);
      Response.ContentType = "text/plain";
      var json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void GetAgentSetting() {
      var pAgentFv = Request.Form["pAgent"];
      var pModeFv = Request.Form["pMode"];
      var pCountryFv = GetStatic.ReadFormData("pCountry", "");
      var pBankType = GetStatic.ReadFormData("pBankType", "");
      var dt = st.GetAgentSetting(GetStatic.GetUser(), pCountryFv, pAgentFv, pModeFv, pBankType);
      Response.ContentType = "text/plain";
      var json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void LoadDataFromDdl(string type) {
      var pAgentFv = Request.Form["pAgent"];
      var pModeFv = Request.Form["pmode"];
      var pCountryFv = Request.Form["pCountry"];

      DataTable dt = null;
      switch (type) {
        case "pMode":
          dt = st.LoadDataFromDdl(GetStatic.GetCountryId(), pCountryFv, pModeFv, GetStatic.GetAgent(), "recModeByCountry", GetStatic.GetUser());
          break;

        case "agentByPmode":
          if (string.IsNullOrWhiteSpace(pModeFv) || string.IsNullOrWhiteSpace(pCountryFv)) {
            Response.Write(null);
            Response.End();
            return;
          }
          dt = st.LoadDataFromDdl(GetStatic.GetCountryId(), pCountryFv, pModeFv, GetStatic.GetAgent(), "recAgentByRecModeAjaxagent", GetStatic.GetUser());
          break;

        case "LoadScheme":
          dt = st.LoadDataFromDdl(GetStatic.GetCountryId(), pCountryFv, pModeFv, pAgentFv, "schemeBysCountryrAgent", GetStatic.GetUser());
          break;
      }

      Response.ContentType = "text/plain";
      var json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void PopulateReceiverBySender() {
      string recId = Request.Form["id"];
      string senderId = Request.Form["senderId"];

      DataTable dt = st.PopulateReceiverBySender(senderId, "", recId);
      Response.ContentType = "text/plain";
      string json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void PCurrPcountry() {
      string pCountry = Request.Form["pCountry"];
      string pMode = Request.Form["pMode"];
      string pAgent = Request.Form["pAgent"];

      DataTable Dt = st.LoadPayCurr(pCountry, pMode, pAgent);
      Response.ContentType = "text/plain";
      string json = DataTableToJson(Dt);
      Response.Write(json);
      Response.End();
    }

    private void PopulateDdl() {
      var natCountry = GetStatic.ReadWebConfig("localCountry", "");
      LoadSenderCountry(ref txtSendNativeCountry, natCountry, "SELECT COUNTRY");
      LoadReceiverCountry(ref pCountry, "", "SELECT");

      _sdd.SetDDL(ref ddSenIdType, "exec proc_sendPageLoadData @flag='idTypeBySCountry',@countryId='" + GetStatic.GetCountryId() + "'", "valueId", "detailTitle", "", "SELECT");
      _sdd.SetDDL(ref ddlCustomerType, "exec proc_sendPageLoadData @flag='search-cust-by'", "VALUE", "TEXT", "", "");
      _sdd.SetDDL(ref ddlSendCustomerType, "EXEC proc_online_dropDownList @flag='dropdownList',@parentId=4700", "valueId", "detailTitle", "", "SELECT CUSTOMER TYPE");
      _sdd.SetDDL(ref ddlIdIssuedCountry, "EXEC proc_sendPageLoadData @flag='idIssuedCountry'", "countryId", "countryName", "", "SELECT COUNTRY");
      _sdd.SetDDL(ref ddlEmpBusinessType, "EXEC proc_online_dropDownList @flag='dropdownList',@parentId=7002", "valueId", "detailTitle", "11007", "");
      _sdd.SetDDL(ref custLocationDDL, "EXEC proc_online_dropDownList @flag='state',@countryId='113'", "stateId", "stateName", "", "SELECT");
      _sdd.SetDDL(ref sendingAgentOnBehalfDDL, "EXEC proc_sendPageLoadData @flag='S-AGENT-BEHALF',@user='" + GetStatic.GetUser() + "',@sAgent='" + GetStatic.GetAgent() + "'", "agentId", "agentName", "", "Select Branch/Agent");
      _sdd.SetDDL(ref ddlRecIdType, "EXEC proc_online_dropDownList @flag='idType',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
      _sdd.SetDDL(ref sourceOfFund, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=3900", "valueId", "detailTitle", "", "Select..");
      _sdd.SetDDL(ref purpose, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=3800", "valueId", "detailTitle", "8060", "Select..");
      _sdd.SetDDL(ref relationship, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=2100", "valueId", "detailTitle", "", "Select..");
      _sdd.SetDDL(ref occupation, "EXEC proc_online_dropDownList @flag='occupationList',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
      _sdd.SetDDL(ref visaStatusDdl, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=7005", "valueId", "detailTitle", "", "Select..");
      _sdd.SetStaticDdl(ref depositedBankDDL, "7010", "", "SELECT BANK");
    }

    private void LoadSenderCountry(ref DropDownList ddl, string defaultValue, string label) {
      var sql = "EXEC proc_dropDownLists @flag='country'";
      _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, label);
    }

    private void LoadReceiverCountry(ref DropDownList ddl, string defaultValue, string label) {
      var sql = "EXEC proc_sendPageLoadData @flag='pCountry',@countryId='" + GetStatic.GetCountryId() + "',@agentid='" + GetStatic.GetAgentId() + "'";
      _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, label);
    }

    private void CustomerSearchLoadData() {
      //string searchType = Request.Form["searchType"];
      //string searchValue = Request.Form["searchValue"];
      string customerId = Request.Form["customerId"];

      //var dt = st.LoadCustomerData(searchType, searchValue, "s", GetStatic.GetCountryId(), GetStatic.GetSettlingAgent());
      string ctrId = null;
      if (string.IsNullOrEmpty(GetStatic.GetCountryId()))
        ctrId = "142";
      var dt = st.LoadCustomerDataNew(GetStatic.GetUser(), customerId, "s-new", ctrId, GetStatic.GetSettlingAgent());
      if (dt == null) {
        Response.Write("");
        Response.End();
        return;
      }
      Response.ContentType = "text/plain";
      string json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void SearchRateScData() {
      string serchType = Request.Form["serchType"];
      string serchValue = Request.Form["serchValue"];

      DataTable dt = st.LoadCustomerData(serchType, serchValue, "s", GetStatic.GetCountryId(), GetStatic.GetSettlingAgent());
      if (dt == null) {
        Response.Write("");
        Response.End();
        return;
      }
      Response.ContentType = "text/plain";
      string json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    public static string DataTableToJson(DataTable table) {
      if (table == null)
        return "";
      var list = new List<Dictionary<string, object>>();

      foreach (DataRow row in table.Rows) {
        var dict = new Dictionary<string, object>();

        foreach (DataColumn col in table.Columns) {
          dict[col.ColumnName] = string.IsNullOrEmpty(row[col].ToString()) ? "" : row[col];
        }
        list.Add(dict);
      }
      var serializer = new JavaScriptSerializer();
      string json = serializer.Serialize(list);
      return json;
    }

    public static string GetJsonString(DataTable dt) {
      var strDc = new string[dt.Columns.Count];

      var headStr = string.Empty;
      for (int i = 0; i < dt.Columns.Count; i++) {
        strDc[i] = dt.Columns[i].Caption;
        headStr += "\"" + strDc[i] + "\" : \"" + strDc[i] + i.ToString() + " " + "\",";
      }

      headStr = headStr.Substring(0, headStr.Length - 1);
      var sb = new StringBuilder();

      sb.Append("{\"" + dt.TableName + "\" : [");
      for (var i = 0; i < dt.Rows.Count; i++) {
        var tempStr = headStr;

        sb.Append("{");
        for (var j = 0; j < dt.Columns.Count; j++) {
          tempStr = tempStr.Replace(dt.Columns[j] + j.ToString() + "¾", dt.Rows[i][j].ToString());
        }
        sb.Append(tempStr + "},");
      }
      sb = new StringBuilder(sb.ToString().Substring(0, sb.ToString().Length - 1));

      sb.Append("]}");
      return sb.ToString();
    }

    protected void Calculate() {
      DataTable dt = new DataTable();
      ExRateRequest exRate = new ExRateRequest();
      ExchangeRateAPIService ExService = new ExchangeRateAPIService();
      exRate.RequestedBy = "core";
      string a = Request.Form["IsExrateFromPartner"];
      exRate.isExRateCalcByPartner = (Request.Form["IsExrateFromPartner"] == "true") ? true : false;

      exRate.PCountry = Request.Form["pCountry"];
      exRate.pCountryName = Request.Form["pCountrytxt"];
      exRate.ServiceType = Request.Form["pMode"];
      exRate.PaymentType = Request.Form["pModetxt"];
      exRate.PAgent = Request.Form["pAgent"];
      var pAgentBranch = Request.Form["pAgentBranch"];
      exRate.CAmount = Request.Form["collAmt"];
      exRate.PAmount = Request.Form["payAmt"];
      exRate.SCurrency = Request.Form["collCurr"];
      exRate.PCurrency = Request.Form["payCurr"];
      exRate.CustomerId = Request.Form["senderId"];
      exRate.SchemeId = Request.Form["schemeCode"];
      exRate.ForexSessionId = Request.Form["couponId"];
      exRate.IsManualSc = (Request.Form["isManualSc"] == "N" ? false : true);
      exRate.ManualSc = Request.Form["sc"];
      //for test
      string diffRate = "";
      JsonResponse jresp = new JsonResponse();
      //if (exRate.PCountry.Equals("203"))
      exRate.isExRateCalcByPartner = true;
      //for test
      if (exRate.isExRateCalcByPartner) {
        exRate.SCountry = GetStatic.GetCountryId();
        exRate.SSuperAgent = GetStatic.GetSuperAgent();
        exRate.SAgent = GetStatic.GetAgent();
        exRate.SBranch = GetStatic.GetBranch();
        exRate.CollCurrency = Request.Form["collCurr"];
        exRate.pCountryCode = Request.Form["PCountryCode"];
        exRate.ProviderId = Request.Form["payoutPartner"];
        string ProcessId = Guid.NewGuid().ToString().Replace("-", "") + ":transfast:exRate";

        exRate.ProcessId = ProcessId.Substring(ProcessId.Length - 40, 40);

        //JsonResponse res = ExService.GetExchangeRate(exRate);

        //ExRateResponse _exrate = (ExRateResponse)res.Data;
        if (exRate.ManualSc.Equals("NaN"))
          exRate.ManualSc = "0";
        diffRate = "0";
        ExRateCalculateRequest excalc = new ExRateCalculateRequest {
          sCountry = GetStatic.GetCountryId(),
          sCurrency = exRate.SCurrency,
          pCurrency = exRate.PCurrency,
          calcBy = "p",
          cAmount = exRate.CAmount,
          pAmount = exRate.PAmount,
          serviceType = exRate.ServiceType,
          pCountry = exRate.PCountry,
          pCountryName = exRate.pCountryName
          ,receiverIsOrg = Request.Form["receiverIsOrg"]
      };
        jresp = ExService.GetTPExrate(excalc);
        if (jresp.Data != null) {
          string fxId = (jresp.Data as ExRateResponse).EXRATEID;
          forexSessionId.Value = fxId;
        }
      } else {
        dt = st.GetExRate(
          GetStatic.GetUser()
          , GetStatic.GetCountryId()
          , GetStatic.GetSuperAgent()
          , GetStatic.GetAgent()
          , GetStatic.GetBranch()
          , exRate.SCurrency
          , exRate.PCountry
          , exRate.PAgent
          , exRate.PCurrency
          , exRate.ServiceType
          , exRate.CAmount
          , exRate.PAmount
          , exRate.SchemeId
          , exRate.CustomerId
          , GetStatic.GetSessionId()
          , exRate.ForexSessionId
          , Request.Form["isManualSc"]
          , exRate.ManualSc
          );
      }

            Response.ContentType = "text/plain";
      //var json = DataTableToJson(dt);
      //if (diffRate.Equals("")) {
      //  Response.Write(json);
      //} else {
        var serializer = new JavaScriptSerializer();
        string jsson = serializer.Serialize(jresp.Data);
        Response.Write(jsson);
      //}
      Response.End();
    }

    private void LoadCustomerRate() {
      var pCountryFv = GetStatic.ReadFormData("pCountry", "");
      var pAgentFv = GetStatic.ReadFormData("pAgent", "");
      var pModeFv = GetStatic.ReadFormData("pMode", "");
      var collCurr = GetStatic.ReadFormData("collCurr", "");

      var dt = st.LoadCustomerRate(GetStatic.GetUser()
          , GetStatic.GetCountryId()
          , GetStatic.GetSuperAgent()
          , GetStatic.GetAgent()
          , GetStatic.GetBranch()
          , collCurr
          , pCountryFv
          , pAgentFv
          , ""
          , pModeFv
          );

      Response.ContentType = "text/plain";
      var json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void CheckSenderIdNumber() {
      var sIdType = GetStatic.ReadQueryString("sIdType", "");
      var sIdNo = GetStatic.ReadFormData("sIdNo", "");

      var dt = st.CheckSenderIdNumber(GetStatic.GetUser(), sIdType, sIdNo);
      Response.ContentType = "text/plain";
      var json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void CheckAvialableBalance() {
      string collectionMode = Request.Form["collectionMode"];
      string customerId = Request.Form["customerId"];
      string branchId = Request.Form["branchId"];
      if (string.IsNullOrEmpty(branchId) || string.IsNullOrWhiteSpace(branchId))
        branchId = "";
      StringBuilder sb = new StringBuilder();
      var result = st.CheckAvailableBanalce(GetStatic.GetUser(), customerId, collectionMode, branchId);
      if (result != null) {
        if (collectionMode == "Bank Deposit")
          sb.AppendLine("<span style='background-color: yellow; font-weight: 600;padding: 4px;' id='availableBalSpan'> Available Bal: <label id=\"availableBal\" style=\"font-size: 14px;font-weight: 800;\">" + GetStatic.ShowDecimal(result.Rows[0]["avilableBalance"].ToString()) + " </label>&nbsp;" + GetStatic.ReadWebConfig("currencyMN", "") + "</span>");
        else
          sb.AppendLine("<span style='background-color: yellow; font-weight: 600;padding: 4px;' id='availableBalSpan'> Available Limit: <label id=\"availableBal\" style=\"font-size: 14px;font-weight: 800;\">" + GetStatic.ShowDecimal(result.Rows[0]["avilableBalance"].ToString()) + " </label>&nbsp;" + GetStatic.ReadWebConfig("currencyMN", "") + " " + " (" + result.Rows[0]["holdType"].ToString() + ")</span>");
      } else {
        sb.AppendLine("<span style='background-color: yellow; font-weight: 600;padding: 4px;' id='availableBalSpan'> Available Bal: <label id=\"availableBal\" style=\"font-size: 14px;font-weight: 800;\">Balance Not Available</label>&nbsp;" + GetStatic.ReadWebConfig("currencyMN", "") + "</span>");
      }
      Response.Write(sb);
      Response.End();
    }

    private void GetPayerDataByBankId() {
      SendTransactionServices GetPayer = new SendTransactionServices();
      string bankCode = Request.Form["bankCode"];
      string bankId = Request.Form["bankId"];
      string partnerId = Request.Form["partnerId"];
      string pMode = (Request.Form["pMode"] == "1" ? "2" : "C");
      string PCountryCode = Request.Form["PCountryCode"];
      string pCountryId = Request.Form["countryId"];
      string payCurr = Request.Form["payCurr"];
      string isSyncPayerData = Request.Form["isSyncPayerData"];

      PayerDataRequest request = new PayerDataRequest() {
        CountryIsoCode = PCountryCode,
        ProviderId = partnerId,
        PaymentModeId = pMode,
        SourceCurrencyIsoCode = "JPY",
        ReceiveCurrencyIsoCode = payCurr,
        BankId = bankCode,
        CityId = 0,
        FeeProduct = "B",
        UserName = "By scheduler"
      };
      JsonResponse _resp = new JsonResponse();
      string xml = "";

      if (isSyncPayerData == "Y") {
        _resp = GetPayer.GetPayerData(request);

        if (_resp.ResponseCode == "0") {
          List<PayerDetailsResults> payerDetailsResultsList = new List<PayerDetailsResults>();
          var data = JsonConvert.DeserializeObject<List<TFPayerMasterResults>>(_resp.Data.ToString());
          foreach (TFPayerMasterResults item in data) {
            foreach (PayerDetailsResults payerDetailsList in item.PayerDetailsResults) {
              payerDetailsResultsList.Add(payerDetailsList);
            }
          }

          xml = GetStatic.ObjectToXML(payerDetailsResultsList);
        }
      }

      DataTable dt = st.GetPayersByAgent(bankId, partnerId, Request.Form["pMode"], pCountryId, xml);
      Response.ContentType = "text/plain";
      string json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void GetPayerDataByPayerAndCityId() {
      string bankId = Request.Form["payerId"];
      string partnerId = Request.Form["partnerId"];
      string cityId = Request.Form["CityId"];
      DataTable dt = st.GetPayerBranchDataByPayerAndCityId(bankId, cityId, partnerId);
      Response.ContentType = "text/plain";
      string json = DataTableToJson(dt);
      Response.Write(json);
      Response.End();
    }

    private void GetReferralBalance() {
      var referralCode = Request.Form["referralCode"];
      var result = st.GetReferralBal(GetStatic.GetUser(), referralCode);

      StringBuilder sb = new StringBuilder();
      if (result != null) {
        sb.AppendLine("<span style='background-color: yellow; font-weight: 600;padding: 4px;' id='availableBalSpanReferral'>Introducer Available Limit: <label id=\"availableBalReferral\" style=\"font-size: 14px;font-weight: 800;\">" + GetStatic.ShowDecimal(result.Rows[0]["availableLimit"].ToString()) + " </label>&nbsp;JPY</span>");
      } else {
        sb.AppendLine("<span style='background-color: yellow; font-weight: 600;padding: 4px;' id='availableBalSpanReferral'>Introducer Available Limit <label id=\"availableBalReferral\" style=\"font-size: 14px;font-weight: 800;\">Balance Not Available</label>&nbsp;JPY</span>");
      }
      Response.ContentType = "text/plain";
      Response.Write(sb);
      Response.End();
    }

    private void GetCurrentBalance() {
      var branchId = Request.Form["branchId"];
      var dr = st.GetAcDetailByBranchIdNew(GetStatic.GetUser(), branchId);
      //if (dr == null)
      //{
      //    availableAmt.Text = "N/A";
      //    return;
      //}
      //availableAmt.Text = GetStatic.FormatData(dr["availableBal"].ToString(), "M");
      //lblPerDayLimit.Text = GetStatic.FormatData(dr["txnPerDayCustomerLimit"].ToString(), "M");
      //lblPerDayCustomerCurr.Text = dr["sCurr"].ToString();
      //lblCollCurr.Text = dr["sCurr"].ToString();
      //lblSendCurr.Text = dr["sCurr"].ToString();
      //lblServiceChargeCurr.Text = dr["sCurr"].ToString();
      //txnPerDayCustomerLimit.Value = dr["txnPerDayCustomerLimit"].ToString();
      //balCurrency.Text = dr["balCurrency"].ToString();
      //hdnLimitAmount.Value = dr["sCountryLimit"].ToString();

      Response.ContentType = "text/plain";
      string json = DataTableToJson(dr);
      Response.Write(json);
      Response.End();
    }

    public void ValidateReferral() {
      var referralCode = Request.Form["referralCode"];
      var dr = st.ValidateReferral(GetStatic.GetUser(), referralCode);

      Response.ContentType = "text/plain";
      string json = DataTableToJson(dr);
      Response.Write(json);
      Response.End();
    }

    private void PopulateData() {
      try {
        string trnDate = Request.Form["tranDate"];
        string particulars = Request.Form["particulars"];
        string customerId = Request.Form["customerId"];
        string amount = Request.Form["amount"];
        DataSet dt = _dao.GetDataForSendMapping(GetStatic.GetUser(), trnDate, particulars, customerId, amount);
        StringBuilder sb = new StringBuilder();
        StringBuilder sb1 = new StringBuilder();

        if (null == dt) {
          Response.ContentType = "application/text";
          Response.Write("<tr><td colspan = \"7\" align=\"center\">No Data To Display</td></tr>[[<<>>]]<tr><td colspan = \"7\" align=\"center\">No Data To Display</td></tr>");
          HttpContext.Current.Response.Flush();
          HttpContext.Current.Response.SuppressContent = true;
          HttpContext.Current.ApplicationInstance.CompleteRequest();
          return;
        }

        if (dt.Tables[0].Rows.Count == 0) {
          sb.AppendLine("<tr><td colspan = \"7\" align=\"center\">No Data To Display</td></tr>");
        }
        if (dt.Tables[1].Rows.Count == 0) {
          sb1.AppendLine("<tr><td colspan = \"7\" align=\"center\">No Data To Display</td></tr>");
        }

        int sNo = 1;
        int sNo1 = 1;

        foreach (DataRow item in dt.Tables[0].Rows) {
          sb.AppendLine("<tr>");
          sb.AppendLine("<td><input type='checkbox' class='unmapped' name='chkDepositMapping' id='chkDepositMapping" + item["tranId"].ToString() + "' value='" + item["tranId"].ToString() + "' /></td>");
          sb.AppendLine("<td>" + item["particulars"].ToString() + "</td>");
          sb.AppendLine("<td>" + item["tranDate"].ToString() + "</td>");
          sb.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["depositAmount"].ToString()) + "</td>");
          sb.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["paymentAmount"].ToString()) + "</td>");
          sb.AppendLine("</tr>");
          sb.AppendLine("<tr id=\"addModel" + item["tranId"].ToString() + "\"></tr>");
          sNo++;
        }

        foreach (DataRow item in dt.Tables[1].Rows) {
          sb1.AppendLine("<tr>");
          sb1.AppendLine("<td><input type='checkbox' class='unapproved' name='chkDepositMappingUnmap' id='chkDepositMappingUnmap" + item["tranId"].ToString() + "' value='" + item["tranId"].ToString() + "'/></td>");
          sb1.AppendLine("<td>" + item["particulars"].ToString() + "</td>");
          sb1.AppendLine("<td>" + item["tranDate"].ToString() + "</td>");
          sb1.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["depositAmount"].ToString()) + "</td>");
          sb1.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["paymentAmount"].ToString()) + "</td>");
          sb1.AppendLine("</tr>");
          sb1.AppendLine("<tr id=\"addModel" + item["tranId"].ToString() + "\"></tr>");
          sNo1++;
        }
        string data = sb + "[[<<>>]]" + sb1;
        Response.ContentType = "application/text";
        Response.Write(data);
        HttpContext.Current.Response.Flush(); // Sends all currently buffered output to the client.
        HttpContext.Current.Response.SuppressContent = true;  // Gets or sets a value indicating whether to send HTTP content to the client.
        HttpContext.Current.ApplicationInstance.CompleteRequest(); // Causes ASP.NET to bypass all events and filtering in the HTTP pipeline chain of execution and directly execute the EndRequest event.
      } catch (ThreadAbortException ex) {
        string msg = ex.Message;
      }
    }

    protected void ProceedMapData() {
      var Ids = Request.Form["tranIds[]"];
      var customerId = Request.Form["customerId"];
      DbResult _res = new DbResult();
      if (!string.IsNullOrEmpty(Ids)) {
        _res = _dao.SaveMultipleCustomerDeposit(GetStatic.GetUser(), Ids, customerId);
      } else {
        GetStatic.AlertMessage(this, "Please choose at least on record!");
      }
      Response.ContentType = "text/plain";
      Response.Write(JsonConvert.SerializeObject(_res));
      Response.End();
    }

    protected void UnMapData() {
      var Ids = Request.Form["tranIds[]"];
      var customerId = Request.Form["customerId"];
      DbResult _res = new DbResult();
      if (!string.IsNullOrEmpty(Ids)) {
        _res = _dao.UnMapCustomerDeposit(GetStatic.GetUser(), Ids, customerId);
      } else {
        GetStatic.AlertMessage(this, "Please choose at least on record!");
      }
      Response.ContentType = "text/plain";
      Response.Write(JsonConvert.SerializeObject(_res));
      Response.End();
    }

    protected void UpdateVisaStatus() {
      var visaStatusId = Request.Form["visaStatusId"];
      var customerId = Request.Form["customerId"];
      DbResult _res = new DbResult();
      if (!string.IsNullOrEmpty(visaStatusId)) {
        _res = _dao.UpdateVisaStatus(GetStatic.GetUser(), visaStatusId, customerId);
      } else {
        GetStatic.AlertMessage(this, "Please choose visa status!");
      }
      Response.ContentType = "text/plain";
      Response.Write(JsonConvert.SerializeObject(_res));
      Response.End();
    }
  }
}