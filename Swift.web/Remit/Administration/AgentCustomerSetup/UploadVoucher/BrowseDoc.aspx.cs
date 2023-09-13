using Swift.DAL.BL.Remit.Reconciliation;
using Swift.DAL.BL.System.Utilities;
using Swift.DAL.BL.System.Utility;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.Script.Serialization;

namespace Swift.web.Remit.Administration.AgentCustomerSetup.UploadVoucher
{
    public partial class BrowseDoc : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40122100";
        private readonly StaticDataDdl _sl = new StaticDataDdl();
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private TxnDocumentsDao _Dao = new TxnDocumentsDao();
        private readonly ScannerSetupDao _scanner = new ScannerSetupDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                //Authenticate();
                if (GetId() > 0)
                {
                    hdnTranId.Value = GetId().ToString();
                }
                //DispalyDocs(hdnTranId.Value);
                CheckDocument();
            }
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("id");
        }

        protected string GetVoucherType()
        {
            return GetStatic.ReadQueryString("txnType", "");
        }

        //public void DispalyDocs(string tranId)
        //{
        //    hdnAgentId.Value = GetStatic.ReadQueryString("agentId", "");
        //    var agentId = GetStatic.GetAgent().ToString();
        //    var txnType = GetStatic.ReadQueryString("txnType", "");
        //    var status = GetStatic.ReadQueryString("status", "");
        //    if (status == "Reconciled")
        //    {
        //        uploadPanel.Visible = false;
        //    }
        //    var dt = _Dao.DisplayDocsAgent(GetStatic.GetUser(), tranId, GetVoucherType());
        //    if (dt == null)
        //    {
        //        return;
        //    }

        // if (dt.Rows.Count > 0) { StringBuilder sb = new StringBuilder();

        // for (int i = 0; i < dt.Rows.Count; i++) { var rows = dt.Rows[i]; var data =
        // PayTXNManager.EncryptTokenWithEncode(string.Format("{0}|{1}|{2}|{3}", rows["fileName"],
        // "20182130", rows["year"], rows["agentId"])).Msg; var voPath = GetStatic.GetUrlRoot() +
        // "/CustDocs.ashx?x=" + data;

        // if (status == "Reconciled") { var delBtn = ""; var td = "<div class='show-image'><a
        // href='javascript:void(0)' onclick=\"OpenInNewWindow('" + voPath + "');\"><img src='" +
        // voPath + "' style='width:170px;height:170px;'/></a><br/>" + delBtn + "</div>";

        // sb.AppendLine("<div style='width:700px;'>" + td + "</div>"); } else { var delBtn = "<input
        // id='" + i + "' class='delete' type='button' value='Delete' onclick=\"return
        // DeleteDocument('" + PayTXNManager.EncryptToken(rows["rowId"].ToString()).Msg + "');\"/>";

        // var td = "<div class='show-image'><a href='javascript:void(0)'
        // onclick=\"OpenInNewWindow('" + voPath + "');\"><img src='" + voPath + "'
        // style='width:170px;height:170px;'/></a><br/>" + delBtn + "</div>";

        // sb.AppendLine("
        // <div style="width:700px;">
        // " + td + "
        // </div>
        // ");

        // }

        // } CheckDocument(); ingDisplay.InnerHtml = sb.ToString();

        // } else { CheckDocument(); ingDisplay.InnerHtml = ""; }

        //}

        //protected void btnDelete_Click(object sender, EventArgs e)
        //{
        //    var id = PayTXNManager.DecryptTokenWithDecode(docId.Value).Msg;
        //    DeleteDocument(id);
        //    DispalyDocs(hdnTranId.Value);

        //}

        //private void DeleteDocument(string id)
        //{
        //    var txnType = GetStatic.ReadQueryString("txnType", "");
        //    var dbResult = _Dao.DeleteDocAgent(GetStatic.GetUser(), id,txnType);
        //    if (dbResult.ErrorCode.Equals("0"))
        //    {
        //        DeleteFile(dbResult.Id);
        //        GetStatic.AlertMessage(this, dbResult.Msg);
        //    }
        //    else
        //    {
        //        GetStatic.AlertMessage(Page, dbResult.Msg);
        //        return;
        //    }
        //}

        private void DeleteFile(string path)
        {
            try
            {
                var filePath = GetStatic.TXNDocumentUploadPath() + @"\ReconcilationDoc\" + path;
                File.Delete(filePath);
            }
            catch (Exception) { }
        }

        private void UploadDocument(string tranId, string docType)
        {
            var thisFile = fileUpload;
            if (!string.IsNullOrWhiteSpace(thisFile.PostedFile.FileName))
            {
                string pFile = thisFile.PostedFile.FileName.Replace("\\", "/");

                var type = "";
                int pos = pFile.LastIndexOf(".");
                if (pos < 0)
                    type = "";
                else
                    type = pFile.Substring(pos + 1, pFile.Length - pos - 1);

                var root = GetStatic.TXNDocumentUploadPath();
                var info = UploadFile(tranId);
                if (info.Substring(0, 5) == "error")
                {
                    GetStatic.AlertMessage(this, info);
                    return;
                }

                string year = DateTime.Now.Year.ToString();
                string agentId = GetStatic.GetAgent().ToString();
                hdntnxType.Value = GetStatic.ReadQueryString("txnType", "");
                var tnxType = hdntnxType.Value;
                var dbResult = _Dao.UpdateAgentDoc(GetStatic.GetUser().ToString(), GetId().ToString(), tranId, docType, type, year, agentId, tnxType);

                string locationToMove = root + "ReconcilationDoc";

                var fileToCreateYear = locationToMove + "\\" + year;
                if (!Directory.Exists(fileToCreateYear))
                    Directory.CreateDirectory(fileToCreateYear);

                var fileToCreateAgent = fileToCreateYear + "\\" + agentId;
                if (!Directory.Exists(fileToCreateAgent))
                    Directory.CreateDirectory(fileToCreateAgent);

                string fileToCreate = fileToCreateAgent + "\\" + dbResult.Id;

                if (File.Exists(fileToCreate))
                    File.Delete(fileToCreate);

                File.Move(info, fileToCreate);

                GetStatic.AlertMessage(this, dbResult.Msg);
            }
        }

        public string UploadFile(string id)
        {
            var root = GetStatic.GetFilePath();
            var thisFile = fileUpload;
            if (thisFile.PostedFile.ContentLength == 0)
            {
                return "error:Invalid file content";
            }
            try
            {
                if (thisFile.PostedFile.ContentLength <= 2097152)
                {
                    var saveFileLocation = root + "\\doc\\tmp\\";
                    if (!Directory.Exists(saveFileLocation))
                        Directory.CreateDirectory(saveFileLocation);

                    var saved_file_name = saveFileLocation + id + "_" + GetStatic.GetSessionId();
                    if (IsImage(thisFile))
                    {
                        CompressImageDao ci = new CompressImageDao();
                        var original_imagePath = root + "\\doc\\tmp\\" + id + "_org_" + GetStatic.GetSessionId();
                        thisFile.PostedFile.SaveAs(original_imagePath);

                        if (!ci.CompressImageAndSave((thisFile.PostedFile.ContentLength / 1024), original_imagePath, saved_file_name))
                        {
                            thisFile.PostedFile.SaveAs(saved_file_name);
                        }
                        return saved_file_name;
                    }
                    return "error:Invalid File";
                }
                else
                {
                    return "error:Unable to upload,file exceeds maximum limit";
                }
            }
            catch (UnauthorizedAccessException ex)
            {
                return "error:" + ex.Message + "Permission to upload file denied";
            }
        }

        public static bool IsImage(System.Web.UI.HtmlControls.HtmlInputFile fileUpload)
        {
            //-------------------------------------------
            //  Check the image mime types
            //-------------------------------------------
            if (fileUpload.PostedFile.ContentType.ToLower() != "image/jpg" &&
                        fileUpload.PostedFile.ContentType.ToLower() != "image/jpeg" &&
                        fileUpload.PostedFile.ContentType.ToLower() != "image/pjpeg" &&
                        fileUpload.PostedFile.ContentType.ToLower() != "image/gif" &&
                        fileUpload.PostedFile.ContentType.ToLower() != "image/x-png" &&
                        fileUpload.PostedFile.ContentType.ToLower() != "image/png")
            {
                return false;
            }

            //-------------------------------------------
            //  Check the image extension
            //-------------------------------------------
            if (Path.GetExtension(fileUpload.PostedFile.FileName).ToLower() != ".jpg"
                && Path.GetExtension(fileUpload.PostedFile.FileName).ToLower() != ".png"
                && Path.GetExtension(fileUpload.PostedFile.FileName).ToLower() != ".gif"
                && Path.GetExtension(fileUpload.PostedFile.FileName).ToLower() != ".jpeg")
            {
                return false;
            }

            return true;
        }

        protected void voucher_Click(object sender, EventArgs e)
        {
            UploadDocument(hdnTranId.Value, "Voucher");
            //DispalyDocs(hdnTranId.Value);
        }

        protected void id_Click(object sender, EventArgs e)
        {
            UploadDocument(hdnTranId.Value, "Id");
            // DispalyDocs(hdnTranId.Value);
        }

        protected void Both_Click(object sender, EventArgs e)
        {
            UploadDocument(hdnTranId.Value, "Both");
            //DispalyDocs(hdnTranId.Value);
        }

        private void CheckDocument()
        {
            string agentId = GetStatic.GetAgent();
            string icn = GetStatic.ReadQueryString("controlNo", "");
            string tranId = GetStatic.ReadQueryString("id", "");
            string vouType = GetStatic.ReadQueryString("txnType", "");
            DataTable dt = _scanner.CheckDocument(agentId, tranId, icn, vouType);

            Disable(Convert.ToInt16(dt.Rows[0]["id"]));
        }

        private void Disable(int type)
        {
            if (type == 0)
            {
                id.Enabled = true;
                Both.Enabled = true;
                voucher.Enabled = true;
                fileUpload.Visible = true;
            }
            else if (type == 1)
            {
                id.Enabled = false;
                Both.Enabled = false;
                voucher.Enabled = true;
                fileUpload.Visible = true;
            }
            else if (type == 2)
            {
                voucher.Enabled = false;
                Both.Enabled = false;
                id.Enabled = true;
                fileUpload.Visible = true;
            }
            else if (type == 3)
            {
                voucher.Enabled = false;
                id.Enabled = false;
                Both.Enabled = false;
                fileUpload.Visible = false;
            }
            else if (type >= 4)
            {
                id.Enabled = false;
                voucher.Enabled = false;
                Both.Enabled = false;
                fileUpload.Visible = false;
            }
        }

        public static string DataTableToJSON(DataTable table)
        {
            List<Dictionary<string, object>> list = new List<Dictionary<string, object>>();
            foreach (DataRow row in table.Rows)
            {
                Dictionary<string, object> dict = new Dictionary<string, object>();
                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = row[col];
                }
                list.Add(dict);
            }
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            return serializer.Serialize(list);
        }
    }
}