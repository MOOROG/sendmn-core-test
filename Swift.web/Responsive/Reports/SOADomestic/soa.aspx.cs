using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Responsive.Reports.SOADomestic
{
    public partial class soa : System.Web.UI.Page
    {
        private readonly TranReportDao rptDao = new TranReportDao();
        private readonly RemittanceLibrary rl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            rl.CheckSession();
            string mode = GetStatic.ReadQueryString("mode", "").ToLower();
            if (mode == "download")
            {
                string format = "xls";
                string reportName = "soa";
                Response.Clear();
                Response.ClearContent();
                Response.ClearHeaders();
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("Content-Disposition", "attachment; filename=" + reportName + "." + format);
                exportDiv.Visible = false;
            }
            ShowReport();
        }

        private void ShowReport()
        {
            var fromDate = GetStatic.ReadQueryString("fromDate", "");
            var toDate = GetStatic.ReadQueryString("toDate", "");
            var agent = GetStatic.ReadQueryString("agent", "");
            var reportFor = GetStatic.ReadQueryString("reportFor", "");
            var branchID = GetStatic.GetBranch();
            DataTable Dt = rptDao.AgentSoaReport(fromDate, toDate, agent, "pay", reportFor, branchID);
            LoadSoaHtml(Dt);
            lblAgentName.Text = GetStatic.GetAgentNameByMapCodeInt(agent);
            lblFrmDate.Text = fromDate;
            lbltoDate.Text = toDate;
            lblGeneratedDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
        }

        private void LoadSoaHtml(DataTable dt)
        {
            int cols = dt.Columns.Count;
            var str = new StringBuilder("<table class='TBLReport table table-condensed table-bordered table-striped'>");

            str.Append("<tr>");
            str.Append("<th><div align=\"left\">Date</div></th>");
            str.Append("<th><div align=\"left\">Particulars</div></th>");
            str.Append("<th><div align=\"left\">DR</div></th>");
            str.Append("<th><div align=\"left\">CR</div></th>");
            str.Append("<th><div align=\"left\">Balance</div></th>");
            str.Append("<th><div align=\"left\">&nbsp;</div></th>");
            str.Append("</tr>");

            int cnt = 0;
            double DR = 0.00;
            double CR = 0.00;
            double BAL = 0.00;
            double OPBal = 0.00;
            double CrTotal = 0.00;
            double DrTotal = 0.00;
            double GTotal = -0.00;

            string DrCr = "";
            int rowsCount = dt.Rows.Count;
            if (rowsCount == 0)
            {
                str.Append("<tr><td colspan='4'><b>No Record Found</td></tr></table>");
                rptDiv.InnerHtml = str.ToString();
                return;
            }

            OPBal = double.Parse(dt.Rows[0]["DR"].ToString());

            DrCr = (OPBal < 0) ? "DR" : "CR";

            str.Append("<tr>");
            str.Append("<td><div align=\"left\"></div></td>");
            str.Append("<td><div align=\"left\">Opening Balance</div></td>");
            str.Append("<td><div align=\"left\"></div></td>");
            str.Append("<td><div align=\"left\"></div></td>");
            str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(Math.Abs(OPBal).ToString()) + "</b></div></td>");
            str.Append("<td>" + DrCr + "</td>");
            str.Append("</tr>");

            foreach (DataRow dr in dt.Rows)
            {
                cnt = cnt + 1;
                BAL = 0;

                if (dr["Particulars"].ToString() != "Opening Balance")
                {
                    str.Append("<tr>");
                    DR = DR + double.Parse(dr["DR"].ToString());
                    CR = CR + double.Parse(dr["CR"].ToString());
                    BAL = BAL + (OPBal - DR + CR);
                    DrCr = (BAL < 0) ? "DR" : "CR";
                    GTotal = GTotal + BAL;
                    if (double.Parse(dr["DR"].ToString()) > 0)
                    {
                        DrTotal = DrTotal + 1;
                    }
                    else
                    {
                        CrTotal = CrTotal + 1;
                    }
                    for (int i = 0; i < cols; i++)
                    {
                        if (i > 1)
                        {
                            str.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr[i].ToString()) +
                                       "</div></td>");
                        }
                        else
                        {
                            str.Append("<td><div align=\"left\">" + dr[i].ToString() + "</div></td>");
                        }
                    }

                    str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(Math.Abs(BAL).ToString()) + "</b></div></td>");
                    str.Append("<td>" + DrCr + "</td>");
                    str.Append("</tr>");
                }
            }

            str.Append("<tr>");
            str.Append("<td  colspan='2'><div align=\"right\"><b>Total</b> </div></td>");
            str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(DR.ToString()) + "</b></div></td>");
            str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(CR.ToString()) + "</b></div></td>");
            str.Append("<td><div align=\"right\"></div></td>");
            str.Append("<td>" + DrCr + "</td>");
            str.Append("</tr>");
            str.Append("</table>");

            rptDiv.InnerHtml = str.ToString();

            lblOpSing.Text = (OPBal < 0) ? "DR" : "CR";
            lblOpAmt.Text = GetStatic.ShowDecimal(Math.Abs(OPBal).ToString());

            if (rowsCount == 1)
            {
                lblCloAmt.Text = GetStatic.ShowDecimal(Math.Abs(OPBal).ToString());
                lblCloSign.Text = (OPBal < 0) ? "DR" : "CR";
            }
            else
            {
                lblCloAmt.Text = GetStatic.ShowDecimal(Math.Abs(BAL).ToString());
                lblCloSign.Text = (BAL < 0) ? "DR" : "CR";
            }

            lblDrTotal.Text = GetStatic.ShowDecimal(Math.Abs(DR).ToString());
            lblCrTotal.Text = GetStatic.ShowDecimal(Math.Abs(CR).ToString());

            lblAmtMsg.Text = (BAL > 0) ? "<i>Payable to Agent</i>" : "<i>Receivable From Agent</i>";
        }
    }
}