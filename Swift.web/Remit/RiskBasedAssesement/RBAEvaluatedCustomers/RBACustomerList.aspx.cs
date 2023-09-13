using Swift.DAL.Remittance.RBA;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.RiskBasedAssesement.RBAEvaluatedCustomers
{
    public partial class RBACustomerList : System.Web.UI.Page
    {

        protected const string GridName = "gridRBACustomerRpt";
        private string ViewFunctionId = "20191400";

        protected string pieValue = "";
        protected string pieValueSc = "";
        protected string level = " ";
        protected string legend = " ";
        protected string hoverText = " ";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly RBACustomerDao obj = new RBACustomerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
             //   Authenticate();
            }

            LoadGrid();
            ShowChart();
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {

            rpt_grid.InnerHtml = "";
            var dt = obj.LoadRBASummary(GetStatic.GetUser());

            int cnt = 0;

            var sb = new StringBuilder("<table class=\"table table-responsive table-striped table-bordered\">");

            sb.AppendLine("<tr >");
            //sb.AppendLine("<th class='frmTitle' nowrap='nowrap'></th>");
            sb.AppendLine("<th nowrap='nowrap' rowspan='2'>ASSESSMENT</th>");
            sb.AppendLine("<th  nowrap='nowrap' rowspan='2'>CLEARED</th>");
            sb.AppendLine("<th  nowrap='nowrap' colspan='2'>PENDING</th>");
            sb.AppendLine("<th  nowrap='nowrap' rowspan='2'>BLOCKED</th>");
            sb.AppendLine("<th  nowrap='nowrap' rowspan='2'>TOTAL</th>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr >");
            sb.AppendLine("<th  nowrap='nowrap'>Last TXN date>=30 Days</th>");
            sb.AppendLine("<th  nowrap='nowrap'>Last TXN date<30 Days</th>");
            sb.AppendLine("</tr>");
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                ++cnt;
                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + dt.Rows[i]["ASSESSMENT"] + "</td>");
                sb.AppendLine("<td class=\"alignRight\">" + dt.Rows[i]["CLEARED"] + "</td>");
                sb.AppendLine("<td class=\"alignRight\">" + dt.Rows[i]["PENDING_GE_30"] + "</td>");
                sb.AppendLine("<td class=\"alignRight\">" + dt.Rows[i]["PENDING_L_30"] + "</td>");
                sb.AppendLine("<td class=\"alignRight\">" + dt.Rows[i]["BLOCKED"] + "</td>");
                sb.AppendLine("<td class=\"alignRight\">" + dt.Rows[i]["TOTAL"] + "</td>");
                sb.AppendLine("</tr>");
            }
            sb.AppendLine("</table>");
            rpt_grid.InnerHtml = sb.ToString();
        }

        private void ShowChart()
        {
            var rptdrildown = GetStatic.ReadQueryString("q", "");
            rptdrildown = rptdrildown.ToLower();

            if (rptdrildown == "high" || rptdrildown == "medium" || rptdrildown == "low")
            {

                var ds = obj.RBAStatisticRptDl(GetStatic.GetUser(), rptdrildown);
                var dt = ds.Tables[0];
                var dt1 = ds.Tables[1];
                pieValueSc = "";
                pieValue = "";
                if (dt.Rows.Count > 0)
                {
                    legend = "RBA - NATIVE COUNTRY WISE " + rptdrildown.ToUpper() + "<br> RISK CUSTOMER EVALUATION";
                    hoverText = "RBA - NATIVE COUNTRY WISE";

                    foreach (DataRow dr in dt.Rows)
                    {
                        pieValue += "{ name: '" + dr["country"].ToString() + "', y: " + dr["percent"].ToString() + " },";
                    }
                }

                if (dt1.Rows.Count > 0)
                {
                    level = "RBA - SENDING IVE COUNTRY WISE " + rptdrildown.ToUpper() + "<br> RISK CUSTOMER EVALUATION";
                    foreach (DataRow dr in dt1.Rows)
                    {
                        pieValueSc += "{ name: '" + dr["country"].ToString() + "', y: " + dr["percent"].ToString() + " },";
                    }
                    sCountryWise.Visible = true;
                }

            }
            else
            {
                legend = "RBA - Overall Customer Evaluation";
                hoverText = "RBA Customer Evaluation";
                var dt = obj.RBAStatisticRpt(GetStatic.GetUser());
                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    pieValue = "{ name: 'HIGH', color: '#e32636', y: " + dr[0] + ", url: 'RBACustomerList.aspx?q=high' },";
                    pieValue += "{ name: 'MEDIUM', color: '#ff9966', y: " + dr[1] + ", url: 'RBACustomerList.aspx?q=medium' },";
                    pieValue += "{ name: 'LOW', color: '#008000', y: " + dr[2] + ", url: 'RBACustomerList.aspx?q=low' }";
                }
            }
        }


    }
}