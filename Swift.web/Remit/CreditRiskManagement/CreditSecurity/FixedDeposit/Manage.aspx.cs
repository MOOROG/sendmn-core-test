using Swift.DAL.BL.Remit.CreditRiskManagement.CreditSecurity;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Drawing;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.CreditRiskManagement.CreditSecurity.FixedDeposit
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20181400";
        private const string AddEditFunctionId = "20181410";
        private readonly CreditSecurityDocDao csd = new CreditSecurityDocDao();
        private readonly FixedDepositDao obj = new FixedDepositDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        private string _fileToBeDeleted = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            followUpDate.ReadOnly = true;
            expiryDate.ReadOnly = true;
            issuedDate.ReadOnly = true;
            if (Request.Form["chkTran"] != null)
                _fileToBeDeleted = Request.Form["chkTran"];
            if (!IsPostBack)
            {
                Authenticate();
                MakeNumericTextBox();
                if (GetId() > 0)
                {
                    PopulateDataById();
                    ListFileInformation(csd.PopulateCustomerDocument(GetStatic.GetUser(), GetId().ToString(), "F"));
                }
                else
                {
                    PopulateDdl(null);
                }
            }
        }

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref amount);
        }

        #region Method

        protected string GetAgentName()
        {
            return "Agent Name : " + sdd.GetAgentName(GetAgentId().ToString());
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("fdId");
        }

        private long GetSdId()
        {
            return GetStatic.ReadNumericDataFromQueryString("sdId");
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref currency, "EXEC proc_currencyMaster @flag = 'bcd'", "currencyId", "currencyCode",
                GetStatic.GetRowData(dr, "currency") == "" ? "1" : GetStatic.GetRowData(dr, "currency"), "");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            fixedDepositNo.Text = dr["fixedDepositNo"].ToString();
            amount.Text = dr["amount"].ToString();
            bankName.Text = dr["bankName"].ToString();
            issuedDate.Text = dr["issuedDate1"].ToString();
            expiryDate.Text = dr["expiryDate1"].ToString();
            followUpDate.Text = dr["followUpDate1"].ToString();
            PopulateDdl(dr);
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(), GetId().ToString(), GetAgentId().ToString(),
                                           fixedDepositNo.Text, amount.Text, currency.Text, bankName.Text,
                                           issuedDate.Text, expiryDate.Text, followUpDate.Text, GetStatic.GetSessionId());
            ManageMessage(dbResult);
        }

        private void DeleteRow()
        {
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), GetId().ToString());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx?agentId=" + GetAgentId());
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        #endregion Method

        #region Element Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DeleteRow();
        }

        #endregion Element Method

        #region FileUpload

        private void Upload()
        {
            string type = "doc";
            string root = "";
            string info = "";

            if (fileUpload.PostedFile.FileName != null)
            {
                string pFile = fileUpload.PostedFile.FileName.Replace("\\", "/");

                int pos = pFile.LastIndexOf(".");
                if (pos < 0)
                    type = "";
                else
                    type = pFile.Substring(pos + 1, pFile.Length - pos - 1);

                root = GetStatic.GetDefaultDocPathMortgage(); //ConfigurationSettings.AppSettings["root"];

                info = UploadFile(fixedDepositNo.Text + "." + type, GetId().ToString(), root);

                if (info.Substring(0, 5) == "error")
                    return;

                DbResult dbResult = csd.Update(GetStatic.GetUser(), GetSdId().ToString(), GetId().ToString(), "F",
                                               fileDescription.Text, type, GetStatic.GetSessionId());
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

                ListFileInformation(csd.PopulateCustomerDocument(GetStatic.GetUser(), GetId().ToString(), "F"));
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
            TableCell td4 = null;

            tblResult.CellPadding = 3;
            tblResult.CellSpacing = 0;

            if (dt.Rows.Count <= 0)
            {
                btnDeleteFile.Visible = false;
                return;
            }
            btnDeleteFile.Visible = true;
            tr = new TableRow();
            td1 = new TableCell();
            td2 = new TableCell();
            td3 = new TableCell();
            td4 = new TableCell();

            td1.Text = "<strong>File Desciption</strong>";
            td2.Text = "<strong>File Type</strong>";
            td3.Text = "<strong>Delete</strong>";
            td4.Text = "<strong>View</strong>";

            td1.CssClass = "HeaderStyle";
            td2.CssClass = "HeaderStyle";
            td3.CssClass = "HeaderStyle";
            td4.CssClass = "HeaderStyle";

            tr.Cells.Add(td1);
            tr.Cells.Add(td2);
            tr.Cells.Add(td3);
            tr.Cells.Add(td4);

            tblResult.Rows.Add(tr);

            foreach (DataRow row in dt.Rows)
            {
                tr = new TableRow();
                td1 = new TableCell();
                td2 = new TableCell();
                td3 = new TableCell();
                td4 = new TableCell();

                string fileLink = "id=" + row["sdId"] + "&functionId=" + ViewFunctionId;
                string filePage = GetStatic.GetUrlRoot() + "/ShowFile.aspx?" + fileLink;
                string PopUpParam = "";
                string jsText = "onclick = \"PopUpWindow('" + filePage + "','" + PopUpParam + "');\"";

                td1.Text = row["fileDescription"].ToString();
                td2.Text = row["fileType"].ToString();
                td3.Text = "<input type='checkbox' name='chkTran' cIdentityId='chkTran' value='" + row["sdId"] + "'>";

                td4.Text = "<a title = \"View File\" href=\"javascript:void(0)\" " + jsText + "\">View</a>";

                tr.Cells.Add(td1);
                tr.Cells.Add(td2);
                tr.Cells.Add(td3);
                tr.Cells.Add(td4);
                tblResult.Rows.Add(tr);
            }
        }

        private void DeleteFile()
        {
            if (_fileToBeDeleted != "")
            {
                string root = GetStatic.GetDefaultDocPath(); //ConfigurationSettings.AppSettings["root"];

                DataTable dt = csd.Delete(GetStatic.GetUser(), _fileToBeDeleted);

                string location = root + "\\doc";

                foreach (DataRow row in dt.Rows)
                {
                    if (File.Exists(location + "\\" + row[0]))
                        File.Delete(location + "\\" + row[0]);
                }

                string strMessage = "File Deleted successfully";
                lblMsg.Text = strMessage;
                lblMsg.ForeColor = Color.Red;

                ListFileInformation(csd.PopulateCustomerDocument(GetStatic.GetUser(), GetId().ToString(), "F"));
            }
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            Upload();
        }

        protected void btnDeleteFile_Click(object sender, EventArgs e)
        {
            DeleteFile();
        }

        #endregion FileUpload
    }
}