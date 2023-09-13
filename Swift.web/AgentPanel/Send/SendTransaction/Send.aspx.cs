using Swift.DAL.BL.AgentPanel.Send;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;

namespace Swift.web.AgentPanel.Send.SendTransactionIRH
{
    public partial class Send : System.Web.UI.Page
    {
        private SendTranIRHDao st = new SendTranIRHDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "40102200";

        protected void Page_Load(object sender, EventArgs e)
        {
            _sdd.CheckSession();
            txtCollAmt.Attributes.Add("onkeyup", "return CalcOnEnter((event?event:evt));");
            string reqMethod = Request.Form["MethodName"];
            if (!string.IsNullOrEmpty(reqMethod))
            {
                if (GetStatic.GetUser() == "")
                {
                    Response.ContentType = "text/plain";
                    Response.Write("[{\"session_end\":\"1\"}]");
                    Response.End();
                    return;
                }
            }
            Authenticate();
            if (String.IsNullOrEmpty(reqMethod))
            {
                GetCurrentBalance();
                //Misc.MakeNumericTextbox(ref txtCollAmt);
                Misc.MakeNumericTextbox(ref txtPayAmt);
            }

            if (!Page.IsPostBack)
            {
                #region Ajax methods

                switch (reqMethod)
                {
                    case "SearchCustomer":
                        CustomerSearchLoadData();
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
                }

                #endregion Ajax methods

                PopulateDdl();
                GetRequiredField();
            }
        }

