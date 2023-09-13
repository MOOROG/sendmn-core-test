using Swift.DAL.VoucherReport;
using Swift.web.Library;
using System;
using System.Data;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI.WebControls;

namespace Swift.web.BillVoucher.VoucherEntry
{
    public partial class VoucherEntry : System.Web.UI.Page
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
                transactionDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                //transactionDate.ReadOnly = true;
                PopulateDDL();
            }
            divuploadMsg.Visible = false;
            mes.Visible = false;
        }

        private void PopulateDDL()
        {
            _sdd.SetDDL(ref voucherType, "EXEC Proc_dropdown_remit @FLAG='voucherDDL'", "value", "functionName", "", "");
            _sdd.SetDDL(ref Department, "EXEC Proc_dropdown_remit @FLAG='Department'", "RowId", "DepartmentName", "", "Select Department");
            _sdd.SetDDL(ref Branch, "EXEC Proc_dropdown_remit @FLAG='Branch'", "agentId", "agentName", "", "Select Branch");
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

            var result = _vrd.InsertTempVoucherEntryDetails(GetStatic.GetSessionId(), GetStatic.GetUser(), acInfo.Value, dropDownDrCr.Text, amt.Text, Department.Text, Branch.Text, EmpName.Text, Field1.Text, "");
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
            var dt = _vrd.GetTempVoucherEntryDataDetails(GetStatic.GetSessionId());
            var sb = new StringBuilder("");
            sb.AppendLine("<div class=\"table-responsive\">");
            sb.AppendLine("<table class=\"table table-bordered\">");
            sb.AppendLine("<tr >");
            sb.AppendLine("<th >S. No</th>");
            sb.AppendLine("<th >AC information</th>");
            sb.AppendLine("<th >Department</th>");
            sb.AppendLine("<th >Branch</th>");
            sb.AppendLine("<th >EmployeeName</th>");
            sb.AppendLine("<th >Type</th>");
            sb.AppendLine("<th>Amount</th>");
            sb.AppendLine("<th>Select</th>");
            sb.AppendLine("</tr>");
            if (dt == null || dt.Rows.Count == 0)
            {
                sb.AppendLine("<tr><td colspan='8' align='center'>No transaction found!</td></tr></table></div>");
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
                sb.AppendLine("<td nowrap='nowrap' width='20%'> " + item["DepartmentName"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' width=20%'> " + item["agentName"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' width='20%'> " + item["emp_name"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' width='5%'>" + item["part_tran_type"].ToString() + " </td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'  width='15%'> <div align='right' style='font-size:12px !important'> " + GetStatic.ShowDecimal(item["tran_amt"].ToString()) + "</div> </td>");
                sb.AppendLine("<td nowrap='nowrap' width='5%'><div align='center'><span class=\"action-icon\"><a class=\"btn btn-xs btn-primary\" title=\"Delete\" data-placement=\"top\" data-toggle=\"tooltip\" href=\"#\" data-original-title=\"Delete\" style='text-decoration:none;' onclick='deleteRecord(" + item["tran_id"].ToString() + ")'><i class=\"fa fa-trash-o\"></i></a></span></div></td>");
                sb.AppendLine("</tr>");
            }
            sb.AppendLine("<tr>");
            sb.AppendLine("<td nowrap='nowrap' align='right' colspan='7' > <div align='right' style='font-size:12px !important'><strong>Total Dr</strong><span style=' text-align:right; font-weight: bold;' > (" + drCount.ToString() + "): &nbsp; &nbsp;" + GetStatic.ShowDecimal(drTotal.ToString()) + "</span></div> </td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td nowrap='nowrap' align='right' colspan='7' > <div align='right' style='font-size:12px !important'><strong>Total Cr</strong><span style=' text-align:right; font-weight: bold;' > (" + crCount.ToString() + "): &nbsp; &nbsp;" + GetStatic.ShowDecimal(crTotal.ToString()) + "</span></div> </td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</div>");
            rpt_tempVoucherTrans.InnerHtml = sb.ToString();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            var res = _vrd.DeleteRecordVoucherEntryDetails(hdnRowId.Value);
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
            if (VImage.HasFile)
            {
                // Get the file extension
                string fileExtension = System.IO.Path.GetExtension(VImage.FileName);

                if (!IsImage(VImage))
                {
                    msg.Visible = true;
                    mes.InnerHtml = "File types other than image are not acceptable.";
                    return;
                }
                else
                {
                    // Get the file size
                    int fileSize = VImage.PostedFile.ContentLength;
                    // If file size is greater than 2 MB
                    if (fileSize > Convert.ToInt32(GetStatic.GetUploadFileSize()))
                    {
                        msg.Visible = true;
                        mes.InnerHtml = "File size cannot be greater than 2 MB";
                        return;
                    }
                    else
                    {
                        // Upload the file
                        hdnfileName1.Value = "UploadedVoucher-" + GetTimestamp(DateTime.Now) + fileExtension;
                        string path = GetStatic.ReadWebConfig("filePath") + "VoucherDoc\\";
                        if (!Directory.Exists(path))
                            Directory.CreateDirectory(path);
                        var filePath = path + hdnfileName1.Value;
                        VImage.SaveAs(filePath);
                    }
                }
            }
            string date = transactionDate.Text;
            var res = _vrd.SaveTempTransaction(GetStatic.GetSessionId(), date, narrationField.Text, voucherType.SelectedValue, chequeNo.Text, GetStatic.GetUser(), hdnfileName1.Value);
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

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (fileUpload.FileContent.Length > 0)
            {
                if (fileUpload.FileName.ToLower().Contains(".csv"))
                {
                    string path = Server.MapPath("..\\..\\") + "\\doc\\tmp\\" + fileUpload.FileName;
                    string Remitpath = Server.MapPath("..\\..\\") + "\\SampleFile\\VoucherEntry\\" + fileUpload.FileName;
                    fileUpload.SaveAs(path);
                    var xml = GetStatic.GetCSVFileInTable(path, true);

                    //File.Move(path, Remitpath);
                    File.Delete(path);
                    var rs = _vrd.InsertTempVoucherEntryFromFile(GetStatic.GetSessionId(), GetStatic.GetUser(), xml);
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
                    divuploadMsg.Visible = true;
                    divuploadMsg.InnerHtml = "Invalid file format uploaded";
                }
            }
        }

        public static bool IsImage(FileUpload fileUpload)
        {
            if (Path.GetExtension(fileUpload.PostedFile.FileName).ToLower() != ".jpg"
                && Path.GetExtension(fileUpload.PostedFile.FileName).ToLower() != ".png"
                && Path.GetExtension(fileUpload.PostedFile.FileName).ToLower() != ".gif"
                && Path.GetExtension(fileUpload.PostedFile.FileName).ToLower() != ".jpeg")
            {
                return false;
            }

            if (fileUpload.PostedFile.ContentType.ToLower() != "image/jpg" &&
                        fileUpload.PostedFile.ContentType.ToLower() != "image/jpeg" &&
                        fileUpload.PostedFile.ContentType.ToLower() != "image/pjpeg" &&
                        fileUpload.PostedFile.ContentType.ToLower() != "image/gif" &&
                        fileUpload.PostedFile.ContentType.ToLower() != "image/x-png" &&
                        fileUpload.PostedFile.ContentType.ToLower() != "image/png")
            {
                return false;
            }

            try
            {
                byte[] buffer = new byte[512];
                fileUpload.PostedFile.InputStream.Read(buffer, 0, 512);
                string content = Encoding.UTF8.GetString(buffer);
                if (Regex.IsMatch(content, @"<script|<html|<head|<title|<body|<pre|<table|<a\s+href|<img|<plaintext|<cross\-domain\-policy|<?php",
                    RegexOptions.IgnoreCase | RegexOptions.CultureInvariant | RegexOptions.Multiline))
                {
                    return false;
                }
            }
            catch (Exception)
            {
                return false;
            }

            try
            {
                using (var bitmap = new System.Drawing.Bitmap(fileUpload.PostedFile.InputStream))
                {
                }
            }
            catch (Exception)
            {
                return false;
            }

            return true;
        }

        public static string GetTimestamp(DateTime value)
        {
            return value.ToString("yyyyMMddHHmmssffff");
        }
    }
}