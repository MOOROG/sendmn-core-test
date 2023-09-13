using System;
using System.Data;
using System.Text;
using System.Web.UI;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.DomesticOperation.CommissionGroupMapping
{
    public partial class CommissionView : Page
    {
        private readonly RemittanceDao obj = new RemittanceDao();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                sl.CheckSession();
                if (GetRuleId() == 0)
                {
                    if (GetRuleType() == "ds")
                        LoadDsRule();
                    else
                        LoadIntlPackage();
                }
                else
                {
                    if (GetRuleType() == "ds")
                        LoadRuleByRuleId();
                    else if (GetRuleType() == "sc")
                        LoadScRuleByRuleId();
                    else if (GetRuleType() == "cp")
                        LoadCpRuleByRuleId();
                    else if (GetRuleType() == "cs")
                        LoadCsRuleByRuleId();
                }
            }
        }

        protected long GetPackageId()
        {
            return GetStatic.ReadNumericDataFromQueryString("packageId");
        }

        private string GetRuleType()
        {
            return GetStatic.ReadQueryString("ruleType", "");
        }

        protected long GetRuleId()
        {
            return GetStatic.ReadNumericDataFromQueryString("ruleId");
        }

        protected string GetPackageName()
        {
            return "Package Name : " + sl.GetPackageName(GetPackageId().ToString());
        }

        private void LoadDsRule()
        {
            DataTable dtPck =
                obj.ExecuteDataset("SELECT ruleId FROM commissionPackage WHERE packageId=" + GetPackageId() +
                                   "  and ISNULL(isDeleted, 'N') = 'N' AND ruleType='"+GetRuleType()+"'").Tables[0];

            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            int sno = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                for (int i = 0; i < colsPck; i++)
                {
                    string scMasterId = drPck["ruleId"].ToString();

                    DataTable dt =
                        obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                     "', @scMasterId ='" + scMasterId + "',@ruleType='" + GetRuleType() + "'");
                    sno = sno + 1;
                    foreach (DataRow dr in dt.Rows)
                    {
                        html.Append("<span class=\"welcome\">Domestic Commission</span>");
                        html.Append(
                            "<table class=\"formTable\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                        html.Append("<tr>");
                        html.Append("<td align=\"right\" rowspan='6' valign='top'>"+sno+".</td>");
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
                        html.Append("<td align=\"right\">Commission Base:</td>");
                        html.Append("<td colspan=\"5\" class=\"formValue\">" + dr["CommBase"].ToString() + "</td>");

                        html.Append("</tr>");
                        html.Append("<tr>");
                        html.Append("<th colspan = \"4\" align = \"left\" width=\"400px\">Sending</th>");
                        html.Append("<th colspan = \"4\" align = \"left\" width=\"400px\">Receiving</th>");
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
                        html.Append("</table>");

                        DataTable dtdetail =
                            obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V1' , @user ='" +
                                         GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='" +
                                         GetRuleType() + "'");


                        html.Append(
                            "<table class='table table-responsive table-striped table-bordered'>");
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
                        var cnt = 0;
                        foreach (DataRow drdetail in dtdetail.Rows)
                        {
                            html.Append(++cnt%2 == 1
                                            ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\">"
                                            : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\" >");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["fromAmt"].ToString(), "M") + "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["toAmt"].ToString(), "M") + "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["serviceChargePcnt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["serviceChargeMinAmt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["serviceChargeMaxAmt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["sAgentCommPcnt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["sAgentCommMinAmt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["sAgentCommMaxAmt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["ssAgentCommPcnt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["ssAgentCommMinAmt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["ssAgentCommMaxAmt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["pAgentCommPcnt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["pAgentCommMinAmt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["pAgentCommMaxAmt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["psAgentCommPcnt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["psAgentCommMinAmt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["psAgentCommMaxAmt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["bankCommPcnt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["bankCommMinAmt"].ToString(), "M") +
                                        "</td>");
                            html.Append("<td>" + GetStatic.FormatData(drdetail["bankCommMaxAmt"].ToString(), "M") +
                                        "</td>");
                            html.Append("</tr>");
                        }
                        html.Append("</table></br>");
                    }
                    i++;
                }
            }
            rpt_rule.InnerHtml = html.ToString();
        }

        private void LoadIntlPackage()
        {
            var ds =
                obj.ExecuteDataset("SELECT ruleId FROM commissionPackage WHERE packageId = " + GetPackageId() +
                                   " AND ISNULL(isDeleted, 'N') = 'N' AND ruleType = 'sc'" + 
                                   "SELECT ruleId FROM commissionPackage WHERE packageId = " + GetPackageId() + 
                                   " AND ISNULL(isDeleted, 'N') = 'N' AND ruleType = 'cp'" + 
                                   "SELECT ruleId FROM commissionPackage WHERE packageId = " + GetPackageId() +
                                   " AND ISNULL(isDeleted, 'N') = 'N' AND ruleType = 'cs'");
            if(ds.Tables.Count > 0)
            {
                var dt = ds.Tables[0];
                LoadScPackage(dt);
            }
            if(ds.Tables.Count > 1)
            {
                var dt = ds.Tables[1];
                LoadCpPackage(dt);
            }
            if(ds.Tables.Count > 2)
            {
                var dt = ds.Tables[2];
                LoadCsPackage(dt);
            }
        }

        private void LoadScPackage(DataTable dtPck)
        {
            //DataTable dtPck =
            //    obj.ExecuteDataset("select ruleId from commissionPackage where packageId=" + GetPackageId() +
            //                       "  and isDeleted is null  and ruleType='" + GetRuleType() + "'").Tables[0];

            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            html.Append("<img id=\"imgSc\" src=\"../../../images/minus.gif\" border=\"0\" onclick=\"ShowHide('divSc', 'imgSc');\" class=\"showHand\" />");
            html.Append("<span class=\"welcome\" onclick=\"ShowHide('divSc', 'imgSc');\" style=\"cursor: pointer;\">International Service Charge</span>");
            html.Append("<div id=\"divSc\" style=\"display: block;\">");
            int sno = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                for (int i = 0; i < colsPck; i++)
                {
                    string scMasterId = drPck["ruleId"].ToString();

                    DataTable dt =
                        obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                     "', @scMasterId ='" + scMasterId + "',@ruleType='sc'");
                    sno = sno + 1;
                    foreach (DataRow dr in dt.Rows)
                    {
                        html.Append(
                            "<table class=\"formTable\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
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
                            obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V1' , @user ='" +
                                         GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='sc'");
                        int cols = dtdetail.Columns.Count;
                        html.Append(
                            "<table class=\"table table-responsive table-bordered table-striped\">");
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
                            html.Append(++cnt%2 == 1
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
                    i++;
                }
            }
            html.Append("</div>");
            html.Append("</br></br>");
            rpt_rule.InnerHtml = html.ToString();
        }

        private void LoadCpPackage(DataTable dtPck)
        {
            //DataTable dtPck =
            //    obj.ExecuteDataset("select ruleId from commissionPackage where packageId=" + GetPackageId() +
            //                       "  and isDeleted is null and ruleType='" + GetRuleType() + "'").Tables[0];

            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            html.Append("<img id=\"imgCp\" src=\"../../../images/minus.gif\" border=\"0\" onclick=\"ShowHide('divCp', 'imgCp');\" class=\"showHand\" />");
            html.Append("<span class=\"welcome\" style=\"cursor: pointer;\" onclick=\"ShowHide('divCp', 'imgCp');\">International Pay Commission</span>");
            html.Append("<div id=\"divCp\" style=\"display: block; clear: both;\">");
            int sno = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                for (int i = 0; i < colsPck; i++)
                {
                    string scMasterId = drPck["ruleId"].ToString();

                    DataTable dt =
                        obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                     "', @scMasterId ='" + scMasterId + "',@ruleType='cp'");
                    sno = sno + 1;
                    foreach (DataRow dr in dt.Rows)
                    {
                        html.Append("<table class=\"formTable\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
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
                            obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V1' , @user ='" +
                                         GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='cp'");
                        int cols = dtdetail.Columns.Count;
                        html.Append(
                            "<table class=\"table table-bordered table-responsive table-striped\">");
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
                    i++;
                }
            }
            html.Append("</div>");
            html.Append("</br></br>");
            rpt_rule.InnerHtml = rpt_rule.InnerHtml + html.ToString();
        }

        private void LoadCsPackage(DataTable dtPck)
        {
            //DataTable dtPck =
            //    obj.ExecuteDataset("select ruleId from commissionPackage where packageId=" + GetPackageId() +
            //                       "  and isDeleted is null and ruleType='" + GetRuleType() + "'").Tables[0];

            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            html.Append("<img id=\"imgCs\" src=\"../../../images/minus.gif\" border=\"0\" onclick=\"ShowHide('divCs', 'imgCs');\" class=\"showHand\" />");
            html.Append("<span class=\"welcome\" onclick=\"ShowHide('divCs', 'imgCs');\" style=\"cursor: pointer;\">International Send Commission</span>");
            html.Append("<div id=\"divCs\" style=\"display: block; clear: both;\">");
            int sno = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                for (int i = 0; i < colsPck; i++)
                {
                    string scMasterId = drPck["ruleId"].ToString();

                    DataTable dt =
                        obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                     "', @scMasterId ='" + scMasterId + "',@ruleType='cs'");
                    sno = sno + 1;
                    foreach (DataRow dr in dt.Rows)
                    {
                        html.Append("<table class=\"formTable\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
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
                            obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V1' , @user ='" +
                                         GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='cs'");
                        int cols = dtdetail.Columns.Count;
                        html.Append(
                            "<table class=\"table table-responsive table-striped table-bordered\">");
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
                    i++;
                }
            }
            html.Append("</div>");
            html.Append("</br>");
            rpt_rule.InnerHtml = rpt_rule.InnerHtml + html.ToString();
        }

        private void LoadRuleByRuleId()
        {
            var html = new StringBuilder();
            DataTable dt =
                obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                             "', @scMasterId ='" + GetRuleId() + "',@ruleType='" + GetRuleType() + "'");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append(
                    "<table class=\"formTable\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                html.Append("<tr>");
                html.Append("<td align=\"right\">Code:</td>");
                html.Append("<td class=\"formValue\">" + dr["Code"].ToString() + "</td>");
                html.Append("<td align=\"right\">Description:</td>");
                html.Append("<td colspan=\"5\" class=\"formValue\">" + dr["Code"].ToString() + "</td>");
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
                html.Append("<td align=\"right\">Commission Base:</td>");
                html.Append("<td colspan=\"5\" class=\"formValue\">" + dr["CommBase"].ToString() + "</td>");

                html.Append("</tr>");
                html.Append("<tr>");
                html.Append("<th colspan = \"4\" align = \"left\" width=\"400px\"  class=\"frmTitle\">Sending</th>");
                html.Append("<th colspan = \"4\" align = \"left\" width=\"400px\"  class=\"frmTitle\">Receiving</th>");
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
                html.Append("</table>");

                DataTable dtdetail =
                    obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V1' , @user ='" + GetStatic.GetUser() +
                                 "', @scMasterId ='" + GetRuleId() + "',@ruleType='" + GetRuleType() + "'");


                html.Append(
                    "<table class=\"table table-responsive table-bordered table-striped\">");
                html.Append("<tr class=\"hdtitle\">");
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
                var cnt = 0;
                foreach (DataRow drdetail in dtdetail.Rows)
                {
                    html.Append(++cnt%2 == 1
                                    ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\">"
                                    : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\" >");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["fromAmt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["toAmt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["serviceChargePcnt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["serviceChargeMinAmt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["serviceChargeMaxAmt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["sAgentCommPcnt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["sAgentCommMinAmt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["sAgentCommMaxAmt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["ssAgentCommPcnt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["ssAgentCommMinAmt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["ssAgentCommMaxAmt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["pAgentCommPcnt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["pAgentCommMinAmt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["pAgentCommMaxAmt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["psAgentCommPcnt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["psAgentCommMinAmt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["psAgentCommMaxAmt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["bankCommPcnt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["bankCommMinAmt"].ToString(), "M") + "</td>");
                    html.Append("<td>" + GetStatic.FormatData(drdetail["bankCommMaxAmt"].ToString(), "M") + "</td>");
                    html.Append("</tr>");
                }
                html.Append("</table>");
            }
            rpt_rule.InnerHtml = html.ToString();
        }

        private void LoadScRuleByRuleId()
        {
            var html = new StringBuilder();
            DataTable dt =
                obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                             "', @scMasterId ='" + GetRuleId() + "',@ruleType='" + GetRuleType() + "'");

            foreach (DataRow dr in dt.Rows)
            {
                html.Append(
                    "<table class=\"formTable\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                html.Append("<tr>");
                html.Append("<td align=\"right\">Code:</td>");
                html.Append("<td class=\"formValue\">" + dr["Code"].ToString() + "</td>");
                html.Append("<td align=\"right\">Description:</td>");
                html.Append("<td colspan=\"5\" class=\"formValue\">" + dr["Code"].ToString() + "</td>");
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
                    obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V1' , @user ='" + GetStatic.GetUser() +
                                 "', @scMasterId ='" + GetRuleId() + "',@ruleType='" + GetRuleType() + "'");
                int cols = dtdetail.Columns.Count;
                html.Append(
                    "<table class=\"table table-responsive table-bordered table-striped\">");
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
                    html.Append(++cnt%2 == 1
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
            rpt_rule.InnerHtml = html.ToString();
        }

        private void LoadCpRuleByRuleId()
        {
            var html = new StringBuilder();
            DataTable dt =
                obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                             "', @scMasterId ='" + GetRuleId() + "',@ruleType='" + GetRuleType() + "'");

            foreach (DataRow dr in dt.Rows)
            {
                html.Append("<table class=\"formTable\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                html.Append("<tr>");
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
                    obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V1' , @user ='" + GetStatic.GetUser() +
                                 "', @scMasterId ='" + GetRuleId() + "',@ruleType='" + GetRuleType() + "'");
                int cols = dtdetail.Columns.Count;
                html.Append(
                    "<table class=\"table table-responsive table-bordered table-striped\">");
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
            rpt_rule.InnerHtml = html.ToString();
        }

        private void LoadCsRuleByRuleId()
        {
            var html = new StringBuilder();
            DataTable dt =
                obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                             "', @scMasterId ='" + GetRuleId() + "',@ruleType='" + GetRuleType() + "'");

            foreach (DataRow dr in dt.Rows)
            {
                html.Append("<table class=\"formTable\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                html.Append("<tr>");
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
                    obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V1' , @user ='" + GetStatic.GetUser() +
                                 "', @scMasterId ='" + GetRuleId() + "',@ruleType='" + GetRuleType() + "'");
                int cols = dtdetail.Columns.Count;
                html.Append(
                    "<table class=\"table table-responsive table-bordered table-striped\">");
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
            rpt_rule.InnerHtml = html.ToString();
        }
    }
}