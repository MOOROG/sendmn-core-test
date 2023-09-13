using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.CustomerEnquiry
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "2019300";
        private const string AddEditFunctionId = "2019310";
        private readonly RemittanceLibrary remLibrary = new RemittanceLibrary();
        private readonly SwiftGrid grid = new SwiftGrid();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
               
            }
        }
       
      
            private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("firstName", "Full Name", "", "T"),
                                      new GridColumn("enquiryTypeNew", "Enquiry Type", "", "T"),
                                      new GridColumn("message", "Enquiry Message", "", "T"),
                                      new GridColumn("mobile", "Mobile No", "", "T"),
                                      new GridColumn("email", "Email", "", "T"),
                                      new GridColumn("controlNo", "Control No", "", "T"),
                                      new GridColumn("createdDate", "Creaed Date", "", "D"),
                                  };

           // var allowAddEdit = true;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = "customerEnqueryMsg";
            grid.GridType = 1;

          //  grid.ShowAddButton = allowAddEdit;
         //   grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
          //  grid.AddButtonTitleText = "Add New ";
            grid.RowIdField = "enquiryId";
           // grid.AddPage = "List.aspx";
           // grid.InputPerRow = 4;
           // grid.InputLabelOnLeftSide = true;
           // grid.AlwaysShowFilterForm = true;
           // grid.AllowEdit = allowAddEdit;
            grid.DisableSorting = true;


            string sql = "proc_customerEnquiry @flag = 's',@enquiryType="+ ddlEnquiryMsg.SelectedValue;
            grid.SetComma();

            rptGrid.InnerHtml = grid.CreateGrid(sql);
        }

            protected void btnSearch_Click(object sender, EventArgs e)
            {
                if (ddlEnquiryMsg.SelectedValue != "" && ddlEnquiryMsg.SelectedValue == "Select")
                {
                    return;
                }
                LoadGrid();
            }
        }
    }
