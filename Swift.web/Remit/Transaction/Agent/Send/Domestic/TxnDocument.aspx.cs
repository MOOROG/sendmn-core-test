using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.IO;
using System.Drawing;
using System.Text;
using System.Web.UI.HtmlControls;
using Swift.web.Library;
using Swift.DAL.SwiftDAL;
using Swift.DAL.BL.AgentPanel.Utilities;
using Swift.DAL.BL.System.Utility;

namespace Swift.web.Remit.Transaction.Agent.Send.Domestic
{
    public partial class TxnDocument : System.Web.UI.Page
    {
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();
        private readonly TxnDocUploadDao obj = new TxnDocUploadDao();
        private readonly StaticDataDdl _sl = new StaticDataDdl();
        public string _txnDocExists;
        private const string ViewFunctionId = "40101000";
        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();


            if (!IsPostBack)
            {
                Authenticate();
                btnScanDoc.Attributes.Add("onclick", "openScanWindow('" + GetStatic.GetUser() + "','" + GetBatchId() + "')");
                PopulateDdl();
            }
            ShowID(IsPostBack);
            
        }
        private void Authenticate()
        {
            remitLibrary.CheckAuthentication(ViewFunctionId);
        }
        private void PopulateDdl()
        {
            _sl.SetStaticDdl(ref docType, "9900", "", "Select");
        }
        private void ShowID(bool IsPostBack)
        {
            dvUpload.Visible = true;
            var dt = obj.GetTxnTempDoc(GetStatic.GetUser(), GetBatchId());
            var img = new StringBuilder();
          
                            //<div class="panel-heading">
                            //    <h4 class="panel-title">Available Balance: 
                            //        <asp:Label ID="availableAmt" runat="server" BackColor="Yellow" ForeColor="Red"></asp:Label>&nbsp;NPR</h4>
                            //    <div class="panel-actions">
                            //        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            //    </div>
                            //</div>;
            img.Append("<div class='panel panel-default margin-b-30'>");
            img.Append("<div class='panel-heading'><h4 class='panel-title'>Documents You have Uploaded: </h4>");
            img.Append("<div class='panel-actions'><a href='#' class='panel-action panel-action-toggle' data-panel-toggle></a>");
            img.Append("</div></div>");
            img.Append("<div class='panel-body'>");
            img.Append("<table class='TBLData table table-condensed table-bordered'><tr>");
            img.Append("<th>S.N.</th>");
            img.Append("<th>Document Type</th>");
            img.Append("<th>Description</th>");
            img.Append("<th>Image</th>");
            img.Append("<th></th>");
            img.Append("</tr>");

            int cnt = 0;
            foreach (DataRow row in dt.Rows)
            {
                string buttonText = "<br>";
                string rowId = row["rowId"].ToString();
                string fileName = row["fileName"].ToString();
                string fileType = row["fileType"].ToString();
                string fileDescription = row["fileDescription"].ToString();


                cnt++;
                img.Append("<tr>");
                img.Append("<td>" + cnt + "</td>");
                img.Append("<td >" + fileType + "</td>");
                img.Append("<td >" + fileDescription + "</td>");


                var dltImg = GetStatic.GetUrlRoot() + "/Images/delete.gif";
                buttonText += "<span onclick=\"DeleteImage('" + rowId + "');\"><img class='linkText' src = " + dltImg + "></span>";



                var imgPath = "";
                if (!string.IsNullOrWhiteSpace(fileName))
                {
                    imgPath = GetStatic.GetUrlRoot() + "/img.ashx?type=txntmp&id=" + fileName + "&ts=" + DateTime.Now.ToString("yyyyMMddHHmmssfff");

                    img.Append("<td valign='top'>");
                    var imageUrl = @"<img alt = ""Image"" class='linkText'  width=""50"" height=""50"" title = ""Transaction Document"" src = """ + imgPath + @""" onclick=ViewImage('" + imgPath + "'); />";
                    img.Append(imageUrl);
                    img.Append("</td>");

                    var butView = GetStatic.GetUrlRoot() + "/Images/but_view.gif";
                    img.Append("<td nowrap='nowrap'><span onclick=\"openImageWindow('" + imgPath + "');\"><img class='linkText' src=" + butView + "></span>");

                    img.Append(buttonText);

                    img.Append("</td>");
                }
                else
                {
                    img.Append("<td ></td><td ></td>");
                }

                img.Append("</tr>");
            }
            img.Append("</table>");
            img.Append("</div>");
            img.Append("</div>");
            txnId.InnerHtml = img.ToString();

            if (cnt > 0)
                _txnDocExists = "true";
            else
                _txnDocExists = "false";

            //GetStatic.CallBackJs1(this, "updateDocStatus", "updateDocStatus('" + _txnDocExists + "');");
            if (!IsPostBack)
                Page.ClientScript.RegisterStartupScript(this.GetType(), "VoteJsFunc", "updateDocStatus('" + _txnDocExists + "');", true);
        }
        protected void btnDocUpload_Click(object sender, EventArgs e)
        {
            Upload();
        }
        protected string GetBatchId()
        {
            //return "1265878558";
            //return new Random().Next(int.MinValue, int.MaxValue).ToString();
            return GetStatic.ReadQueryString("txnBatchId", "");
        }
        int counter = 1;
        string getFileName(string batchId, string docType, string type)
        {
            var root = GetStatic.GetFilePath();
            var temproot = GetStatic.GetFilePath();


            var fileName = batchId + "_" + docType + "." + type;
            try
            {
                root += "\\TxnDocUpload\\" + fileName;
                temproot += "\\TxnDocUploadTmp\\" + fileName;

                bool isFileExists = false, isTmpFileExists = false;

                if (File.Exists(root))
                {
                    isFileExists = true;
                }
                if (File.Exists(temproot))
                {
                    isTmpFileExists = true;
                }

                if (isFileExists || isTmpFileExists)
                {
                    counter++;
                    docType = docType.Split('_')[0] + "_" + counter.ToString();
                    fileName = getFileName(batchId, docType, type);
                }
                else
                    counter = 1;

                return fileName;
            }
            catch (Exception ex)
            {
                return batchId + "_" + docType + "." + type;
            }



        }
        private void Upload()
        {
            string type = "jpg";
            string root = "";
            string info = "";


            if (fileUpload.PostedFile.FileName != null)
            {

                if (!IsImage(fileUpload))
                {
                    lblMsg.Text = "File types other than image are not acceptable.";
                    lblMsg.ForeColor = Color.Red;
                    return;
                }

                string pFile = fileUpload.PostedFile.FileName.Replace("\\", "/");

                int pos = pFile.LastIndexOf(".");
                if (pos < 0)
                    type = "";
                else
                    type = pFile.Substring(pos + 1, pFile.Length - pos - 1);

                if (!type.ToImage())
                {
                    GetStatic.AlertMessage(this, "Invalid file format. Please upload image file format only.");
                    return;
                }


                root = GetStatic.GetFilePath();
                string batchId = GetBatchId();
                string fileName = getFileName(batchId, docType.SelectedItem.Value, type);//batchId + "_" + docType.Text + "." + type;

                info = UploadFile(fileName, batchId, root);

                if (info.Substring(0, 5) == "error")
                    return;

                DbResult dr = obj.SaveTxnDocumentTemp(GetStatic.GetUser(), batchId, fileName, docType.SelectedItem.Text, docDesc.Text);
                if (dr.ErrorCode.Equals("0"))
                {
                    string locationToMove = root + "\\TxnDocUploadTmp";
                    string fileToCreate = locationToMove + "\\" + fileName;

                    if (File.Exists(fileToCreate))
                        File.Delete(fileToCreate);

                    if (!Directory.Exists(locationToMove))
                        Directory.CreateDirectory(locationToMove);

                    File.Move(info, fileToCreate);
                    docType.SelectedValue = "";
                    docDesc.Text = "";
                    GetStatic.AlertMessage(this, dr.Msg);
                    ShowID(false);
                }
            }
        }
        public string UploadFile(string fileName, string batchId, string root)
        {
            if (fileName == "")
            {
                return "error:Invalid filename supplied";
            }
            if (fileUpload.PostedFile.ContentLength == 0)
            {
                return "error:Invalid file content";
            }

            try
            {
                if (fileUpload.PostedFile.ContentLength <= 2097152)
                {
                    var saveFileLocation = root + "\\tmp\\";

                    if (!Directory.Exists(saveFileLocation))
                        Directory.CreateDirectory(saveFileLocation);

                    var saved_file_name = saveFileLocation + batchId + "_" + fileName;


                    if (IsImage(fileUpload))
                    {
                        CompressImageDao ci = new CompressImageDao();

                        var original_imagePath = root + "\\tmp\\" + batchId + "_org_" + fileName;
                        fileUpload.PostedFile.SaveAs(original_imagePath);

                        if (!ci.CompressImageAndSave((fileUpload.PostedFile.ContentLength / 1024), original_imagePath, saved_file_name))
                        {
                            fileUpload.PostedFile.SaveAs(saved_file_name);
                        }
                    }
                    else
                    {

                        fileUpload.PostedFile.SaveAs(saved_file_name);
                    }

                    return saved_file_name;
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

        public static bool IsImage(HtmlInputFile fileUpload)
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
        private void ManageMessage(DbResult dr)
        {
            var url = "List.aspx";
            GetStatic.CallJSFunction(this, string.Format("CallBackSave('{0}','{1}", dr.ErrorCode, dr.Msg.Replace("'", "") + "','" + url + "')"));
        }
        protected void btnDocDelete_Click(object sender, EventArgs e)
        {
            var root = GetStatic.GetFilePath();
            if (!string.IsNullOrWhiteSpace(hddFileId.Value))
            {
                var dbResult = obj.DeleteTxnTmpDoc(GetStatic.GetUser(), hddFileId.Value, GetBatchId());

                if (dbResult.ErrorCode.Equals("0"))
                {
                    var filePath = root + "\\TxnDocUploadTmp\\" + dbResult.Id;

                    var patoToMove = GetStatic.GetFilePath() + "\\Deleted";

                    if (File.Exists(filePath))
                    {
                        if (!Directory.Exists(patoToMove))
                        {
                            Directory.CreateDirectory(patoToMove);
                        }
                        if (File.Exists(patoToMove + "\\" + dbResult.Id))
                            File.Delete(patoToMove + "\\" + dbResult.Id);

                        File.Move(filePath, patoToMove + "\\" + dbResult.Id);
                    }
                    ShowID(false);
                }

                GetStatic.AlertMessage(Page, dbResult.Msg);
            }
        }
    }
}