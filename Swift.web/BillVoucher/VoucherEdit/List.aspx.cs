using Swift.DAL.VoucherReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.BillVoucher.VoucherEdit
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20150100";
        private const string ChangeDateFunctionId = "20150040";
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

                transactionDate.Attributes.Add("readonly", "readonly");
                //transactionDate.ReadOnly = true;
                PopulateDDL();
            }
            divuploadMsg.Visible = false;
        }

        private void PopulateDDL()
        {
            _sdd.SetDDL(ref TypeDDL, "EXEC Proc_dropdown_remit @FLAG='voucherDDL'", "value", "functionName", "", "");
            _sdd.SetDDL(ref FCY, "EXEC Proc_dropdown_remit @FLAG='Currency'", "val", "Name", "", "FCY");
            _sdd.SetDDL(ref Department, "EXEC Proc_dropdown_remit @FLAG='Department'", "RowId", "DepartmentName", "", "Select Department");
            _sdd.SetDDL(ref Branch, "EXEC Proc_dropdown_remit @FLAG='Branch'", "agentId", "agentName", "", "Select Branch");
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        protected bool AllowChangeDate()
        {
            return _sdd.HasRight(ChangeDateFunctionId);
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
            if (string.IsNullOrWhiteSpace(VoucherNumber.Text) || string.IsNullOrWhiteSpace(TypeDDL.Text))
            {
                GetStatic.AlertMessage(this, "Voucher No is not found,please refresh the page and try again!");
                return;
            }
            var result = _vrd.InsertTempVoucherEntry(GetStatic.GetSessionId(), GetStatic.GetUser(), acInfo.Value, dropDownDrCr.Text, amt.Text, Department.Text, Branch.Text
                , EmpName.Text, Field1.Text, "", FCY.Text, FCYAmt.Text, Rate.Text, VoucherNumber.Text, TypeDDL.Text);
            if (result.ErrorCode == "1")
            {
                GetStatic.AlertMessage(this, result.Msg);
            }
            else
            {
                ShowTempVoucher("S");
            }
        }

        private void ShowTempVoucher(string flag)
        {
            //show data on div
            int sno = 0, drCount = 0, crCount = 0;
            double drTotal = 0, crTotal = 0;
            var dt = _vrd.GetEditVoucherData(VoucherNumber.Text, TypeDDL.Text, GetStatic.GetSessionId(), flag);
            var sb = new StringBuilder("");
            sb.AppendLine("<div class=\"table-responsive\">");
            sb.AppendLine("<table class=\"table table-bordered\">");
            sb.AppendLine("<tr >");
            sb.AppendLine("<th >S. No</th>");
            sb.AppendLine("<th >AC information</th>");
            sb.AppendLine("<th >FCY</th>");
            sb.AppendLine("<th >FCY Amount</th>");
            sb.AppendLine("<th >Rate</th>");
            sb.AppendLine("<th >Department</th>");
            sb.AppendLine("<th >Branch</th>");
            sb.AppendLine("<th >EmployeeName</th>");
            sb.AppendLine("<th >Type</th>");
            sb.AppendLine("<th>JPY Amount</th>");
            sb.AppendLine("<th>Select</th>");
            sb.AppendLine("</tr>");
            if (dt == null || dt.Rows.Count == 0)
            {
                sb.AppendLine("<tr><td colspan='11' align='center'>No transaction found!</td></tr></table></div>");
                rpt_tempVoucherTrans.InnerHtml = sb.ToString();
                return;
            }

            if (dt.Columns[0].ToString().ToLower() == "errorcode")
            {
                sb.AppendLine("<tr><td colspan='11' align='center'>" + dt.Rows[0][1].ToString() + "</td></tr></table></div>");
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

                sb.AppendLine("<td nowrap='nowrap' width='5%'>" + sno.ToString() + " </td>");
                sb.AppendLine("<td nowrap='nowrap' width='40%'> " + item["acct_num"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' width='5%'> " + item["trn_currency"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' width='10%' align='right'> " + GetStatic.ShowDecimal(item["usd_amt"].ToString()) + "</td>");
                sb.AppendLine("<td nowrap='nowrap' width='10%' align='right'> " + item["ex_rate"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' width='20%'> " + item["DepartmentName"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' width='20%'> " + item["agentName"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' width='20%'> " + item["emp_name"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' width='5%'>" + item["part_tran_type"].ToString() + " </td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'  width='15%'> <div align='right' style='font-size:12px !important'> " + GetStatic.ShowDecimal(item["tran_amt"].ToString()) + "</div> </td>");
                sb.AppendLine("<td nowrap='nowrap' width='5%'><div align='center'><span class=\"action-icon\"><a class=\"btn btn-xs btn-primary\" title=\"Delete\" data-placement=\"top\" data-toggle=\"tooltip\" href=\"#\" data-original-title=\"Delete\" style='text-decoration:none;' onclick='deleteRecord(" + item["tran_id"].ToString() + ")'><i class=\"fa fa-trash-o\"></i></a></span></div></td>");
                sb.AppendLine("</tr>");
                transactionDate.Text = item["tran_date"].ToString();
                narrationField.Text = item["tran_particular"].ToString();
            }
            sb.AppendLine("<tr>");
            sb.AppendLine("<td nowrap='nowrap' align='right' colspan='10' > <div align='right' style='font-size:12px !important'><strong>Total Dr</strong><span style=' text-align:right; font-weight: bold;' > (" + drCount.ToString() + "): &nbsp; &nbsp;" + GetStatic.ShowDecimal(drTotal.ToString()) + "</span></div> </td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td nowrap='nowrap' align='right' colspan='10' > <div align='right' style='font-size:12px !important'><strong>Total Cr</strong><span style=' text-align:right; font-weight: bold;' > (" + crCount.ToString() + "): &nbsp; &nbsp;" + GetStatic.ShowDecimal(crTotal.ToString()) + "</span></div> </td>");
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
            ShowTempVoucher("s");
        }

        protected void btnUnSave_Click(object sender, EventArgs e)
        {
            ShowTempVoucher("S");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string date = transactionDate.Text;
            var res = _vrd.finalSaveEditVoucher(GetStatic.GetSessionId(), GetStatic.GetUser(), date, VoucherNumber.Text, TypeDDL.Text, narrationField.Text, chequeNo.Text);
            if (res.ErrorCode == "0")
            {
                chequeNo.Text = "";
                narrationField.Text = "";
                vNum.InnerHtml = res.Msg;
                //rpt_tempVoucherTrans.InnerHtml = res.Msg;
                ClearData();
            }
            else
            {
                GetStatic.AlertMessage(this, res.Msg);
            }
        }

        private void ClearData()
        {
            BtnSearch.Enabled = true;
            VoucherNumber.Enabled = true;
            TypeDDL.Enabled = true;
            editDiv.Visible = false;
        }

        public static string GetTimestamp(DateTime value)
        {
            return value.ToString("yyyyMMddHHmmssffff");
        }

        protected void BtnSearch_Click(object sender, EventArgs e)
        {
            DisableControls();
            ShowTempVoucher("sv");
        }

        private void DisableControls()
        {
            BtnSearch.Enabled = false;
            VoucherNumber.Enabled = false;
            TypeDDL.Enabled = false;
            editDiv.Visible = true;
        }
    }
}