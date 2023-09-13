using Swift.DAL.GeneralDataSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.GeneralSetting.GeneralData
{
    public partial class Manage : System.Web.UI.Page
    {
        private string title = null;
        private const string ViewFunctionId = "10101700";
        private const string AddEditFunctionId = "10101710";

        private readonly GeneralSettingsSubGridDao _obj = new GeneralSettingsSubGridDao();
        private readonly SwiftLibrary _sdd = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            title = GetTitle();
            header.Text = GetTitle().ToUpper();
            labelHead.Text = GetTitle();
            _sdd.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                if (!string.IsNullOrEmpty(GetId()))
                {
                    PopulateDataById();
                }
            }
        }

        protected string GetId()
        {
            return GetStatic.ReadQueryString("id", "");
        }

        protected string Getrefid()
        {
            return GetStatic.ReadQueryString("refid", "");
        }

        protected string GetTitle()
        {
            return GetStatic.ReadQueryString("title", "");
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
            btnSubmit.Visible = _sdd.HasRight(AddEditFunctionId);
        }

        private void PopulateDataById()
        {
            DataRow dr = new DataTable().NewRow();
            dr = _obj.SelectById(GetStatic.GetUser(), Getrefid().ToString());
            if (dr == null)
                return;
            createdBy.Text = dr["CREATED_BY"].ToString();
            createdDate.Text = dr["CREATED_DATE"].ToString();
            modifiedBy.Text = dr["MODIFIED_BY"].ToString();
            modifiedDate.Text = dr["MODIFIED_DATE"].ToString();
            createdByLabel.Visible = true;
            createdBy.Visible = true;
            createdDate.Visible = true;
            createdDateLabel.Visible = true;
            modifiedBy.Visible = true;
            modifiedByLabel.Visible = true;
            modifiedDate.Visible = true;
            modifiedDateLabel.Visible = true;

            labelHead.Text = dr["title"].ToString();
            header.Text = dr["title"].ToString().ToUpper();
            code.Text = dr["ref_code"].ToString();
            description.Text = dr["ref_desc"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = _obj.Update(GetStatic.GetUser(), Getrefid().ToString(), GetId().ToString(), code.Text, description.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            if (dbResult.ErrorCode == "0")
            {
                GetStatic.SetMessage(dbResult);
                Response.Redirect("List.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        protected void btnSumit_Click(object sender, EventArgs e)
        {
            Update();
        }
    }
}