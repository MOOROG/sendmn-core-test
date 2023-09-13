using Swift.DAL.BL.Remit.AgentRiskProfiling;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.AgentRiskProfiling
{
    public partial class Manage : System.Web.UI.Page
    {
        protected const string GridName = "grid_agentRisk";
        private string ViewFunctionId = "20191000";
        private string AddEditFunctionId = "20191010";

        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly agentRiskProfilingDao obj = new agentRiskProfilingDao();
        private string type = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();

                type = GetStatic.ReadQueryString("type", "");
                Session["riskProfiling"] = null;
                if (type.ToLower() == "risk")
                {
                    trNew.Visible = false;
                    trRiskProfiling.Visible = true;

                    trReviewercomment.Visible = false;
                    trReviewerdetails.Visible = false;

                    btnSaveRiskProfiling.Visible = true;
                    btnSaveReview.Visible = false;
                    reviewDetails.InnerHtml = "";
                    loadgrid();
                }
                else if (type.ToLower() == "review")
                {
                    trNew.Visible = false;

                    trRiskProfiling.Visible = true;
                    trReviewercomment.Visible = true;
                    btnSaveReview.Visible = true;

                    trReviewerdetails.Visible = false;
                    btnSaveRiskProfiling.Visible = false;
                    reviewDetails.InnerHtml = "";
                    loadgrid();
                    makeDatagridReadOnly();
                }
                else if (type.ToLower() == "riskhistory")
                {
                    trNew.Visible = false;

                    trRiskProfiling.Visible = true;
                    trReviewercomment.Visible = true;
                    btnSaveReview.Visible = false;
                    trReviewerdetails.Visible = true;
                    btnSaveRiskProfiling.Visible = false;
                    //reviewDetails.InnerHtml = "";
                    reviewersComment.Attributes.Add("readOnly", "true");
                    loadgrid();
                    makeDatagridReadOnly();
                }
                else
                {
                    trNew.Visible = true;
                    trRiskProfiling.Visible = false;
                }
            }
        }

        private void makeDatagridReadOnly()
        {
            for (int i = 0; i < riskProfiling.Items.Count; i++)
            {
                txtScore = (TextBox)riskProfiling.Items[i].FindControl("txtScore");
                txtRemarks = (TextBox)riskProfiling.Items[i].FindControl("txtRemarks");
                txtScore.Attributes.Add("readOnly", "true");
                txtScore.Attributes.Remove("onblur");

                txtRemarks.Attributes.Add("readOnly", "true");
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void loadgrid()
        {
            DataSet ds = null;

            var assessementId = GetStatic.ReadQueryString("aId", "");
            var agentId = GetStatic.ReadQueryString("agentId", "");

            ds = obj.profilingCriteria(GetStatic.GetUser(), agentId, assessementId);

            if (null != ds)
            {
                Session["riskProfiling"] = ds.Tables[0];

                if (ds.Tables.Count > 1)
                {
                    DataTable scoringCriteria = ds.Tables[1];
                    for (int i = 0; i < scoringCriteria.Rows.Count; i++)
                    {
                        hdnscoringCriteria.Value += scoringCriteria.Rows[i]["scoreTo"].ToString() + ":" + scoringCriteria.Rows[i]["rating"].ToString() + ":";
                    }
                }

                riskProfiling.DataSource = ds.Tables[0];
                riskProfiling.DataBind();

                try
                {
                    DataRow dr = ds.Tables[0].Rows[0];
                    if (null != dr["reviewerComment"])
                    {
                        reviewersComment.Text = dr["reviewerComment"].ToString();
                    }
                    if (null != dr["reviewedDate"])
                    {
                        var reviewDate = dr["reviewedDate"].ToString();
                        if (!string.IsNullOrEmpty(reviewDate))
                        {
                            makeDatagridReadOnly();
                        }
                    }

                    if (type.ToLower() == "riskhistory")
                    {
                        if (null != dr["createdBy"] && null != dr["createdDate"] && null != dr["reviewdBy"] && null != dr["reviewedDate"])
                        {
                            reviewDetails.InnerHtml = "<br /><b>Created By</b>: " + dr["createdBy"].ToString() + "  &nbsp;&nbsp;<b>Created Date</b>: " + dr["createdDate"] + " &nbsp;&nbsp;<b>Review By</b>: " + dr["reviewdBy"] + "  &nbsp;&nbsp;<b>Reviewed Date</b>: " + dr["reviewedDate"] + "";
                        }
                    }
                }
                catch (Exception ex)
                { }
            }
        }

        private Label lblCriteria;
        private TextBox txtMinScore;
        private TextBox txtMaxScore;
        private TextBox txtScore;
        private TextBox txtRemarks;
        private TextBox txtScoreTotal;
        private TextBox txtRiskCategory;
        private decimal totalScore = 0;

        protected void riskProfiling_ItemDataBound(object sender, System.Web.UI.WebControls.DataGridItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item | e.Item.ItemType == ListItemType.AlternatingItem)
            {
                lblCriteria = (Label)e.Item.FindControl("lblCriteria");
                txtMinScore = (TextBox)e.Item.FindControl("txtMinScore");
                txtMaxScore = (TextBox)e.Item.FindControl("txtMaxScore");
                txtScore = (TextBox)e.Item.FindControl("txtScore");
                txtRemarks = (TextBox)e.Item.FindControl("txtRemarks");

                txtScore.Attributes.Add("onfocus", "resetInput(this, '0', 1, true);");
                txtScore.Attributes.Add("onblur", "resetInput(this, '0', 2, true, 'true');CalculateScore();");
                txtScore.Attributes.Add("onkeydown", "return numericOnly(this, (event?event:evt), true,'true');");
                txtScore.Attributes.Add("onpaste", "return manageOnPaste(this);");

                txtScore.Attributes.Add("class", "form-control");
                txtRemarks.Attributes.Add("class", "form-control");

                // Misc.MakeNumericTextbox(ref txtScore);
                txtRemarks = (TextBox)e.Item.FindControl("txtRemarks");

                DataTable dt = new DataTable();
                dt = (DataTable)Session["riskProfiling"];
                if (dt != null)
                {
                    lblCriteria.Text = dt.Rows[e.Item.ItemIndex]["topic"].ToString();
                    txtMinScore.Text = dt.Rows[e.Item.ItemIndex]["minimumScore"].ToString();
                    txtMaxScore.Text = dt.Rows[e.Item.ItemIndex]["maximumScore"].ToString();
                    txtScore.Text = dt.Rows[e.Item.ItemIndex]["score"].ToString();
                    txtRemarks.Text = dt.Rows[e.Item.ItemIndex]["remarks"].ToString();
                    totalScore += (txtScore.Text.Trim() != "") ? Convert.ToDecimal(txtScore.Text) : 0;
                }
            }
            if (e.Item.ItemType == ListItemType.Footer)
            {
                txtScoreTotal = (TextBox)e.Item.FindControl("txtScoreTotal");
                Misc.MakeDisabledTextbox(ref txtScoreTotal);
                txtScoreTotal.Text = (totalScore > 0) ? totalScore.ToString() : "";
                txtScoreTotal.Attributes.Add("class", "form-control");

                txtRiskCategory = (TextBox)e.Item.FindControl("txtRiskCategory");
                txtRiskCategory.Attributes.Add("readOnly", "true");

                string[] scoringCriteria = hdnscoringCriteria.Value.Split(':');

                var scCriteria = "";
                var scColor = "";

                if (totalScore <= Convert.ToDecimal(scoringCriteria[0]))
                {
                    scCriteria = scoringCriteria[1];
                    scColor = "#87a96b";
                }
                else if (totalScore <= Convert.ToDecimal(scoringCriteria[2]))
                {
                    scCriteria = scoringCriteria[3];
                    scColor = "#a1caf1";
                }
                else if (totalScore > Convert.ToDecimal(scoringCriteria[2]))
                {
                    scCriteria = scoringCriteria[5];
                    scColor = "#fd5e53";
                }
                txtRiskCategory.Text = scCriteria;
                txtRiskCategory.Style.Add("background-color", scColor);

                //Misc.MakeDisabledTextbox(ref txtRiskCategory);
            }
        }

        protected void btnSaveAgent_Click(object sender, EventArgs e)
        {
            Page.Validate();

            if (Page.IsValid)
            {
                var dbResult = obj.SaveRiskProfilingAgent(GetStatic.GetUser(), hddAgentId.Value, assessementdate.Text);
                //if (dbResult.ErrorCode.Equals("0"))
                //GetStatic.AlertMessage(Page, dbResult.Msg);
                ManageMessage(dbResult);
            }
        }

        protected void btnSaveRiskProfiling_Click(object sender, EventArgs e)
        {
            var sb = new StringBuilder("<root>");

            var assessementId = GetStatic.ReadQueryString("aId", "");
            decimal totalScore = 0;
            var rating = "";
            for (int i = 0; i < riskProfiling.Items.Count; i++)
            {
                var criteriaId = riskProfiling.DataKeys[i].ToString();
                txtScore = (TextBox)riskProfiling.Items[i].FindControl("txtScore");
                txtRemarks = (TextBox)riskProfiling.Items[i].FindControl("txtRemarks");
                //txtRiskCategory=(TextBox)riskProfiling.Items[i].FindControl("txtRiskCategory");

                sb.Append("<row assessementId=\"" + assessementId + "\" ");
                sb.Append(" criteriaId=\"" + criteriaId + "\" ");
                sb.Append(" score=\"" + txtScore.Text + "\" ");
                sb.Append(" remarks=\"" + obj.FilterStringForXml(txtRemarks.Text.Trim()) + "\" />");

                totalScore += Convert.ToDecimal((txtScore.Text.Trim() == "") ? "0" : txtScore.Text.Trim());
            }

            Table tbl = (Table)riskProfiling.Controls[0];
            DataGridItem footer = (DataGridItem)tbl.Controls[tbl.Controls.Count - 1]; //header would be tbl.Controls[0]
            txtRiskCategory = (TextBox)footer.FindControl("txtRiskCategory");
            rating = txtRiskCategory.Text.Trim();

            sb.Append("</root>");

            var dbResult = obj.SaveRiskProfiling(GetStatic.GetUser(), sb, assessementId, rating, totalScore);
            //GetStatic.AlertMessage(this, dbResult.Msg);
            loadgrid();
            ManageMessage(dbResult);
        }

        protected void btnSaveReview_Click(object sender, EventArgs e)
        {
            if (GetStatic.ReadQueryString("type", "") == "review")
            {
                var assessementId = GetStatic.ReadQueryString("aId", "");
                var agentId = GetStatic.ReadQueryString("agentId", "");

                var dbResult = obj.SaveReview(GetStatic.GetUser(), agentId, assessementId, reviewersComment.Text);
                ManageMessage(dbResult);
            }
        }

        private void ManageMessage(DbResult dbResult)
        {
            var url = "List.aspx";

            GetStatic.CallJSFunction(this, string.Format("CallBackSave('{0}','{1}", dbResult.ErrorCode, dbResult.Msg.Replace("'", "") + "','" + url + "')"));
        }
    }
}