using Swift.DAL.BL.Remit.Compliance;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.OFACManagement.ManualComplianceSetup
{
    public partial class UploadFromCSV : System.Web.UI.Page
    {

        private readonly string ViewFunctionId = "20601400";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        complianceDao comDao = new complianceDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateDDl();
                GetStatic.PrintMessage(Page);
                Authenticate();
            }
        }
        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }
        private void PopulateDDl()
        {
            _sl.SetDDL(ref ofacSourceDdl, "EXEC proc_online_dropDownList @flag='ofacSource'", "valueId", "detailTitle", ofacSourceDdl.SelectedValue, "Select..");
        }
        protected void import_Click(object sender, EventArgs e)
        {
            DbResult _res = new DbResult();
            var ofacSourceValue = ofacSourceDdl.SelectedValue;
            if (fileUpload.FileContent.Length > 0)
            {
                if (fileUpload.FileName.ToLower().Contains(".csv"))
                {
                    string path = Server.MapPath("..\\..\\..\\") + "\\doc\\tmp\\" + fileUpload.FileName;
                    fileUpload.SaveAs(path);
                    var xml = GetStatic.GetCSVFileInTable(path, true);

                    File.Delete(path);
                    var rs = comDao.ImportOFACList(GetStatic.GetUser(), xml, GetStatic.GetSessionId(), ofacSourceValue);

                    _res = _sl.ParseDbResult(rs.Tables[0]);
                    if (_res.ErrorCode == "0")
                    {
                        GetStatic.SetMessage(_res);
                        Response.Redirect("UploadFromCSV.aspx");

                        //PopulateData(rs.Tables[1]);
                    }
                    else
                    {
                        GetStatic.AlertMessage(this, _res.Msg);
                    }
                }
                else
                {
                    GetStatic.AlertMessage(this, "Invalid file format!");
                }
            }
            else
            {
                GetStatic.AlertMessage(this, "Please select file");
            }

        }
        protected void btnConfirmSave_Click(object sender, EventArgs e)
        {
            //var Ids = Request.Form["chkRateUpload"];
            //if (!string.IsNullOrEmpty(Ids))
            //{
            //    var _res = _isd.ConfirmSave(GetStatic.GetUser(), Ids, GetStatic.GetSessionId());

            //    if (_res.ErrorCode == "0")
            //    {
            //        step1.Visible = true;
            //        step1a.Visible = true;
            //        step2.Visible = false;
            //        step2a.Visible = false;

            //        GetStatic.AlertMessage(this, _res.Msg);
            //    }
            //    else
            //    {
            //        GetStatic.AlertMessage(this, _res.Msg);
            //    }
            //}
            //else
            //{
            //    GetStatic.AlertMessage(this, "Please choose at least on record!");
            //}
        }
        protected void btnClear_Click(object sender, EventArgs e)
        {
            //_isd.ClearData(GetStatic.GetUser(), GetStatic.GetSessionId());
            //step1.Visible = true;
            //step1a.Visible = true;
            //step2.Visible = false;
            //step2a.Visible = false;
        }
    }
}