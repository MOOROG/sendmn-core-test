using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.IO;
using System.Web.UI;

namespace Swift.web.Remit.Administration.AgentSetup.Document
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20111000";
        private readonly AgentDocumentDao obj = new AgentDocumentDao();
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnl1.Visible = GetMode().ToString() == "1";
                //Authenticate();
                PopulateDataById();
            }
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            Upload();
        }

        #region QueryString

        protected string GetAgentName()
        {
            return remitLibrary.GetAgentBreadCrumb(GetAgentId().ToString());
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("adId");
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
        }

        protected long GetParentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("parent_id");
        }

        protected long GetAgentType()
        {
            return GetStatic.ReadNumericDataFromQueryString("aType");
        }

        protected string GetActAsBranchFlag()
        {
            return GetStatic.ReadQueryString("actAsBranch", "");
        }

        #endregion QueryString

        #region method

        private void Authenticate()
        {
            remitLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetAgentId().ToString());
            if (dr == null)
                return;

            fileDescription.Text = dr["fileDescription"].ToString();
        }

        private void Upload()
        {
            string type = "doc";
            string root = "";
            string info = "";
            if (fileUpload.PostedFile.FileName != null)
            {
                string p_file = fileUpload.PostedFile.FileName.Replace("\\", "/");

                int pos = p_file.LastIndexOf(".");
                if (pos < 0)
                    type = "";
                else
                    type = p_file.Substring(pos + 1, p_file.Length - pos - 1);

                root = GetStatic.GetFilePath(); //ConfigurationSettings.AppSettings["root"];

                info = UploadFile(fileDescription.Text + "." + type, GetAgentId().ToString(), root);

                if (info.Substring(0, 5) == "error")
                    return;
            }

            DbResult dbResult = obj.Update(GetStatic.GetUser(), GetId().ToString(), GetAgentId().ToString(),
                                           fileDescription.Text, type);

            if (GetId() == 0)
            {
                string location_2_move = root + "\\doc";

                string file_2_create = location_2_move + "\\" + dbResult.Id;

                if (File.Exists(file_2_create))
                    File.Delete(file_2_create);

                if (!Directory.Exists(location_2_move))
                    Directory.CreateDirectory(location_2_move);

                File.Move(info, file_2_create);
            }

            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx?agentId=" + GetAgentId() + "&mode=" + GetMode() + "&parent_id=" +
                                  GetParentId() + "&aType=" + GetAgentType());
            }
            else
            {
                if (GetMode() == 2)
                    GetStatic.AlertMessage(Page);
                else
                    GetStatic.PrintMessage(Page);
            }
        }

        public string UploadFile(String fileName, string id, string root)
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
                if (fileUpload.PostedFile.ContentLength <= 2048000)
                {
                    string tmpPath = root + "\\doc\\tmp\\";

                    if (!Directory.Exists(tmpPath))
                        Directory.CreateDirectory(tmpPath);

                    string saved_file_name = root + "\\doc\\tmp\\" + id + "_" + fileName;
                    fileUpload.PostedFile.SaveAs(saved_file_name);
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

        #endregion method
    }
}