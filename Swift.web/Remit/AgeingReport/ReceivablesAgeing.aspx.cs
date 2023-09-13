using Swift.DAL.Remittance.Partner;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.AgeingReport
{
    public partial class ReceivablesAgeing : System.Web.UI.Page
    {
        protected PartnerDao _dao = new PartnerDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateReport();
            }
        }

        private void PopulateReport()
        {
            string asOnDate = GetStatic.ReadQueryString("asOnDate", "");

            DataSet ds = _dao.GetAgentAgeingReport(GetStatic.GetUser(), asOnDate);

            if (ds == null)
            {
                return;
            }

            DataTable drTbl = ds.Tables[1];
            DataTable crTbl = ds.Tables[0];

            int sNo = 0;
            string accNum = "";
            double belowFourDaysTotal = 0;
            double overFourDaysTotal = 0;
            double overOneMonthTotal = 0;
            double overThreeMonthTotal = 0;
            double overSixMonthTotal = 0;
            double outStandingTotal = 0;
            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in drTbl.Rows)
            {
                sNo++;
                accNum = item["ACCOUNT_NUMBER"].ToString();
                DataRow[] rows = crTbl.Select("ACC_NUM = ('" + accNum + "')");
                double[] amt = GetAmountArray(item, GetDoubleValue(rows[0][0].ToString()));
                if (amt[0] != 0)
                {
                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td>" + sNo.ToString() + "</td>");
                    sb.AppendLine("<td>" + item["AGENT_NAME"].ToString() + "</td>");
                    sb.AppendLine("<td align='right'>" + GetStatic.GetNegativeFigureOnBrac((amt[0]).ToString()) + "</td>");
                    sb.AppendLine("<td align='right'>" + GetStatic.GetNegativeFigureOnBrac((amt[1]).ToString()) + "</td>");
                    sb.AppendLine("<td align='right'>" + GetStatic.GetNegativeFigureOnBrac((amt[2]).ToString()) + "</td>");
                    sb.AppendLine("<td align='right'>" + GetStatic.GetNegativeFigureOnBrac((amt[3]).ToString()) + "</td>");
                    sb.AppendLine("<td align='right'>" + GetStatic.GetNegativeFigureOnBrac((amt[4]).ToString()) + "</td>");
                    sb.AppendLine("<td align='right'>" + GetStatic.GetNegativeFigureOnBrac((amt[5]).ToString()) + "</td>");
                    sb.AppendLine("</tr>");

                    outStandingTotal += (amt[0]);
                    belowFourDaysTotal += (amt[1]);
                    overFourDaysTotal += (amt[2]);
                    overOneMonthTotal += (amt[3]);
                    overThreeMonthTotal += (amt[4]);
                    overSixMonthTotal += (amt[5]);
                }
            }
            sb.AppendLine("<tr>");
            sb.AppendLine("<td align='right' colspan='2'><b>Grand Total</b></td>");
            sb.AppendLine("<td align='right'><b>" + GetStatic.GetNegativeFigureOnBrac(outStandingTotal.ToString()) + "</b></td>");
            sb.AppendLine("<td align='right'><b>" + GetStatic.GetNegativeFigureOnBrac(belowFourDaysTotal.ToString()) + "</b></td>");
            sb.AppendLine("<td align='right'><b>" + GetStatic.GetNegativeFigureOnBrac(overFourDaysTotal.ToString()) + "</b></td>");
            sb.AppendLine("<td align='right'><b>" + GetStatic.GetNegativeFigureOnBrac(overOneMonthTotal.ToString()) + "</b></td>");
            sb.AppendLine("<td align='right'><b>" + GetStatic.GetNegativeFigureOnBrac(overThreeMonthTotal.ToString()) + "</b></td>");
            sb.AppendLine("<td align='right'><b>" + GetStatic.GetNegativeFigureOnBrac(overSixMonthTotal.ToString()) + "</b></td>");
            sb.AppendLine("</tr>");
            ageingRptBody.InnerHtml = sb.ToString();
        }

        private double[] GetAmountArray(DataRow item, double crAmount)
        {
            double[] amt = new double[6];

            amt[0] = GetDoubleValue(item["TOTAL_OUT_STANDING"].ToString()) - crAmount;
            if (GetDoubleValue(item["OVER_SIX_MONTH"].ToString()) < crAmount)
            {
                crAmount = GetDoubleValue(item["OVER_SIX_MONTH"].ToString()) - crAmount;
                if (crAmount < 0)
                {
                    amt[5] = 0;
                    crAmount = GetDoubleValue(item["OVER_THREE_MONTH"].ToString()) + crAmount;
                    if (crAmount < 0)
                    {
                        amt[4] = 0;
                        crAmount = GetDoubleValue(item["OVER_ONE_MONTH"].ToString()) + crAmount;
                        if (crAmount < 0)
                        {
                            amt[3] = 0;
                            crAmount = GetDoubleValue(item["OVER_FOUR_DAYS"].ToString()) + crAmount;
                            if (crAmount < 0)
                            {
                                amt[2] = 0;
                                amt[1] = GetDoubleValue(item["BELOW_FOUR_DAYS"].ToString()) + crAmount;
                            }
                            else
                            {
                                amt[2] = crAmount;
                                amt[1] = GetDoubleValue(item["BELOW_FOUR_DAYS"].ToString());
                            }
                        }
                        else
                        {
                            amt[3] = crAmount;
                            amt[2] = GetDoubleValue(item["OVER_FOUR_DAYS"].ToString());
                            amt[1] = GetDoubleValue(item["BELOW_FOUR_DAYS"].ToString());
                        }

                    }
                    else
                    {
                        amt[4] = crAmount;
                        amt[3] = GetDoubleValue(item["OVER_ONE_MONTH"].ToString());
                        amt[2] = GetDoubleValue(item["OVER_FOUR_DAYS"].ToString());
                        amt[1] = GetDoubleValue(item["BELOW_FOUR_DAYS"].ToString());
                    }
                }
                else
                {
                    amt[4] = crAmount;
                    amt[3] = GetDoubleValue(item["OVER_THREE_MONTH"].ToString());
                    amt[2] = GetDoubleValue(item["OVER_ONE_MONTH"].ToString());
                    amt[2] = GetDoubleValue(item["OVER_FOUR_DAYS"].ToString());
                    amt[1] = GetDoubleValue(item["BELOW_FOUR_DAYS"].ToString());
                }
            }
            else
            {
                amt[5] = GetDoubleValue(item["OVER_SIX_MONTH"].ToString()) - crAmount;
                amt[4] = GetDoubleValue(item["OVER_THREE_MONTH"].ToString());
                amt[3] = GetDoubleValue(item["OVER_ONE_MONTH"].ToString());
                amt[2] = GetDoubleValue(item["OVER_FOUR_DAYS"].ToString());
                amt[1] = GetDoubleValue(item["BELOW_FOUR_DAYS"].ToString());
            }

            return amt;
        }

        public double GetDoubleValue(string inPutVal)
        {
            double outPut = 0;
            Double.TryParse(inPutVal, out outPut);
            return outPut;
        }
    }
}