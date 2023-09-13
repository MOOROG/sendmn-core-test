using System;
using System.Data;
using System.Text;
using System.Web.UI;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using Swift.DAL.BL.System.GeneralSettings;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class ManageEmailTemplate : Page
    {
        private const string ViewFunctionId = "10111100";
        private const string AddEditFunctionId = "10111110";
        private readonly MessageSettingDao obj = new MessageSettingDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                
                PopulateKeyword();
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    PopulateDdl(null);
                }
            }
        }

        private void PopulateDdl(DataRow dr)
        {

            sdd.SetDDL(ref templateFor, "EXEC proc_staticDataValue @flag = 'c', @typeId = 7000", "detailTitle", "detailTitle",
                       GetStatic.GetRowData(dr, "templateFor"), "Select");
        } 
        #region Method

        private void PopulateKeyword()
        {
            DataTable dt = obj.GetKeyword(GetStatic.GetUser());

            int cols = dt.Columns.Count;
            StringBuilder str = new StringBuilder("<table width=\"50%\" border=\"0\" class=\"TBL2\" cellpadding=\"4\" cellspacing=\"4\"");
            str.Append("<tr>");
            for (int i = 0; i < cols; i++)
            {
                str.Append("<th nowrap=\"nowrap\" align=\"left\" style=\"font-size:15px; color:#993300;\">" + dt.Columns[i].ColumnName + "</th>");
            }
            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");
                str.Append("<td align=\"left\" nowrap='nowrap' style=\"font-size:11px; color:#993300;\">" + dr[0].ToString() + "</td>");
                str.Append("<td align=\"left\" nowrap='nowrap' style=\"font-size:11px; color:#993300;\">" + dr[1].ToString() + "</td>");
                str.Append("</tr>");
            }
            str.Append("</table>");
            keyword.InnerHtml = str.ToString();
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("id");
        }

        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectEmailTemplateById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;
            
            templateName.Text = dr["templateName"].ToString();
            emailSubject.Text = dr["emailSubject"].ToString();
            textarea1.Text = dr["emailFormat"].ToString();
            replyTo.Text = dr["replyTo"].ToString();
            PopulateDdl(dr);
            if (dr["isEnabled"].ToString()=="Y")
            {
                chkEnabled.Checked = true;
            }
            if (dr["isResponseToAgent"].ToString() == "Y")
            {
                chkResToAgent.Checked = true;
            }
        }

        private void Update()
        {
            string isEnabled = "";
            string isResToAgent = "";

            if (chkEnabled.Checked == true)
                isEnabled = "Y";
            if (chkResToAgent.Checked == true)
                isResToAgent = "Y";

            DbResult dbResult = obj.UpdateEmailTemplate(GetStatic.GetUser(), GetId().ToString(), templateName.Text,
                emailSubject.Text, isEnabled, isResToAgent, textarea1.Text, templateFor.Text,replyTo.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("ListEmailTemplate.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        #endregion

        #region Element Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        #endregion

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            Delete();
        }

        private void Delete()
        {
            DbResult dbResult = obj.DeleteEmailTemplate(GetStatic.GetUser(), GetId().ToString());
            ManageMessage(dbResult);
        }

    }
}