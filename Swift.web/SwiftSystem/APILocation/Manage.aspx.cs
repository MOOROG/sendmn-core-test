using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.APILocationMapping
{
    public partial class Manage : Page
    {
        //put your code to create dao object
        private const string ViewFunctionId = "10111700";
        private const string AddEditFunctionId = "10111710";
        private const string DeleteFunctionId = "10111720";
        private readonly ApiLocationMapperDao _obj = new ApiLocationMapperDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected long RowId;

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            GetStatic.SetActiveMenu(ViewFunctionId);
            if (!IsPostBack)
            {
                if (GetDistrictId() > 0)
                {
                    PopulateDataById();
                }
            }
        }

        #region Method

        private long GetDistrictId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rowId");
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnDelete.Visible = _sdd.HasRight(DeleteFunctionId);
            btnSumit.Visible = _sdd.HasRight(AddEditFunctionId);
        }

        private void PopulateDataById()
        {
            DataRow dr = _obj.SelectLocation(GetStatic.GetUser(), GetDistrictId().ToString());
            if (dr == null)
                return;

            districtCode.Text = dr["districtCode"].ToString();
            districtName.Text = dr["districtName"].ToString();
            isActive.SelectedValue = dr["isActive"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = _obj.UpdateLocation(GetStatic.GetUser(), GetDistrictId().ToString(), districtCode.Text, districtName.Text, isActive.Text);
            ManageMessage(dbResult);
        }

        private void Delete()
        {
            var dbResult = _obj.DeleteLocation(GetStatic.GetUser(), GetDistrictId().ToString());
            ManageMessage(dbResult);
        }
        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        #endregion

        #region Element Method

        protected void btnSumit_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            Delete();
        }

        #endregion
    }
}