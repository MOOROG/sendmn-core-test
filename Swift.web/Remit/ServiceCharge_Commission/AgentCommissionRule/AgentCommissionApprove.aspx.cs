using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Commission;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.Commission.AgentCommissionRule
{
    public partial class AgentCommissionApprove : System.Web.UI.Page
    {
        private readonly RemittanceDao obj = new RemittanceDao();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private readonly AgentCommissionDao cgmDao = new AgentCommissionDao();
        private const string ApproveFunctionId = "20131530";                                            
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                LoadIntlPackageOld();
                AuditLog();
            }
        }
        private void Authenticate()
        {
            sl.CheckAuthentication(ApproveFunctionId);
        }
        private void AuditLog()
        {
            var dr = cgmDao.GetAgentCommissionAuditLog(GetStatic.GetUser(), GetAgentId().ToString());
            if (dr == null)
                return;
            changedBy.Text = dr["createdBy"].ToString();
            changedDate.Text = dr["createdDate"].ToString();
            if (dr["createdBy"].ToString() == GetStatic.GetUser())
            {
                btnApprove.Visible = false;
                btnReject.Visible = false;
            }
            else
            {
                btnApprove.Visible = true;
                btnReject.Visible = true;
            }

        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected long GetRuleId()
        {
            return GetStatic.ReadNumericDataFromQueryString("ruleId");
        }

        protected string GetAgentName()
        {
            return GetStatic.ReadQueryString("agentName", "");
        }

        private void LoadIntlPackageOld()
        {
            var ds = cgmDao.SelectForViewChanges(GetStatic.GetUser(), GetAgentId().ToString());
            if (ds.Tables.Count > 0)
            {
                var dt = ds.Tables[0];
                LoadScPackageOld(dt);
            }
            if (ds.Tables.Count > 1)
            {
                var dt = ds.Tables[1];
                LoadCpPackageOld(dt);
            }
            if (ds.Tables.Count > 2)
            {
                var dt = ds.Tables[2];
                LoadCsPackageOld(dt);
            }
        }

        private void LoadScPackageOld(DataTable dtPck)
        {
            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            html.Append("<img id=\"imgSc\" src=\"../../../images/minus.gif\" border=\"0\" onclick=\"ShowHide('divSc', 'imgSc');\" class=\"showHand\" />");
            html.Append("<span class=\"welcome\" onclick=\"ShowHide('divSc', 'imgSc');\" style=\"cursor: pointer;\">International Service Charge</span>");
            html.Append("<div id=\"divSc\" style=\"display: block;\">");
            int sno = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                string scMasterId = drPck["ruleId"].ToString();
                var modType = drPck["modType"].ToString();
                DataTable dt =
                    obj.ExecuteDataTable("EXEC proc_agentCommissionRule @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                    "', @scMasterId ='" + scMasterId + "',@ruleType='sc'");
                sno = sno + 1;
                foreach (DataRow dr in dt.Rows)
                {
                    if (modType == "I")
                        html.Append(
                            "<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color: yellow;\">");
                    else if (modType == "D")
                        html.Append(
                            "<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color: red;\">");
                    else
                        html.Append(
                            "<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\" rowspan='9' valign='top'>" + sno + ".</td>");
                    html.Append("<td align=\"right\">Code:</td>");
                    html.Append("<td class=\"formValue\">" + dr["Code"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Description:</td>");
                    html.Append("<td colspan=\"5\" class=\"formValue\">" + dr["Desc"].ToString() + "</td>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Effective From:</td>");
                    html.Append("<td class=\"formValue\">" + dr["effectiveFrom"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Effective To:</td>");
                    html.Append("<td colspan=\"5\" class=\"formValue\">" + dr["effectiveTo"].ToString() + "</td>");
                    html.Append("</tr>");

                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Transaction Type:</td>");
                    html.Append("<td class=\"formValue\">" + dr["tranType"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Base Currency:</td>");
                    html.Append("<td colspan=\"5\" class=\"formValue\">" + dr["baseCurrency"].ToString() + "</td>");
                    html.Append("</tr>");



                    html.Append("<tr>");
                    html.Append("<th colspan = \"4\" align = \"left\" width=\"400px\">Sending</th>");
                    html.Append("<th colspan = \"4\" align = \"left\" width=\"400px\">Receiving</th>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Country:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sCountry"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Super Agent:</td>");
                    html.Append("<td class=\"formValue\">" + dr["ssAgent"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Country:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rCountry"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Super Agent:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rsAgent"].ToString() + "</td>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Agent:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sAgent"].ToString() + "</td>");
                    html.Append("<td align=\"right\">State:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sState"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Agent:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rAgent"].ToString() + "</td>");
                    html.Append("<td align=\"right\">State:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rState"].ToString() + "</td>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Branch:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sBranch"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Group:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sGroup"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Branch:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rBranch"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Group:</td>");
                    html.Append("<td nowrap=\"nowrap\" class=\"formValue\">" + dr["rGroup"].ToString() + "</td>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Zip Code:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sZip"].ToString() + "</td>");
                    html.Append("<td align=\"right\"></td>");
                    html.Append("<td></td>");
                    html.Append("<td align=\"right\">Zip Code:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rZip"].ToString() + "</td>");
                    html.Append("<td align=\"right\"></td>");
                    html.Append("<td nowrap=\"nowrap\"></td>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Positive Discount:</td>");
                    html.Append("<td class=\"formValue\">" + dr["positiveDisc"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Discount Type:</td>");
                    html.Append("<td class=\"formValue\">" + dr["positiveDiscType"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Negative Discount:</td>");
                    html.Append("<td class=\"formValue\">" + dr["negativeDisc"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Discount Type:</td>");
                    html.Append("<td class=\"formValue\">" + dr["negativeDiscType"].ToString() + "</td>");
                    html.Append("</tr>");
                    html.Append("</table>");

                    DataTable dtdetail =
                        obj.ExecuteDataTable("EXEC proc_agentCommissionRule @flag = 'V1' , @user ='" +
                                        GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='sc'");
                    int cols = dtdetail.Columns.Count;
                    html.Append(
                        "<table class=\"gridTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                    html.Append("<tr class=\"hdtitle\">");
                    for (int j = 0; j < cols; j++)
                    {
                        html.Append("<th class=\"hdtitle\"><div align=\"left\">" + dtdetail.Columns[j].ColumnName +
                                    "</div></th>");
                    }
                    html.Append("</tr>");
                    var cnt = 0;
                    foreach (DataRow drdetail in dtdetail.Rows)
                    {
                        html.Append(++cnt % 2 == 1
                                        ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\">"
                                        : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\" >");
                        for (int j = 0; j < cols; j++)
                        {
                            html.Append("<td>" + GetStatic.FormatData(drdetail[j].ToString(), "M") + "</td>");
                        }
                        html.Append("</tr>");
                    }
                    html.Append("</table>");
                }
            }
            html.Append("</div>");
            html.Append("</br></br>");
            rpt_oldrule.InnerHtml = html.ToString();
        }

        private void LoadCpPackageOld(DataTable dtPck)
        {
            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            html.Append("<img id=\"imgCp\" src=\"../../../images/minus.gif\" border=\"0\" onclick=\"ShowHide('divCp', 'imgCp');\" class=\"showHand\" />");
            html.Append("<span class=\"welcome\" style=\"cursor: pointer;\" onclick=\"ShowHide('divCp', 'imgCp');\">International Pay Commission</span>");
            html.Append("<div id=\"divCp\" style=\"display: block; clear: both;\">");
            int sno = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                string scMasterId = drPck["ruleId"].ToString();
                var modType = drPck["modType"].ToString();

                DataTable dt =
                    obj.ExecuteDataTable("EXEC proc_agentCommissionRule @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                    "', @scMasterId ='" + scMasterId + "',@ruleType='cp'");
                sno = sno + 1;
                foreach (DataRow dr in dt.Rows)
                {
                    if (modType == "I")
                        html.Append(
                            "<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color: yellow;\">");
                    else if (modType == "D")
                        html.Append(
                            "<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color: red;\">");
                    else
                        html.Append(
                            "<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\" rowspan='8' valign='top'>" + sno + ".</td>");
                    html.Append("<td align=\"right\">Code:</td>");
                    html.Append("<td class=\"formValue\">" + dr["Code"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Description:</td>");
                    html.Append("<td colspan=\"5\" class=\"formValue\">" + dr["Desc"].ToString() + "</td>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Effective From:</td>");
                    html.Append("<td class=\"formValue\">" + dr["effectiveFrom"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Effective To:</td>");
                    html.Append("<td colspan=\"5\" class=\"formValue\">" + dr["effectiveTo"].ToString() + "</td>");
                    html.Append("</tr>");

                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Transaction Type:</td>");
                    html.Append("<td class=\"formValue\">" + dr["tranType"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Base Currency:</td>");
                    html.Append("<td class=\"formValue\">" + dr["baseCurrency"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Commission Currency:</td>");
                    html.Append("<td class=\"formValue\">" + dr["commCurrency"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Commission Base:</td>");
                    html.Append("<td class=\"formValue\">" + dr["commBase"].ToString() + "</td>");
                    html.Append("</tr>");

                    html.Append("<tr>");
                    html.Append("<th colspan = \"4\" align = \"left\" width=\"400px\">Sending</th>");
                    html.Append("<th colspan = \"4\" align = \"left\" width=\"400px\">Receiving</th>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Country:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sCountry"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Super Agent:</td>");
                    html.Append("<td class=\"formValue\">" + dr["ssAgent"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Country:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rCountry"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Super Agent:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rsAgent"].ToString() + "</td>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Agent:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sAgent"].ToString() + "</td>");
                    html.Append("<td align=\"right\">State:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sState"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Agent:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rAgent"].ToString() + "</td>");
                    html.Append("<td align=\"right\">State:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rState"].ToString() + "</td>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Branch:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sBranch"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Group:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sGroup"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Branch:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rBranch"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Group:</td>");
                    html.Append("<td nowrap=\"nowrap\" class=\"formValue\">" + dr["rGroup"].ToString() + "</td>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Zip Code:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sZip"].ToString() + "</td>");
                    html.Append("<td align=\"right\"></td>");
                    html.Append("<td></td>");
                    html.Append("<td align=\"right\">Zip Code:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rZip"].ToString() + "</td>");
                    html.Append("<td align=\"right\"></td>");
                    html.Append("<td nowrap=\"nowrap\"></td>");
                    html.Append("</tr>");
                    html.Append("</table>");

                    DataTable dtdetail =
                        obj.ExecuteDataTable("EXEC proc_agentCommissionRule @flag = 'V1' , @user ='" +
                                     GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='cp'");
                    int cols = dtdetail.Columns.Count;
                    html.Append(
                        "<table class=\"gridTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                    html.Append("<tr class=\"hdtitle\">");
                    for (int j = 0; j < cols; j++)
                    {
                        html.Append("<th class=\"hdtitle\"><div align=\"left\">" + dtdetail.Columns[j].ColumnName +
                                    "</div></th>");
                    }
                    html.Append("</tr>");
                    var cnt = 0;
                    foreach (DataRow drdetail in dtdetail.Rows)
                    {
                        html.Append(++cnt % 2 == 1
                                        ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\">"
                                        : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\" >");
                        for (int j = 0; j < cols; j++)
                        {
                            html.Append("<td>" + GetStatic.FormatData(drdetail[j].ToString(), "M") + "</td>");
                        }
                        html.Append("</tr>");
                    }
                    html.Append("</table>");
                }
            }
            html.Append("</div>");
            html.Append("</br></br>");
            rpt_oldrule.InnerHtml = rpt_oldrule.InnerHtml + html.ToString();
        }

        private void LoadCsPackageOld(DataTable dtPck)
        {
            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            html.Append("<img id=\"imgCs\" src=\"../../../images/minus.gif\" border=\"0\" onclick=\"ShowHide('divCs', 'imgCs');\" class=\"showHand\" />");
            html.Append("<span class=\"welcome\" onclick=\"ShowHide('divCs', 'imgCs');\" style=\"cursor: pointer;\">International Send Commission</span>");
            html.Append("<div id=\"divCs\" style=\"display: block; clear: both;\">");
            int sno = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                string scMasterId = drPck["ruleId"].ToString();
                var modType = drPck["modType"].ToString();
                DataTable dt =
                    obj.ExecuteDataTable("EXEC proc_agentCommissionRule @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                    "', @scMasterId ='" + scMasterId + "',@ruleType='cs'");
                sno = sno + 1;
                foreach (DataRow dr in dt.Rows)
                {
                    if (modType == "I")
                        html.Append(
                            "<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color: yellow;\">");
                    else if (modType == "D")
                        html.Append(
                            "<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color: red;\">");
                    else
                        html.Append(
                            "<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\" rowspan='8'  valign='top'>" + sno + ".</td>");
                    html.Append("<td align=\"right\">Code:</td>");
                    html.Append("<td class=\"formValue\">" + dr["Code"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Description:</td>");
                    html.Append("<td colspan=\"5\" class=\"formValue\">" + dr["Desc"].ToString() + "</td>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Effective From:</td>");
                    html.Append("<td class=\"formValue\">" + dr["effectiveFrom"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Effective To:</td>");
                    html.Append("<td colspan=\"5\" class=\"formValue\">" + dr["effectiveTo"].ToString() + "</td>");
                    html.Append("</tr>");

                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Transaction Type:</td>");
                    html.Append("<td class=\"formValue\">" + dr["tranType"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Base Currency:</td>");
                    html.Append("<td class=\"formValue\">" + dr["baseCurrency"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Commission Base:</td>");
                    html.Append("<td class=\"formValue\">" + dr["commBase"].ToString() + "</td>");
                    html.Append("<td align=\"right\"></td>");
                    html.Append("<td class=\"formValue\"></td>");
                    html.Append("</tr>");

                    html.Append("<tr>");
                    html.Append("<th colspan = \"4\" align = \"left\" width=\"400px\">Sending</th>");
                    html.Append("<th colspan = \"4\" align = \"left\" width=\"400px\">Receiving</th>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Country:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sCountry"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Super Agent:</td>");
                    html.Append("<td class=\"formValue\">" + dr["ssAgent"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Country:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rCountry"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Super Agent:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rsAgent"].ToString() + "</td>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Agent:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sAgent"].ToString() + "</td>");
                    html.Append("<td align=\"right\">State:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sState"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Agent:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rAgent"].ToString() + "</td>");
                    html.Append("<td align=\"right\">State:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rState"].ToString() + "</td>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Branch:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sBranch"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Group:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sGroup"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Branch:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rBranch"].ToString() + "</td>");
                    html.Append("<td align=\"right\">Group:</td>");
                    html.Append("<td nowrap=\"nowrap\" class=\"formValue\">" + dr["rGroup"].ToString() + "</td>");
                    html.Append("</tr>");
                    html.Append("<tr>");
                    html.Append("<td align=\"right\">Zip Code:</td>");
                    html.Append("<td class=\"formValue\">" + dr["sZip"].ToString() + "</td>");
                    html.Append("<td align=\"right\"></td>");
                    html.Append("<td></td>");
                    html.Append("<td align=\"right\">Zip Code:</td>");
                    html.Append("<td class=\"formValue\">" + dr["rZip"].ToString() + "</td>");
                    html.Append("<td align=\"right\"></td>");
                    html.Append("<td nowrap=\"nowrap\"></td>");
                    html.Append("</tr>");
                    html.Append("</table>");

                    DataTable dtdetail =
                        obj.ExecuteDataTable("EXEC proc_agentCommissionRule @flag = 'V1' , @user ='" +
                                        GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='cs'");
                    int cols = dtdetail.Columns.Count;
                    html.Append(
                        "<table class=\"gridTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                    html.Append("<tr class=\"hdtitle\">");
                    for (int j = 0; j < cols; j++)
                    {
                        html.Append("<th class=\"hdtitle\"><div align=\"left\">" + dtdetail.Columns[j].ColumnName +
                                    "</div></th>");
                    }
                    html.Append("</tr>");
                    var cnt = 0;
                    foreach (DataRow drdetail in dtdetail.Rows)
                    {
                        html.Append(++cnt % 2 == 1
                                        ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\">"
                                        : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\" >");
                        for (int j = 0; j < cols; j++)
                        {
                            html.Append("<td>" + GetStatic.FormatData(drdetail[j].ToString(), "M") + "</td>");
                        }
                        html.Append("</tr>");
                    }
                    html.Append("</table></br>");
                }
            }
            html.Append("</div>");
            html.Append("</br>");
            rpt_oldrule.InnerHtml = rpt_oldrule.InnerHtml + html.ToString();
        }

        private void Approve()
        {
            var dbResult = cgmDao.ApprovePackage(GetStatic.GetUser(), GetAgentId().ToString());
            ManageMessage(dbResult);
        }

        private void Reject()
        {
            var dbResult = cgmDao.RejectPackage(GetStatic.GetUser(), GetAgentId().ToString());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            var mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            var scriptName = "CallBack";
            var functionName = "CallBack('" + mes + "')";
            GetStatic.CallBackJs1(Page, scriptName, functionName);

            // Page.ClientScript.RegisterStartupScript(this.GetType(), "Done", "<script language = \"javascript\">return CallBack('" + mes + "')</script>");

        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            Approve();
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            Reject();
        }

    }
}