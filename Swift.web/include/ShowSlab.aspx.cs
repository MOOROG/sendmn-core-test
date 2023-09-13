using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Include
{
    public partial class ShowSlab : System.Web.UI.Page
    {
        private string master = GetStatic.ReadQueryString("master", "");
        private string masterId = GetStatic.ReadQueryString("masterId", "0");
        private string detail = GetStatic.ReadQueryString("detail", "");
        private RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (master == "scMaster")
                LoadDomesticCommissionSlab();
            else
                LoadIntlCommissionSlab();
        }

        private void LoadIntlCommissionSlab()
        {
            var dao = new RemittanceDao();
            var sql = "EXEC proc_" + detail + " @flag = 's', @" + master + "Id = " + sl.FilterString(masterId);
            sql += ", @user = " + sl.FilterString(GetStatic.GetUser());
            sql += ", @pageNumber = '1', @pageSize='100', @sortBy='" + detail + "Id', @sortOrder='ASC'";
            var ds = dao.ExecuteDataset(sql);
            var dt = ds.Tables[1];

            if (dt == null || dt.Rows.Count == 0)
            {
                Response.Write("Not Available");
                return;
            }

            var html = new StringBuilder();
            html.AppendLine(
                "<table  class=\"table table-responsive table-bordered \"  align=\"left\">");
            html.AppendLine("<tr>");
            html.AppendLine("<th>Amount From</th>");
            html.AppendLine("<th>Amount To</th>");
            html.AppendLine("<th>Percent</th>");
            html.AppendLine("<th>Min</th>");
            html.AppendLine("<th>Max</th>");
            html.AppendLine("</tr>");
            foreach (DataRow dr in dt.Rows)
            {
                html.AppendLine("<tr>");
                html.AppendLine("<td align=\"right\">" + GetStatic.FormatData(dr["fromAmt"].ToString(), "M") + "</td>");
                html.AppendLine("<td align=\"right\">" + GetStatic.FormatData(dr["toAmt"].ToString(), "M") + "</td>");
                html.AppendLine("<td align=\"right\">" + GetStatic.FormatData(dr["pcnt"].ToString(), "M") + "</td>");
                html.AppendLine("<td align=\"right\">" + GetStatic.FormatData(dr["minAmt"].ToString(), "M") + "</td>");
                html.AppendLine("<td align=\"right\">" + GetStatic.FormatData(dr["maxAmt"].ToString(), "M") + "</td>");
                html.AppendLine("</tr>");
            }
            html.AppendLine("</table>");
            Response.Write(html.ToString());
        }

        private void LoadDomesticCommissionSlab()
        {
            var dao = new RemittanceDao();
            var sql = "EXEC proc_" + detail + " @flag = 's', @" + master + "Id = " + sl.FilterString(masterId);
            sql += ", @user = " + sl.FilterString(GetStatic.GetUser());
            sql += ", @pageNumber = '1', @pageSize='100', @sortBy='" + detail + "Id', @sortOrder='ASC'";
            var ds = dao.ExecuteDataset(sql);
            var dt = ds.Tables[1];

            if (dt == null || dt.Rows.Count == 0)
            {
                Response.Write("Not Available");
                return;
            }

            var html = new StringBuilder();
            html.Append("<table  class=\"table table-responsive table-bordered \"  align=\"left\">");
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
                html.Append("<td class=\"alignRight\">" + dr["serviceChargePcnt"] + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["serviceChargeMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["serviceChargeMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + dr["sAgentCommPcnt"] + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["sAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["sAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + dr["ssAgentCommPcnt"] + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["ssAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["ssAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + dr["pAgentCommPcnt"] + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["pAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["pAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + dr["psAgentCommPcnt"] + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["psAgentCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["psAgentCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + dr["bankCommPcnt"] + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["bankCommMinAmt"].ToString(), "M") + "</td>");
                html.Append("<td class=\"alignRight\">" + GetStatic.FormatData(dr["bankCommMaxAmt"].ToString(), "M") + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table>");
            Response.Write(html.ToString());
        }
    }
}