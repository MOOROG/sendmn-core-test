using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentNew.SOA
{
    public partial class Manage : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();
        private const string ViewFunctionId = "40121100";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                DivRptHead.Visible = false;
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected void BtnSave_Click(object sender, EventArgs e)
        {
            DivFrm.Visible = false;
            DivRptHead.Visible = true;

            DataTable Dt = new TranAgentReportDao().AgentSoaReportAgentNew(fromDate.Text, toDate.Text, GetStatic.GetAgent(), GetStatic.GetBranch(), GetStatic.GetUser());
            LoadSoaHtml(Dt);

            lblFrmDate.Text = fromDate.Text;
            lbltoDate.Text = toDate.Text;
            lblAgentName.Text = GetStatic.GetAgentName() + " - " + GetStatic.GetBranchName();

            lblGeneratedDate.Text = DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss");
            lblGeneratedBy.Text = GetStatic.GetUser();

            //Need to pickup from agent Master settlement currecny
            string agentCurr = new TranAgentReportDao().AgentCurrency(GetStatic.GetAgent());

            lblCurr.Text = agentCurr;
        }

        private void LoadSoaHtml(DataTable dt)
        {
            int cols = dt.Columns.Count;
            var str = new StringBuilder("<table class='table table-responsive table-condensed table-bordered'>");

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

            if (dt.Rows.Count == 0)
            {
                str.Append("<tr><td colspan='4'><b>No Record Found Or your have selected Invalid Search Criteria</td></tr></table>");
                rptDiv.InnerHtml = str.ToString();
                return;
            }

            OPBal = double.Parse(dt.Rows[0]["DR"].ToString());
            //BAL = OPBal;

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
                else
                {
                    BAL = OPBal;
                }
            }

            str.Append("<tr>");
            str.Append("<td  colspan='2'><div align=\"right\"><b>Total</b> </div></td>");
            str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(DR.ToString()) + "</b></div></td>");
            str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(CR.ToString()) + "</b></div></td>");
            str.Append("<td colspan=\"2\"></td>");
            str.Append("</tr>");
            str.Append("</table>");

            rptDiv.InnerHtml = str.ToString();

            lblOpSing.Text = (OPBal < 0) ? "DR" : "CR";
            lblOpAmt.Text = GetStatic.ShowDecimal(Math.Abs(OPBal).ToString());

            if (BAL == 0)
            {
                lblCloAmt.Text = GetStatic.ShowDecimal(Math.Abs(OPBal).ToString());
                lblCloSign.Text = (OPBal < 0) ? "DR" : "CR";
            }
            else
            {
                lblCloAmt.Text = GetStatic.ShowDecimal(Math.Abs(BAL).ToString());
                lblCloSign.Text = (BAL < 0) ? "DR" : "CR";
            }
            lblDrTotal.Text = GetStatic.ShowDecimal(DR.ToString());
            lblCrTotal.Text = GetStatic.ShowDecimal(CR.ToString());
            lblAmtMsg.Text = (BAL > 0) ? "Receivable From Agent" : "Payable to Agent";
            //lblAmtMsg.Text = (BAL > 0) ? "Payable to Agent" : "Receivable From Agent";
        }
    }
}