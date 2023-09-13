using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.CustomerSetup
{
    public partial class CustomerDocument : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private readonly SwiftGrid _grid = new SwiftGrid();
        private const string ViewFunctionId = "20111300";
        private const string ViewFunctionIdAgent = "40120000";
        private const string ViewDocFunctionId = "20111330";
        private const string UploadDocFunctionId = "20111340";
        private const string ViewDocFunctionIdAgent = "40120030";
        private const string UploadDocFunctionIdAgent = "40120040";
        private const string GridName = "grid_list";

        protected void Page_Load(object sender, EventArgs e)
        {
            downloadFile.Visible = false;
            fileDisplay.ImageUrl = "/Remit/GetFileView.ashx?fileName=" + hdnFileName.Value + "&membershipNo=" + hdnMembershipId.Value + "&registerDate=" + hdnRegisterDate.Value;
            LoadGrid();
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                string cusDocumentId = GetStatic.ReadQueryString("cdId", "");
                DDLPopulate();
                if (cusDocumentId != "")
                {
                    populateForm(cusDocumentId);
                }
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId) + "," + GetFunctionIdByUserType(ViewDocFunctionIdAgent, ViewDocFunctionId));

            var hasRight = _sl.HasRight(GetFunctionIdByUserType(UploadDocFunctionIdAgent, UploadDocFunctionId));
            saveDocument.Enabled = hasRight;
            saveDocument.Visible = hasRight;
        }

        private void LoadGrid()
        {
            string cusId = GetStatic.ReadQueryString("customerId", "");
            var dr = _cd.GetCustomerDetails(cusId, GetStatic.GetUser());
            hdncustomerId.Value = cusId;
            customerName.InnerText = dr["fullName"].ToString();
            hdnMembershipId.Value = dr["membershipId"].ToString();
            hdnRegisterDate.Value = dr["createdDate"].ToString();

            _grid.FilterList = new List<GridFilter>
                                  {
                                     new GridFilter("fileType", "File Type", "1:EXEC proc_online_dropDownList @flag='dropdownGridList',@parentId='7009'"),
                                     new GridFilter("fileDescription", "File Description", "T"),
                                     new GridFilter("createdDate", "Created Date", "d"),
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("fileName", "File Name", "", "T"),
                                      new GridColumn("fileType", "File Type", "", "T"),
                                      new GridColumn("fileDescription", "File Description", "", "T"),
                                      new GridColumn("documentType", "Document Type", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate","Regd. Date","","D"),
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.ShowAddButton = _sl.HasRight(GetFunctionIdByUserType(UploadDocFunctionIdAgent, UploadDocFunctionId));
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "cdId";
            _grid.InputPerRow = 4;
            _grid.AddPage = "CustomerDocument.aspx?customerId=" + cusId;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.AllowCustomLink = true;
            _grid.CustomLinkVariables = "cdId,customerId";

            var uploadLink = _sl.HasRight(GetFunctionIdByUserType(UploadDocFunctionIdAgent, UploadDocFunctionId)) ? "<btn type=\"button\" class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Edit\" onclick=\"editPage(@cdId);\"><i class=\"fa fa-edit\" ></i></btn>" : "";

            _grid.CustomLinkText = uploadLink + "&nbsp;<btn type=\"button\" class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"View\" onclick=\"showDocument(@cdId);\"><i class=\"fa fa-eye\"></i></btn>"; string sql = "EXEC [proc_customerDocumentType] @flag = 's',@customerId='" + cusId + "' ";
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }

        private void DDLPopulate()
        {
            _sl.SetDDL(ref ddlDocumentType, "EXEC proc_online_dropDownList @flag='dropdownList',@parentId='7009'", "valueId", "detailTitle", ddlDocumentType.SelectedValue, "Select..");
        }

        private void populateForm(string customerDocumentId)
        {
            msgDiv.Visible = false;
            var dr = _cd.GetCustomerDocumentByDocumentId(customerDocumentId, GetStatic.GetUser());
            if (dr != null)
            {
                var registerDate = Convert.ToDateTime(dr["registerDate"]).ToString("yyyy-MM-dd");
                hdnRegisterDate.Value = registerDate;
                hdnDocumentTypeId.Value = dr["cdId"].ToString();
                hdncustomerId.Value = dr["customerId"].ToString();
                hdnFileName.Value = dr["fileName"].ToString();
                ddlDocumentType.SelectedValue = dr["documentType"].ToString();
                txtDocumentDescription.Text = dr["fileDescription"].ToString();
                hdnFileType.Value = dr["fileType"].ToString();
                if (dr["fileName"].ToString() != "")
                    fileDisplay.ImageUrl = "/Remit/GetFileView.ashx?fileName=" + dr["fileName"] + "&membershipNo=" + hdnMembershipId.Value + "&registerDate=" + registerDate;
                //downloadFile.Visible = true;
            }
        }

        protected void saveDocument_Click(object sender, EventArgs e)
        {
            DbResult _dbRes = new DbResult();
            if (!_sl.HasRight(GetFunctionIdByUserType(UploadDocFunctionIdAgent, UploadDocFunctionId)))
            {
                _dbRes.SetError("1", "You are not authorized to Update Data", null);
                GetStatic.AlertMessage(this, _dbRes.Msg);
                return;
            }

            string fileType = "";
            //string fileName = (!string.IsNullOrWhiteSpace(fileDocument.FileName) ? UploadDocument(fileDocument, out fileType) : hdnFileName.Value);
            var fileName = fileDocument.FileName != "" ? UploadImage(fileDocument, hdnRegisterDate.Value, hdnMembershipId.Value, hdncustomerId.Value, ddlDocumentType.SelectedItem.Text, out fileType) : "";
            if (fileName == "invalidSize")
            {
                GetStatic.AlertMessage(this, "File size exceeded for passport. Please upload image of size less than 2mb.");
                return;
            }
            else if (fileName == "notValid")
            {
                GetStatic.AlertMessage(this, "Only " + GetStatic.ReadWebConfig("customerDocFileExtension", "") + " files are allowed");
                return;
            }
            if (fileName != "")
            {
                var result = _cd.UpdateCustomerDocument(hdnDocumentTypeId.Value, hdncustomerId.Value, fileName, txtDocumentDescription.Text, fileType, ddlDocumentType.SelectedValue, GetStatic.GetUser());
                if (result.ErrorCode == "0")
                {
                    GetStatic.SetMessage(result);
                    Response.Redirect("CustomerDocument.aspx?customerId=" + hdncustomerId.Value);
                    return;
                }
                else
                {
                    GetStatic.AlertMessage(this, result.Msg);
                    return;
                }
            }
        }

        protected void clickEditCustomerDocument_Click(object sender, EventArgs e)
        {
            var customerDocumentId = hdnDocumentTypeId.Value;
            populateForm(customerDocumentId);
        }

        public string UploadImage(FileUpload doc, string registerDate, string membershipId, string customerId, string idTypeName, out string fileType)
        {
            fileType = "";
            try
            {
                string fileExtension = new FileInfo(doc.PostedFile.FileName).Extension;
                string documentExtension = GetStatic.ReadWebConfig("customerDocFileExtension", "");
                if (documentExtension.ToLower().Contains(fileExtension.ToLower()))
                {
                    fileType = doc.PostedFile.ContentType;
                    string rootPath = GetStatic.GetCustomerFilePath();
                    string folderPath = Path.Combine(rootPath, "CustomerDocument", registerDate.Replace("-", "\\"), membershipId);
                    if (!Directory.Exists(folderPath))
                        Directory.CreateDirectory(folderPath);
                    string fileName = customerId + "_" + idTypeName + fileExtension;
                    string filePath = Path.Combine(folderPath, fileName);
                    doc.SaveAs(filePath);
                    return fileName;
                }
                return "invalidSize";
            }
            catch (Exception)
            {
                return "";
            }
        }

        protected void downloadFile_Click(object sender, EventArgs e)
        {
            try
            {
                downloadFile.Visible = false;
                var path = GetStatic.GetFilePath() + "CustomerDocument\\" + hdnMembershipId.Value + "\\" + hdnFileName.Value;
                if (!File.Exists(path))
                {
                    msgDiv.Visible = true;
                    msgLabel.Text = "File Not Found";
                    Page_Load(sender, e);
                    return;
                }
                FileInfo ObjArchivo = new FileInfo(path);
                Response.Clear();
                Response.AddHeader("Content-Disposition", "attachment; filename=" + hdnFileName.Value);
                Response.AddHeader("Content-Length", ObjArchivo.Length.ToString());
                Response.ContentType = hdnFileType.Value;
                Response.WriteFile(ObjArchivo.FullName);
                Response.End();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}