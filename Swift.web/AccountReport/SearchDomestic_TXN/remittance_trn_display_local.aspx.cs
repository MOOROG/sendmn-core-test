using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AccountReport.SearchDomestic_TXN
{
    public partial class remittance_trn_display_local : System.Web.UI.Page
    {
        SwiftLibrary swft_lib = new SwiftLibrary();
        SwiftGrid sgrid = new SwiftGrid();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadGrid();
            }
        }
        protected void LoadGrid()
        {
            sgrid.FilterList = new List<GridFilter>
            {
                new GridFilter("TRAN_ID","TRAN ID","LT"),
                new GridFilter("TRN_REF_NO","REF NO","REF"),
                new GridFilter("RECEIVER_NAME","RECEIVER","LT"),
                new GridFilter("SENDER_NAME","SENDER","LT"),
                new GridFilter("CONFIRM_DATE","TRN DATE","DT"),
                new GridFilter("CANCEL_DATE","CANCLE DATE","DT"),
                new GridFilter("P_DATE","PAID DATE","DT"),
                new GridFilter("S_AMT","COLLECT AMT","ET"),
                new GridFilter("P_AMT","PAY AMT","ET")
           

            };
            sgrid.ColumnList=new List<GridColumn>
            {
                new GridColumn("TRAN_ID","TRN ID","40","T"),                
                new GridColumn("TRN_REF_NO","REF NO","","T"),
                new GridColumn("SENDER_NAME","SENDER NAME","","T"),
                new GridColumn("RECEIVER_NAME","RECEIVER","","T"),
                new GridColumn( "S_AMT","COLLECT AMT","","M"),
                new GridColumn("P_AMT","PAY AMT","","M"),
                new GridColumn("R_AGENT","PAY AGENT","","T"),
                new GridColumn( "CONFIRM_DATE","TRN DATE","","D")
            };
          
            sgrid.GridType=1;
            sgrid.ShowAddButton=false;
            sgrid.GridName="REMIT_TRN_LOCAL";
            sgrid.ShowFilterForm=true;
            sgrid.ShowCheckBox=true;
            sgrid.MultiSelect=true;
            sgrid.ShowPagingBar=true;
            sgrid.ThisPage="remittance_trn_diplay_local.aspx";
            sgrid.AllowEdit=false;
            sgrid.GridWidth=800;
           sgrid.RowIdField="TRAN_ID";

        }
    }
}