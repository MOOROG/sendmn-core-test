using Swift.DAL.VoucherReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.BillVoucher.VoucherEntry
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20150000,20150010,20150020,20150030";
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
                Misc.MakeAmountTextBox(ref amt);
                transactionDate.Text = DateTime.Today.ToString("d");
                transactionDate.Attributes.Add("readonly", "readonly");
                //transactionDate.ReadOnly = true;
                PopulateDDL();
            }
        }

        private void PopulateDDL()
        {
            _sdd.SetDDL(ref voucherType, "EXEC Proc_dropdown_remit @FLAG='voucherDDL'", "value", "functionName", "", "");
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
            if (GetStatic.ParseDouble(amt.Text) <= 0)
            {
                GetStatic.AlertMessage(this, "Please enter valid Amount! ");
                amt.Text = " ";
                amt.Focus();
                return;
            }

            //var result = _vrd.InsertTempVoucherEntry(GetStatic.GetSessionId(),GetStatic.GetUser(),acInfo.Value,dropDownDrCr.Text,amt.Text);
            //if (result.ErrorCode == "1")
            //{
            //    GetStatic.AlertMessage(this, result.Msg);
            //}
            //else
            //{
            //    ShowTempVoucher();
            //}
        }

        private void ShowTempVoucher()
        {
            //show data on div
            int sno = 0, drCount = 0, crCount = 0;
            double drTotal = 0, crTotal = 0;
            var dt = _vrd.GetTempVoucherEntryData(GetStatic.GetSessionId());
            var sb = new StringBuilder("");
            sb.AppendLine("<div class=\"table-responsive\">");
            sb.AppendLine("<table class=\"table table-bordered\">");
            sb.AppendLine("<tr >");
            sb.AppendLine("<th >S. No</th>");
            sb.AppendLine("<th >AC information</th>");
            sb.AppendLine("<th >Type</th>");
            sb.AppendLine("<th>Amount</th>");
            sb.AppendLine("<th>Select</th>");
            sb.AppendLine("</tr>");
            if (dt == null || dt.Rows.Count == 0)
            {
                sb.AppendLine("<tr><td colspan='5' align='center'>No transaction found!</td></tr></table></div>");
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
            var res = _vrd.DeleteRecordVoucherEntry(hdnRowId.Value);
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
            var res = _vrd.SaveTempTransaction(GetStatic.GetSessionId(), date, narrationField.Text, voucherType.SelectedValue, chequeNo.Text, GetStatic.GetUser(), "");
            if (res.ErrorCode == "0")
            {
                chequeNo.Text = "";
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