        protected string sb = "";

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void GetRequiredField()
        {
            var dt = st.GetRequiredField(GetStatic.GetCountryId(), GetStatic.GetAgent());
            if (dt == null)
                return;
            var dr = dt.Tables[0].Rows[0];
            if (dr["customerRegistration"].ToString() == "H")
            {
                EnrollCust.Visible = false;
            }
            if (dr["newCustomer"].ToString() == "H")
            {
                NewCust.Visible = false;
            }

            //Sender ID
            ddSenIdType_err.Visible = false;
            txtSendIdNo_err.Visible = false;
            switch (dr["id"].ToString())
            {
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
            txtSendIdValidDate_err.Visible = false;
            switch (dr["iDValidDate"].ToString())
            {
                case "H":
                    tdSenExpDateLbl.Attributes.Add("style", "display: none;");
                    tdSenExpDateTxt.Attributes.Add("style", "display: none;");

                    //Sender DOB
                    txtSendDOB_err.Visible = false;
                    switch (dr["dob"].ToString())
                    {
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
                    txtSendIdValidDate_err.Visible = true;

                    //Sender DOB
                    txtSendDOB_err.Visible = false;
                    switch (dr["dob"].ToString())
                    {
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
                    switch (dr["dob"].ToString())
                    {
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
            switch (dr["contact"].ToString())
            {
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
            switch (dr["city"].ToString())
            {
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
            switch (dr["address"].ToString())
            {
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
            switch (dr["occupation"].ToString())
            {
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
            switch (dr["company"].ToString())
            {
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
            switch (dr["salaryRange"].ToString())
            {
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
            switch (dr["purposeofRemittance"].ToString())
            {
                case "H":
                    trPurposeOfRemittance.Attributes.Add("style", "display: none;");
                    break;

                case "M":
                    purpose.Attributes.Add("Class", "required");
                    purpose_err.Visible = true;
                    break;
            }

            sourceOfFund_err.Visible = false;
            switch (dr["sourceofFund"].ToString())
            {
                case "H":
                    trSourceOfFund.Attributes.Add("style", "display: none;");
                    break;

                case "M":
                    lblSof.Visible = true;
                    sourceOfFund.Attributes.Add("Class", "required");
                    sourceOfFund_err.Visible = true;
                    break;
            }

            //Receiver ID
            ddlRecIdType_err.Attributes.Add("style", "display: none;");
            txtRecIdNo_err.Attributes.Add("style", "display: none;");
            switch (dr["rId"].ToString())
            {
                case "H":
                    trRecId.Attributes.Add("style", "display: none;");
                    break;

                case "M":
                    ddlRecIdType.Attributes.Add("Class", "required");
                    txtRecIdNo.Attributes.Add("Class", "required");
                    ddlRecIdType_err.Attributes.Add("style", "display: block;");
                    txtRecIdNo_err.Attributes.Add("style", "display: block;");
                    break;
            }

            //Receiver ID Expiry Date
            txtRecValidDate_err.Visible = false;
            switch (dr["rIdValidDate"].ToString())
            {
                case "H":
                    tdRecIdExpiryLbl.Attributes.Add("style", "display:none;");
                    tdRecIdExpiryTxt.Attributes.Add("style", "display:none;");
                    txtRecDOB_err.Visible = false;
                    switch (dr["rDOB"].ToString())
                    {
                        case "H":
                            tdRecDobLbl.Attributes.Add("style", "display:none;");
                            tdRecDobTxt.Attributes.Add("style", "display:none;");
                            break;

                        case "M":
                            txtRecDOB.Attributes.Add("Class", "required");
                            txtRecDOB_err.Visible = true;
                            break;
                    }
                    break;

                case "M":
                    txtRecValidDate.Attributes.Add("Class", "required");
                    txtRecValidDate_err.Visible = true;
                    txtRecDOB_err.Visible = false;
                    switch (dr["rDOB"].ToString())
                    {
                        case "H":
                            tdRecDobLbl.Attributes.Add("style", "display:none;");
                            tdRecDobTxt.Attributes.Add("style", "display:none;");
                            break;

                        case "M":
                            txtRecDOB.Attributes.Add("Class", "required");
                            txtRecDOB_err.Visible = true;
                            break;
                    }
                    break;

                default:
                    txtRecDOB_err.Visible = false;
                    switch (dr["rDOB"].ToString())
                    {
                        case "H":
                            tdRecDobLbl.Attributes.Add("style", "display:none;");
                            tdRecDobTxt.Attributes.Add("style", "display:none;");
                            break;

                        case "M":
                            txtRecDOB.Attributes.Add("Class", "required");
                            txtRecDOB_err.Visible = true;
                            break;
                    }
                    break;
            }

            //Receiver Mobile
            txtRecMobile_err.Attributes.Add("style", "display: none;");
            switch (dr["rContact"].ToString())
            {
                case "H":
                    trRecContactNo.Attributes.Add("style", "display: none;");
                    break;

                case "M":
                    txtRecMobile.Attributes.Add("Class", "required");
                    txtRecMobile_err.Attributes.Add("style", "display: block;");
                    break;
            }

            //Receiver City
            txtRecCity_err.Visible = false;
            switch (dr["rcity"].ToString())
            {
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
            switch (dr["raddress"].ToString())
            {
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
            switch (dr["rRelationShip"].ToString())
            {
                case "H":
                    trRelWithRec.Attributes.Add("style", "display: none;");
                    break;

                case "M":
                    relationship.Attributes.Add("Class", "required");
                    relationship_err.Visible = true;
                    break;
            }

            hdnBeneficiaryIdReq.Value = dr["rId"].ToString();
            hdnBeneficiaryContactReq.Value = dr["rContact"].ToString();
            hdnRelationshipReq.Value = dr["rRelationShip"].ToString();
        }

        private void LoadSchemeByRCountry()
        {
            string pCountryFv = Request.Form["pCountry"];
            string pAgentFv = Request.Form["pAgent"];
            string sCustomerId = Request.Form["sCustomerId"];

            var dt = st.LoadSchemeByRCountry(GetStatic.GetCountryId(), GetStatic.GetAgent(), GetStatic.GetBranch(), pCountryFv, pAgentFv, sCustomerId);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void GetCurrentBalance()
        {
            var dr = st.GetAcDetail(GetStatic.GetUser());
            if (dr == null)
            {
                availableAmt.Text = "N/A";
                return;
            }
            availableAmt.Text = GetStatic.FormatData(dr["availableBal"].ToString(), "M");
            lblPerDayLimit.Text = GetStatic.FormatData(dr["txnPerDayCustomerLimit"].ToString(), "M");
            lblPerDayCustomerCurr.Text = dr["sCurr"].ToString();
            lblCollCurr.Text = dr["sCurr"].ToString();
            lblSendCurr.Text = dr["sCurr"].ToString();
            lblServiceChargeCurr.Text = dr["sCurr"].ToString();
            txnPerDayCustomerLimit.Value = dr["txnPerDayCustomerLimit"].ToString();
            balCurrency.Text = dr["balCurrency"].ToString();
            hdnLimitAmount.Value = dr["sCountryLimit"].ToString();
        }

        protected long GetResendId()
        {
            return GetStatic.ReadNumericDataFromQueryString("resendId");
        }

        private void LoadAgentByExtAgent()
        {
            var pAgentFv = Request.Form["pAgent"];
            var dt = st.LoadAgentByExtAgent(GetStatic.GetUser(), pAgentFv);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void LoadAgentByExtBranch()
        {
            var pBranchFv = Request.Form["pBranch"];
            var dt = st.LoadAgentByExtBranch(GetStatic.GetUser(), pBranchFv);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void GetAgentSetting()
        {
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

        private void LoadDataFromDdl(string type)
        {
            var pAgentFv = Request.Form["pAgent"];
            var pModeFv = Request.Form["pmode"];
            var pCountryFv = Request.Form["pCountry"];

            DataTable dt = null;
            switch (type)
            {
                case "pMode":
                    dt = st.LoadDataFromDdl(GetStatic.GetCountryId(), pCountryFv, pModeFv, GetStatic.GetAgent(), "recModeByCountry", GetStatic.GetUser());
                    break;

                case "agentByPmode":
                    if (string.IsNullOrWhiteSpace(pModeFv) || string.IsNullOrWhiteSpace(pCountryFv))
                    {
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

        private void PopulateReceiverBySender()
        {
            string recId = Request.Form["id"];
            string senderId = Request.Form["senderId"];

            DataTable dt = st.PopulateReceiverBySender(senderId, "", recId);
            Response.ContentType = "text/plain";
            string json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void PCurrPcountry()
        {
            string pCountry = Request.Form["pCountry"];

            DataTable Dt = st.LoadPayCurr(pCountry);
            Response.ContentType = "text/plain";
            string json = DataTableToJson(Dt);
            Response.Write(json);
            Response.End();
        }

        private void PopulateDdl()
        {
            LoadSenderCountry(ref txtSendNativeCountry, "151", "");
            LoadReceiverCountry(ref pCountry, "", "Select");

            _sdd.SetDDL(ref ddSenIdType, "exec proc_sendPageLoadData @flag='idTypeBySCountry',@countryId='" + GetStatic.GetCountryId() + "'", "valueId", "detailTitle", "", "Select");

            _sdd.SetStaticDdl(ref ddlRecIdType, "1300", "", "Select");
            _sdd.SetStaticDdl(ref purpose, "3800", "", "Select");
            _sdd.SetStaticDdl(ref sourceOfFund, "3900", "", "Select");
            _sdd.SetStaticDdl(ref relationship, "2100", "", "Select");

            _sdd.SetStaticDdl(ref ddlSalary, "8300", "", "Select");

            _sdd.SetDDL(ref ddlSalary, "SELECT valueId, detailTitle FROM staticDataValue WITH(NOLOCK) WHERE typeID = 8100 AND ISNULL(IS_DELETE, 'N') = 'N'", "valueId", "detailTitle", "", "Select");
            // _sdd.SetDDL(ref occupation, "exec proc_sendPageLoadData @flag='loadOccupation'",
            // "occupationId", "detailTitle", "", "Select");
            _sdd.SetStaticDdl(ref occupation, "2000", "", "Select");
        }

        private void LoadSenderCountry(ref DropDownList ddl, string defaultValue, string label)
        {
            var sql = "EXEC proc_dropDownLists @flag='country'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, label);
        }

        private void LoadReceiverCountry(ref DropDownList ddl, string defaultValue, string label)
        {
            var sql = "EXEC proc_sendPageLoadData @flag='pCountry',@countryId='" + GetStatic.GetCountryId() + "',@agentid='" + GetStatic.GetAgentId() + "'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, label);
        }

        private void CustomerSearchLoadData()
        {
            string searchType = Request.Form["searchType"];
            string searchValue = Request.Form["searchValue"];

            var dt = st.LoadCustomerData(searchType, searchValue, "s", GetStatic.GetCountryId(), GetStatic.GetSettlingAgent());
            if (dt == null)
            {
                Response.Write("");
                Response.End();
                return;
            }
            Response.ContentType = "text/plain";
            string json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void SearchRateScData()
        {
            string serchType = Request.Form["serchType"];
            string serchValue = Request.Form["serchValue"];

            DataTable dt = st.LoadCustomerData(serchType, serchValue, "s", GetStatic.GetCountryId(), GetStatic.GetSettlingAgent());
            if (dt == null)
            {
                Response.Write("");
                Response.End();
                return;
            }
            Response.ContentType = "text/plain";
            string json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        public static string DataTableToJson(DataTable table)
        {
            if (table == null)
                return "";
            var list = new List<Dictionary<string, object>>();

            foreach (DataRow row in table.Rows)
            {
                var dict = new Dictionary<string, object>();

                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = string.IsNullOrEmpty(row[col].ToString()) ? "" : row[col];
                }
                list.Add(dict);
            }
            var serializer = new JavaScriptSerializer();
            string json = serializer.Serialize(list);
            return json;
        }

        public static string GetJsonString(DataTable dt)
        {
            var strDc = new string[dt.Columns.Count];

            var headStr = string.Empty;
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                strDc[i] = dt.Columns[i].Caption;
                headStr += "\"" + strDc[i] + "\" : \"" + strDc[i] + i.ToString() + " " + "\",";
            }

            headStr = headStr.Substring(0, headStr.Length - 1);
            var sb = new StringBuilder();

            sb.Append("{\"" + dt.TableName + "\" : [");
            for (var i = 0; i < dt.Rows.Count; i++)
            {
                var tempStr = headStr;

                sb.Append("{");
                for (var j = 0; j < dt.Columns.Count; j++)
                {
                    tempStr = tempStr.Replace(dt.Columns[j] + j.ToString() + "¾", dt.Rows[i][j].ToString());
                }
                sb.Append(tempStr + "},");
            }
            sb = new StringBuilder(sb.ToString().Substring(0, sb.ToString().Length - 1));

            sb.Append("]}");
            return sb.ToString();
        }

        protected void Calculate()
        {
            var pCountryFv = Request.Form["pCountry"];
            var pcountrytxt = Request.Form["pCountrytxt"];
            var pModeFv = Request.Form["pMode"];
            var pModetxt = Request.Form["pModetxt"];
            var pAgentFv = Request.Form["pAgent"];
            var pAgentBranch = Request.Form["pAgentBranch"];
            var collAmt = Request.Form["collAmt"];
            var payAmt = Request.Form["payAmt"];
            var collCurr = Request.Form["collCurr"];
            var senderId = Request.Form["senderId"];
            var schemeCode = Request.Form["schemeCode"];
            var couponId = Request.Form["couponId"];

            var dt = st.GetExRate(GetStatic.GetUser()
                , GetStatic.GetCountryId()
                , GetStatic.GetSuperAgent()
                , GetStatic.GetAgent()
                , GetStatic.GetBranch()
                , collCurr
                , pCountryFv
                , pAgentFv
                , ""
                , pModeFv
                , collAmt
                , payAmt
                , schemeCode
                , senderId
                , GetStatic.GetSessionId()
                , couponId);

            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void LoadCustomerRate()
        {
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

        private void CheckSenderIdNumber()
        {
            var sIdType = GetStatic.ReadQueryString("sIdType", "");
            var sIdNo = GetStatic.ReadFormData("sIdNo", "");

            var dt = st.CheckSenderIdNumber(GetStatic.GetUser(), sIdType, sIdNo);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }
    }
}