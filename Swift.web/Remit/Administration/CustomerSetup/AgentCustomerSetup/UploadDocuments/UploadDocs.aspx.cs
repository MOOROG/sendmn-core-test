using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.BL.System.Utility;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.IO;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.CustomerSetup.AgentCustomerSetup.UploadDocuments
{
    public partial class UploadDocs : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40122000";
        private const string AddEditFunctionId = "40122010";

        private readonly StaticDataDdl _sl = new StaticDataDdl();
        private readonly CustomerDocumentDao cdd = new CustomerDocumentDao();
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();
        private readonly CustomersDao obj = new CustomersDao();

        private string _fileToBeDeleted = "";
        //string root = ConfigurationSettings.AppSettings["root"];

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            GetStatic.ResizeFrame(Page);

            if (Request.Form["chkTran"] != null)
                _fileToBeDeleted = Request.Form["chkTran"];
            string reqMethod = Request.Form["MethodName"];
            if (!IsPostBack)
            {
                //Authenticate();
                PopulateDdl();
                PopulateDataById();

                #region Ajax methods

                switch (reqMethod)
                {
                    case "calender":
                        LoadCalender();
                        break;
                }

                #endregion Ajax methods
            }
            idType.Attributes.Add("onchange", "IdOnChange()");

            dobEng.Attributes.Add("onchange", "LoadCalender('e','dob')");
            dobNep.Attributes.Add("onchange", "LoadCalender('n','dob')");

            issueDate.Attributes.Add("onchange", "LoadCalender('e','issue')");
            issueDateNp.Attributes.Add("onchange", "LoadCalender('n','issue')");

            expiryDate.Attributes.Add("onchange", "LoadCalender('e','expiry')");
            expiryDateNp.Attributes.Add("onchange", "LoadCalender('n','expiry')");
        }

        private void LoadCalender()
        {
            var date = Request.Form["date"];
            var type = Request.Form["type"];
            var dt = obj.LoadCalender(GetStatic.GetUser(), date, type);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        public static string DataTableToJson(DataTable table)
        {
            if (table == null)
                return "";
            var list = new List<Dictionary<string, object>>();

            foreach (DataRow row in table.Rows)
            {
                var dict = new Dictionary<string, object>();

                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = string.IsNullOrEmpty(row[col].ToString()) ? "" : row[col];
                }
                list.Add(dict);
            }
            var serializer = new JavaScriptSerializer();
            string json = serializer.Serialize(list);
            return json;
        }

        private void PopulateDataById()
        {
            if (GetCustomerId() <= 0) return;

            DataRow dr = obj.SelectByIdAgent(GetStatic.GetUser(), GetCustomerId().ToString());
            if (dr == null)
                return;
            hdnCustomerId.Value = dr["customerId"].ToString();

            customerCardNo.Text = dr["membershipId"].ToString();
            customerCardNo.Attributes.Add("readonly", "true");

            firstName.Text = dr["firstName"].ToString();
            firstName.Attributes.Add("readonly", "true");

            middleName.Text = dr["middleName"].ToString();
            middleName.Attributes.Add("readonly", "true");

            lastName.Text = dr["lastName"].ToString();
            lastName.Attributes.Add("readonly", "true");

            dobEng.Text = dr["dobEng"].ToString();
            dobNep.Text = dr["dobNep"].ToString();

            idType.SelectedValue = dr["idType1"].ToString();
            GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
            issueDate.Text = dr["issueDate"].ToString();
            expiryDate.Text = dr["expiryDate"].ToString();
            issueDateNp.Text = dr["issueDateNp"].ToString();
            expiryDateNp.Text = dr["expiryDateNp"].ToString();
            idNo.Text = dr["idNo"].ToString();
            placeOfIssue.SelectedValue = dr["placeOfIssue"].ToString();

            if (dr["approvedBy"].ToString() != "")
            {
                customerCardNo.Enabled = false;
                tblResult.Visible = true;
                //hdnIsDelete.Value = "N";
                btnSave.Visible = false;
            }
            else
            {
                tblResult.Visible = true;
                //hdnIsDelete.Value = "Y";
                btnSave.Visible = true;
            }
            ListFileInformation(cdd.PopulateCustomerDocument(GetStatic.GetUser(), GetCustomerId().ToString()));
        }

        /*
         private bool ClientValidation()
         {
             DateTime dt;
             bool isValidDate = false;
             if (!String.IsNullOrEmpty(dobEng.Text))
             {
                 isValidDate = String.IsNullOrEmpty(dobEng.Text) ? false : DateTime.TryParse(dobEng.Text, out dt);
                 if (isValidDate)
                 {
                     DateTime _dob = Convert.ToDateTime(dobEng.Text);
                     if (_dob > DateTime.Now)
                     {
                         lblDobChk.Text = "Invalid Date";
                         dobEng.Focus();
                         GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
                         return false;
                     }
                 }
                 else
                 {
                     lblDobChk.Text = "Invalid Data Format.";
                     dobEng.Focus();
                     GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
                     return false;
                 }
             }

             string[] idTypeArr = idType.SelectedValue.Split('|');

             if (idTypeArr.Length > 1)
             {
             }

                 if (issueDate.Text == "")
                 {
                     GetStatic.AlertMessage(Page, "Please enter identification's Issue Date & Expiry Date.");
                     GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
                     return false;
                 }
                 if (issueDate.Text == "" || expiryDate.Text == "")
                 {
                     GetStatic.AlertMessage(Page, "Please enter identification's Issue Date & Expiry Date.");
                     GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
                     return false;
                 }

                 isValidDate = String.IsNullOrEmpty(issueDate.Text) ? false : DateTime.TryParse(issueDate.Text, out dt);
                 if (!isValidDate)
                 {
                     GetStatic.AlertMessage(Page, "Invalid Date Format for Issue Date.");
                     GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
                     return false;
                 }

                 isValidDate = String.IsNullOrEmpty(expiryDate.Text) ? false : DateTime.TryParse(expiryDate.Text, out dt);
                 if (!isValidDate)
                 {
                     GetStatic.AlertMessage(Page, "Invalid Date Format for Expiry Date.");
                     GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
                     return false;
                 }

             return true;
         }
         */

        private bool ClientValidation()
        {
            DateTime dt;
            string[] idTypeSelected = idType.SelectedValue.Split('|');
            bool isValidDate = false;
            if (!String.IsNullOrEmpty(dobEng.Text))
            {
                isValidDate = String.IsNullOrEmpty(dobEng.Text) ? false : DateTime.TryParse(dobEng.Text, out dt);
                if (isValidDate)
                {
                    DateTime _dob = Convert.ToDateTime(dobEng.Text);
                    if (_dob > DateTime.Now)
                    {
                        lblDobChk.Text = "Invalid Date";
                        dobEng.Focus();
                        GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
                        return false;
                    }
                }
                else
                {
                    lblDobChk.Text = "Invalid Data Format.";
                    dobEng.Focus();
                    GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
                    return false;
                }
            }

            if (issueDate.Text == "")
            {
                GetStatic.AlertMessage(Page, "Please enter identification's Issue Date.");
                GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
                return false;
            }

            if (idTypeSelected.Length == 2)
            {
                if (idTypeSelected[1] == "E")
                {
                    if (expiryDate.Text == "")
                    {
                        GetStatic.AlertMessage(Page, "Please enter identification's Expiry Date.");
                        GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
                        return false;
                    }
                }
            }
            else
            {
                if (idTypeSelected[0] != "1301" && idTypeSelected[0] != "Citizenship")
                {
                    if (expiryDate.Text == "")
                    {
                        GetStatic.AlertMessage(Page, "Please enter identification's Expiry Date.");
                        GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
                        return false;
                    }
                }
            }

            isValidDate = String.IsNullOrEmpty(issueDate.Text) ? false : DateTime.TryParse(issueDate.Text, out dt);
            if (!isValidDate)
            {
                GetStatic.AlertMessage(Page, "Invalid Date Format for Issue Date.");
                GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
                return false;
            }
            isValidDate = String.IsNullOrEmpty(expiryDate.Text.Trim()) ? true : DateTime.TryParse(expiryDate.Text, out dt);
            if (!isValidDate)
            {
                GetStatic.AlertMessage(Page, "Invalid Date Format for Expiry Date.");
                GetStatic.CallBackJs1(Page, "IdOnChange", "IdOnChange();");
                return false;
            }

            return true;
        }

        private void PopulateDdl()
        {
            var strSQL = @"SELECT 'IdCard' valueId,'Citizenship-1' detailTitle
                            UNION ALL
                            SELECT 'IdCard_2' valueId,'Citizenship-2' detailTitle
                            UNION ALL
                            SELECT 'Photo' valueId,'Photo' detailTitle  ";

            _sl.SetDDL3(ref docType, strSQL, "valueId", "detailTitle", "", "Select");
            _sl.SetDDL3(ref placeOfIssue, "EXEC proc_IdIssuedPlace ", "valueId", "detailTitle", "", "Select");
            _sl.SetDDL(ref idType, "EXEC proc_countryIdType @flag = 'il-with-et', @countryId='151', @spFlag = '5201'", "valueId", "detailTitle", "", "Select");
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
            remitLibrary.CheckAuthentication(ViewFunctionId);
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
            string type = "";
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

                if (info.Substring(0, 5) == "Error")
                {
                    strMessage = info;
                    lblMsg.Text = strMessage;
                    lblMsg.ForeColor = Color.Red;

                    return;
                }

                DbResult dbResult = cdd.Update(GetStatic.GetUser(), GetCdId().ToString(), GetCustomerId().ToString(),
                                               docType.SelectedValue, type, GetStatic.GetAgentId(), GetStatic.GetBranch());

                if (dbResult.ErrorCode != "0")
                {
                    strMessage = dbResult.Msg;
                    lblMsg.Text = strMessage;
                    lblMsg.ForeColor = Color.Red;

                    if (File.Exists(info))
                        File.Delete(info);
                }
                else
                {
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
                }

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
                    if (IsImage(fileUpload))
                    {
                        CompressImageDao ci = new CompressImageDao();
                        var original_imagePath = root + "\\doc\\tmp\\" + id + "_org_" + GetStatic.GetSessionId();
                        fileUpload.PostedFile.SaveAs(original_imagePath);

                        if (!ci.CompressImageAndSave((fileUpload.PostedFile.ContentLength / 1024), original_imagePath, saved_file_name))
                        {
                            fileUpload.PostedFile.SaveAs(saved_file_name);
                        }
                        return saved_file_name;
                    }
                    return "Error:Invalid File Type";
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

                string fileLink = "id=" + row["cdId"] + "&functionId=20101100";
                string filePage = GetStatic.GetUrlRoot() + "/ShowFile.aspx?" + fileLink;
                string PopUpParam = "";
                string jsText = "onclick = \"PopUpWindow('" + filePage + "','" + PopUpParam + "');\"";

                td1.Text = row["fileDescription"].ToString();
                td2.Text = row["fileType"].ToString();
                if (hdnIsDelete.Value == "Y")
                    td3.Text = "<a title = \"View File\" href=\"javascript:void(0)\" " + jsText + "\">" + Misc.GetIcon("info") + " </a>&nbsp;<span onclick=Delete('" + row["cdId"] + "')>" + Misc.GetIcon("delete") + "</span>";
                else
                    td3.Text = "<a title = \"View File\" href=\"javascript:void(0)\" " + jsText + "\">" + Misc.GetIcon("info") + " </a>";
                tr.Cells.Add(td1);
                tr.Cells.Add(td2);
                tr.Cells.Add(td3);
                tblResult.Rows.Add(tr);
            }
        }

        #endregion FileUpload

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            Upload();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void Update()
        {
            if (!ClientValidation())
                return;

            DbResult dbResult = obj.UpdateCustEnrollAgent(
                                GetStatic.GetUser(),
                                GetCustomerId().ToString(),
                                customerCardNo.Text,
                                dobEng.Text,
                                dobNep.Text,
                                idType.SelectedValue.Split('|')[0],
                                idNo.Text,
                                placeOfIssue.Text,
                                issueDate.Text,
                                expiryDate.Text,
                                issueDateNp.Text,
                                expiryDateNp.Text,
                                GetStatic.GetBranch()
                                );
            if (dbResult.ErrorCode.Equals("0"))
            {
                PopulateDataById();
            }

            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.PrintMessage(this, dbResult);
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
    }
}