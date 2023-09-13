using Swift.DAL.ExchangeSystem.LedgerSetup;
using Swift.web.Library;
using System;

namespace Swift.web.include
{
    public partial class AddGL : System.Web.UI.Page
    {
        private LedgerDao _obj = new LedgerDao();
        private readonly SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                breadCrumb.InnerHtml = "Add Ledger Group";
                frmTitle.InnerHtml = "Add Ledger Group";
                btnUpdate.Visible = false;
                GLCode.Text = GetParentId();
                GetMapName();
                if (!string.IsNullOrEmpty(GetRowId()))
                {
                    breadCrumb.InnerHtml = "Edit Ledger Sub Group";
                    frmTitle.InnerHtml = "Edit Ledger Sub Group";
                    PopulateData();
                }
            }
        }

        private void PopulateData()
        {
            var dr = _obj.GetGLData(GetRowId());
            if (dr == null)
                return;
            GLCode.Text = GetRowId();
            GLMap.SelectedValue = dr["p_id"].ToString();
            GLMap.Enabled = false;
            description.Text = dr["gl_desec"].ToString();
            accountPrifix.Text = dr["acc_Prefix"].ToString();
            ConditionDDl.SelectedValue = "";
            addNewGL.Visible = false;
            btnUpdate.Visible = true;
        }

        protected void addNewGL_Click(object sender, EventArgs e)
        {
            string code = GLCode.Text;
            string desc = description.Text;
            if (desc == "")
            {
                GetStatic.AlertMessage(this, "* fields are required !");
                return;
            }
            string map = GLMap.Text;
            string id = GetRowId();
            string user = GetStatic.GetUser();
            string accPrifix = accountPrifix.Text;
            var dbResult = _obj.InsertLedger(id, user, map, desc, code, accPrifix);
            if (dbResult.ErrorCode == "0")
            {
                GetStatic.AlertMessage(this, dbResult.Msg);
                return;
            }
            else
            {
                GetStatic.AlertMessage(this, dbResult.Msg);
                return;
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            string desc = description.Text;
            if (desc == "")
            {
                GetStatic.AlertMessage(this, "* fields are required !");
                return;
            }
            string id = GetRowId();
            var dbResult = _obj.UpdateLedger(id, desc, accountPrifix.Text);
            GetStatic.AlertMessage(this, dbResult.Msg);
        }

        private string GetRowId()
        {
            return GetStatic.ReadQueryString("Rowid", "");
        }

        private string GetParentId()
        {
            return GetStatic.ReadQueryString("ParentID", "");
        }

        private string GetId()
        {
            return GetStatic.ReadQueryString("id", "");
        }

        private void GetMapName()
        {
            if (!GetParentId().Contains("r"))
            {
                //string a = "";
                //int length = 1;
                //for (int i = 0; i < length; i++)
                //{
                //    if (i == 0)
                //        a = _sl.GetSingleResult("select P_id from gl_group WITH(NOLOCK)  where gl_code = '" + GetParentId() + "'");
                //    else
                //        a = _sl.GetSingleResult("select P_id from gl_group WITH(NOLOCK)  where gl_code = '" + a + "'");

                //    if (!a.Contains("r"))
                //        length++;
                //}
                _sl.SetDDL(ref GLMap, "select gl_name lable,gl_code reportid from gl_group WITH(NOLOCK)  where gl_code ='" + GetParentId() + "'", "reportId", "lable", "", "");
            }
            else
                _sl.SetDDL(ref GLMap, "SELECT lable,reportid FROM report_format WITH(NOLOCK) WHERE reportid=REPLACE('" + GetParentId() + "','r','')", "reportId", "lable", "", "");
        }
    }
}