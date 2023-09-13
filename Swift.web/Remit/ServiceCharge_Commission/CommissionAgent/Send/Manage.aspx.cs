using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.BL.Remit.Commission.Send;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Commission.CommissionAgent.Send
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20131100";
        private const string AddEditFunctionId = "20131110";
        private const string DeleteFunctionId = "20131120";
        private const string ApproveFunctionId = "20131130";
        private const string ApproveFunctionId2 = "20131135";

        protected const string GridName = "grd_scSendDetail";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly ScSendMasterDao obj = new ScSendMasterDao();
        private readonly ScSendDetailDao sscdDao = new ScSendDetailDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                MakeNumericTextBox();
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    PopulateDdl(null);
                    PopulateData();
                }
                if (GetId() > 0)
                {
                    tblCopySlab.Visible = true;
                    LoadMaxAmount();
                }
            }
            if (GetId() > 0)
                LoadGrid(GetId().ToString());
            GetStatic.CallBackJs1(Page, "Populate", "PopulateDataById();");
        }

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref zipCode);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void LoadCountry(ref DropDownList ddl, string defaultValue)
        {
            string sql = "EXEC proc_countryMaster @flag = 'ocl'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, "All");
        }

        private void LoadSuperAgent(ref DropDownList ddl,string countryId, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'sal', @agentCountry="+ _sdd.FilterString(countryId);

            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

        private void LoadAgent(ref DropDownList ddl, string parentId, string countryId, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'al', @parentId=" + _sdd.FilterString(parentId) +
                         ", @agentCountry=" + _sdd.FilterString(countryId);

            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

        private void LoadBranch(ref DropDownList ddl, string parentId, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'bl', @parentId=" + _sdd.FilterString(parentId);

            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

        private void LoadState(ref DropDownList ddl, string countryId, string defaultValue)
        {
            string sql = "EXEC proc_countryStateMaster @flag = 'csl', @countryId=" + _sdd.FilterString(countryId);

            _sdd.SetDDL(ref ddl, sql, "stateId", "stateName", defaultValue, "All");
        }

        private void LoadGroup(ref DropDownList ddl, string countryId, string groupCat, string defaultValue)
        {
            string sql = "EXEC proc_countryGroupMapping @flag = 'gl', @countryId = " + _sdd.FilterString(countryId) +
                         ", @groupCat = " + _sdd.FilterString(groupCat);

            _sdd.SetDDL(ref ddl, sql, "groupId", "groupName", defaultValue, "Any");
        }

        private void LoadCurrency(ref DropDownList ddl, string countryId, string agentId, string defaultValue)
        {
            string sql = "";
            if (!string.IsNullOrEmpty(agentId))
                sql = "EXEC proc_agentCurrency @flag = 'acl', @agentId = " + _sdd.FilterString(agentId);
            else
                sql = "EXEC proc_countryCurrency @flag = 'l', @countryId = " + _sdd.FilterString(countryId);

            _sdd.SetDDL(ref ddl, sql, "currencyId", "currencyCode", defaultValue, "Select");
        }

        #region Amount Slab
        private void LoadGrid(string scSendMasterId)
        {
            amountSlab.Visible = true;
            var allowApprove = _sdd.HasRight(ApproveFunctionId);
            var allowDelete = _sdd.HasRight(DeleteFunctionId);
            var popUpParam = "dialogHeight:400px;dialogWidth:500px;dialogLeft:300;dialogTop:100;center:yes";
            var ds = sscdDao.PopulateCommissionDetail(GetStatic.GetUser(), scSendMasterId);
            var dt = ds.Tables[1];
            var html = new StringBuilder();
            html.Append("<table class=\"table table-responsive table-bordered table-striped\">");
            html.Append("<tr class=\"hdtitle\">");
            html.Append("<th class=\"hdtitle\" style=\"text-align: center;\"><a href=\"#\" onclick=\"ClearSelection('" + GridName + "');\">X</a></th>");
            html.Append("<th class=\"hdtitle\">Amount From</th>");
            html.Append("<th class=\"hdtitle\">Amount To</th>");
            html.Append("<th class=\"hdtitle\">Percent</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("<th class=\"hdtitle\"></th>");
            html.Append("</tr>");
            var i = 0;
            foreach (DataRow dr in dt.Rows)
            {
                html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\">" : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\" >");
                html.Append("<td align=\"center\"><input type = \"checkbox\" value = \"" + dr["scSendDetailId"] +
                            "\" name =\"" + GridName + "_rowId\" onclick = \"EditSelected(this, '" + GridName + "', '" + dr["scSendDetailId"] + "')\"" + AppendChkBoxProperties(dr["scSendDetailId"].ToString()) + "></td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["fromAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["toAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["pcnt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + dr["minAmt"] + "</td>");
                html.Append("<td class=\"alignRight\">" + dr["maxAmt"] + "</td>");
                html.Append("<td nowrap=\"nowrap\">");

                if (allowDelete)
                {
                    html.AppendLine("<a title=\"Delete\" href=\"#\" onclick=\"DeleteCommissionDetail('" + dr["scSendDetailId"] + "');\" /><img alt = \"Delete\" border = \"0\" title = \"Delete\" src=\"" + GetStatic.GetUrlRoot() + "/images/delete.gif\" /></a>");
                }
                if (allowApprove)
                {
                    if (dr["haschanged"].ToString().ToUpper().Equals("Y"))
                    {
                        if (dr["modifiedby"].ToString() == GetStatic.GetUser())
                        {
                            var approveLink = "id=" + dr["scSendDetailId"] + "&functionId=" + (ApproveFunctionId2 == "" ? ApproveFunctionId : ApproveFunctionId2) +
                                          "&functionId2=" + ApproveFunctionId + "&modBy=" + dr["modifiedby"];
                            var approvePage = GetStatic.GetUrlRoot() + "/ViewChanges.aspx?" + approveLink;
                            var jsText = "onclick = \"PopUp('" + GridName + "','" + approvePage + "','" + popUpParam + "');\"";
                            html.AppendLine("&nbsp;<a title = \"View Changes\" href=\"javascript:void(0)\" " + jsText + "\"><img alt = \"Waiting for Approval\" border = \"0\" title = \"Waiting for Approval\" src=\"" + GetStatic.GetUrlRoot() + "/images/wait-icon.png\" /></a>");
                        }
                        else
                        {
                            var approveLink = "id=" + dr["scSendDetailId"] + "&functionId=" + (ApproveFunctionId2 == "" ? ApproveFunctionId : ApproveFunctionId2) +
                                          "&functionId2=" + ApproveFunctionId;
                            var approvePage = GetStatic.GetUrlRoot() + "/ViewChanges.aspx?" + approveLink;
                            var jsText = "onclick = \"PopUp('" + GridName + "','" + approvePage + "','" + popUpParam + "');";
                            html.AppendLine("&nbsp;<a title = \"View Changes\" href=\"javascript:void(0)\" " + jsText + "\"><img alt = \"View Changes\" border = \"0\" title = \"View Changes\" src=\"" + GetStatic.GetUrlRoot() + "/images/view-changes.jpg\" /></a>");
                        }
                    }
                }
                html.Append("</td>");
                html.Append("</tr>");
            }
            html.Append("<tr>");
            html.Append("<td colspan=\"5\">Add/Edit Amount Details<input type=\"button\" value=\"Add New\" class='btn btn-primary' onclick=\"AddNew();\" /></td>");
            html.Append("</tr>");
            html.Append("<tr class=\"evenbg\">");
            html.Append("<td></td>");
            html.Append("<td style=\"text-align: center;\"><input id=\"fromAmt1\" type=\"text\" class=\"textbox\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td style=\"text-align: center;\"><input id=\"toAmt1\" type=\"text\" class=\"textbox\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td style=\"text-align: center;\"><input id=\"pcnt1\" type=\"text\" class=\"textbox\" onblur=\"ManageDetail1('pcnt1','minAmt1','maxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td style=\"text-align: center;\"><input id=\"minAmt1\" type=\"text\" class=\"textbox\" onblur=\"ManageDetail2('pcnt1','minAmt1','maxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td style=\"text-align: center;\"><input id=\"maxAmt1\" type=\"text\" class=\"textbox\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td><input id=\"btnSave1\" type=\"button\" class='btn btn-primary' value=\"Save\" onclick=\"Save();\" /></td>");
            html.Append("</tr>");
            html.Append("</table>");
            html.AppendLine("<input type = \"submit\" id = \"" + GridName + "_submitButton\" name = \"" + GridName + "_submitButton\" style=\"display:none\">");
            rpt_grid.InnerHtml = html.ToString();
        }

        private string AppendChkBoxProperties(string id)
        {
            var selectionCheckBoxList = GetStatic.ReadFormData(GridName + "_rowId", "");
            var valueList = selectionCheckBoxList.Split(',');
            if (valueList.Any(s => s.ToUpper().Equals(id.ToUpper())))
            {
                return "checked = \"checked\"";
            }
            return "";
        }

        private void PopulateCommissionDetailById()
        {
            DataRow dr = sscdDao.SelectById(GetStatic.GetUser(), hddScSendDetailId.Value);
            if (dr == null)
                return;
            fromAmt.Value = GetStatic.FormatData(dr["fromAmt"].ToString(), "M");
            toAmt.Value = GetStatic.FormatData(dr["toAmt"].ToString(), "M");
            pcnt.Value = GetStatic.FormatData(dr["pcnt"].ToString(), "M");
            minAmt.Value = dr["minAmt"].ToString();
            maxAmt.Value = dr["maxAmt"].ToString();

            GetStatic.CallBackJs1(Page, "Populate Data", "PopulateDataById();");
        }

        private void DeleteRow()
        {
            if (string.IsNullOrEmpty(hddScSendDetailId.Value))
                return;
            DbResult dbResult = sscdDao.Delete(GetStatic.GetUser(), hddScSendDetailId.Value);
            ManageMessage2(dbResult);
        }

        private void UpdateCommissionDetail()
        {
            DbResult dbResult = sscdDao.Update(GetStatic.GetUser()
                                           , hddScSendDetailId.Value
                                           , GetId().ToString()
                                           , fromAmt.Value
                                           , toAmt.Value
                                           , pcnt.Value
                                           , minAmt.Value
                                           , maxAmt.Value);
            ManageMessage2(dbResult);
        }

        private void ManageMessage2(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
            if (dbResult.ErrorCode == "0")
            {
                LoadGrid(GetId().ToString());
                AddNew();
            }
        }

        private void AddNew()
        {
            LoadMaxAmount();
            hddScSendDetailId.Value = "";
            toAmt.Value = "";
            pcnt.Value = "";
            minAmt.Value = "";
            maxAmt.Value = "";

            GetStatic.CallBackJs1(Page, "New Record", "NewRecord();");
        }

        private void LoadMaxAmount()
        {
            double maxAmount = _sdd.GetMaxAmount("scSendMasterId", GetId().ToString(), "scSendDetail");
            double startAmt = maxAmount + 0.01;
            fromAmt.Value = startAmt.ToString();
        }

        protected void btnSaveDetail_Click(object sender, EventArgs e)
        {
            UpdateCommissionDetail();
        }

        protected void btnEditDetail_Click(object sender, EventArgs e)
        {
            PopulateCommissionDetailById();
        }

        protected void btnDeleteDetail_Click(object sender, EventArgs e)
        {
            DeleteRow();
        }

        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            AddNew();
        }
        #endregion

        #region Copy Module
        private void LoadSlabGridForCopy(string scSendMasterId)
        {
            if (scSendMasterId == "")
            {
                divSlabgrid.Visible = false;
                rpt_slabgrid.InnerHtml = "";
                return;
            }
            divSlabgrid.Visible = true;
            var ds = sscdDao.PopulateCommissionDetail(GetStatic.GetUser(), scSendMasterId);
            var dt = ds.Tables[1];
            var html = new StringBuilder();
            html.Append("<table class=\"table table-responsive table-striped table-bordered\">");
            html.Append("<tr class=\"hdtitle\">");
            html.Append("<th class=\"hdtitle\">Amount From</th>");
            html.Append("<th class=\"hdtitle\">Amount To</th>");
            html.Append("<th class=\"hdtitle\">Percent</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("</tr>");
            var i = 0;
            foreach (DataRow dr in dt.Rows)
            {
                html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\">" : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\" >");
                html.Append("<td>" + GetStatic.FormatData(dr["fromAmt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["toAmt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["pcnt"].ToString(), "M") + "</td>");
                html.Append("<td>" + dr["minAmt"] + "</td>");
                html.Append("<td>" + dr["maxAmt"] + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table>");
            rpt_slabgrid.InnerHtml = html.ToString();
        }

        protected void commissionSlab_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSlabGridForCopy(commissionSlab.Text);
            commissionSlab.Focus();
        }

        private void CopySlab()
        {
            var dbResult = sscdDao.CopySlab(GetStatic.GetUser(), commissionSlab.Text, GetId().ToString());
            ManageMessage(dbResult);
        }

        protected void btnCopySlab_Click(object sender, EventArgs e)
        {
            CopySlab();
        }
        #endregion

        private void LoadGrid2(string scSendMasterId)
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("fromAmt", "Amount From", "", "M"),
                                      new GridColumn("toAmt", "Amount To", "", "M"),
                                      new GridColumn("pcnt", "Percent", "", "M"),
                                      new GridColumn("minAmt", "Min Amount", "", "M"),
                                      new GridColumn("maxAmt", "Max Amount", "", "M")
                                  };

            bool allowAddEdit = _sdd.HasRight(AddEditFunctionId);

            grid.GridName = GridName;

            grid.GridType = 1;

            grid.DisableJsFilter = true;
            grid.DisableSorting = true;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New ";
            grid.RowIdField = "scSendDetailId";
            grid.ShowPopUpWindowOnAddButtonClick = true;
            grid.AddPage = "Setup.aspx?scSendMasterId=" + scSendMasterId;

            grid.ApproveFunctionId = ApproveFunctionId;
            grid.ApproveFunctionId2 = ApproveFunctionId2;
            grid.AllowApprove = _sdd.HasRight(ApproveFunctionId);
            grid.AllowEdit = allowAddEdit;
            grid.AllowDelete = _sdd.HasRight(DeleteFunctionId);
            grid.GridWidth = 1020;

            string sql = "EXEC proc_scSendDetail @flag = 's', @scSendMasterId = " + scSendMasterId;
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        #region Control Method

        protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSuperAgent(ref ssAgent, sCountry.Text, "");
            LoadAgent(ref sAgent, ssAgent.Text, sCountry.Text, "");
            LoadState(ref state, sCountry.Text, "");
            LoadCurrency(ref baseCurrency, sCountry.Text, sAgent.Text, "");
            LoadGroup(ref agentGroup, sCountry.Text, "6300", "");
            sCountry.Focus();
        }

        protected void ssAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref sAgent, ssAgent.Text, sCountry.Text, "");
            ssAgent.Focus();
        }

        protected void sAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBranch(ref sBranch, sAgent.Text, "");
            //LoadCurrency(ref baseCurrency, sCountry.Text, sAgent.Text, "");
            sAgent.Focus();
        }

        protected void rCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSuperAgent(ref rsAgent, rCountry.Text, "");
            LoadAgent(ref rAgent, rsAgent.Text, rCountry.Text, "");
            LoadState(ref rState, rCountry.Text, "");
            LoadGroup(ref rAgentGroup, rCountry.Text, "6400", "");
            rCountry.Focus();
        }

        protected void rsAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref rAgent, rsAgent.Text, rCountry.Text, "");
            rsAgent.Focus();
        }

        protected void rAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBranch(ref rBranch, rAgent.Text, "");
            rAgent.Focus();
        }

        #endregion

        #region QueryString

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("scSendMasterId");
        }

        protected string GetSHub()
        {
            return GetStatic.ReadNumericDataFromQueryString("sHub").ToString();
        }

        protected string GetRHub()
        {
            return GetStatic.ReadNumericDataFromQueryString("rHub").ToString();
        }

        protected string GetSCountryId()
        {
            return GetStatic.ReadNumericDataFromQueryString("sCountry").ToString();
        }

        protected string GetRCountryId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rCountry").ToString();
        }

        protected string GetSsAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("ssAgent").ToString();
        }

        protected string GetRsAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rsAgent").ToString();
        }

        protected string GetSAgent()
        {
            return GetStatic.ReadNumericDataFromQueryString("sAgent").ToString();
        }

        protected string GetRAgent()
        {
            return GetStatic.ReadNumericDataFromQueryString("rAgent").ToString();
        }

        protected string GetSBranch()
        {
            return GetStatic.ReadNumericDataFromQueryString("sBranch").ToString();
        }

        protected string GetRBranch()
        {
            return GetStatic.ReadNumericDataFromQueryString("rBranch").ToString();
        }

        protected string GetAgentGroup()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentGroup").ToString();
        }

        protected string GetState()
        {
            return GetStatic.ReadNumericDataFromQueryString("state").ToString();
        }

        protected string GetTranType()
        {
            return GetStatic.ReadNumericDataFromQueryString("tranType").ToString();
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnSave.Visible = _sdd.HasRight(AddEditFunctionId);
        }

        #endregion

        #region Populate DropDown

        private void PopulateDdl(DataRow dr)
        {
            string sql = "SELECT valueId, detailTitle FROM staticDataValue WHERE valueId IN (4200,4202,4203,4203)";
            _sdd.SetDDL(ref commissionBase, sql, "valueId", "detailTitle", GetStatic.GetRowData(dr, "commissionBase"),
                        "Select");
            _sdd.SetDDL(ref commissionSlab, "EXEC proc_scSendMaster @flag = 'cl'", "scSendMasterId", "code", "", "Select");
            LoadCountry(ref sCountry, GetStatic.GetRowData(dr, "sCountry"));
            LoadCountry(ref rCountry, GetStatic.GetRowData(dr, "rCountry"));
            LoadSuperAgent(ref ssAgent, sCountry.Text, GetStatic.GetRowData(dr, "ssAgent"));
            LoadSuperAgent(ref rsAgent, rCountry.Text,GetStatic.GetRowData(dr, "rsAgent"));
            LoadAgent(ref sAgent, ssAgent.Text, sCountry.Text, GetStatic.GetRowData(dr, "sAgent"));
            LoadAgent(ref rAgent, rsAgent.Text, rCountry.Text, GetStatic.GetRowData(dr, "rAgent"));
            LoadCurrency(ref baseCurrency, sCountry.Text, "", GetStatic.GetRowData(dr, "baseCurrency"));
            LoadBranch(ref sBranch, sAgent.Text, GetStatic.GetRowData(dr, "sBranch"));
            LoadBranch(ref rBranch, rAgent.Text, GetStatic.GetRowData(dr, "rBranch"));
            LoadState(ref state, sCountry.Text, GetStatic.GetRowData(dr, "state"));
            LoadState(ref rState, rCountry.Text, GetStatic.GetRowData(dr, "rState"));
            LoadGroup(ref agentGroup, sCountry.Text, "6300", GetStatic.GetRowData(dr, "agentGroup"));
            LoadGroup(ref rAgentGroup, rCountry.Text, "6400", GetStatic.GetRowData(dr, "rAgentGroup"));
            _sdd.SetDDL(ref tranType, "EXEC proc_serviceTypeMaster @flag = 'l2'", "serviceTypeId", "typeTitle",
                        GetStatic.GetRowData(dr, "tranType"), "All");
        }

        private void PopulateData()
        {
            string sCountryId = GetSCountryId();
            string rCountryId = GetRCountryId();
            string ssAgentId = GetSsAgentId();
            string rsAgentId = GetRsAgentId();
            string sAgentId = GetSAgent();
            string rAgentId = GetRAgent();
            string sBranchId = GetSBranch();
            string rBranchId = GetRBranch();
            string tranTypeId = GetTranType();
            string stateId = GetState();
            string agentGroupId = GetAgentGroup();

            if (sCountryId != "0")
            {
                sCountry.SelectedValue = sCountryId;
                LoadAgent(ref sAgent, sCountryId, sCountry.Text, "");
                LoadState(ref state, sCountryId, "");
            }
            if (rCountryId != "0")
            {
                rCountry.SelectedValue = rCountryId;
                LoadAgent(ref rAgent, rCountryId, rCountry.Text, "");
                LoadState(ref rState, rCountryId, "");
            }
            if (ssAgentId != "0")
            {
                ssAgent.SelectedValue = ssAgentId;
                LoadAgent(ref sAgent, ssAgentId, sCountry.Text, "");
            }
            if (rsAgentId != "0")
            {
                rsAgent.SelectedValue = rsAgentId;
                LoadAgent(ref rAgent, rsAgentId, rCountry.Text, "");
            }
            if (sAgentId != "0")
            {
                sAgent.SelectedValue = sAgentId;
                LoadBranch(ref sBranch, sAgentId, "");
            }
            if (rAgentId != "0")
            {
                rAgent.SelectedValue = rAgentId;
                LoadBranch(ref rBranch, rAgentId, "");
            }
            if (sBranchId != "0")
            {
                sBranch.SelectedValue = sBranchId;
            }
            if (rBranchId != "0")
            {
                rBranch.SelectedValue = rBranchId;
            }
            if (tranTypeId != "0")
            {
                tranType.SelectedValue = tranTypeId;
            }
            if (stateId != "0")
            {
                state.SelectedValue = stateId;
            }
            if (agentGroupId != "0")
            {
                agentGroup.SelectedValue = agentGroupId;
            }
        }

        #endregion

        #region Method

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            PopulateDdl(dr);
            code.Text = dr["code"].ToString();
            description.Text = dr["description"].ToString();
            zipCode.Text = dr["zip"].ToString();
            rZipCode.Text = dr["rZip"].ToString();
            effectiveFrom.Text = dr["effFrom"].ToString();
            effectiveTo.Text = dr["effTo"].ToString();
            isEnable.SelectedValue = dr["isEnable"].ToString();
            //DisableField();
        }

        private void DisableField()
        {
            sCountry.Enabled = false;
            ssAgent.Enabled = false;
            sAgent.Enabled = false;
            sBranch.Enabled = false;
            rCountry.Enabled = false;
            rsAgent.Enabled = false;
            rAgent.Enabled = false;
            rBranch.Enabled = false;
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser()
                                           , GetId().ToString()
                                           , code.Text
                                           , description.Text
                                           , sCountry.SelectedValue
                                           , ssAgent.SelectedValue
                                           , sAgent.SelectedValue
                                           , sBranch.SelectedValue
                                           , rCountry.SelectedValue
                                           , rsAgent.SelectedValue
                                           , rAgent.SelectedValue
                                           , rBranch.SelectedValue
                                           , state.Text
                                           , zipCode.Text
                                           , agentGroup.SelectedValue
                                           , rState.Text
                                           , rZipCode.Text
                                           , rAgentGroup.Text
                                           , baseCurrency.SelectedValue
                                           , tranType.SelectedValue
                                           , commissionBase.SelectedValue
                                           , effectiveFrom.Text
                                           , effectiveTo.Text
                                           , isEnable.SelectedValue);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("Manage.aspx?sCountry=" +
                                  GetSCountryId() + "&rCountry=" + GetRCountryId() + "&ssAgent=" + GetSsAgentId() +
                                  "&rsAgent=" + GetRsAgentId() + "&sAgent=" + GetSAgent() + "&rAgent=" + GetRAgent() +
                                  "&tranType=" + GetTranType() + "&scSendMasterId=" + dbResult.Id);
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        #endregion
    }
}