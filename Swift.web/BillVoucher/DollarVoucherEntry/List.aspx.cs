using Swift.DAL.VoucherReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.BillVoucher.DollarVoucherEntry
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20150080";
        private const string DateFunctionId = "20150040";
        private readonly RemittanceLibrary _sdd = new RemittanceLibrary();
        private readonly VoucherReportDAO _vrd = new VoucherReportDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sdd.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                AllowChangeDate();
                Misc.MakeAmountTextBox(ref usdAmt);
                Misc.MakeAmountTextBox(ref rate);
                Misc.MakeAmountTextBox(ref lcAmt);
                transactionDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                transactionDate.Attributes.Add("readonly", "readonly");
                lcAmt.Attributes.Add("readonly", "readonly");
                //transactionDate.ReadOnly = true;
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        protected bool AllowChangeDate()
        {
            return _sdd.HasRight(DateFunctionId);
        }

        protected void addBtn_Click(object sender, EventArgs e)
        {
            if (GetStatic.ParseDouble(usdAmt.Text) <= 0)
            {
                GetStatic.AlertMessage(this, "Please enter valid Amount! ");
                usdAmt.Text = " ";
                usdAmt.Focus();
                return;
            }

            var result = _vrd.InsertTempVoucherEntryUSD(GetStatic.GetSessionId(), GetStatic.GetUser(), acInfo.Value, trantype.SelectedValue,
                usdAmt.Text, rate.Text, lcAmt.Text);
            if (result.ErrorCode == "1")
            {
                GetStatic.AlertMessage(this, result.Msg);
            }
            else
            {
                ShowTempVoucher();
            }
        }

        private void ShowTempVoucher()
        {
            //show data on div
            int sno = 0, drCount = 0, crCount = 0;
            double drTotal = 0, crTotal = 0;
            var dt = _vrd.GetTempVoucherEntryDataFRV(GetStatic.GetSessionId());
            var sb = new StringBuilder("");
            sb.AppendLine("<div class=\"table-responsive\">");
            sb.AppendLine("<table class=\"table table-bordered\">");
            sb.AppendLine("<tr >");
            sb.AppendLine("<th >S. No</th>");
            sb.AppendLine("<th >AC information</th>");
            sb.AppendLine("<th >Type</th>");
            sb.AppendLine("<th>(USD) Amount</th>");
            sb.AppendLine("<th>Ex. Rate</th>");
            sb.AppendLine("<th>LC Amt</th>");
            sb.AppendLine("<th>Select</th>");
            sb.AppendLine("</tr>");
            if (dt == null || dt.Rows.Count == 0)
            {
                sb.AppendLine("<tr><td colspan='7' align='center'>No transaction found!</td></tr></table></div>");
                rpt_tempVoucherTrans.InnerHtml = sb.ToString();
                return;
            }

            foreach (DataRow item in dt.Rows)
            {
                sno++;
                if (item["part_tran_type"].ToString().ToLower() == "dr")
                {
                    drCount++;
                    drTotal = drTotal + Convert.ToDouble(item["tran_amt"]);
                }
                else if (item["part_tran_type"].ToString().ToLower() == "cr")
                {
                    crCount++;
                    crTotal = crTotal + Convert.ToDouble(item["tran_amt"]);
                }

                sb.AppendLine("<tr>");

                sb.AppendLine("<td nowrap='nowrap' width='10%'>" + sno.ToString() + " </td>");
                sb.AppendLine("<td nowrap='nowrap' width='50%'> " + item["acct_num"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' width='5%'>" + item["part_tran_type"].ToString() + " </td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'  width='25%'> <div align='right' style='font-size:12px !important'> " + GetStatic.ShowDecimal(item["tran_amt"].ToString()) + "</div> </td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'  width='25%'> <div align='right' style='font-size:12px !important'> " + GetStatic.ShowDecimal(item["usd_rate"].ToString()) + "</div> </td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'  width='25%'> <div align='right' style='font-size:12px !important'> " + GetStatic.ShowDecimal(item["lc_amt_cr"].ToString()) + "</div> </td>");
                sb.AppendLine("<td nowrap='nowrap' width='5%'><div align='center'><span class=\"action-icon\"><a class=\"btn btn-xs btn-primary\" title=\"Delete\" data-placement=\"top\" data-toggle=\"tooltip\" href=\"#\" data-original-title=\"Delete\" style='text-decoration:none;' onclick='deleteRecord(" + item["tran_id"].ToString() + ")'><i class=\"fa fa-trash-o\"></i></a></span></div></td>");
                sb.AppendLine("</tr>");
            }
            sb.AppendLine("<tr>");
            sb.AppendLine("<td nowrap='nowrap' align='right' colspan='4' > <div align='right' style='font-size:12px !important'><strong>Total Dr</strong><span style=' text-align:right; font-weight: bold;' > (" + drCount.ToString() + "): &nbsp; &nbsp;" + GetStatic.ShowDecimal(drTotal.ToString()) + "</span></div> </td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td nowrap='nowrap' align='right' colspan='4' > <div align='right' style='font-size:12px !important'><strong>Total Cr</strong><span style=' text-align:right; font-weight: bold;' > (" + crCount.ToString() + "): &nbsp; &nbsp;" + GetStatic.ShowDecimal(crTotal.ToString()) + "</span></div> </td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</div>");
            rpt_tempVoucherTrans.InnerHtml = sb.ToString();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            var res = _vrd.DeleteRecordVoucherEntryFRV(hdnRowId.Value);
            if (res.ErrorCode == "0")
            {
                GetStatic.AlertMessage(this, res.Msg);
            }
            ShowTempVoucher();
        }

        protected void btnUnSave_Click(object sender, EventArgs e)
        {
            ShowTempVoucher();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string date = transactionDate.Text;
            var res = _vrd.SaveTempTransactionUSD(GetStatic.GetSessionId(), date, narrationField.Text, chequeNumber.Text, "J", GetStatic.GetUser(), "");
            if (res.ErrorCode == "0")
            {
                narrationField.Text = "";
                rpt_tempVoucherTrans.InnerHtml = res.Msg;
            }
            else
            {
                GetStatic.AlertMessage(this, res.Msg);
            }
        }
    }
}