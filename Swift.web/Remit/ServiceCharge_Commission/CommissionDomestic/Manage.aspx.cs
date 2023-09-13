using System;
using System.Data;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.BL.Remit.DomesticOperation.CommissionSetup;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.Commission.CommissionDomestic
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20131300";
        private const string AddEditFunctionId = "20131310";
        private const string DeleteFunctionId = "20131320";
        private const string ApproveFunctionId = "20131330";
        private const string ApproveFunctionId2 = "20131335";

        protected const string GridName = "grd_scDetail";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly ScDetailDao dscdDao = new ScDetailDao();
        private readonly ScMasterDao obj = new ScMasterDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
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
            {
                LoadGrid(GetId().ToString());
            }
            GetStatic.CallBackJs1(Page, "Populate", "PopulateDataById();");
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            Update();
        }

        #region QueryString

        protected string GetSAgent()
        {
            return GetStatic.ReadNumericDataFromQueryString("sAgent").ToString();
        }
        protected string GetSBranch()
        {
            return GetStatic.ReadNumericDataFromQueryString("sBranch").ToString();
        }
        protected string GetSState()
        {
            return GetStatic.ReadNumericDataFromQueryString("sState").ToString();
        }
        protected string GetSGroup()
        {
            return GetStatic.ReadNumericDataFromQueryString("sGroup").ToString();
        }
        protected string GetRAgent()
        {
            return GetStatic.ReadNumericDataFromQueryString("rAgent").ToString();
        }
        protected string GetRBranch()
        {
            return GetStatic.ReadNumericDataFromQueryString("rBranch").ToString();
        }
        protected string GetRState()
        {
            return GetStatic.ReadNumericDataFromQueryString("rState").ToString();
        }
        protected string GetRGroup()
        {
            return GetStatic.ReadNumericDataFromQueryString("rGroup").ToString();
        }

        protected string GetTranType()
        {
            return GetStatic.ReadNumericDataFromQueryString("tranType").ToString();
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("scMasterId");
        }
        #endregion

        #region Method
        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnSave.Visible = _sdd.HasRight(AddEditFunctionId);
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;
            PopulateDdl(dr);
            code.Text = dr["code"].ToString();
            description.Text = dr["description"].ToString();
            isEnable.SelectedValue = dr["isEnable"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser()
                                           , GetId().ToString()
                                           , code.Text
                                           , description.Text
                                           , sAgent.Text
                                           , sBranch.Text
                                           , sState.Text
                                           , sGroup.Text
                                           , rAgent.Text
                                           , rBranch.Text
                                           , rState.Text
                                           , rGroup.Text
                                           , tranType.Text
                                           , commissionBase.Text
                                           , effectiveFrom.Text
                                           , effectiveTo.Text
                                           , isEnable.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("Manage.aspx?sAgent=" + GetSAgent() + "&sBranch=" + GetSBranch() + "&sState=" + GetSState() + "&sGroup=" + GetSGroup() + "&rAgent=" + GetRAgent() + "&rBranch=" + GetRBranch() + "&rState=" + GetRState() + "&rGroup=" + GetRGroup() + "&tranType=" + GetTranType() + "&scMasterId=" + dbResult.Id);
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        #region PopulateDropDown

        private void PopulateDdl(DataRow dr)
        {
            string sql = "SELECT valueId, detailTitle FROM staticDataValue WHERE valueId IN (4200,4202,4203,4204)";
            _sdd.SetDDL(ref commissionSlab, "EXEC proc_scMaster @flag = 'cl'", "scMasterId", "code", "", "Select");
            //_sdd.SetDDL(ref commissionBase, sql, "valueId", "detailTitle", GetStatic.GetRowData(dr, "commissionBase"),"Select");

            _sdd.SetStaticDdl(ref commissionBase, "4200","", "Any");

            LoadAgent(ref sAgent, GetStatic.GetDomesticSuperAgentId(), GetStatic.GetDomesticCountryId(), GetStatic.GetRowData(dr, "sAgent"));
            LoadAgent(ref rAgent, GetStatic.GetDomesticSuperAgentId(), GetStatic.GetDomesticCountryId(), GetStatic.GetRowData(dr, "rAgent"));
            LoadBranch(ref sBranch, sAgent.Text, GetStatic.GetRowData(dr, "sBranch"));
            LoadBranch(ref rBranch, rAgent.Text, GetStatic.GetRowData(dr, "rBranch"));
            LoadState(ref sState, GetStatic.GetDomesticCountryId(), GetStatic.GetRowData(dr, "sState"));
            LoadState(ref rState, GetStatic.GetDomesticCountryId(), GetStatic.GetRowData(dr, "rState"));
            _sdd.SetStaticDdl(ref sGroup, "6300", GetStatic.GetRowData(dr, "sGroup"), "Any");
            _sdd.SetStaticDdl(ref rGroup, "6300", GetStatic.GetRowData(dr, "rGroup"), "Any");
            _sdd.SetDDL(ref tranType, "EXEC proc_serviceTypeMaster @flag = 'l2'", "serviceTypeId", "typeTitle",
                        GetStatic.GetRowData(dr, "tranType"), "All");
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

        private void PopulateData()
        {
            string sAgentId = GetSAgent();
            string sBranchId = GetSBranch();
            string sStateId = GetSState();
            string sGroupId = GetSGroup();
            string rAgentId = GetRAgent();
            string rBranchId = GetRBranch();
            string rStateId = GetRState();
            string rGroupId = GetRGroup();
            if (sAgentId != "0")
            {
                sAgent.Text = sAgentId;
            }
            if (sBranchId != "0")
            {
                sBranch.Text = sBranchId;
            }
            if (sStateId != "0")
            {
                sState.Text = sStateId;
            }
            if (sGroupId != "0")
            {
                sGroup.Text = sGroupId;
            }
            if (rAgentId != "0")
            {
                rAgent.Text = rAgentId;
            }
            if (rBranchId != "0")
            {
                rBranch.Text = rBranchId;
            }
            if (rStateId != "0")
            {
                rState.Text = rStateId;
            }
            if (rGroupId != "0")
            {
                rGroup.Text = rGroupId;
            }
            string tranTypeId = GetTranType();
            if (tranTypeId != "0")
            {
                tranType.Text = tranTypeId;
            }
        }

        #endregion

        #endregion

        #region SwiftGrid
        private void LoadSlabGridForCopy(string scMasterId)
        {
            if(scMasterId == "")
            {
                divSlabgrid.Visible = false;
                return;
            }
            divSlabgrid.Visible = true;
            var ds = dscdDao.PopulateCommissionDetail(GetStatic.GetUser(), scMasterId);
            var dt = ds.Tables[1];
            var html = new StringBuilder();
            html.Append("<table class=\"table table-responsive table-striped table-bordered\">");
            html.Append("<tr class=\"hdtitle\">");
            html.Append("<th colspan=\"2\" class=\"hdtitle\">Amount</th>");
            html.Append("<th colspan=\"3\" class=\"hdtitle\">Service Charge</th>");
            html.Append("<th colspan=\"3\" class=\"hdtitle\">Sending Agent Comm.</th>");
            html.Append("<th colspan=\"3\" class=\"hdtitle\">Sending Sup Agent Comm.</th>");
            html.Append("<th colspan=\"3\" class=\"hdtitle\">Paying Agent Comm.</th>");
            html.Append("<th colspan=\"3\" class=\"hdtitle\">Paying Sup Agent Comm.</th>");
            html.Append("<th colspan=\"3\" class=\"hdtitle\">Bank Comm.</th>");
            html.Append("</tr><tr class=\"hdtitle\">");
            html.Append("<th class=\"hdtitle\">From</th>");
            html.Append("<th class=\"hdtitle\">To</th>");
            html.Append("<th class=\"hdtitle\">Percent</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("<th class=\"hdtitle\">Percent</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("<th class=\"hdtitle\">Percent</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("<th class=\"hdtitle\">Percent</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("<th class=\"hdtitle\">Percent</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("<th class=\"hdtitle\">Percent</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("</tr>");
            var i = 0;
            foreach (DataRow dr in dt.Rows)
            {
                html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\">" : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\" >");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["fromAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["toAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["serviceChargePcnt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["serviceChargeMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["serviceChargeMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["sAgentCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["sAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["sAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["ssAgentCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["ssAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["ssAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["pAgentCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["pAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["pAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["psAgentCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["psAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["psAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["bankCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["bankCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["bankCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table>");
            rpt_slabgrid.InnerHtml = html.ToString();
        }

        private void LoadGrid(string scMasterId)
        {
            amountSlab.Visible = true;
            var allowApprove = _sdd.HasRight(ApproveFunctionId);
            var allowDelete = _sdd.HasRight(DeleteFunctionId);
            var popUpParam = "dialogHeight:400px;dialogWidth:500px;dialogLeft:300;dialogTop:100;center:yes";
            var ds = dscdDao.PopulateCommissionDetail(GetStatic.GetUser(), scMasterId);
            //var drPaging = ds.Tables[0].Rows[0];
            //tblCopySlab.Visible = Convert.ToInt16(drPaging["totalRow"]) <= 0;
            var dt = ds.Tables[1];
            var html = new StringBuilder();
            html.Append("<table class=\"table table-responsive table-striped table-bordered\" ");
            html.Append("<tr class=\"hdtitle\">");
            html.Append("<th rowspan=\"2\" class=\"hdtitle\" style=\"text-align: center;\"><a href=\"#\" onclick=\"ClearSelection('" + GridName + "');\">X</a></th>");
            html.Append("<th colspan=\"2\" class=\"hdtitle\">Amount</th>");
            html.Append("<th colspan=\"3\" class=\"hdtitle\">Service Charge</th>");
            html.Append("<th colspan=\"3\" class=\"hdtitle\">Sending Agent Comm.</th>");
            html.Append("<th colspan=\"3\" class=\"hdtitle\">Sending Sup Agent Comm.</th>");
            html.Append("<th colspan=\"3\" class=\"hdtitle\">Paying Agent Comm.</th>");
            html.Append("<th colspan=\"3\" class=\"hdtitle\">Paying Sup Agent Comm.</th>");
            html.Append("<th colspan=\"3\" class=\"hdtitle\">Bank Comm.</th>");
            html.Append("<th rowspan=\"2\" class=\"hdtitle\"></th>");
            html.Append("</tr><tr class=\"hdtitle\">");
            html.Append("<th class=\"hdtitle\">From</th>");
            html.Append("<th class=\"hdtitle\">To</th>");
            html.Append("<th class=\"hdtitle\">%</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("<th class=\"hdtitle\">%</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("<th class=\"hdtitle\">%</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("<th class=\"hdtitle\">%</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("<th class=\"hdtitle\">%</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("<th class=\"hdtitle\">%</th>");
            html.Append("<th class=\"hdtitle\">Min Amt</th>");
            html.Append("<th class=\"hdtitle\">Max Amt</th>");
            html.Append("</tr>");
            var i = 0;
            foreach (DataRow dr in dt.Rows)
            {
                html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\">" : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\" >");
                html.Append("<td align=\"center\"><input type = \"checkbox\" value = \"" + dr["scDetailId"] +
                            "\" name =\"" + GridName + "_rowId\" onclick = \"EditSelected(this, '" + GridName + "', '" + dr["scDetailId"] + "')\"" + AppendChkBoxProperties(dr["scDetailId"].ToString()) + "></td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["fromAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["toAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["serviceChargePcnt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["serviceChargeMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["serviceChargeMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["sAgentCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["sAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["sAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["ssAgentCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["ssAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["ssAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["pAgentCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["pAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["pAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["psAgentCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["psAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["psAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["bankCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["bankCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["bankCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td nowrap=\"nowrap\">");

                if (allowDelete)
                {
                    html.AppendLine("<a title=\"Delete\" href=\"#\" onclick=\"DeleteCommissionDetail('" + dr["scDetailId"] + "');\" /><img alt = \"Delete\" border = \"0\" title = \"Delete\" src=\"" + GetStatic.GetUrlRoot() + "/images/delete.gif\" /></a>");
                }
                if (allowApprove)
                {
                    if (dr["haschanged"].ToString().ToUpper().Equals("Y"))
                    {
                        if (dr["modifiedby"].ToString() == GetStatic.GetUser())
                        {
                            var approveLink = "id=" + dr["scDetailId"] + "&functionId=" + (ApproveFunctionId2 == "" ? ApproveFunctionId : ApproveFunctionId2) +
                                          "&functionId2=" + ApproveFunctionId + "&modBy=" + dr["modifiedby"];
                            var approvePage = GetStatic.GetUrlRoot() + "/ViewChanges.aspx?" + approveLink;
                            var jsText = "onclick = \"PopUp('" + GridName + "','" + approvePage + "','" + popUpParam + "');\"";
                            html.AppendLine("&nbsp;<a title = \"View Changes\" href=\"javascript:void(0)\" " + jsText + "\"><img alt = \"Waiting for Approval\" border = \"0\" title = \"Waiting for Approval\" src=\"" + GetStatic.GetUrlRoot() + "/images/wait-icon.png\" /></a>");
                        }
                        else
                        {
                            var approveLink = "id=" + dr["scDetailId"] + "&functionId=" + (ApproveFunctionId2 == "" ? ApproveFunctionId : ApproveFunctionId2) +
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
            html.Append("<td colspan=\"6\">Add/Edit Amount Details<input type=\"button\" value=\"Add New\" onclick=\"ClearSelection('" + GridName + "');\"</td>");
            html.Append("</tr>");
            html.Append("<tr class=\"evenbg\">");
            html.Append("<td></td>");
            html.Append("<td class=\"alignRight\"><input id=\"fromAmt1\" type=\"text\" class=\"textbox\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"toAmt1\" type=\"text\" class=\"textbox\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"serviceChargePcnt1\" type=\"text\" class=\"textboxPcnt\" onblur=\"ManageDetail1('serviceChargePcnt1','serviceChargeMinAmt1','serviceChargeMaxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"serviceChargeMinAmt1\" type=\"text\" class=\"textbox\" onblur=\"ManageDetail2('serviceChargePcnt1','serviceChargeMinAmt1','serviceChargeMaxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"serviceChargeMaxAmt1\" type=\"text\" class=\"textbox\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"sAgentCommPcnt1\" type=\"text\" class=\"textboxPcnt\" onblur=\"ManageDetail1('sAgentCommPcnt1','sAgentCommMinAmt1','sAgentCommMaxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"sAgentCommMinAmt1\" type=\"text\" class=\"textbox\" onblur=\"ManageDetail2('sAgentCommPcnt1','sAgentCommMinAmt1','sAgentCommMaxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"sAgentCommMaxAmt1\" type=\"text\" class=\"textbox\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"ssAgentCommPcnt1\" type=\"text\" class=\"textboxPcnt\" onblur=\"ManageDetail1('ssAgentCommPcnt1','ssAgentCommMinAmt1','ssAgentCommMaxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"ssAgentCommMinAmt1\" type=\"text\" class=\"textboxSmall\" onblur=\"ManageDetail2('ssAgentCommPcnt1','ssAgentCommMinAmt1','ssAgentCommMaxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"ssAgentCommMaxAmt1\" type=\"text\" class=\"textboxSmall\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"pAgentCommPcnt1\" type=\"text\" class=\"textboxPcnt\" onblur=\"ManageDetail1('pAgentCommPcnt1','pAgentCommMinAmt1','pAgentCommMaxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"pAgentCommMinAmt1\" type=\"text\" class=\"textbox\" onblur=\"ManageDetail2('pAgentCommPcnt1','pAgentCommMinAmt1','pAgentCommMaxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"pAgentCommMaxAmt1\" type=\"text\" class=\"textbox\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"psAgentCommPcnt1\" type=\"text\" class=\"textboxPcnt\" onblur=\"ManageDetail1('psAgentCommPcnt1','psAgentCommMinAmt1','psAgentCommMaxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"psAgentCommMinAmt1\" type=\"text\" class=\"textboxSmall\" onblur=\"ManageDetail2('psAgentCommPcnt1','psAgentCommMinAmt1','psAgentCommMaxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"psAgentCommMaxAmt1\" type=\"text\" class=\"textboxSmall\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"bankCommPcnt1\" type=\"text\" class=\"textboxPcnt\" onblur=\"ManageDetail1('bankCommPcnt1','bankCommMinAmt1','bankCommMaxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"bankCommMinAmt1\" type=\"text\" class=\"textbox\" onblur=\"ManageDetail2('bankCommPcnt1','bankCommMinAmt1','bankCommMaxAmt1');\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"bankCommMaxAmt1\" type=\"text\" class=\"textbox\" onkeydown=\"return numericOnly(this, (event?event:evt), true);\"/></td>");
            html.Append("<td class=\"alignRight\"><input id=\"btnSave1\" type=\"button\" value=\"Save\" onclick=\"Save();\" /></td>");
            html.Append("</tr>");
            html.Append("</table></div>");
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
            DataRow dr = dscdDao.SelectById(GetStatic.GetUser(), hddScDetailId.Value);
            if (dr == null)
                return;

            fromAmt.Value = GetStatic.FormatData(dr["fromAmt"].ToString(), "M");
            toAmt.Value = GetStatic.FormatData(dr["toAmt"].ToString(), "M");
            serviceChargePcnt.Value = GetStatic.FormatData(dr["serviceChargePcnt"].ToString(), "M");
            serviceChargeMinAmt.Value = GetStatic.FormatData(dr["serviceChargeMinAmt"].ToString(), "M");
            serviceChargeMaxAmt.Value = GetStatic.FormatData(dr["serviceChargeMaxAmt"].ToString(), "M");
            sAgentCommPcnt.Value = GetStatic.FormatData(dr["sAgentCommPcnt"].ToString(), "M");
            sAgentCommMinAmt.Value = GetStatic.FormatData(dr["sAgentCommMinAmt"].ToString(), "M");
            sAgentCommMaxAmt.Value = GetStatic.FormatData(dr["sAgentCommMaxAmt"].ToString(), "M");
            ssAgentCommPcnt.Value = GetStatic.FormatData(dr["ssAgentCommPcnt"].ToString(), "M");
            ssAgentCommMinAmt.Value = GetStatic.FormatData(dr["ssAgentCommMinAmt"].ToString(), "M");
            ssAgentCommMaxAmt.Value = GetStatic.FormatData(dr["ssAgentCommMaxAmt"].ToString(), "M");
            pAgentCommPcnt.Value = GetStatic.FormatData(dr["pAgentCommPcnt"].ToString(), "M");
            pAgentCommMinAmt.Value = GetStatic.FormatData(dr["pAgentCommMinAmt"].ToString(), "M");
            pAgentCommMaxAmt.Value = GetStatic.FormatData(dr["pAgentCommMaxAmt"].ToString(), "M");
            psAgentCommPcnt.Value = GetStatic.FormatData(dr["psAgentCommPcnt"].ToString(), "M");
            psAgentCommMinAmt.Value = GetStatic.FormatData(dr["psAgentCommMinAmt"].ToString(), "M");
            psAgentCommMaxAmt.Value = GetStatic.FormatData(dr["psAgentCommMaxAmt"].ToString(), "M");
            bankCommPcnt.Value = GetStatic.FormatData(dr["bankCommPcnt"].ToString(), "M");
            bankCommMinAmt.Value = GetStatic.FormatData(dr["bankCommMinAmt"].ToString(), "M");
            bankCommMaxAmt.Value = GetStatic.FormatData(dr["bankCommMaxAmt"].ToString(), "M");

            GetStatic.CallBackJs1(Page, "Populate Data", "PopulateDataById();");
        }

        private void DeleteRow()
        {
            if (string.IsNullOrEmpty(hddScDetailId.Value))
                return;
            DbResult dbResult = dscdDao.Delete(GetStatic.GetUser(), hddScDetailId.Value);
            ManageMessage2(dbResult);
        }

        private void UpdateCommissionDetail()
        {
            DbResult dbResult = dscdDao.Update(GetStatic.GetUser()
                                           , hddScDetailId.Value
                                           , GetId().ToString()
                                           , fromAmt.Value
                                           , toAmt.Value
                                           , serviceChargePcnt.Value
                                           , serviceChargeMinAmt.Value
                                           , serviceChargeMaxAmt.Value
                                           , sAgentCommPcnt.Value
                                           , sAgentCommMinAmt.Value
                                           , sAgentCommMaxAmt.Value
                                           , ssAgentCommPcnt.Value
                                           , ssAgentCommMinAmt.Value
                                           , ssAgentCommMaxAmt.Value
                                           , pAgentCommPcnt.Value
                                           , pAgentCommMinAmt.Value
                                           , pAgentCommMaxAmt.Value
                                           , psAgentCommPcnt.Value
                                           , psAgentCommMinAmt.Value
                                           , psAgentCommMaxAmt.Value
                                           , bankCommPcnt.Value
                                           , bankCommMinAmt.Value
                                           , bankCommMaxAmt.Value);
            ManageMessage2(dbResult);
        }

        private void LoadGrid2(string scMasterId)
        {
            amountSlab.Visible = true;
            int i;
            var ds = dscdDao.PopulateCommissionDetail(GetStatic.GetUser(), scMasterId);
            var dt = ds.Tables[1];
            var html = new StringBuilder();
            html.Append("<table>");
            html.Append("<tr>");

            i = 0;
            html.Append("<td valign=\"top\">");
            html.Append("<input id=\"btnAmt\" type=\"button\" value=\"-\" onclick=\"ShowHide('btnAmt', 'tblAmt');\" />");
            html.Append("<table id=\"tblAmt\" class=\"gridTable\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
            html.Append("<tr>");
            html.Append("<th class=\"hdtitle\" colspan=\"2\">Amount</th>");
            html.Append("</tr>");
            html.Append("<tr>");
            html.Append("<th class=\"hdtitle\">From</th><th class=\"hdtitle\">To</th></tr>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\">" : "<tr class=\"evenbg\">");
                html.Append("<td>" + GetStatic.FormatData(dr["fromAmt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["toAmt"].ToString(), "M") + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table></td>");

            i = 0;
            html.Append("<td valign=\"top\">");
            html.Append("<input id=\"btnServiceCharge\" type=\"button\" value=\"-\" onclick=\"ShowHide('btnServiceCharge', 'tblServiceCharge');\" />");
            html.Append("<table id=\"tblServiceCharge\" class=\"gridTable\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
            html.Append("<tr>");
            html.Append("<th class=\"hdtitle\" colspan=\"3\">Service Charge</th>");
            html.Append("</tr><tr>");
            html.Append("<th class=\"hdtitle\">Percent</th><th class=\"hdtitle\">Min</th><th class=\"hdtitle\">Max</th></tr>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\">" : "<tr class=\"evenbg\">");
                html.Append("<td>" + GetStatic.FormatData(dr["serviceChargePcnt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["serviceChargeMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["serviceChargeMaxAmt"].ToString(), "M") + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table>");

            i = 0;
            html.Append("<td valign=\"top\">");
            html.Append("<input id=\"btnSAgentComm\" type=\"button\" value=\"-\" onclick=\"ShowHide('btnSAgentComm', 'tblSAgentComm');\" />");
            html.Append("<table id=\"tblSAgentComm\" class=\"gridTable\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
            html.Append("<tr>");
            html.Append("<th class=\"hdtitle\" colspan=\"3\">Sending Agent Comm.</th>");
            html.Append("</tr><tr>");
            html.Append("<th class=\"hdtitle\">Percent</th><th class=\"hdtitle\">Min</th><th class=\"hdtitle\">Max</th></tr>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\">" : "<tr class=\"evenbg\">");
                html.Append("<td>" + GetStatic.FormatData(dr["sAgentCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["sAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["sAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table></td>");

            i = 0;
            html.Append("<td valign=\"top\">");
            html.Append("<input id=\"btnSsAgentComm\" type=\"button\" value=\"-\" onclick=\"ShowHide('btnSsAgentComm', 'tblSsAgentComm');\" />");
            html.Append("<table id=\"tblSsAgentComm\" class=\"gridTable\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
            html.Append("<tr>");
            html.Append("<th class=\"hdtitle\" colspan=\"3\">Sending Sup Agent Comm.</th>");
            html.Append("</tr><tr>");
            html.Append("<th class=\"hdtitle\">Percent</th><th class=\"hdtitle\">Min</th><th class=\"hdtitle\">Max</th></tr>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\">" : "<tr class=\"evenbg\">");
                html.Append("<td>" + GetStatic.FormatData(dr["ssAgentCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["ssAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["ssAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table></td>");

            i = 0;
            html.Append("<td valign=\"top\">");
            html.Append("<input id=\"btnPAgentComm\" type=\"button\" value=\"-\" onclick=\"ShowHide('btnPAgentComm', 'tblPAgentComm');\" />");
            html.Append("<table id=\"tblPAgentComm\" class=\"gridTable\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
            html.Append("<tr>");
            html.Append("<th class=\"hdtitle\" colspan=\"3\">Paying Agent Comm.</th>");
            html.Append("</tr><tr>");
            html.Append("<th class=\"hdtitle\">Percent</th><th class=\"hdtitle\">Min</th><th class=\"hdtitle\">Max</th></tr>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\">" : "<tr class=\"evenbg\">");
                html.Append("<td>" + GetStatic.FormatData(dr["pAgentCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["pAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["pAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table></td>");

            i = 0;
            html.Append("<td valign=\"top\">");
            html.Append("<input id=\"btnPsAgentComm\" type=\"button\" value=\"-\" onclick=\"ShowHide('btnPsAgentComm', 'tblPsAgentComm');\" />");
            html.Append("<table id=\"tblPsAgentComm\" class=\"gridTable\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
            html.Append("<tr>");
            html.Append("<th class=\"hdtitle\" colspan=\"3\">Paying Sup Agent Comm.</th>");
            html.Append("</tr><tr>");
            html.Append("<th class=\"hdtitle\">Percent</th><th class=\"hdtitle\">Min</th><th class=\"hdtitle\">Max</th></tr>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\">" : "<tr class=\"evenbg\">");
                html.Append("<td>" + GetStatic.FormatData(dr["psAgentCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["psAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["psAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table></td>");

            i = 0;
            html.Append("<td valign=\"top\">");
            html.Append("<input id=\"btnBankComm\" type=\"button\" value=\"-\" onclick=\"ShowHide('btnBankComm', 'tblBankComm');\" />");
            html.Append("<table id=\"tblBankComm\" class=\"gridTable\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
            html.Append("<tr>");
            html.Append("<th class=\"hdtitle\" colspan=\"3\">Bank Comm.</th>");
            html.Append("</tr><tr>");
            html.Append("<th class=\"hdtitle\">Percent</th><th class=\"hdtitle\">Min</th><th class=\"hdtitle\">Max</th></tr>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append(++i % 2 == 1 ? "<tr class=\"oddbg\">" : "<tr class=\"evenbg\">");
                html.Append("<td>" + GetStatic.FormatData(dr["bankCommPcnt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["bankCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td>" + GetStatic.FormatData(dr["bankCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table></td>");

            html.Append("</tr></table>");
            rpt_grid.InnerHtml = html.ToString();

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
            hddScDetailId.Value = "";
            toAmt.Value = "";
            serviceChargePcnt.Value = "";
            serviceChargeMinAmt.Value = "";
            serviceChargeMaxAmt.Value = "";
            sAgentCommPcnt.Value = "";
            sAgentCommMinAmt.Value = "";
            sAgentCommMaxAmt.Value = "";
            ssAgentCommPcnt.Value = "";
            ssAgentCommMinAmt.Value = "";
            ssAgentCommMaxAmt.Value = "";
            pAgentCommPcnt.Value = "";
            pAgentCommMinAmt.Value = "";
            pAgentCommMaxAmt.Value = "";
            psAgentCommPcnt.Value = "";
            psAgentCommMinAmt.Value = "";
            psAgentCommMaxAmt.Value = "";
            bankCommPcnt.Value = "";
            bankCommMinAmt.Value = "";
            bankCommMinAmt.Value = "";
            bankCommMaxAmt.Value = "";
            GetStatic.CallBackJs1(Page, "New Record", "NewRecord();");
        }

        private void LoadMaxAmount()
        {
            double maxAmount = _sdd.GetMaxAmount("scMasterId", GetId().ToString(), "scDetail");
            double startAmt = maxAmount + 0.01;
            fromAmt.Value = startAmt.ToString();
        }

        #endregion

        protected void btnSave_Click(object sender, EventArgs e)
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

        protected void sAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBranch(ref sBranch, sAgent.Text, "");
            sAgent.Focus();
        }

        protected void rAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBranch(ref rBranch, rAgent.Text, "");
            rAgent.Focus();
        }

        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            AddNew();
        }

        protected void commissionSlab_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSlabGridForCopy(commissionSlab.Text);
            commissionSlab.Focus();
        }

        private void CopySlab()
        {
            var dbResult = dscdDao.CopySlab(GetStatic.GetUser(), commissionSlab.Text, GetId().ToString());
            ManageMessage(dbResult);
        }
        protected void btnCopySlab_Click(object sender, EventArgs e)
        {
            CopySlab();
        }
    }
}