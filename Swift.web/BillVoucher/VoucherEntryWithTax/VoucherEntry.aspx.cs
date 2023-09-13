using Swift.DAL.Common;
using Swift.DAL.SwiftDAL;
using Swift.DAL.VoucherReport;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;

namespace Swift.web.BillVoucher.VoucherEntryWithTax
{
    public partial class VoucherEntry : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20302400";
        private const string DateFunctionId = "20302410";
        private readonly RemittanceLibrary _sdd = new RemittanceLibrary();
        private readonly VoucherReportDAO _vrd = new VoucherReportDAO();
        protected void Page_Load(object sender, EventArgs e)
        {
            _sdd.CheckSession();

            string methodName = Request.Form["MethodName"];
            if (methodName == "SaveTemp")
                SaveTempData();
            if (methodName == "PopulateTempData")
                ShowTempVoucher();
            if (methodName == "DeleteTemp")
                DeleteTemp();
            if (methodName == "SaveMainData")
                SaveMainData();

            if (!IsPostBack)
            {
                Authenticate();
                Misc.MakeAmountTextBox(ref amt);
                transactionDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                PopulateDDL();
            }
        }
        
        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDDL()
        {
            _sdd.SetDDL(ref voucherType, "EXEC Proc_dropdown_remit @FLAG='voucherDDL'", "value", "functionName", "", "");
            _sdd.SetDDL(ref Department, "EXEC Proc_dropdown_remit @FLAG='Department'", "RowId", "DepartmentName", "", "Select Department");
            _sdd.SetDDL(ref Branch, "EXEC Proc_dropdown_remit @FLAG='Branch'", "agentId", "agentName", "", "Select Branch");
        }

        protected void SaveTempData()
        {
            DbResult _dbRes = new DbResult();
            string amount = Request.Form["amt"];
            string acInfo = Request.Form["acInfo"];
            string dropDownDrCr = Request.Form["dropDownDrCr"];
            string Department = Request.Form["Department"];
            string Branch = Request.Form["Branch"];
            string EmpName = Request.Form["EmpName"];
            string Field1 = Request.Form["Field1"];
            string percent = Request.Form["Percent"];


            if (GetStatic.ParseDouble(amount) <= 0)
            {
                _dbRes.SetError("1", "Please enter valid Amount!", null);
                GetStatic.JsonResponse(_dbRes, this);
                return;
            }

            _dbRes = _vrd.InsertTempVoucherEntryDetailsNew(GetStatic.GetSessionId(), GetStatic.GetUser(), acInfo, dropDownDrCr, amount, Department, Branch, EmpName, Field1, "", percent);

            GetStatic.JsonResponse(_dbRes, this);
        }

        protected bool AllowChangeDate()
        {
            return _sdd.HasRight(DateFunctionId);
        }

        protected void DeleteTemp()
        {
            string rowId = Request.Form["RowId"];
            var res = _vrd.DeleteRecordVoucherEntryDetails(rowId);

            GetStatic.JsonResponse(res, this);
        }

        protected void Unsave()
        {
            ShowTempVoucher();
        }

        protected void SaveMainData()
        {
            DbResult _dbRes = new DbResult();
            string fileName = "";
            string filePath = "";
            var VoucherImage = Request.Files["vImage"];
            var date = Request.Form["transactionDate"];
            var narration = Request.Form["narrationField"];
            var vType = Request.Form["voucherType"];
            var chequeNumber = Request.Form["chequeNo"];

            if (null != VoucherImage)
            {
                // Get the file extension
                string fileExtension = System.IO.Path.GetExtension(VoucherImage.FileName);

                if (!IsImage(VoucherImage))
                {
                    _dbRes.SetError("1", "File types other than image are not acceptable.", null);
                    GetStatic.JsonResponse(_dbRes, this);
                    return;
                }
                else
                {
                    // Get the file size
                    int fileSize = VoucherImage.ContentLength;
                    // If file size is greater than 2 MB
                    if (fileSize > Convert.ToInt32(GetStatic.GetUploadFileSize()))
                    {
                        _dbRes.SetError("1", "File size cannot be greater than 2 MB", null);
                        GetStatic.JsonResponse(_dbRes, this);
                        return;
                    }
                    else
                    {
                        // Upload the file
                        fileName = "UploadedVoucher-" + GetTimestamp(DateTime.Now) + fileExtension;
                        string path = GetStatic.ReadWebConfig("filePath") + "VoucherDoc\\";
                        if (!Directory.Exists(path))
                            Directory.CreateDirectory(path);
                        filePath = path + fileName;
                        VoucherImage.SaveAs(filePath);
                    }
                }
            }
            _dbRes = _vrd.SaveTempTransaction(GetStatic.GetSessionId(), date, narration, vType, chequeNumber, GetStatic.GetUser(), fileName);

            if (!string.IsNullOrEmpty(filePath) && _dbRes.ErrorCode != "0")
            {
                File.Delete(filePath);
            }
            GetStatic.JsonResponse(_dbRes, this);
        }

        private void ShowTempVoucher()
        {
            IList<VoucherTempData> _voucherData = new List<VoucherTempData>();
            _voucherData = _vrd.GetTempVoucherEntryDataDetailsList(GetStatic.GetSessionId());

            GetStatic.JsonResponse(_voucherData, this);
        }
        
        public static bool IsImage(HttpPostedFile fileUpload)
        {
            if (Path.GetExtension(fileUpload.FileName).ToLower() != ".jpg"
                && Path.GetExtension(fileUpload.FileName).ToLower() != ".png"
                && Path.GetExtension(fileUpload.FileName).ToLower() != ".gif"
                && Path.GetExtension(fileUpload.FileName).ToLower() != ".jpeg")
            {
                return false;
            }

            if (fileUpload.ContentType.ToLower() != "image/jpg" &&
                        fileUpload.ContentType.ToLower() != "image/jpeg" &&
                        fileUpload.ContentType.ToLower() != "image/pjpeg" &&
                        fileUpload.ContentType.ToLower() != "image/gif" &&
                        fileUpload.ContentType.ToLower() != "image/x-png" &&
                        fileUpload.ContentType.ToLower() != "image/png")
            {
                return false;
            }

            try
            {
                byte[] buffer = new byte[512];
                fileUpload.InputStream.Read(buffer, 0, 512);
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
                using (var bitmap = new System.Drawing.Bitmap(fileUpload.InputStream))
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