using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using Swift.DAL.BL.SwiftSystem;

namespace Swift.web.SwiftSystem.UserManagement.AgentSetup
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20111000";
        private const string AddEditFunctionId = "20111010";
        private const string DeleteFunctionId = "20111020";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly AgentDao obj = new AgentDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            string PType = GetPageType();
            if (!IsPostBack)
            {
                intlCheck.Checked = false;
                branchCodeField.Visible = false;
                var actAsBranch = GetStatic.ReadQueryString("actAsBranch", "");
                if (actAsBranch == "N" && GetAgentType() == "2902")
                {
                    intlCheck.Checked = true;
                }
                if (actAsBranch == "Y" && GetAgentType() == "2903")
                {
                    branchCodeField.Visible = true;
                }
                Authenticate();
                //payOption.Items.Insert(0, new ListItem("Select", ""));
                pnl1.Visible = GetMode().ToString() == "1";
                MakeNumericTextBox();
                CheckMessageHead();

                btnDelete.Visible = (GetAgentId() > 0 ? true : false);

                if (GetAgentId() > 0)
                {

                    //spnCname.InnerHtml = _sdd.GetAgentBreadCrumb(GetAgentId().ToString());
                    LoadTab();
                    PopulateDataById();
                    ManageEditMode();
                }
                else
                {
                    // spnCname.InnerHtml = _sdd.GetAgentBreadCrumb(GetParentId().ToString());
                    PopulateDdl(null);
                    ConfigurePageLoad();
                    PullDefaultValueById();
                }
            }
            if (PType == "agentDetail")
            {
                bntSubmit.Visible = false;
                btnDelete.Visible = false;
                divTab.InnerHtml = "";
            }
        }

        private void LoadTab()
        {
            divTab.Visible = true;
            var html = new StringBuilder();
            var agentId = GetAgentId();
            var mode = GetMode();
            var parentId = GetParentId();
            var sParentId = GetParentId();
            var aType = GetAgentType();
            var actAsBranch = GetActAsBranchFlag();
            html.Append(
                "<table width=\"100%\" border=\"0\" align=\"left\" cellpadding=\"0\" cellspacing=\"0\" style=\"clear: both; margin-left:16px;\">" +
                "<tr><td height=\"10\">");
            html.Append("<ul class=\"nav nav-tabs\" role=\"tablist\"><li class=\"active\"> <a href=\"#\" class=\"selected\">Agent Information </a></li>" +
                            "<li> <a href=\"../../../Remit/Administration/AgentSetup/AgentCurrency.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\"> Allowed Currency </a></li>" +
                            "<li> <a href=\"../../../Remit/Administration/AgentSetup/AgentBusinessHistory.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\"> Business History </a></li>" +
                            "<li> <a href=\"../../../Remit/Administration/AgentSetup/OwnerInf/List.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\">Owners</a></li>" +
                            "<li> <a href=\"../../../Remit/Administration/AgentSetup/Document/List.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\">Required Document</a></li>" +
                            "<li> <a href=\"../../../Remit/Administration/AgentSetup/AgentContactPerson/List.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\">Contact Person</a></li>" +
                            "<li> <a href=\"../../../Remit/Administration/AgentSetup/AgentBankAccount/List.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\">Bank Account</a></li>" +
                                            "</ul> ");
            html.Append("</td></tr></table>");
            divTab.InnerHtml = html.ToString();
        }

        private void PullDefaultValueById()
        {
            DataRow dr = obj.PullDefaultValueById(GetStatic.GetUser(), GetParentId().ToString());
            if (dr == null)
                return;

            agentCity.Text = dr["agentCity"].ToString();
            //agentZip.Text = dr["agentZip"].ToString();
            isActive.SelectedValue = dr["isActive"].ToString();
            if (GetAgentType() == "2904")
                agentName.Text = dr["agentName"] + " - ";
            PopulateDdl(dr);
        }

        private void CheckMessageHead()
        {
            if (GetAgentType() == "2904")
                headMsgShow.Visible = true;

            else if (GetAgentType() == "2903" && GetActAsBranchFlag() == "Y")
                headMsgShow.Visible = true;
        }

        private void ManageEditMode()
        {
            isSettlingAgent.Enabled = false;
            agentCountry.Enabled = false;

        }

        private void ConfigurePageLoad()
        {
            isSettlingAgent.Text = "N";
            var IsSettling = obj.GetParentAgentSettlementStatus(GetParentId().ToString());

            if (GetAgentType() == "2904" || GetActAsBranchFlag() == "Y")
            {
                if (IsSettling != "Y")
                {
                    isSettlingAgent.Text = "Y";
                }
                isSettlingAgent.Enabled = false;
            }
            else
            {
                if (IsSettling == "Y")
                    isSettlingAgent.Enabled = false;
                else
                    isSettlingAgent.Enabled = true;
            }
        }

        private void MakeNumericTextBox()
        {
            //Misc.MakeNumericTextbox(ref agentZip);
        }

        #region QueryString

        protected string GetAgentName()
        {
            return "Agent Name : " + _sdd.GetAgentName(GetAgentId().ToString());
        }
        protected string GetFullDetail()
        {
            return GetStatic.ReadQueryString("fullDetail", "");
        }
        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
        }

        protected String GetPageType()
        {
            return GetStatic.ReadQueryString("PageType", "");
        }
        protected long GetParentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("parent_id");
        }

        protected long GetSParentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("sParentId");
        }
        protected string GetAgentType()
        {
            string atype = GetStatic.ReadNumericDataFromQueryString("aType").ToString();
            return atype;
        }

        protected string GetActAsBranchFlag()
        {
            return GetStatic.ReadQueryString("actAsBranch", "");
        }
        #endregion

        #region Method

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
            btnDelete.Visible = _sdd.HasRight(DeleteFunctionId);
            bntSubmit.Visible = _sdd.HasRight(AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            string sql = "";

            string aType = GetAgentType();
            string mode = GetMode().ToString();
            if (mode == "1" || mode == "2")
            {
                if (aType == "")
                    sql = "SELECT valueId, detailTitle FROM staticDataValue WHERE valueId IN(2900)";
                if (aType == "2901")
                    sql = "SELECT valueId, detailTitle FROM staticDataValue WHERE valueId IN(2901)";
                if (aType == "2902" || aType == "2903")
                    sql = "SELECT valueId, detailTitle FROM staticDataValue WHERE valueId IN(2902)";
                if (aType == "2903")
                    sql = "SELECT valueId, detailTitle FROM staticDataValue WHERE valueId IN(2903)";
                if (aType == "2904")
                    sql = "SELECT valueId, detailTitle FROM staticDataValue WHERE valueId IN(2904)";
            }
            else
            {
                if (aType == "2900")
                    sql = "SELECT valueId, detailTitle FROM staticDataValue WHERE valueId IN(2901)";
                else if (aType == "2901")
                    sql = "SELECT valueId, detailTitle FROM staticDataValue WHERE valueId IN(2902)";
                else if (aType == "2902")
                    sql = "SELECT valueId, detailTitle FROM staticDataValue WHERE valueId IN(2903)";
                else if (aType == "2903")
                    sql = "SELECT valueId, detailTitle FROM staticDataValue WHERE valueId IN(2904)";
            }

            _sdd.SetDDL(ref agentType, sql, "valueId", "detailTitle", GetStatic.GetRowData(dr, "agentType"), "");

            _sdd.SetStaticDdl(ref agentGroup, "4300", GetStatic.GetRowData(dr, "agentGrp"), "Select");
            _sdd.SetStaticDdl(ref businessOrgType, "4500", GetStatic.GetRowData(dr, "businessOrgType"), "Select");
            _sdd.SetStaticDdl(ref businessType, "6200", GetStatic.GetRowData(dr, "businessType"), "Select");

            _sdd.SetDDL(ref agentLocation, "EXEC proc_apiLocation @flag = 'l'", "districtCode", "districtName",
                        GetStatic.GetRowData(dr, "agentLocation"), "Select");

            LoadCountry(ref agentCountry, GetStatic.GetRowData(dr, "agentCountry"));
            LoadRegionSettings(agentCountry.SelectedItem.Text);

            LoadState(ref agentState, agentCountry.Text, GetStatic.GetRowData(dr, "agentState"));

            LoadDistrict(ref agentDistrict, agentState.Text, GetStatic.GetRowData(dr, "agentDistrict"));


            _sdd.SetDDL(ref agentSettCurr, "EXEC proc_dropDownLists @flag = 'allCurr'", "currencyCode", "currencyCode",
            GetStatic.GetRowData(dr, "agentSettCurr"), "Select");

        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetAgentId().ToString());
            if (dr == null)
                return;

            agentName.Text = dr["agentName"].ToString();
            agentAddress.Text = dr["agentAddress"].ToString();
            agentCity.Text = dr["agentCity"].ToString();
            //agentZip.Text = dr["agentZip"].ToString();
            agentPhone1.Text = dr["agentPhone1"].ToString();
            agentPhone2.Text = dr["agentPhone2"].ToString();
            agentFax1.Text = dr["agentFax1"].ToString();
            agentFax2.Text = dr["agentFax2"].ToString();
            agentMobile1.Text = dr["agentMobile1"].ToString();
            agentMobile2.Text = dr["agentMobile2"].ToString();
            agentEmail1.Text = dr["agentEmail1"].ToString();
            agentEmail2.Text = dr["agentEmail2"].ToString();
            bankBranch.Text = dr["bankBranch"].ToString();
            bankCode.Text = dr["bankCode"].ToString();
            accNumber.Text = dr["bankAccountNumber"].ToString();
            accHolderName.Text = dr["accountHolderName"].ToString();
            //agentRole.SelectedValue = dr["agentRole"].ToString();
            agentType.SelectedValue = dr["agentType"].ToString();
            //allowAccountDeposit.Text = dr["allowAccountDeposit"].ToString();
            contractExpiryDate.Text = dr["contractExpiryDate1"].ToString();
            renewalFollowupDate.Text = dr["renewalFollowupDate1"].ToString();
            isSettlingAgent.Text = dr["isSettlingAgent"].ToString();

            businessLicense.Text = dr["businessLicense"].ToString();
            agentBlock.SelectedValue = dr["agentBlock"].ToString();
            branchCode.Text = dr["branchCode"].ToString();
            branchCode.ReadOnly = true;
            agentDetails.Text = dr["agentDetails"].ToString();
            isActive.SelectedValue = dr["isActive"].ToString();
            mapCodeDom.Text = dr["mapCodeDom"].ToString();
            partnerBankcode.Text = dr["routingCode"].ToString();
            agentDetails.Text = dr["agentDetails"].ToString();
            headMessage.Text = dr["headMessage"].ToString();
            contactPerson1.Text = dr["contactPerson1"].ToString();
            contactPerson2.Text = dr["contactPerson2"].ToString();
            isHeadOffice.Text = dr["isHeadOffice"].ToString();
            isApiPartner.Checked = string.IsNullOrEmpty(dr["isApiPartner"].ToString()) ? false : Convert.ToBoolean(dr["isApiPartner"].ToString());
            intlCheck.Checked = string.IsNullOrEmpty(dr["IsIntl"].ToString()) ? false : Convert.ToBoolean(dr["IsIntl"].ToString());
            divAuditLog.InnerHtml = _sdd.GetAuditLog(dr);
            PopulateDdl(dr);
        }

        private void Update()
        {
            string isInt = intlCheck.Checked ? "1" : "0";
            string isAPIPartner = isApiPartner.Checked ? "1" : "0";
            agentBlock.Text = "U";
            try
            {
                DbResult dbResult = obj.Update(GetStatic.GetUser()
                                                , GetAgentId().ToString()
                                                , GetParentId().ToString()
                                                , agentName.Text
                                                , agentAddress.Text
                                                , agentCity.Text
                                                , agentCountry.Text
                                                , agentCountry.Text == "" ? agentCountry.Text : agentCountry.SelectedItem.Text
                                                , agentState.Text == "" ? agentState.Text : agentState.SelectedItem.Text
                                                , agentDistrict.Text == "" ? agentDistrict.Text : agentDistrict.SelectedItem.Text
                                                //, agentZip.Text
                                                , agentLocation.Text
                                                , agentPhone1.Text
                                                , agentPhone2.Text
                                                , agentFax1.Text
                                                , agentFax2.Text
                                                , agentMobile1.Text
                                                , agentMobile2.Text
                                                , agentEmail1.Text
                                                , agentEmail2.Text
                                                , bankBranch.Text
                                                , bankCode.Text
                                                , accNumber.Text
                                                , accHolderName.Text
                                                , businessOrgType.Text
                                                , businessType.Text
                                                , agentType.Text
                                                , GetActAsBranchFlag()
                                                , contractExpiryDate.Text
                                                , renewalFollowupDate.Text
                                                , isSettlingAgent.Text
                                                , agentGroup.Text
                                                , businessLicense.Text
                                                , agentBlock.Text
                                                , agentDetails.Text
                                                , isActive.Text
                                                , headMessage.Text
                                                , mapCodeDom.Text
                                                , partnerBankcode.Text
                                                , agentSettCurr.Text
                                                , contactPerson1.Text
                                                , contactPerson2.Text
                                                , isInt
                                                , isAPIPartner
                                                , isHeadOffice.Text,
                                                branchCode.Text
                                                );
                lblMsg.Text = dbResult.Msg;
                ManageMessage(dbResult);
            }
            catch (SqlException ex)
            {
                var dbResult = new DbResult();
                dbResult.SetError("1", "Cannot save data : " + ex, "");
                ManageMessage(dbResult);
            }
        }

        private void DeleteRow()
        {
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), GetAgentId().ToString());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                if (GetMode().ToString() == "1")
                    Response.Redirect("Functions/ListAgent.aspx");
                else
                {
                    Response.Redirect("List.aspx");
                    string mes = GetStatic.ParseResultJsPrint(dbResult);
                    mes = mes.Replace("<center>", "");
                    mes = mes.Replace("</center>", "");

                    string scriptName = "CallBack";
                    string functionName = "CallBack('" + mes + "')";
                    GetStatic.CallBackJs1(Page, scriptName, functionName);
                    Session.Remove("message");

                }
                //ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseWindow", "parent.parent.GB_hide()", true);
            }
            else
            {
                if (GetMode() == 2)
                    GetStatic.AlertMessage(Page);
                else
                    GetStatic.PrintMessage(Page);
            }
        }

        private void LoadState(ref DropDownList ddl, string countryId, string defaultValue)
        {
            //string sql = "EXEC Proc_dropdown_remit @flag='static', @typeId = '2'";
            //_sdd.SetDDL3(ref ddl, sql, "valueId", "detailTitle", defaultValue, "Select");
            string sql = "exec proc_dropdown_remit @flag='filterState', @countryId = '" + agentCountry.SelectedValue + "'";
            _sdd.SetDDL3(ref ddl, sql, "stateId", "stateName", defaultValue, "select");
        }

        private void LoadDistrict(ref DropDownList ddl, string zone, string defaultValue)
        {
            //string sql = "EXEC Proc_dropdown_remit @flag='static', @typeId = '3'";
            //_sdd.SetDDL3(ref ddl, sql, "valueId", "detailTitle", defaultValue, "Select");
            string sql = "EXEC Proc_dropdown_remit @flag = 'filterDist', @zone = '" + agentState.SelectedValue + "'";
            _sdd.SetDDL(ref agentDistrict, sql, "districtName", "districtName", defaultValue, "Select District");

        }

        private void LoadCountry(ref DropDownList ddl, string defaultValue)
        {
            string sql = "EXEC Proc_dropdown_remit @flag='country'";

            _sdd.SetDDL3(ref ddl, sql, "countryId", "countryName", defaultValue, "Select");
        }

        #endregion

        #region Control Methods

        protected void bntSubmit_Click(object sender, EventArgs e)
        {
            string atype = GetStatic.ReadNumericDataFromQueryString("aType").ToString();
            if (atype == "2904" && branchCode.Text.Length < 3)
            {
                var dbResult = new DbResult()
                {
                    ErrorCode = "1",
                    Msg = "Branch code must be three characters",
                    Id = null
                };
                branchCodeField.Visible = true;
                ManageMessage(dbResult);
            }
            else
            {
                Update();
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DeleteRow();
        }


        protected void agentCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            //if (agentCountry.SelectedValue != "")
            //{
            //    _sdd.SetDDL(ref agentState, "Proc_dropdown_remit @flag = 'filterState', @countryId = '" + agentCountry.SelectedValue + "'", "stateId", "stateName", "", "Select State");
            //}
            LoadState(ref agentState, agentCountry.Text, "");
            LoadRegionSettings(agentCountry.SelectedItem.Text);
            agentCountry.Focus();
        }

        protected void agentState_SelectedIndexChanged(object sender, EventArgs e)
        {
            //if (agentDistrict.SelectedValue != "")
            //{
            //    _sdd.SetDDL(ref agentDistrict, "Proc_dropdown_remit @flag = 'filterDist', @zone = '" + agentState.SelectedValue + "'", "districtId", "districtName", "", "Select District");
            //}
            LoadDistrict(ref agentDistrict, agentState.Text, "");
            agentState.Focus();
        }

        protected void companyCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            //LoadState(ref companyState, companyCountry.Text, "");
            //LoadCompanyRegionSettings(companyCountry.SelectedItem.Text);
            //companyCountry.Focus();
        }

        protected void companyState_SelectedIndexChanged(object sender, EventArgs e)
        {
            //LoadDistrict(ref companyDistrict, companyState.Text, "");
            //companyState.Focus();
        }

        protected void LoadRegionSettings(string countryId)
        {
            if (countryId == "Nepal")
            {
                lblRegionType.Text = "Zone";
                //pnlDistrict.Visible = true;
                //pnlZip.Visible = false;

                agentLocation.Enabled = true;
                spnAgentLocation.Visible = true;

                // rfvAgentLocation.Enabled = true;
            }
            else
            {
                lblRegionType.Text = "State";
                //pnlDistrict.Visible = false;
                //pnlZip.Visible = true;

                agentLocation.Text = "";
                agentLocation.Enabled = false;
                spnAgentLocation.Visible = false;
                //  rfvAgentLocation.Enabled = false;
            }
        }

        protected void LoadCompanyRegionSettings(string countryId)
        {
            //if (countryId == "Nepal")
            //{
            //    lblCompanyRegionType.Text = "Zone";
            //    pnlCompanyDistrict.Visible = true;
            //    pnlCompanyZip.Visible = false;
            //}
            //else
            //{
            //    lblCompanyRegionType.Text = "State";
            //    pnlCompanyDistrict.Visible = false;
            //    pnlCompanyZip.Visible = true;
            //}
        }

        #endregion
        protected void payOption_SelectedIndexChanged(object sender, EventArgs e)
        {
            //ManagePayOption(payOption.Text);
            //payOption.Focus();
        }

        private void ManagePayOption(string pOption)
        {
            //switch (pOption)
            //{
            //    case "10":
            //        mapCodeIntAC.Enabled = false;
            //        mapCodeDomAC.Enabled = false;
            //        allowAccountDeposit.Text = "N";
            //        allowAccountDeposit.Enabled = false;
            //        break;
            //    case "20":
            //        //mapCodeIntAC.Enabled = false;
            //        allowAccountDeposit.Enabled = true;
            //        break;
            //    case "30":
            //        mapCodeIntAC.Enabled = true;
            //        allowAccountDeposit.Enabled = true;
            //        break;
            //    case "40":
            //        mapCodeIntAC.Enabled = true;
            //        allowAccountDeposit.Enabled = true;
            //        break;
            //    default:
            //        mapCodeIntAC.Enabled = true;
            //        allowAccountDeposit.Enabled = true;
            //        break;
            //}
        }

        protected void allowAccountDeposit_SelectedIndexChanged(object sender, EventArgs e)
        {
            //mapCodeDomAC.Enabled = allowAccountDeposit.Text == "Y";
            //allowAccountDeposit.Focus();
        }
    }
}