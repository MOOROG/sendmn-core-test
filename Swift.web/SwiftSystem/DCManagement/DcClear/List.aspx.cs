using System;
using System.Collections.Generic;
using Swift.DAL.BL.System.DCManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.DCManagement.DCClear
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20170000";
        private const string ClearFunctionId = "20170010";

        private const string GridName = "grdDcClear";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly DcManagementDao _obj = new DcManagementDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadGrid();
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + ClearFunctionId);
            btnClearDc.Visible = _sdd.HasRight(ClearFunctionId);
        }

        private void LoadGrid()
        {

            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("dcRequestId", "DC Id", "T"),
                                      new GridFilter("userName", "User Name", "T"),
                                      new GridFilter("companyName", "Agent Name", "T"),
                                      new GridFilter("approvedFromDate", "Approved From Date", "D"),
                                      new GridFilter("approvedToDate", "Approved To Date", "D")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("dcRequestId", "DC Id", "", "T"),
                                      new GridColumn("userId", "Employee ID", "", "T"),
                                      new GridColumn("userName", "User Name", "", "T"),
                                      new GridColumn("userFullName", "Full Name", "", "T"),
                                      new GridColumn("country", "Country", "", "T"),
                                      new GridColumn("address", "Address", "", "T"),
                                      new GridColumn("companyName", "Company Name", "", "T"),
                                      new GridColumn("dcApprovedDate", "DC Approved Date", "", "T"),
                                      new GridColumn("approvedBy", "Approved By", "", "T")
                                  };
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.GridType = 1;
            grid.LoadGridOnFilterOnly = true;
            grid.AlwaysShowFilterForm = true;
            grid.EnableFilterCookie = false;
            grid.InputPerRow = 3;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "userId";

            grid.ShowCheckBox = true;
            grid.MultiSelect = false;
            grid.SetComma();
            grid.GridWidth = 880;
            grid.PageSize = 10000;

            var sql = @"EXEC proc_dcManagement @flag = 'dcl'";
            rpt_grid.InnerHtml = grid.CreateGrid(sql);

        }

        protected void btnClearDc_Click(object sender, EventArgs e)
        {
            string requestId = grid.GetRowId(GridName);
            DbResult dbResult = _obj.ClearDc(GetStatic.GetUser(), requestId);
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

        protected void btnRemoveDc_Click(object sender, EventArgs e)
        {
            string requestId = grid.GetRowId(GridName);
            DbResult dbResult = _obj.RemoveDc(GetStatic.GetUser(), requestId);
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

        /*
        private void ApproveCA()
        {
            //  Create all the objects that will be required
            CX509Enrollment objEnroll = new CX509EnrollmentClass();
            string strCert = "14";

            try
            {
                //strCert = responseText.Text;

                // Install the certificate
                objEnroll.Initialize(X509CertificateEnrollmentContext.ContextUser);
                objEnroll.InstallResponse(
                    InstallResponseRestrictionFlags.AllowUntrustedRoot,
                    strCert,
                    EncodingType.XCN_CRYPT_STRING_BASE64,
                    null
                );

                //MessageBox.Show("Certificate installed!");
            }
            catch (Exception ex)
            {
                //MessageBox.Show(ex.Message);
            }
        }
        */
        /*
        private void ViewCertificateServicesDatabase(string strServer, string strCAName, DirectoryEntry templatesEntry)
        {
            // Variables
            CERTADMINLib.CCertView certView = null;
            CERTADMINLib.IEnumCERTVIEWROW certViewRow = null;
            CERTADMINLib.IEnumCERTVIEWCOLUMN certViewColumn = null;
            CERTADMINLib.IEnumCERTVIEWEXTENSION certViewExt = null;
            int iColumnCount = 0;
            string strBase64Value = "";
            string strValue = "";
            string strOID = "";
            int iStartIndex = 0;
            string strDisplayName = "";
            object objValue = null;
            string strOutput = "";

            // Connecting to the Certificate Authority
            certView = new CERTADMINLib.CCertViewClass();
            certView.OpenConnection(strServer + "\\" + strCAName);

            // Get a column count and place columns into the view
            iColumnCount = certView.GetColumnCount(0);
            certView.SetResultColumnCount(iColumnCount);

            // Place each column in the view.
            for (int x = 0; x < iColumnCount; x++)
            {
                certView.SetResultColumn(x);
            }

            // Open the View and reset the row position
            certViewRow = certView.OpenView();
            certViewRow.Reset();

            // Enumerate Row and Column Information

            // Rows         
            for (int x = 0; certViewRow.Next() != -1; x++)
            {
                // Extensions
                strOutput = "ROW #" + x.ToString() + " EXTENSIONS\n\n";
                certViewExt = certViewRow.EnumCertViewExtension(0);
                certViewExt.Reset();

                while (certViewExt.Next() != -1)
                {
                    switch (certViewExt.GetName())
                    {
                        // Certificate Template
                        case "1.3.6.1.4.1.311.21.7":

                            // Certificate Template OID, Mayor Version Number and Minor Version Number
                            strBase64Value = (string)certViewExt.GetValue(Win32.PROPTYPE_BINARY, Win32.CV_OUT_BASE64);
                            strValue = FormatObject("1.3.6.1.4.1.311.21.7", Convert.FromBase64String(strBase64Value));
                            strOutput += "Certificate Template OID = \"" + strValue + "\"\n\n";

                            strDisplayName = "";
                            if (strValue.StartsWith("Template="))
                            {
                                // Certificate Template OID
                                iStartIndex = strValue.IndexOf("=") + 1;
                                strOID = strValue.Substring(iStartIndex, strValue.IndexOf(",") - iStartIndex);

                                // Certificate Template Display Name
                                strDisplayName = TranslateTemplateOID(strOID, templatesEntry);
                            }
                            strOutput += "Certificate Template Display Name = \"" + strDisplayName + "\"\n\n";
                            break;

                        // Enhanced Key Usage
                        case "2.5.29.37":
                            strBase64Value = (string)certViewExt.GetValue(Win32.PROPTYPE_BINARY, Win32.CV_OUT_BASE64);
                            strValue = FormatObject("2.5.29.37", Convert.FromBase64String(strBase64Value));
                            strOutput += "Enhanced Key Usage = \"" + strValue + "\"\n\n";
                            break;

                        default:
                            break;
                    }
                }

                // Columns
                strOutput += "ROW #" + x.ToString() + " COLUMNS\n\n";
                certViewColumn = certViewRow.EnumCertViewColumn();
                while (certViewColumn.Next() != -1)
                {
                    switch (certViewColumn.GetDisplayName())
                    {
                        // Certificate Template
                        case "Certificate Template":
                            objValue = certViewColumn.GetValue(Win32.PROPTYPE_STRING);
                            if (objValue != null)
                            {
                                strOutput += "Certificate Template Name = \"" + objValue.ToString() + "\"\n\n";
                            }
                            else
                            {
                                strOutput += "Certificate Template Name = \"\"\n\n";
                            }
                            break;

                        // "Certificate Expiration Date"
                        case "Certificate Expiration Date":
                            objValue = certViewColumn.GetValue(Win32.PROPTYPE_DATE);
                            if (objValue != null)
                            {
                                strOutput += "Certificate Expiration Date = \"" + objValue.ToString() + "\"\n\n";
                            }
                            else
                            {
                                strOutput += "Certificate Expiration Date = \"\"\n\n";
                            }
                            break;

                        default:
                            break;
                    }
                }

                // Show row info
                MessageBox.Show(strOutput);
            }
        }
         * * */
    }
}