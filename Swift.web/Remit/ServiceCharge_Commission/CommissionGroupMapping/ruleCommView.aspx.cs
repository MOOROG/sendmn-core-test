using System;
using System.Data;
using System.Text;
using System.Web.UI;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.Commission.CommissionGroupMapping
{
    public partial class ruleCommView : Page
    {
        private readonly RemittanceDao obj = new RemittanceDao();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                sl.CheckSession();
                string groupId = GetGroupId().ToString();
                string packageId = GetPackageId().ToString();
                if (groupId == "0")
                {
                    lblHeading.Text = "Commission Package Detail : <span style='color: red'>" + GetPackageName() + "</span>";
                    LoadByPackageId();
                }
                else if (packageId == "0")
                {
                    lblHeading.Text = "Commission Group Detail : <span style='color: red'>" + GetGroupName() + "</span>";
                    LoadDataByGroupId();
                }
            }
        }

        private void LoadDataByGroupId()
        {
            DataTable dtType =obj.ExecuteDataset(@"SELECT distinct ruleType FROM commissionPackage a with(nolock) inner join 
	                                    commissionGroup b with(nolock) on a.packageId=b.packageId WHERE groupId="+GetGroupId()+"").Tables[0];

            foreach (DataRow dr in dtType.Rows)
            {
                string ruleType = dr["ruleType"].ToString();

                if (ruleType == "ds")
                    LoadDsRule(ruleType);
                else if (ruleType == "sc")
                    LoadScPackage(ruleType);
                else if (ruleType == "cp")
                    LoadCpPackage(ruleType);
                else if (ruleType == "cs")
                    LoadCsPackage(ruleType);
            }
        }

        private void LoadByPackageId()
        {
            DataTable dtType = obj.ExecuteDataset(@"select distinct ruleType from commissionPackage where packageId="+GetPackageId()+"").Tables[0];

            foreach (DataRow dr in dtType.Rows)
            {
                string ruleType = dr["ruleType"].ToString();

                if (ruleType == "ds")
                    LoadDsRulePckId(ruleType);
                else if (ruleType == "sc")
                    LoadScPackagePckId(ruleType);
                else if (ruleType == "cp")
                    LoadCpPackagePckId(ruleType);
                else if (ruleType == "cs")
                    LoadCsPackagePckId(ruleType);
            }
        }

        protected long GetGroupId()
        {
            return GetStatic.ReadNumericDataFromQueryString("groupId");
        }

        protected long GetPackageId()
        {
            return GetStatic.ReadNumericDataFromQueryString("packageId");
        }

        protected string GetGroupName()
        {
            return "" + sl.GetGroupName(GetGroupId().ToString());
        }

        protected string GetPackageName()
        {
            return "" + sl.GetPackageName(GetPackageId().ToString());
        }

        private void LoadDsRule(string ruleType)
        {
            domestic.Visible = true;
            DataTable dtPck =
                obj.ExecuteDataset(@"SELECT distinct ruleId FROM commissionPackage a with(nolock) inner join 
	                    commissionGroup b with(nolock) on a.packageId=b.packageId WHERE groupId=" + GetGroupId() + " and ruleType='" + ruleType + "'").Tables[0];

            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            int sn = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                for (int i = 0; i < colsPck; i++)
                {
                    string scMasterId = drPck["ruleId"].ToString();

                    DataTable dt =
                        obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                     "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType + "'");

                    sn = sn + 1;
                    foreach (DataRow dr in dt.Rows)
                    {
                        html.Append(
                            "<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                        html.Append("<tr>");
                        html.Append("<td align=\"right\" rowspan='6' valign='top'>" + sn + ".</td>");
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
                                         GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType + "'");


                        html.Append(
                            "<table class=\"gridTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
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
            rpt_domestic.InnerHtml = html.ToString();
        }

        private void LoadScPackage(string ruleType)
        {
            serviceCharge.Visible = true;
            DataTable dtPck =
                obj.ExecuteDataset(@"SELECT distinct ruleId FROM commissionPackage a with(nolock) inner join 
	                    commissionGroup b with(nolock) on a.packageId=b.packageId WHERE groupId=" + GetGroupId() + " and ruleType='" + ruleType + "'").Tables[0];

            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            int sn = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                
                for (int i = 0; i < colsPck; i++)
                {
                    string scMasterId = drPck["ruleId"].ToString();

                    DataTable dt =
                        obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                     "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType + "'");
                    sn = sn + 1;
                    foreach (DataRow dr in dt.Rows)
                    {
                        html.Append(
                            "<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                        html.Append("<tr>");
                        html.Append("<td align=\"right\" rowspan='9' valign='top'>" + sn + ".</td>");
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
                                         GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType + "'");
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
                            html.Append(++cnt%2 == 1
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
            rpt_sc.InnerHtml = html.ToString();
        }

        private void LoadCpPackage(string ruleType)
        {
            payComm.Visible = true;
            DataTable dtPck =
                obj.ExecuteDataset(@"SELECT distinct ruleId FROM commissionPackage a with(nolock) inner join 
	                    commissionGroup b with(nolock) on a.packageId=b.packageId WHERE groupId=" + GetGroupId() + " and ruleType='" + ruleType + "'").Tables[0];

            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            int sn = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                
                for (int i = 0; i < colsPck; i++)
                {
                    string scMasterId = drPck["ruleId"].ToString();

                    DataTable dt =
                        obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                     "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType+ "'");
                    sn = sn + 1;
                    foreach (DataRow dr in dt.Rows)
                    {
                        html.Append("<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                        html.Append("<tr>");
                        html.Append("<td align=\"right\" rowspan='8' valign='top'>" + sn + ".</td>");
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
                                         GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType + "'");
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
                    i++;
                }
            }
            rpt_cp.InnerHtml = html.ToString();
        }

        private void LoadCsPackage(string ruleType)
        {
            sendComm.Visible = true;
            DataTable dtPck =
                obj.ExecuteDataset(@"SELECT distinct ruleId FROM commissionPackage a with(nolock) inner join 
	                    commissionGroup b with(nolock) on a.packageId=b.packageId WHERE groupId=" + GetGroupId() + " and ruleType='" + ruleType + "'").Tables[0];

            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            int sn = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                
                for (int i = 0; i < colsPck; i++)
                {
                    string scMasterId = drPck["ruleId"].ToString();

                    DataTable dt =
                        obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                     "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType + "'");
                    sn = sn + 1;
                    foreach (DataRow dr in dt.Rows)
                    {
                        html.Append("<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                        html.Append("<tr>");
                        html.Append("<td align=\"right\" rowspan='8' valign='top'>" + sn + ".</td>");
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
                                         GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='" +
                                         ruleType + "'");
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
                    i++;
                }
            }
            rpt_cs.InnerHtml = html.ToString();
        }

        private void LoadDsRulePckId(string ruleType)
        {
            domestic.Visible = true;
            DataTable dtPck =
                obj.ExecuteDataset(@"SELECT distinct ruleId FROM commissionPackage a with(nolock) inner join 
	                    commissionGroup b with(nolock) on a.packageId=b.packageId WHERE a.packageId=" + GetPackageId() + " and ruleType='" + ruleType + "'").Tables[0];

            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            int sn = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                
                for (int i = 0; i < colsPck; i++)
                {
                    string scMasterId = drPck["ruleId"].ToString();

                    DataTable dt =
                        obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                     "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType + "'");

                    sn = sn + 1;
                    foreach (DataRow dr in dt.Rows)
                    {
                        html.Append(
                            "<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                        html.Append("<tr>");
                        html.Append("<td align=\"right\" rowspan='6' valign='top'>" + sn + ".</td>");
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
                                         GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType + "'");


                        html.Append(
                            "<table class=\"gridTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
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
                            html.Append(++cnt % 2 == 1
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
            rpt_domestic.InnerHtml = html.ToString();
        }

        private void LoadScPackagePckId(string ruleType)
        {
            serviceCharge.Visible = true;
            DataTable dtPck =
                obj.ExecuteDataset(@"SELECT distinct ruleId FROM commissionPackage a with(nolock) inner join 
	                    commissionGroup b with(nolock) on a.packageId=b.packageId WHERE a.packageId=" + GetPackageId() + " and a.ruleType='" + ruleType + "'").Tables[0];

            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            int sn = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                
                for (int i = 0; i < colsPck; i++)
                {
                    string scMasterId = drPck["ruleId"].ToString();

                    DataTable dt =
                        obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                     "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType + "'");
                    sn = sn + 1;
                    foreach (DataRow dr in dt.Rows)
                    {
                        
                        html.Append(
                            "<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                        html.Append("<tr>");
                        html.Append("<td align=\"right\" rowspan='9' valign='top'>" + sn + ".</td>");
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
                                         GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType + "'");
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
                    i++;
                }
            }
            rpt_sc.InnerHtml = html.ToString();
        }

        private void LoadCpPackagePckId(string ruleType)
        {
            payComm.Visible = true;
            DataTable dtPck =
                obj.ExecuteDataset(@"SELECT distinct ruleId FROM commissionPackage a with(nolock) inner join 
	                    commissionGroup b with(nolock) on a.packageId=b.packageId WHERE a.packageId=" + GetPackageId() + " and ruleType='" + ruleType + "'").Tables[0];

            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            int sn = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                
                for (int i = 0; i < colsPck; i++)
                {
                    string scMasterId = drPck["ruleId"].ToString();

                    DataTable dt =
                        obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                     "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType + "'");
                    
                    sn = sn + 1;
                    foreach (DataRow dr in dt.Rows)
                    {
                        html.Append("<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                        html.Append("<tr>");
                        html.Append("<td align=\"right\" rowspan='8' valign='top'>" + sn + ".</td>");
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
                                         GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType + "'");
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
                    i++;
                }
            }
            rpt_cp.InnerHtml = html.ToString();
        }

        private void LoadCsPackagePckId(string ruleType)
        {
            sendComm.Visible = true;
            DataTable dtPck =
                obj.ExecuteDataset(@"SELECT distinct ruleId FROM commissionPackage a with(nolock) inner join 
	                    commissionGroup b with(nolock) on a.packageId=b.packageId WHERE a.packageId=" + GetPackageId() + " and ruleType='" + ruleType + "'").Tables[0];

            int colsPck = dtPck.Columns.Count;
            var html = new StringBuilder();
            int sn = 0;
            foreach (DataRow drPck in dtPck.Rows)
            {
                
                for (int i = 0; i < colsPck; i++)
                {
                    string scMasterId = drPck["ruleId"].ToString();

                    DataTable dt =
                        obj.getTable("EXEC proc_commissionGroupMapping  @flag = 'V' , @user ='" + GetStatic.GetUser() +
                                     "', @scMasterId ='" + scMasterId + "',@ruleType='" + ruleType + "'");
                    sn = sn + 1;
                    foreach (DataRow dr in dt.Rows)
                    {
                        html.Append("<table class=\"formTable\" width=\"1000px\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">");
                        html.Append("<tr>");
                        html.Append("<td align=\"right\" rowspan='8' valign='top'>" + sn + ".</td>");
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
                                         GetStatic.GetUser() + "', @scMasterId ='" + scMasterId + "',@ruleType='" +
                                         ruleType + "'");
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
                    i++;
                }
            }
            rpt_cs.InnerHtml = html.ToString();
        }
    }
}