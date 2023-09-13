using Swift.DAL.OnlineAgent;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Responsive.CustomerSetup
{
    public partial class CustomerDocument : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private readonly SwiftGrid _grid = new SwiftGrid();
        private const string ViewFunctionId = "20111300";
        private const string GridName = "grid_list";

        protected void Page_Load(object sender, EventArgs e)
        {
            downloadFile.Visible = false;
            LoadGrid();
            DDLPopulate();
            if (!IsPostBack)
            {
                _sl.CheckAuthentication(ViewFunctionId);
                GetStatic.PrintMessage(Page);
                
                string cusDocumentId = GetStatic.ReadQueryString("cdId", "");
                if (cusDocumentId != "")
                {
                    populateForm(cusDocumentId);
                }
            }

        }

        private void LoadGrid()
        {
            string cusId = GetStatic.ReadQueryString("customerId", "");
            var dr = _cd.GetCustomerDetails(cusId, GetStatic.GetUser());
            hdncustomerId.Value = cusId;
            customerName.InnerText = dr["fullName"].ToString();
            hdnMembershipId.Value= dr["membershipId"].ToString();
            _grid.FilterList = new List<GridFilter>
                                  {
                                     new GridFilter("fileName", "File Name", "T"),
                                     new GridFilter("fileDescription", "File Description", "T"),
                                     new GridFilter("createdDate", "Created Date", "d"),
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("fileName", "File Name", "", "T"),
                                      new GridColumn("fileType", "File Type", "", "T"),
                                      new GridColumn("fileDescription", "fileDescription", "", "T"),
                                      new GridColumn("documentTypeName", "Document Type", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate","Regd. Date","","D"),
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.ShowAddButton = true;
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
            _grid.CustomLinkText = "<btn class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Edit\"> <a href =\"CustomerDocument.aspx?cdId=@cdId&customerId=@customerId\"><i class=\"fa fa-edit\" ></i></a></btn>";
            string sql = "EXEC [proc_customerDocumentType] @flag = 's',@customerId='" + cusId + "' ";
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void DDLPopulate()
        {
            _sl.SetDDL(ref ddlDocumentType, "EXEC proc_online_dropDownList @flag='dropdownList',@parentId='7009'", "valueId", "detailTitle", ddlDocumentType.SelectedValue, "Select..");
        }

        private void populateForm(string customerDocumentId)
        {
            var dr = _cd.GetCustomerDocumentByDocumentId(customerDocumentId, GetStatic.GetUser());
            if (dr != null)
            {
                hdnDocumentTypeId.Value = dr["cdId"].ToString();
                hdncustomerId.Value = dr["customerId"].ToString();
                hdnFileName.Value = dr["fileName"].ToString();
                ddlDocumentType.SelectedValue = dr["documentType"].ToString();
                txtDocumentDescription.Text = dr["fileDescription"].ToString();
                hdnFileType.Value = dr["fileType"].ToString();
                if (dr["fileName"].ToString() != "")
                    fileDisplay.ImageUrl = "../../../AgentPanel/OnlineAgent/CustomerSetup/GetFileView.ashx?imageName=" + dr["fileName"] + "&customerId=" +hdnMembershipId.Value + "&fileType=" + dr["fileType"].ToString();
                downloadFile.Visible = true;
            }
        }
        protected void saveDocument_Click(object sender, EventArgs e)
        {
            string fileType = "";
            string fileName = (!string.IsNullOrWhiteSpace(fileDocument.FileName) ? UploadDocument(fileDocument, out fileType) : hdnFileName.Value);
            if (fileName == "invalidSize")
            {
                GetStatic.AlertMessage(this, "File size exceeded for passport. Please upload image of size less than 2mb.");
                return;
            }
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
        private string UploadDocument(FileUpload doc, out string fileType)
        {
            var maxFileSize = GetStatic.ReadWebConfig("csvFileSize", "2097152");
            fileType = "";
            string fName = "";
            try
            {
                fileType = doc.PostedFile.ContentType;
                if (doc.PostedFile.ContentLength > Convert.ToDouble(maxFileSize))
                {
                    fName = "invalidSize";
                }
                else
                {
                    string fileExtension = new FileInfo(doc.PostedFile.FileName).Extension;
                    string fileName =hdncustomerId.Value+"_"+ DateTime.Now. Ticks.ToString()+"_" +ddlDocumentType.SelectedItem.Text+ fileExtension;
                    fileName = Regex.Replace(fileName, @"[;,/:\t\r ]|[\n]{2}", "_");
                    string path = GetStatic.GetFilePath() + "CustomerDocument\\" + hdnMembershipId.Value;
                    if (!Directory.Exists(path))
                        Directory.CreateDirectory(path);
                    doc.SaveAs(path + "/" + fileName);
                    fName = fileName;
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