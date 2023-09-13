using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.web.Library;
using System.Data;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.IO;
using Swift.DAL.BL.System.Utility;
using Swift.DAL.BL.System.GeneralSettings;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class DynamicPopupManage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "10111100";
        private readonly StaticDataDdl _sl = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private readonly DynamicPopupMessageDao _dpMDao = new DynamicPopupMessageDao();

        protected void Page_Load(object sender, EventArgs e)
        {

            _sl.CheckSession();
            fromDate.ReadOnly = true;
            toDate.ReadOnly = true;
            if (!IsPostBack)
            {
                Authenticate();
                if (GetId() > 0)
                {
                    hdnRowId.Value = GetId().ToString();
                    PupulateDataById();
                }
                else {
                    fromDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
                    toDate.Text = DateTime.Now.ToString("MM/dd/yyyy");

                }
                DispalyDocs(hdnRowId.Value);
                

            }
           
            DispalyDocs(hdnRowId.Value);



        }
        private void PupulateDataById()
        {
            DataRow dr = _dpMDao.SelectById(GetId().ToString(), GetStatic.GetUser());
            if (dr == null)
                return;

            RequiredFieldValidator6.Enabled = false;
            //scope.SelectedValue = dr["scope"].ToString();
            var scope = dr["scope"].ToString();
            if (scope == "admin")
                chkAdmin.Checked = true;
            else if (scope == "agent")
                chkAgent.Checked = true;
            else if (scope == "agentIntl")
                chkAgentIntl.Checked = true;
            else if (scope == "agentAgentIntl")
            {
                chkAgent.Checked = true;
                chkAgentIntl.Checked = true;
            }
            else if (scope == "adminAgentIntl")
            {
                chkAdmin.Checked = true;
                chkAgentIntl.Checked = true;
            }
            else if (scope == "adminAgent")
            {
                chkAdmin.Checked = true;
                chkAgent.Checked = true;
            }
            else if (scope == "all")
            {
                chkAdmin.Checked = true;
                chkAgent.Checked = true;
                chkAgentIntl.Checked = true;
            }
            else
            {
                chkAdmin.Checked = false;
                chkAgent.Checked = false;
                chkAgentIntl.Checked = false;
            }
               
            fileDescription.Text = dr["fileDescription"].ToString();
            imageLink.Text = dr["imageLink"].ToString();
            fromDate.Text = dr["fromDate"].ToString();
            toDate.Text = dr["toDate"].ToString();
            var enable = dr["isEnable"].ToString();
            if (enable == "Y")
            {
                isEnable.Checked = true;
            }
            else
                isEnable.Checked = false;

        }
        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }
        public void DispalyDocs(string rowId)
        {

            var dt = _dpMDao.DisplayDocs(GetStatic.GetUser(), rowId);
            if (dt == null)
            {
                docDisplay.InnerHtml = "";
                return;
            }
            var sb = new StringBuilder();
            sb.Append(" <div class=\"table-responsive\"><table class=\"TBLData  table table-striped table-bordered\" cellspacing=\"0\" cellpadding=\"0\" >");
            sb.Append("<tr>");
            sb.Append("<th>S.N.</th>");
            sb.Append("<th>File For</th>");
            sb.Append("<th>File Description</th>");
            sb.Append("<th>View</th>");
            sb.Append("</tr>");
            int cnt = 0;

            foreach (DataRow dr in dt.Rows)
            {
                cnt = cnt + 1;
                sb.Append("<tr>");
                sb.Append("<td>" + cnt + "</td>");
                sb.Append("<td>" + dr["scope"].ToString() + "</td>");
                sb.Append("<td>" + dr["fileDescription"].ToString() + "</td>");
                string fileLink = "id=" + dr["rowId"] + "&functionId=10111100";
                string filePage = GetStatic.GetUrlRoot() + "/ShowFile.aspx?" + fileLink;
                string PopUpParam = "dialogHeight:800px;dialogWidth:1000px;dialogLeft:300;dialogTop:100;center:yes";
                string jsText = "onclick = \"OpenInNewWindow('" + filePage + "','" + PopUpParam + "');\"";
                sb.Append("<td nowrap='nowrapnowrap'><a title = \"View File\" href=\"javascript:void(0)\" " + jsText + "\">" + Misc.GetIcon("info") + " </a>&nbsp;<span onclick=DeleteDoc('" + dr["rowId"].ToString() + "','temp')>" + Misc.GetIcon("delete") + "</span></td>");
                sb.Append("</tr>");
            }
            sb.Append("</table></div>");
            docDisplay.InnerHtml = sb.ToString();
        }
        private void Upload(string rowId)
        {
            var thisFile = fileUpload;
            var enable = "";
            var scope = "";
            if (chkAdmin.Checked == true)
                scope = "admin";
            if (chkAgent.Checked == true)
                scope = "agent";
            if (chkAgentIntl.Checked == true)
                scope = "agentIntl";
            if (chkAgentIntl.Checked == true && chkAgent.Checked == true)
                scope = "agentAgentIntl";
            if (chkAgentIntl.Checked == true && chkAdmin.Checked == true)
                scope = "adminAgentIntl";
            if (chkAgent.Checked == true && chkAdmin.Checked == true)
                scope = "adminAgent";
            if (chkAgentIntl.Checked == true && chkAgent.Checked == true && chkAdmin.Checked == true)
                scope = "all";            
            if (isEnable.Checked == true)
            {
                enable = "Y";
            }
            else
                enable = "N";

            if (!string.IsNullOrWhiteSpace(thisFile.PostedFile.FileName))
            {
                string pFile = thisFile.PostedFile.FileName.Replace("\\", "/");

                var type = "";
                int pos = pFile.LastIndexOf(".");
                if (pos < 0)
                    type = "";
                else
                    type = pFile.Substring(pos + 1, pFile.Length - pos - 1);

                var root = GetStatic.GetFilePath();
                var info = UploadFile(rowId);
                if (info.Substring(0, 5) == "error")
                {
                    GetStatic.AlertMessage(this, info);
                    return;
                }

                DbResult dbResult = _dpMDao.Update(GetId().ToString(), GetStatic.GetUser(), scope, fileDescription.Text, type, enable, fromDate.Text, toDate.Text, imageLink.Text);
                if (dbResult.ErrorCode == "1")
                {
                    GetStatic.AlertMessage(this, dbResult.Msg);
                    return;
                }

                string locationToMove = root + "PopupMessage";
                string fileToCreate = locationToMove + "\\" + dbResult.Id;

                if (File.Exists(fileToCreate))
                    File.Delete(fileToCreate);

                if (!Directory.Exists(locationToMove))
                    Directory.CreateDirectory(locationToMove);

                File.Move(info, fileToCreate);

                lblMsg.Text = "File(s) Uploaded Successfully.";
                lblMsg.Attributes.Add("class", "SuccessMsg");
            }
            else
            {
                DbResult dbResult = _dpMDao.Update(GetId().ToString(), GetStatic.GetUser(), scope, fileDescription.Text, null, enable, fromDate.Text, toDate.Text,imageLink.Text);
                if (dbResult.ErrorCode == "1")
                {
                    GetStatic.AlertMessage(this, dbResult.Msg);
                    return;
                }
                lblMsg.Text = "Data Updated Successfully.";
                lblMsg.Attributes.Add("class", "SuccessMsg");
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
                   
                        var original_imagePath = root + "\\doc\\tmp\\" + id + "_org_" + GetStatic.GetSessionId();
                        thisFile.PostedFile.SaveAs(original_imagePath);                   
                            thisFile.PostedFile.SaveAs(saved_file_name);
                   
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

        protected void uploadFIle_Click(object sender, EventArgs e)
        {

            Upload(hdnRowId.Value);
            DispalyDocs(hdnRowId.Value);
        }

        protected void deleteDoc_Click(object sender, EventArgs e)
        {
            var dbResult = _dpMDao.DeleteDoc(GetStatic.GetUser(), tempRowId.Value);
            if (dbResult.ErrorCode.Equals("0"))
            {
                lblMsg.Text = dbResult.Msg;
                lblMsg.Attributes.Add("class", "SuccessMsg");
                DispalyDocs(hdnRowId.Value);
                Response.Redirect("DynamicPopupList.aspx");
            }
            else
            {
                GetStatic.AlertMessage(Page, dbResult.Msg);
                return;
            }
        }
        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rowId");
        }
    }
}