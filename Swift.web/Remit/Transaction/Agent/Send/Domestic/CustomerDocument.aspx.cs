using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Drawing;
using Swift.web.Library;
using System.Data;
using Swift.DAL.SwiftDAL;
using System.Configuration;
using System.IO;
using Swift.DAL.BL.Remit.Administration.Customer;

namespace Swift.web.Remit.Transaction.Agent.Send.Domestic
{
    public partial class CustomerDocument : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40101000";

        private readonly StaticDataDdl _sl = new StaticDataDdl();
        private readonly CustomerDocumentDao cdd = new CustomerDocumentDao();
        private readonly RemittanceLibrary remLibrary = new RemittanceLibrary();
        //private readonly SwiftLibrary swiftLibrary = new SwiftLibrary();
        private string _fileToBeDeleted = "";
        //string root = ConfigurationSettings.AppSettings["root"];
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.Form["chkTran"] != null)
                _fileToBeDeleted = Request.Form["chkTran"];
            if (!IsPostBack)
            {
                 Authenticate();
                PopulateDdl();
                ListFileInformation(cdd.PopulateCustomerDocument(GetStatic.GetUser(), GetCustomerId().ToString()));
            }
        }
        private void PopulateDdl()
        {
            var strSQL = @"SELECT 'IdCard' valueId,'Citizenship-1' detailTitle  
                            UNION ALL
                            SELECT 'IdCard_2' valueId,'Citizenship-2' detailTitle  
                            UNION ALL
                            SELECT 'Photo' valueId,'Photo' detailTitle  ";

            _sl.SetDDL3(ref docType, strSQL, "valueId", "detailTitle", "", "Select");
        }

        protected string GetCustomerName()
        {
            return "Customer Name : " + remLibrary.GetCustomerName(GetCustomerId().ToString());
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
            remLibrary.CheckAuthentication(ViewFunctionId);
        }
        #region FileUpload

        private void Upload()
        {
            if (docType.SelectedValue == "")
            {
                lblMsg.Text = "Please select file type.";
                lblMsg.ForeColor = Color.Red;
                return;
            }
            string type = "doc";
            string root = "";
            string info = "";
            string strMessage = "";
            if (fileUpload.PostedFile.FileName != null)
            {
                string pFile = fileUpload.PostedFile.FileName.Replace("\\", "/");

                int pos = pFile.LastIndexOf(".");
                if (pos < 0)
                    type = "";
                else
                    type = pFile.Substring(pos + 1, pFile.Length - pos - 1);

                root = GetStatic.GetDefaultDocPath(); //ConfigurationSettings.AppSettings["root"];

                info = UploadFile(docType.SelectedValue + "." + type, GetCustomerId().ToString(), root);

                if (info.Substring(0, 5) == "error")
                {
                    strMessage = info;
                    lblMsg.Text = strMessage;
                    lblMsg.ForeColor = Color.Red;

                    return;
                }

                DbResult dbResult = cdd.Update(GetStatic.GetUser(), GetCdId().ToString(), GetCustomerId().ToString(),
                                               docType.SelectedValue, type, GetStatic.GetAgentId(), GetStatic.GetBranch());
                string locationToMove = root + "\\doc";

                string fileToCreate = locationToMove + "\\" + dbResult.Id;

                if (File.Exists(fileToCreate))
                    File.Delete(fileToCreate);

                if (!Directory.Exists(locationToMove))
                    Directory.CreateDirectory(locationToMove);

                File.Move(info, fileToCreate);

                strMessage = "File Uploaded Successfully.";
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

        private void ListFileInformation(DataTable dt)
        {
            TableRow tr = null;
            TableCell td1 = null;
            TableCell td2 = null;
            TableCell td3 = null;

            tblResult.CellPadding = 3;
            tblResult.CellSpacing = 0;

            tr = new TableRow();
            td1 = new TableCell();
            td2 = new TableCell();
            td3 = new TableCell();

            td1.Text = "<strong>File Desciption</strong>";
            td2.Text = "<strong>File Type</strong>";
            td3.Text = "<strong>View</strong>";

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
                td3.Text = "<a title = \"View File\" href=\"javascript:void(0)\" " + jsText + "\">View</a>";

                tr.Cells.Add(td1);
                tr.Cells.Add(td2);
                tr.Cells.Add(td3);
                tblResult.Rows.Add(tr);
            }
        }
        #endregion
        protected void btnUpload_Click(object sender, EventArgs e)
        {
            Upload();
        }
    }
}