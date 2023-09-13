using Swift.DAL.VoucherReport;
using Swift.web.Library;
using System;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;

namespace Swift.web.BillVoucher.VoucherUpload
{
    public partial class Upload : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sdd = new RemittanceLibrary();
        private readonly VoucherReportDAO _vrd = new VoucherReportDAO();
        private const string ViewFunctionId = "20201900";
        protected void Page_Load(object sender, EventArgs e)
        {
            _sdd.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                ShowTempVoucher();
            }
        }
        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }
        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (fileUpload.FileContent.Length > 0)
            {
                if (fileUpload.FileName.ToLower().Contains(".csv"))
                {
                    string path = Server.MapPath("..\\..\\") + "\\doc\\tmp\\" + fileUpload.FileName;
                    fileUpload.SaveAs(path);
                    var xml = GetStatic.GetCSVFileInTable(path, true, 5);

                    string fileName = fileUpload.FileName.ToString();
                    File.Delete(path);
                    var rs = _vrd.InsertTempVoucherEntryFCYFromFileNew(GetStatic.GetSessionId(), GetStatic.GetUser(), xml, fileName);
                    if (rs.ErrorCode == "1")
                    {
                        GetStatic.AlertMessage(this, rs.Msg);
                    }
                    else
                    {
                        ShowTempVoucher();
                    }

                }
                else
                {
                    GetStatic.AlertMessage(this, "Invalid file format uploaded");
                }
            }
            else
            {
                GetStatic.AlertMessage(this, "Choose file first");
            }
        }

        private void ShowTempVoucher()
        {
            //show data on div
            int sno = 0;

            var dt = _vrd.GetTempVoucherEntryDataNew(GetStatic.GetSessionId());

            StringBuilder sb = new StringBuilder();
            if (dt == null || dt.Rows.Count == 0)
            {
                tblBody.InnerHtml = "<tr><td colspan='7'>No data to view</td></tr>";
                divBtn.Visible = false;
                btnSaveFinal.Enabled = false;
                return;
            }

            divBtn.Visible = true;
            btnSaveFinal.Enabled = true;

            int forColor = 0;
            string color = "";
            int len = dt.Rows.Count;
            for (int i = 0; i < dt.Rows.Count; i += 2)
            {
                forColor++;
                sno++;
                color = "#F5F5E8";
                if (forColor % 2 != 0)
                {
                    color = "#EEEEEE";
                }

                sb.AppendLine("<tr style=\"background-color:" + color + " !important;\">");
                //sb.AppendLine("<td><input type='checkbox' name='voucherEntryList' value='" + dt.Rows[i]["ROW_ID"].ToString() + "' checked='true'/></td>");
                sb.AppendLine("<td nowrap='nowrap'>" + sno.ToString() + " </td>");
                sb.AppendLine("<td nowrap='nowrap'> " + dt.Rows[i]["ACCT_NAME"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'> <div align='right' style='font-size:12px !important'> " + GetStatic.ShowDecimal(dt.Rows[i]["AMOUNT"].ToString()) + "</div> </td>");
                sb.AppendLine("<td nowrap='nowrap'>" + dt.Rows[i]["TRAN_DATE"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap'>" + dt.Rows[i]["TRAN_TYPE"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap'>" + dt.Rows[i]["field2"].ToString() + "</div></td>");
                sb.AppendLine("<td nowrap='nowrap' rowspan='2'>" + dt.Rows[i]["NARRATION"].ToString() + "</div></td>");
                sb.AppendLine("</tr>");

                sno++;
                sb.AppendLine("<tr style=\"background-color:" + color + " !important;\">");
                //sb.AppendLine("<td><input type='checkbox' name='voucherEntryList' value='" + dt.Rows[i + 1]["ROW_ID"].ToString() + "' checked='true'/></td>");
                sb.AppendLine("<td nowrap='nowrap'>" + (sno).ToString() + " </td>");
                sb.AppendLine("<td nowrap='nowrap'> " + dt.Rows[i + 1]["ACCT_NAME"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'> <div align='right' style='font-size:12px !important'> " + GetStatic.ShowDecimal(dt.Rows[i + 1]["AMOUNT"].ToString()) + "</div> </td>");
                sb.AppendLine("<td nowrap='nowrap'>" + dt.Rows[i + 1]["TRAN_DATE"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap'>" + dt.Rows[i + 1]["TRAN_TYPE"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap'>" + dt.Rows[i]["field2"].ToString() + "</div></td>");
                sb.AppendLine("</tr>");

                //var isConsecutive = list.Select((n, index) => n == index + list.ElementAt(i)).All(n => n);
                
            }

            //foreach (DataRow item in dt.Rows)
            //{
            //    sno++;
            //    color = "#F5F5F5";
                
            //    for (int i = 1; i < list.Length; i += 2)
            //    {
            //        Console.WriteLine(i);
            //        Console.WriteLine(i + 1);
                    
            //        if (i % 2)
            //        {

            //        }
            //    }

            //    sb.AppendLine("<tr style=\"background-color:" + color + " !important;\">");
            //    sb.AppendLine("<td><input type='checkbox' name='voucherEntryList' value='" + item["ROW_ID"].ToString() + "' checked='true'/></td>");
            //    sb.AppendLine("<td nowrap='nowrap'>" + sno.ToString() + " </td>");
            //    sb.AppendLine("<td nowrap='nowrap'> " + item["ACCT_NAME"].ToString() + "</td>");
            //    sb.AppendLine("<td nowrap='nowrap' align='right'> <div align='right' style='font-size:12px !important'> " + GetStatic.ShowDecimal(item["AMOUNT"].ToString()) + "</div> </td>");
            //    sb.AppendLine("<td nowrap='nowrap'>" + item["TRAN_DATE"].ToString() + "</td>");
            //    sb.AppendLine("<td nowrap='nowrap'>" + item["TRAN_TYPE"].ToString() + "</td>");
            //    if (sno % 2 != 0)
            //    {
            //        sb.AppendLine("<td nowrap='nowrap' rowspan='2'>" + item["NARRATION"].ToString() + "</div></td>");
            //    }
            //    else
            //    {
            //        i = 1;
            //    }

            //    sb.AppendLine("</tr>");
            //}
            tblBody.InnerHtml = sb.ToString();
        }

        protected void btnSaveFinal_Click(object sender, EventArgs e)
        {
            finalResult.Visible = true;
            divReUpload.Visible = true;
            divBtn.Visible = false;
            tblTempUpload.Visible = false;
            divUpload.Visible = false;

            DataTable dt = _vrd.FinalSave(GetStatic.GetUser(), GetStatic.GetSessionId());

            if (null == dt || dt.Rows.Count == 0)
            {
                tblResult.InnerHtml = "<tr><td colspan='6'>No data to view</td></tr>";
                return;
            }

            int sno = 1;
            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in dt.Rows)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + sno.ToString() +"</td>");
                sb.AppendLine("<td>" + item["ERROR_CODE"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["tran_particular"].ToString() +"</td>");
                sb.AppendLine("<td>" + item["MSG"].ToString() + "</td>");
                sb.AppendLine("</tr>");

                sno++;
            }
            tblResult.InnerHtml = sb.ToString();
        }

        protected void btnClearData_Click(object sender, EventArgs e)
        {
            _vrd.ClearData(GetStatic.GetUser(), GetStatic.GetSessionId());
            ShowTempVoucher();
        }

        protected void btnReUpload_Click(object sender, EventArgs e)
        {
            finalResult.Visible = false;
            divReUpload.Visible = false;
            divBtn.Visible = false;
            tblTempUpload.Visible = true;
            divUpload.Visible = true;
            ShowTempVoucher();
        }
    }
}