using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using Swift.web.Library;
using System.Runtime.Serialization;
using System.IO;
using Swift.DAL.RiskBasedAssessment;
using System.Data;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.DAL.SwiftDAL;
namespace Swift.web.RiskBasedAssessment
{
    public partial class List : Page
    {
        private const string GridName = "grd_ssc";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private string ViewFunctionId = "2022000";
        private string AddEditFunctionId = "2022010";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        RiskBasedAssessmentDao _rbaDao = new RiskBasedAssessmentDao();
        public string criteriaID;
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            criteriaID = Request.QueryString["criteriaId"];
            if (!IsPostBack)
            {
                
                GetStatic.PrintMessage(Page);
            }
            
            LoadGrid();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            //1:1:
            _grid.FilterList = new List<GridFilter>
                                   {
                                      new GridFilter("CriteriaFilter", "Criteria", "1:EXEC proc_dropDownLists2 @flag = 'criteriaall'"),
                                       new GridFilter("ConditionFilter", "Condition", "1:EXEC proc_dropDownLists2 @FLAG='condition'")
                                   };
            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SNO", "", "T"),
                                      new GridColumn("Criteria", "Criteria", "", "T"),
                                      new GridColumn("Condition", "Condition", "", "T"),
                                      new GridColumn("CriteriaDetail", "Criteria Detail", "", "T"),
                                      new GridColumn("Value", "Value", "", "T"),
                                      new GridColumn("Weight", "Weight", "", "T"),
                                      new GridColumn("Result", "Result", "", "T"),
                                      new GridColumn("CreatedBy", "Created By", "", "T"),
                                      new GridColumn("CreatedDate", "Created Date", "", "T"),
                                      new GridColumn("ModifiedBy", "Modified By", "", "T"),
                                      new GridColumn("ModifiedDate", "Modified Date", "", "T")

                                  };
            //bool allowAddEdit = true;// _sl.HasRight(AddEditFunctionId);

            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AllowEdit = false;
            _grid.AllowDelete = false;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.EnableFilterCookie = false;
            _grid.ShowAddButton =true;
            _grid.AddButtonTitleText = "Add New Individual Txn";
            _grid.AddPage = "IndividualRiskAssessment.aspx?type=new";
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "ID";
            _grid.ThisPage = "List.aspx"; ;
            _grid.InputPerRow = 5;
            _grid.CustomLinkVariables = "ID";
            //_grid.CustomLinkVariables = "arDetailid,agentId";
            _grid.AllowCustomLink = true;
            var customLinkText = new StringBuilder();
            customLinkText.Append
                    ("<a href=\"#\" onclick=\"Edit(@ID)\"><span class=\"action-icon\"><btn class=\"btn btn-xs btn-primary\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Edit\"><i class=\"fa fa-pencil\"></i></btn></span></a>&nbsp;&nbsp;");
            customLinkText.Append
                    ("<a href=\"#\" onclick=\"DelRow(@ID)\" ><span class=\"action-icon\"><btn class=\"btn btn-xs btn-primary\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Delete\"><i class=\"fa fa-trash\"></i></btn></span></a>&nbsp;&nbsp;");

            _grid.CustomLinkText = customLinkText.ToString();
           
            string sql = "EXEC [proc_rbaMaster] @flag = 'rbarating', @criteriaID=" + _sl.FilterString(GetStatic.ReadQueryString("Id", "")) + ",@condition=" + _sl.FilterString(GetStatic.ReadQueryString("condition", ""));
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
       
        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

    }
}