using Swift.DAL.BL.Remit.OFACManagement;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.OFACManagement.OfacTrackerSetting
{
    public partial class OfacTrackerSetting : System.Web.UI.Page
    {
        OFACDao ofacDao = new OFACDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if(!IsPostBack){
                LoadOfacData();
            }
        }
        private void LoadOfacData()
        {
            var datarow = ofacDao.SelectOFACSetting(GetStatic.GetUser());
            ofacTracker.SelectedValue = datarow["OFAC_TRACKER"].ToString();
            ofacTran.SelectedValue = datarow["OFAC_TRAN"].ToString();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {

        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string ofacTrackerVal = ofacTracker.SelectedValue;
            string ofacTranVal = ofacTran.SelectedValue;
            var res = ofacDao.UpdateOFACSetting(GetStatic.GetUser(), ofacTrackerVal, ofacTranVal);
            GetStatic.AlertMessage(this.Page, res.Msg);
        }
    }
}