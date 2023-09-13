using Swift.DAL.Remittance.Partner;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.Transaction.Reports.ReferralReport
{
    public partial class ReferralReportComm : System.Web.UI.Page
    {
        protected PartnerDao _dao = new PartnerDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateReportData();
            }
        }

        private void PopulateReportData()
        {
            string fromDate = GetStatic.ReadQueryString("fromDate", "");
            string toDate = GetStatic.ReadQueryString("toDate", "");
            string referralCode = GetStatic.ReadQueryString("referralCode", "");

            DataTable dt = _dao.GetReferralReport(GetStatic.GetUser(), fromDate, toDate, referralCode);

            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }

            DataView view = new DataView(dt);

            DataTable distinctData = view.ToTable(true, "REFERRAL_NAME", "DATE");

            StringBuilder sb = new StringBuilder();
            double total = 0;
            int sNo = 1;
            double npFx = 0, npComm = 0, tfFX = 0, tfComm = 0, flat = 0, newCust = 0, mainTotal = 0, taxTotal = 0, scTotal = 0;

            foreach (DataRow item in dt.Rows)
            {
                bool isNepal = (item["PARTNER_ID"].ToString() == "393880") ? true : false;

                string REFERRAL_NAME = item["REFERRAL_NAME"].ToString();
                string DATE = item["DATE"].ToString();
                string CONTROLNO = item["CONTROLNO"].ToString();
                string serviceCharge = item["serviceCharge"].ToString();
                total = 0;
                
                sb.AppendLine("<tr>");
                sb.AppendLine("<td> " + sNo + "</td>");
                if (isNepal)
                {
                    sb.AppendLine("<td>" + REFERRAL_NAME + "</td>");
                    sb.AppendLine("<td>" + CONTROLNO + "</td>");
                    sb.AppendLine("<td>" + serviceCharge + "</td>");
                    sb.AppendLine("<td>" + DATE + "</td>");
                    sb.AppendLine("<td>" + item["FX_PCNT"] + "</td>");
                    sb.AppendLine("<td>" + item["PAID_FX"] + "</td>");
                    sb.AppendLine("<td>" + item["COMMISSION_PCNT"] + "</td>");
                    sb.AppendLine("<td>" + item["PAID_COMMISSION"] + "</td>");
                    sb.AppendLine("<td>0</td>");
                    sb.AppendLine("<td>0</td>");
                    sb.AppendLine("<td>0</td>");
                    sb.AppendLine("<td>0</td>");

                    npFx += Convert.ToDouble(item["PAID_FX"]);
                    npComm += Convert.ToDouble(item["PAID_COMMISSION"]);
                }
                else
                {
                    sb.AppendLine("<td>" + REFERRAL_NAME + "</td>");
                    sb.AppendLine("<td>" + CONTROLNO + "</td>");
                    sb.AppendLine("<td>" + serviceCharge + "</td>");
                    sb.AppendLine("<td>" + DATE + "</td>");
                    sb.AppendLine("<td>0</td>");
                    sb.AppendLine("<td>0</td>");
                    sb.AppendLine("<td>0</td>");
                    sb.AppendLine("<td>0</td>");
                    sb.AppendLine("<td>" + item["FX_PCNT"] + "</td>");
                    sb.AppendLine("<td>" + item["PAID_FX"] + "</td>");
                    sb.AppendLine("<td>" + item["COMMISSION_PCNT"] + "</td>");
                    sb.AppendLine("<td>" + item["PAID_COMMISSION"] + "</td>");

                    tfFX += Convert.ToDouble(item["PAID_FX"]);
                    tfComm += Convert.ToDouble(item["PAID_COMMISSION"]);
                }
                sb.AppendLine("<td>" + item["FLAT_RATE"] + "</td>");
                sb.AppendLine("<td>" + item["PAID_FLAT"] + "</td>");
                sb.AppendLine("<td>" + item["PAID_NEW_CUSTOMER_RATE"] + "</td>");
                sb.AppendLine("<td>" + item["PAID_NEW_CUSTOMER"] + "</td>");
                sb.AppendLine("<td>" + Convert.ToDecimal(item["TAX_AMOUNT"]) + "</td>");

                total = Convert.ToDouble(item["PAID_FX"]) + Convert.ToDouble(item["PAID_COMMISSION"]);
                total += Convert.ToDouble(item["PAID_FLAT"]) + Convert.ToDouble(item["PAID_NEW_CUSTOMER"]);


                flat += Convert.ToDouble(item["PAID_FLAT"]);
                newCust += Convert.ToDouble(item["PAID_NEW_CUSTOMER"]);
                taxTotal += Convert.ToDouble(item["TAX_AMOUNT"]);
                scTotal += Convert.ToDouble(serviceCharge);

                mainTotal += total;
                sNo++;
               
                //sb.AppendLine("<td>" + incentive + "</td>");
                sb.AppendLine("<td>" + total + "</td>");
                sb.AppendLine("</tr>");
            }
            sb.Append("<tr>");
            sb.AppendLine("<td colspan='2' style='font-weight: bold;text-align: right;'>Total<td>");
            sb.AppendLine("<td style='font-weight: bold;'>" + scTotal + "</td>");
            sb.AppendLine("<td></td>");
            sb.AppendLine("<td></td>");
            sb.AppendLine("<td style='font-weight: bold;'>" + npFx + "</td>");
            sb.AppendLine("<td></td>");
            sb.AppendLine("<td style='font-weight: bold;'>" + npComm + "</td>");
            sb.AppendLine("<td></td>");
            sb.AppendLine("<td style='font-weight: bold;'>" + tfFX + "</td>");
            sb.AppendLine("<td></td>");
            sb.AppendLine("<td style='font-weight: bold;'>" + tfComm + "</td>");
            sb.AppendLine("<td></td>");
            sb.AppendLine("<td style='font-weight: bold;'>" + flat + "</td>");
            sb.AppendLine("<td></td>");
            sb.AppendLine("<td style='font-weight: bold;'>" + newCust + "</td>");
            sb.AppendLine("<td style='font-weight: bold;'>" + taxTotal + "</td>");
            sb.AppendLine("<td style='font-weight: bold;'>" + mainTotal + "</td>");
            sb.Append("</tr>");
            referralCommTbl.InnerHtml = sb.ToString();
        }

        private void GetHTMLForTable(DataTable dt, string rEFERRAL_NAME, string dATE, string CONTROLNO, ref StringBuilder sb)
        {
            double sumComm = 0;
            double sumFx = 0;
            double sumFlat = 0;
            double sumNewCust = 0;
            double total = 0;
            //int sumTxn = 0;

            sb.AppendLine("<td>" + rEFERRAL_NAME + "</td>");
            sb.AppendLine("<td>" + dATE + " (" + CONTROLNO + ")</td>");

            DataRow[] jmeNepal = dt.Select("PARTNER_ID = '393880' AND REFERRAL_NAME = '" + rEFERRAL_NAME + "' AND DATE = '" + dATE + "'");
            if (jmeNepal.Length > 0)
            {
                foreach (DataRow item in jmeNepal)
                {
                    sumComm += Convert.ToDouble(item["PAID_COMMISSION"]);
                    sumFx += Convert.ToDouble(item["PAID_FX"]);
                    sumFlat += Convert.ToDouble(item["PAID_FLAT"]);
                    sumNewCust += Convert.ToDouble(item["PAID_NEW_CUSTOMER"]);
                    //sumTxn += Convert.ToInt32(item["NO_OF_TXN"]);
                }
                total = sumComm + sumFx;

                sb.AppendLine("<td>" + jmeNepal[0]["COMMISSION_PCNT"] + "</td>");
                sb.AppendLine("<td>" + sumComm + "</td>");
                sb.AppendLine("<td>" + jmeNepal[0]["FX_PCNT"] + "</td>");
                sb.AppendLine("<td>" + sumFx + "</td>");
            }
            else
            {
                sb.AppendLine("<td>0</td>");
                sb.AppendLine("<td>0</td>");
                sb.AppendLine("<td>0</td>");
                sb.AppendLine("<td>0</td>");
            }

            sumComm = 0;
            sumFx = 0;

            DataRow[] tf = dt.Select("PARTNER_ID = '394130' AND REFERRAL_NAME = '" + rEFERRAL_NAME + "' AND DATE = '" + dATE + "'");
            if (tf.Length > 0)
            {
                foreach (DataRow item in tf)
                {
                    sumComm += Convert.ToDouble(item["PAID_COMMISSION"]);
                    sumFx += Convert.ToDouble(item["PAID_FX"]);
                    sumFlat += Convert.ToDouble(item["PAID_FLAT"]);
                    sumNewCust += Convert.ToDouble(item["PAID_NEW_CUSTOMER"]);
                    //sumTxn += Convert.ToInt32(item["NO_OF_TXN"]);
                }
                total += sumFx + sumComm;

                sb.AppendLine("<td>" + tf[0]["COMMISSION_PCNT"] + "</td>");
                sb.AppendLine("<td>" + sumComm + "</td>");
                sb.AppendLine("<td>" + tf[0]["FX_PCNT"] + "</td>");
                sb.AppendLine("<td>" + sumFx + "</td>");
            }
            else
            {
                sb.AppendLine("<td>0</td>");
                sb.AppendLine("<td>0</td>");
                sb.AppendLine("<td>0</td>");
                sb.AppendLine("<td>0</td>");
            }

            sb.AppendLine("<td>" + dt.Rows[0]["FLAT_RATE"] + "</td>");
            sb.AppendLine("<td>" + sumFlat + "</td>");
            sb.AppendLine("<td>" + dt.Rows[0]["PAID_NEW_CUSTOMER_RATE"] + "</td>");
            sb.AppendLine("<td>" + sumNewCust + "</td>");
            //sb.AppendLine("<td><b>" + sumTxn + "</b></td>");
            sb.AppendLine("<td>" + total + sumFlat + sumNewCust + "</td>");
        }
    }
}