using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentNew.SOA
{
    public partial class SOA_DrillDetail : System.Web.UI.Page
    {
        private string flag = "";
        private RemittanceLibrary sl = new RemittanceLibrary();
        private const string ViewFunctionId = "40121100";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            LoadSoaHtml();
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadSoaHtml()
        {
            flag = GetStatic.ReadQueryString("flag", "");

            switch (flag)
            {
                case "SEND_INTL":
                    rptTitle.Text = " >> Send Transaction Detail";
                    break;

                case "CANCEL_INTL":
                    rptTitle.Text = " >> Cancel Transaction Detail";
                    break;

                case "SEND_INTL_COMM":
                    rptTitle.Text = " >> Send Commission Detail";
                    break;

                default:
                    break;
            }

            var fromDate = GetStatic.ReadQueryString("DATE1", "");
            var toDate = GetStatic.ReadQueryString("DATE2", "");
            var agent = GetStatic.ReadQueryString("AGENT", "");
            var branch = GetStatic.ReadQueryString("BRANCH", "");
            var FLAG2 = GetStatic.ReadQueryString("FLAG2", "");

            switch (FLAG2)
            {
                case "SEND_CASH":
                    collMode.Text = "(Cash)";
                    break;

                case "SEND_BANK":
                    collMode.Text = "(Bank)";
                    break;

                default:
                    collMode.Text = "";
                    break;
            }

            lblFrmDate.Text = fromDate;
            lbltoDate.Text = toDate;
            lblGeneratedDate.Text = DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss");
            lblGeneratedBy.Text = GetStatic.GetUser();
            lblAgentName.Text = sl.GetAgentNameByMapCodeInt(agent);

            DataTable dt = new TranAgentReportDao().AgentSoaDrilldownReportNew(fromDate, toDate, agent, flag, branch, FLAG2);

            int cols = dt.Columns.Count;
            var str = new StringBuilder("<table class='table table-responsive table-condensed table-bordered'>");

            str.Append("<tr>");
            str.Append("<th><div align=\"left\">SN</div></th>");
            for (int i = 0; i < cols; i++)
            {
                str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
            }
            str.Append("</tr>");

            int cnt = 0;
            double BAL = 0.00;
            double Comm = 0.00;
            double setUsd = 0.00;
            double fx = 0.00;
            if (dt.Rows.Count == 0)
            {
                str.Append("<tr><td colspan='4'><b>No Record Found</td></tr></table>");
                rptDiv.InnerHtml = str.ToString();
                return;
            }
            if (cols == 10)
            {
                foreach (DataRow dr in dt.Rows)
                {
                    cnt = cnt + 1;
                    str.Append("<tr>");
                    str.Append("<td>" + cnt + "</td>");
                    for (int i = 0; i < cols; i++)
                    {
                        if (i == 5)
                        {
                            BAL = BAL + double.Parse(dr[i].ToString());
                            str.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</div></td>");
                        }
                        else if (i == 6)
                        {
                            Comm = Comm + double.Parse(dr[i].ToString());
                            str.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</div></td>");
                        }
                        else if (i == 7)
                        {
                            fx = fx + double.Parse(dr[i].ToString());
                            str.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</div></td>");
                        }
                        else if (i == 8)
                        {
                            setUsd = setUsd + double.Parse(dr[i].ToString());
                            str.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</div></td>");
                        }
                        else
                            str.Append("<td><div align=\"left\">" + dr[i] + "</div></td>");
                    }
                    str.Append("</tr>");
                }

                str.Append("<tr>");
                str.Append("<td  colspan='6'><div align=\"right\"><b>Total</b> </div></td>");
                str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(BAL.ToString()) + "</b></div></td>");
                str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(Comm.ToString()) + "</b></div></td>");
                str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(fx.ToString()) + "</b></div></td>");
                str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(setUsd.ToString()) + "</b></div></td>");
                str.Append("<td>&nbsp;</td>");
                str.Append("</tr>");
            }
            else
            {
                foreach (DataRow dr in dt.Rows)
                {
                    cnt = cnt + 1;
                    str.Append("<tr>");
                    str.Append("<td>" + cnt + "</td>");
                    for (int i = 0; i < cols; i++)
                    {
                        if (i == 6)
                        {
                            BAL = BAL + double.Parse(dr[i].ToString());
                            str.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</div></td>");
                        }
                        //else if (i == 7)
                        //{
                        //    Comm = Comm + double.Parse(dr[i].ToString());
                        //    str.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</div></td>");
                        //}
                        //else if (i == 7)
                        //{
                        //    setUsd = setUsd + double.Parse(dr[i].ToString());
                        //    str.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</div></td>");
                        //}
                        else
                            str.Append("<td><div align=\"left\">" + dr[i] + "</div></td>");
                    }
                    str.Append("</tr>");
                }

                str.Append("<tr>");
                str.Append("<td colspan='7'><div align=\"right\"><b>Total</b> </div></td>");
                str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(BAL.ToString()) + "</b></div></td>");
                //str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(Comm.ToString()) + "</b></div></td>");
                str.Append("<td>&nbsp;</td>");
                str.Append("</tr>");
            }
            str.Append("</table>");
            rptDiv.InnerHtml = str.ToString();
        }
    }
}