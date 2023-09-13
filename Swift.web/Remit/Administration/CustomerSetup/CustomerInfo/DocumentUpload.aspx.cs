using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.BL.System.Utility;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Configuration;
using System.Data;
using System.Drawing;
using System.IO;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.CustomerSetup.CustomerInfo
{
    public partial class DocumentUpload : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20821800,20822000";
        private const string AddEditFunctionId = "20821810,20822010";
        private const string DeleteFunctionId = "20821820,20822020";
        private readonly CustomerDocumentDao cdd = new CustomerDocumentDao();
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();
        private string root = ConfigurationSettings.AppSettings["filePath"];

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                pnl1.Visible = GetSection() == "";
                ListFileInformation(cdd.PopulateCustomerDocument(GetStatic.GetUser(), GetCustomerId().ToString()));
            }
        }

        protected string GetCustomerName()
        {
            return "Customer Name : " + remitLibrary.GetCustomerName(GetCustomerId().ToString());
        }

        protected long GetCustomerId()
        {
            return GetStatic.ReadNumericDataFromQueryString("customerId");
        }

        protected string GetSection()
        {
            return GetStatic.ReadQueryString("section", "");
        }

        protected long GetCdId()
        {
            return GetStatic.ReadNumericDataFromQueryString("cdId");
        }

        private void Authenticate()
        {
            remitLibrary.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
        }

        #region FileUpload

        private void Upload()
        {
            string type = "doc";
            string info = "";

            if (fileUpload.PostedFile.FileName != null)
            {
                string pFile = fileUpload.PostedFile.FileName.Replace("\\", "/");

                int pos = pFile.LastIndexOf(".");
                if (pos < 0)
                    type = "";
                else
                    type = pFile.Substring(pos + 1, pFile.Length - pos - 1);
                switch (type)
                {
                    case "jpeg":
                        break;

                    case "jpg":
                        break;

                    case "gif":
                        break;

                    case "JPEG":
                        break;

                    case "JPG":
                        break;

                    case "GIF":
                        break;

                    default:
                        lblMsg.Text = "Error:Unable to upload,Please select jpg/gif file only!";
                        lblMsg.ForeColor = Color.Red;
                        return;
                }
                info = UploadFile(fileDescription.Text + "." + type, GetCustomerId().ToString(), root);

                if (info.Substring(0, 5) == "error")
                    return;

                DbResult dbResult = cdd.Update(GetStatic.GetUser(), GetCdId().ToString(), GetCustomerId().ToString(),
                                               fileDescription.Text, type, GetStatic.GetAgentId(), GetStatic.GetBranch());
                string locationToMove = root + "\\doc";

                string fileToCreate = locationToMove + "\\" + dbResult.Id;

                if (File.Exists(fileToCreate))
                    File.Delete(fileToCreate);

                if (!Directory.Exists(locationToMove))
                    Directory.CreateDirectory(locationToMove);

                File.Move(info, fileToCreate);

                string strMessage = "File Uploaded Successfully";
                lblMsg.Text = strMessage;
                lblMsg.ForeColor = Color.Green;

                ListFileInformation(cdd.PopulateCustomerDocument(GetStatic.GetUser(), GetCustomerId().ToString()));
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
                if (fileUpload.PostedFile.ContentLength <= 2097152)
                {
                    var saveFileLocation = root + "\\doc\\tmp\\";
                    if (!Directory.Exists(saveFileLocation))
                        Directory.CreateDirectory(saveFileLocation);

                    string saved_file_name = saveFileLocation + id + "_" + fileName;
                    CompressImageDao ci = new CompressImageDao();
                    var original_imagePath = root + "\\doc\\tmp\\" + id + "_org_" + fileName;
                    fileUpload.PostedFile.SaveAs(original_imagePath);

                    if (!ci.CompressImageAndSave((fileUpload.PostedFile.ContentLength / 1024), original_imagePath, saved_file_name))
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

        private void ListFileInformation(DataTable dt)
        {
            TableRow tr = null;
            TableCell td1 = null;
            TableCell td2 = null;
            TableCell td3 = null;
            tblResult.CellPadding = 3;
            tblResult.CellSpacing = 0;
            if (dt.Rows.Count <= 0)
                return;

            tr = new TableRow();
            td1 = new TableCell();
            td2 = new TableCell();
            td3 = new TableCell();

            td1.Text = "<strong>File Desciption</strong>";
            td2.Text = "<strong>File Type</strong>";
            td3.Text = "<strong></strong>";

            td1.CssClass = "";
            td2.CssClass = "";
            td3.CssClass = "";

            tr.Cells.Add(td1);
            tr.Cells.Add(td2);
            tr.Cells.Add(td3);

            tblResult.Rows.Add(tr);

            foreach (DataRow row in dt.Rows)
            {
                tr = new TableRow();
                td1 = new TableCell();
                td2 = new TableCell();
                td3 = new TableCell();

                string fileLink = "id=" + row["cdId"] + "&functionId=" + ViewFunctionId;
                string filePage = GetStatic.GetUrlRoot() + "/ShowFile.aspx?" + fileLink;
                string PopUpParam = "";
                string jsText = "onclick = \"PopUpWindow('" + filePage + "','" + PopUpParam + "');\"";

                td1.Text = row["fileDescription"].ToString();
                td2.Text = row["fileType"].ToString();
                td3.Text = "<a title = \"View File\" href=\"javascript:void(0)\" " + jsText + "\">" + Misc.GetIcon("info") + " </a>&nbsp;<span onclick=Delete('" + row["cdId"] + "')>" + Misc.GetIcon("delete") + "</span>";
                tr.Cells.Add(td1);
                tr.Cells.Add(td2);
                tr.Cells.Add(td3);
                tblResult.Rows.Add(tr);
            }
        }

        private void DeleteFile()
        {
            DataTable dt = cdd.Delete(GetStatic.GetUser(), hdnRowId.Value);
            string location = root + "\\doc";
            foreach (DataRow row in dt.Rows)
            {
                if (File.Exists(location + "\\" + row[0]))
                    File.Delete(location + "\\" + row[0]);
            }
            string strMessage = "File Deleted successfully";
            lblMsg.Text = strMessage;
            lblMsg.ForeColor = Color.Red;
            ListFileInformation(cdd.PopulateCustomerDocument(GetStatic.GetUser(), GetCustomerId().ToString()));
        }

        #endregion FileUpload

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            Upload();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DeleteFile();
        }
    }
}