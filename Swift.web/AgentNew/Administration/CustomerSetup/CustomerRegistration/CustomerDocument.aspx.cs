using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.Administration.CustomerSetup.CustomerRegistration
{
    public partial class CustomerDocument : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private readonly SwiftGrid _grid = new SwiftGrid();
        private const string ViewFunctionId = "20111300";
        private const string ViewFunctionIdAgent = "20205000";
        private const string ViewDocFunctionId = "20111330";
        private const string UploadDocFunctionId = "20111340";
        private const string ViewDocFunctionIdAgent = "20205010";
        private const string UploadDocFunctionIdAgent = "20205020";
        private const string GridName = "grid_list";

        protected void Page_Load(object sender, EventArgs e)
        {
            downloadFile.Visible = false;
            if (!IsPostBack)
            {
                HideSearchDiv();
                Authenticate();
                GetStatic.PrintMessage(Page);
                DDLPopulate();
                fileDisplay.ImageUrl = "../../../GetFileView.ashx?imageName=";
            }
            if (GetCustomerId() != "")
            {
                LoadGrid();
            }
            else
            {
                GetStatic.CallBackJs1(Page, "hideDive", "HideFormDisplay()");
            }
        }
        private void HideSearchDiv()
        {
            string hide = GetStatic.ReadQueryString("hideSearchDiv","").ToString();
            if (hide == "true")
            {
                displayOnlyOnEdit.Visible = false;
                hideSearchDiv.Value = "true";
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
            string cusId = GetCustomerId();
            if (cusId == "")
            {
                return;
            }
            var dr = _cd.GetCustomerDetails(cusId, GetStatic.GetUser());
            customerName.InnerText = dr["fullName"].ToString();
            hdnMembershipId.Value = dr["membershipId"].ToString();
            hdnRegisterDate.Value = Convert.ToDateTime(dr["createdDate"]).ToString("yyyy/MM/dd");

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
                                      new GridColumn("documentTypeName", "Document Type", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate","Regd. Date","","D"),
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
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
            _grid.CustomLinkVariables = "cdId,customerId,fileType";
            var uploadLink = _sl.HasRight(GetFunctionIdByUserType(UploadDocFunctionIdAgent, UploadDocFunctionId)) ? "<btn type=\"button\" class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Edit\" onclick=\"editPage(@cdId);\"><i class=\"fa fa-edit\" ></i></btn>" : "";

            _grid.CustomLinkText = uploadLink + "&nbsp;<btn type=\"button\" class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"View\" onclick=\"showDocument(@cdId,'@fileType');\"><i class=\"fa fa-eye\"></i></btn>";
            string sql = "EXEC [proc_customerDocumentType] @flag = 's',@customerId='" + cusId + "' ";
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
            _sl.SetDDL(ref ddlSearchBy, "exec proc_sendPageLoadData @flag='search-cust-by'", "VALUE", "TEXT", "", "");
        }

        private string GetCustomerId()
        {
            string customerId = GetStatic.ReadQueryString("customerId", "");
            if (customerId == "")
                customerId = hdncustomerId.Value;
            return customerId;
        }
        private string GetCustomerDocumentId()
        {
            string customerDocId = GetStatic.ReadQueryString("cdId", "");
            if (customerDocId == "")
                customerDocId = hdnDocumentTypeId.Value;
            return customerDocId;
        }
        private void populateForm()
        {
            msgDiv.Visible = false;
            if (GetCustomerDocumentId() == "")
                return;
            var dr = _cd.GetCustomerDocumentByDocumentId(GetCustomerDocumentId(), GetStatic.GetUser());
            if (dr["fileType"].ToString() == "signature")
            {
                //saveDocument.Enabled = false;
                hdnDocumentTypeId.Value = "";
                GetStatic.AlertMessage(this, "Sorry signature cannot be edited");
                return;
            }
            saveDocument.Enabled = true;
            txtSearchData.Value = dr["customerId"].ToString();
            txtSearchData.Text = dr["fullName"].ToString();
            if (dr != null)
            {
                hdnDocumentTypeId.Value = dr["cdId"].ToString();
                hdncustomerId.Value = dr["customerId"].ToString();
                hdnFileName.Value = dr["fileName"].ToString();
                ddlDocumentType.SelectedValue = dr["documentType"].ToString();
                txtDocumentDescription.Text = dr["fileDescription"].ToString();
                hdnMembershipId.Value = dr["membershipId"].ToString();
                hdnFileType.Value = dr["fileType"].ToString();
                if (dr["fileName"].ToString() != "")
                    fileDisplay.ImageUrl = "../../../GetFileView.ashx?imageName=" + dr["fileName"] + "&customerId=" + hdnMembershipId.Value + "&fileType=" + dr["fileType"].ToString();
                downloadFile.Visible = true;
            }
        }

        protected void saveDocument_Click(object sender, EventArgs e)
        {
            if (hdncustomerId.ToString() == "" || hdncustomerId.ToString() == null)
            {
                GetStatic.AlertMessage(this, "Please choose customer first");
            }
            DbResult _dbRes = new DbResult();
            if (!_sl.HasRight(GetFunctionIdByUserType(UploadDocFunctionIdAgent, UploadDocFunctionId)))
            {
                _dbRes.SetError("1", "You are not authorized to Update Data", null);
                GetStatic.AlertMessage(this, _dbRes.Msg);
                return;
            }

            string fileType = "";
            string fileName = (!string.IsNullOrWhiteSpace(fileDocument.FileName) ? UploadDocument(fileDocument, out fileType) : hdnFileName.Value);
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
            string custId = GetCustomerId();
            hdncustomerId.Value = hdncustomerId.Value == "" ? custId : hdncustomerId.Value;
            var result = _cd.UpdateCustomerDocument(hdnDocumentTypeId.Value, hdncustomerId.Value, fileName, txtDocumentDescription.Text, fileType, ddlDocumentType.SelectedValue, GetStatic.GetUser());
            if (result.ErrorCode == "0")
            {
                //GetStatic.SetMessage(result);
                ////Response.Redirect("CustomerDocument.aspx?customerId=" + hdncustomerId.Value);
                //Response.Redirect("CustomerDocument.aspx");
                GetStatic.AlertMessage(this, result.Msg);
                ddlDocumentType.Text = "";
                txtDocumentDescription.Text = "";
                string custInfo = hdncustomerId.Value + "," + (hdncustomerName.Value == "" ? GetCustomerName(custId) : hdncustomerName.Value) + "," + result.Msg;
                GetStatic.CallBackJs1(Page, "customerDoc", "PopulateAutoComplete('" + custInfo + "')");
                LoadGrid();
                return;
            }
            else
            {
                GetStatic.AlertMessage(this, result.Msg);
                return;
            }
        }

        private string UploadDocument(FileUpload doc, out string fileType)
        {
            fileType = "";
            string fName = "";
            try
            {
                fileType = doc.PostedFile.ContentType;
                string fileExtension = new FileInfo(doc.PostedFile.FileName).Extension;
                string documentExtension = GetStatic.ReadWebConfig("customerDocFileExtension", "");
                if (documentExtension.ToLower().Contains(fileExtension.ToLower()))
                {
                    string fileName = hdncustomerId.Value + "_" + ddlDocumentType.SelectedItem.Text + "_" + DateTime.Now.Hour.ToString() + DateTime.Now.Millisecond.ToString() + "_" + hdnRegisterDate.Value.Replace("/", "_") + fileExtension;
                    string path = GetStatic.GetCustomerFilePath() + "CustomerDocument\\" + hdnRegisterDate.Value.Replace("_", "\\") + "\\" + hdnMembershipId.Value;
                    if (!Directory.Exists(path))
                        Directory.CreateDirectory(path);
                    doc.SaveAs(path + "/" + fileName);
                    fName = fileName;
                }
                else
                {
                    fName = "notValid";
                }

            }
            catch (Exception ex)
            {
                fName = "";
            }
            return fName;
        }

        protected void downloadFile_Click(object sender, EventArgs e)
        {
            try
            {
                msgDiv.Visible = false;
                if (string.IsNullOrEmpty(hdnFileName.Value) && string.IsNullOrWhiteSpace(hdnFileName.Value) || hdnFileName.Value.Split('_').Count() < 6)
                    return;
                var dirLocation = hdnFileName.Value.Split('_')[3].ToString() + "\\" + hdnFileName.Value.Split('_')[4].ToString() + "\\" + hdnFileName.Value.Split('_')[5].Split('.')[0].ToString() + "\\";
                var path = GetStatic.GetCustomerFilePath() + "CustomerDocument\\" + dirLocation + hdnMembershipId.Value + "\\" + hdnFileName.Value;
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

        protected void clickBtnForGetCustomerDetails_Click(object sender, EventArgs e)
        {
            downloadFile.Visible = false;
            hdnFileName.Value = null;
            fileDisplay.ImageUrl = "/AgentNew/GetFileView.ashx?imageName=" + hdnFileName.Value + "&customerId=" + hdnMembershipId.Value + "&fileType=" + hdnFileType.Value;
            populateForm();
        }

        protected void clickEditCustomerDocument_Click(object sender, EventArgs e)
        {
            populateForm();
        }
        protected string GetCustomerName(string cusId)
        {
            OnlineCustomerDao _cd = new OnlineCustomerDao();
            var dr = _cd.GetCustomerDetails(cusId, GetStatic.GetUser());
            return dr["fullName"].ToString();
        }
    }
}