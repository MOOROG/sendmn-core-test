using Swift.DAL.OnlineAgent;
using Swift.web.Library;
using System;
using System.IO;

namespace Swift.web.Remit.Administration.CustomerSetup
{
    public partial class DocumentView : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20111300";
        private const string ViewFunctionIdAgent = "40120000";
        private const string ViewDocFunctionId = "20111330";
        private const string ViewDocFunctionIdAgent = "40120030";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        private readonly OnlineCustomerDao _oC = new OnlineCustomerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                msg.Visible = false;
                string cdId = GetStatic.ReadQueryString("cdId", "");
                var result = _oC.GetCustomerDocumentByDocumentId(cdId, GetStatic.GetUser());
                if (result != null)
                {
                    hdnDocumentTypeId.Value = result["cdId"].ToString();
                    hdnMembershipId.Value = result["membershipId"].ToString();
                    hdnFileName.Value = result["fileName"].ToString();
                    var registerDate = Convert.ToDateTime(result["registerDate"]).ToString("yyyy-MM-dd");
                    hdnRegisterDate.Value = registerDate;
                    if (result["fileName"].ToString() != "")
                        fileDisplay.ImageUrl = "/Remit/GetFileView.ashx?fileName=" + result["fileName"] + "&membershipNo=" + hdnMembershipId.Value + "&registerDate=" + registerDate;
                    return;
                }
                msg.InnerText = "File Not Found";
                msg.Visible = true;
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId) + "," + GetFunctionIdByUserType(ViewDocFunctionIdAgent, ViewDocFunctionId));
        }

        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }

        protected void downloadFile_Click(object sender, EventArgs e)
        {
            try
            {
                var imageName = hdnFileName.Value;
                var dirLocation = imageName.Split('_')[3].ToString() + "\\" + imageName.Split('_')[4].ToString() + "\\" + imageName.Split('_')[5].Split('.')[0].ToString() + "\\";
                var path = GetStatic.GetCustomerFilePath() + "CustomerDocument\\" + dirLocation + hdnMembershipId.Value + "\\" + imageName;
                if (!File.Exists(path))
                {
                    //msgDiv.Visible = true;
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