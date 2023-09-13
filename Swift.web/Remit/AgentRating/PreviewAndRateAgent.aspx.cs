using Swift.DAL.BL.Remit.AgentRating;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.AgentRating
{
    public partial class PreviewAndRateAgent : System.Web.UI.Page
    {
        private string ViewFunctionId = "20191200";
        private string AddEditFunctionId = "20191210";
        private string RatingCompletedFunctionId = "20191250";

        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly AgentRatingDao obj = new AgentRatingDao();
        private string type = "";
        private bool ctrlEnable;

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            type = GetStatic.ReadQueryString("type", "").ToLower();

            if (!IsPostBack)
            {
                Authenticate();
                printRatingDetails();

                if (type == "rating" || type == "review" || type == "approve" || type == "riskhistory" || type == "preview")
                {
                    checkIsRatingOrReviewOrApprove(type);
                    loadgrid(type, false);
                }
                //loadgrid(type);
            }
            else
            {
                if (type == "rating" || type == "review" || type == "approve" || type == "preview")
                    loadgrid(type, true);
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void printRatingDetails()
        {
            AgentName.Text = GetStatic.ReadQueryString("aName", "");
            agentBranch.Text = GetStatic.ReadQueryString("aBranchName", "All");
            ReviewPeriod.Text = GetStatic.ReadQueryString("rPeriod", "");

            Reviewedon.Text = GetStatic.ReadQueryString("ron", "");
            Reviewer.Text = GetStatic.ReadQueryString("r", "");

            ratedby.Text = GetStatic.ReadQueryString("ratedby", "");
            ratedOn.Text = GetStatic.ReadQueryString("ratedon", "");

            approvedBy.Text = GetStatic.ReadQueryString("appby", "");
            approvedOn.Text = GetStatic.ReadQueryString("appon", "");

            string strPrintUrl = "print.aspx?type=print&arId=" + GetStatic.ReadQueryString("arId", "") +
                        "&aId=" + GetStatic.ReadQueryString("aId", "") + "&aName=" + GetStatic.ReadQueryString("aName", "") + "&aType=" + GetStatic.ReadQueryString("aType", "") +
                        "&ratedby=" + GetStatic.ReadQueryString("ratedby", "") + "&ratedon=" + GetStatic.ReadQueryString("ratedon", "") +
                        "&ron=" + GetStatic.ReadQueryString("ron", "") + "&r=" + GetStatic.ReadQueryString("r", "") +
                        "&appby=" + GetStatic.ReadQueryString("appby", "") + "&appon=" + GetStatic.ReadQueryString("appon", "") + "&rPeriod=" + GetStatic.ReadQueryString("rPeriod", "") + "";

            printBtn.Attributes.Add("onClick", "openPrint('" + strPrintUrl + "');");
        }

        private void checkIsRatingOrReviewOrApprove(string actionType)
        {
            if (actionType == "rating")
            {
                btnAgentRating.Visible = true;

                btnReview.Visible = false;
                trReviewercomment.Visible = false;

                trApproverComment.Visible = false;
                btnApprove.Visible = false;

                reviewersComment.Enabled = false;
                approversComment.Enabled = false;
            }
            else if (actionType == "review")
            {
                btnAgentRating.Visible = false;

                btnReview.Visible = true;
                trReviewercomment.Visible = true;
                reviewersComment.Enabled = true;

                trApproverComment.Visible = false;
                approversComment.Enabled = false;

                btnApprove.Visible = false;
            }
            else if (actionType == "approve")
            {
                btnReview.Visible = false;
                btnAgentRating.Visible = false;

                trReviewercomment.Visible = true;
                reviewersComment.Enabled = false;

                trApproverComment.Visible = true;
                approversComment.Enabled = true;
                btnApprove.Visible = true;
            }
            else if (actionType == "riskhistory")
            {
                btnReview.Visible = false;
                btnAgentRating.Visible = false;
                btnApprove.Visible = false;

                trReviewercomment.Visible = true;
                trApproverComment.Visible = true;

                reviewersComment.Enabled = false;
                approversComment.Enabled = false;
            }
            else
            {
                btnReview.Visible = false;
                trReviewercomment.Visible = false;
                btnAgentRating.Visible = false;

                trApproverComment.Visible = false;
                btnApprove.Visible = false;
                reviewersComment.Enabled = false;
                approversComment.Enabled = false;
            }
        }

        private void loadgrid(string actionType, bool isPagePostBack = false)
        {
            DataSet ds = null;

            var arDetaildId = GetStatic.ReadQueryString("arId", "");
            var agentId = GetStatic.ReadQueryString("aId", "");
            var agentType = GetStatic.ReadQueryString("atype", "");

            ds = obj.ratingCriteriaPreview(GetStatic.GetUser(), agentId, agentType, arDetaildId, actionType);

            //ctrlEnable = (!isPagePostBack) ? true : ctrlEnable;

            if (null != ds)
            {
                if (ds.Tables.Count > 2)
                {
                    DataTable scoringCriteria = ds.Tables[2];
                    for (int i = 0; i < scoringCriteria.Rows.Count; i++)
                    {
                        hdnscoringCriteria.Value += scoringCriteria.Rows[i]["scoreTo"].ToString() + ":" + scoringCriteria.Rows[i]["rating"].ToString() + ":";
                    }
                }

                if (!isPagePostBack)
                {
                    string expression = "type = 'C'";
                    DataRow[] drows;
                    drows = ds.Tables[0].Select(expression);

                    if (drows[0]["ratingDate"].ToString() != "")
                    {
                        //ratingComment.InnerText = drows[0]["ratingComment"].ToString();
                        //trRatingComment.Visible = true;
                        ctrlEnable = false;
                    }
                }

                WriteRow(ds, ctrlEnable);
                PrintSummaryTable(ds);
            }
            if (actionType == "riskhistory" || actionType == "approve" || actionType == "preview")
            {
                string expression = "type = 'C'";
                DataRow[] drows;
                drows = ds.Tables[0].Select(expression);

                if (drows[0]["reviewedDate"].ToString() != "")
                {
                    trReviewercomment.Visible = true;
                    reviewersComment.Text = drows[0]["reviewerComment"].ToString();
                }

                if (drows[0]["approvedDate"].ToString() != "")
                {
                    trApproverComment.Visible = true;
                    approversComment.Text = drows[0]["approverComment"].ToString();
                }
            }
        }

        private void WriteRow(DataSet ds, bool ctrlEnable)
        {
            var actionType = GetStatic.ReadQueryString("type", "").ToLower();
            bool isControlReadOnly = (actionType == "rating") ? false : true;

            myData.CssClass = "TBL";
            myData.Rows.Clear();

            // Header
            var tr = new TableRow();
            tr.Style.Add("background-color", "#cccccc");

            var td = new TableCell();
            td.ColumnSpan = 2;
            td.Text = "Risk Category";
            td.Style.Add(HtmlTextWriterStyle.TextAlign, "center");
            tr.Cells.Add(td);

            td = new TableCell();
            td.ColumnSpan = 2;
            td.Text = "Scoring";
            td.Style.Add(HtmlTextWriterStyle.TextAlign, "center");
            tr.Cells.Add(td);

            myData.Rows.Add(tr);

            tr = new TableRow();
            tr.Style.Add("background-color", "#333333");
            td = new TableCell();
            td.ColumnSpan = 2;
            td.Text = "";
            tr.Cells.Add(td);

            td = new TableCell();
            td.Text = "Marks (1-5)";
            td.Style.Add(HtmlTextWriterStyle.TextAlign, "center");
            td.Style.Add(HtmlTextWriterStyle.Color, "white");
            tr.Cells.Add(td);

            td = new TableCell();
            td.Text = "Remarks";
            td.Style.Add(HtmlTextWriterStyle.TextAlign, "center");
            td.Style.Add(HtmlTextWriterStyle.Color, "white");
            tr.Cells.Add(td);
            myData.Rows.Add(tr);

            int index = 0;
            int subCatIndex = 0;
            var Category = "";
            foreach (DataRow item in ds.Tables[0].Rows)
            {
                index++;

                tr = new TableRow();

                if (item["type"].ToString() == "A")
                {
                    td = new TableCell();
                    td.ColumnSpan = 4;
                    td.Text = item["description"].ToString();
                    Category = item["summaryDescription"].ToString();
                    tr.Style.Add("background-color", "Red");
                    td.Style.Add(HtmlTextWriterStyle.TextAlign, "center");
                    td.Style.Add(HtmlTextWriterStyle.Color, "white");
                    td.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");
                    tr.Cells.Add(td);

                    subCatIndex = 0;
                }
                else if (item["type"].ToString() == "B")
                {
                    subCatIndex++;

                    string expression = "ParentId = '" + item["ParentId"] + "' and type = 'C'";
                    DataRow[] foundRows;
                    foundRows = ds.Tables[0].Select(expression); // Use the Select method to find all rows matching the filter.

                    td = new TableCell();
                    td.RowSpan = foundRows.Length + 1;
                    td.Text = subCatIndex.IntToLetter();
                    td.CssClass = "tdSubCatIndex";
                    tr.Cells.Add(td);

                    td = new TableCell();
                    td.CssClass = "tdContent";
                    td.Text = item["description"].ToString();
                    td.Style.Add("font-weight", "bold");
                    td.Width = 400;
                    tr.Cells.Add(td);

                    td = new TableCell();
                    td.Text = "";
                    td.ColumnSpan = 2;
                    td.Width = 200;
                    tr.Cells.Add(td);
                }
                else if (item["type"].ToString() == "C")
                {
                    td = new TableCell();
                    td.CssClass = "tdContent";

                    HiddenField hdnId = new HiddenField();
                    hdnId.Value = item["rowId"].ToString();
                    hdnId.ID = "hdn_" + index.ToString();
                    td.Controls.Add(hdnId);

                    System.Web.UI.HtmlControls.HtmlGenericControl dvContent =
                    new System.Web.UI.HtmlControls.HtmlGenericControl("DIV");
                    dvContent.Style.Add(HtmlTextWriterStyle.Width, "500px");
                    dvContent.Attributes.Add("class", "tdContent");
                    dvContent.InnerHtml = "<i>(" + Convert.ToInt32(item["displayOrder"].ToString()).ToRomanNumeral() + ") " + item["description"].ToString() + "</i>";

                    td.Controls.Add(dvContent);
                    tr.Cells.Add(td);

                    td = new TableCell();
                    td.CssClass = "tdddl";
                    var ddl = new DropDownList();
                    ddl.ID = "ddl_" + index.ToString();
                    //ddl.Width = 100;
                    ddl.CssClass = "ddl";
                    ddl.Items.Insert(0, new ListItem("Select", ""));
                    for (int i = 0; i <= 5; i++)
                    {
                        ddl.Items.Insert(i + 1, new ListItem((i).ToString("0.00") + " - " + ((i == 0 || i == 1) ? "Low" : (i == 2 || i == 3) ? "Medium" : "High"), (i).ToString("0.00")));
                    }

                    ddl.SelectedValue = item["score"].ToString();
                    //ddl.Enabled = isControlReadOnly;
                    ddl.Attributes.Add("disabled", "disabled");
                    td.Controls.Add(ddl);
                    tr.Cells.Add(td);

                    td = new TableCell();
                    var txt = new TextBox(); //new System.Web.UI.HtmlControls.HtmlGenericControl("DIV");

                    txt.ID = "txt_" + index.ToString();
                    txt.CssClass = "RemarksTextBox";
                    txt.TextMode = TextBoxMode.MultiLine;
                    txt.Rows = 3;
                    txt.Text = item["remarks"].ToString();
                    //txt.ReadOnly = true;
                    if (isControlReadOnly)
                        txt.Attributes.Add("readonly", "true");
                    else
                        txt.Attributes.Remove("readonly");

                    td.Controls.Add(txt);
                    tr.Cells.Add(td);
                }

                myData.Rows.Add(tr);
            }
            hdnRowsCount.Value = index.ToString();
        }

        private void PrintSummaryTable(DataSet ds)
        {
            Dictionary<string, decimal> CatTotalList = new Dictionary<string, decimal>();

            //string[,] weight = new string[,] { {"","","","" }, { } };

            var catWeightList = new ItemList<string, decimal>();
            //ItemList<string, decimal> subCatTotalList;

            var maxScore = 5;
            var totalMaxScore = 0; // maxScore*itemCount
            decimal totalScore = 0;
            decimal Score = 0;

            string strTable = @" <table runat='server' id='tblSummary' width='300px'>
                                <tr>
                                    <th width='200px' style='text-align: left;'>
                                        Risk Category
                                    </th>
                                    <th width='50px' style='text-align: left;'>
                                        Score
                                    </th>
                                    <th width='50px' style='text-align: left;'>
                                        Rating
                                    </th>
                                </tr>";

            if (ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 1)
            {
                DataTable dtSummary = ds.Tables[1];
                if (dtSummary.Rows.Count > 1)
                {
                    for (int i = 0; i < dtSummary.Rows.Count; i++)
                    {
                        decimal score;
                        decimal ratingScore = 0;

                        if (decimal.TryParse(dtSummary.Rows[i]["score"].ToString(), out score))
                            ratingScore = score;

                        strTable += "<tr class='" + rating(ratingScore).ToLower() + "'><td>";
                        strTable += dtSummary.Rows[i]["riskCategory"].ToString() + "</td><td>";

                        strTable += ratingScore.ToString("0.00") + "</td><td>" + rating(ratingScore) + "</td></tr>";
                    }
                }
            }
            else
            {
                string expression = "type = 'A'";
                DataRow[] Category;
                Category = ds.Tables[0].Select(expression);
                int index = 0;

                foreach (var item in Category)
                {
                    index++;

                    strTable += "<tr><td>";
                    strTable += item["summaryDescription"].ToString() + "</td><td>";

                    catWeightList.Add(item["summaryDescription"].ToString(), Convert.ToDecimal(item["weight"].ToString()));

                    string expression1 = "ParentId Like '" + index.ToString() + ".%' and type = 'B'";
                    DataRow[] SubCategory;
                    SubCategory = ds.Tables[0].Select(expression1);

                    decimal subCatWeight = Convert.ToDecimal(item["weight"].ToString()) / ((SubCategory.Length > 0) ? SubCategory.Length : 1);

                    int subCatIndex = 0;

                    //subCatTotalList = new ItemList<string, decimal>();

                    Dictionary<string, decimal> subCatTotalList = new Dictionary<string, decimal>();

                    foreach (var subCat in SubCategory)
                    {
                        subCatIndex++;

                        expression = "ParentId Like '" + index.ToString() + "." + subCatIndex.ToString() + "' and type = 'C'";
                        DataRow[] foundRows;
                        foundRows = ds.Tables[0].Select(expression);

                        var itemCount = foundRows.Length;
                        totalMaxScore = maxScore * itemCount;

                        decimal subTotal = 0;

                        foreach (var row in foundRows)
                        {
                            if (decimal.TryParse(row["score"].ToString(), out Score))
                                subTotal += Score;
                        }

                        subCatTotalList.Add(subCatIndex.IntToLetter(), (subTotal / totalMaxScore) * subCatWeight);
                    }

                    decimal subCatTotal = 0;

                    foreach (KeyValuePair<string, decimal> kvp in subCatTotalList)
                    {
                        subCatTotal += kvp.Value;
                    }

                    var score = (subCatTotal / Convert.ToDecimal(item["weight"].ToString())) * maxScore;

                    strTable += (score).ToString("0.00") + "</td><td>" + rating(score) + "</td></tr>";
                    totalScore += score * Convert.ToDecimal(item["weight"].ToString()) / 100;
                }

                strTable += "<tr><td>";
                strTable += "Overall " + "</td><td>";

                strTable += (totalScore).ToString("0.00") + "</td><td>" + rating(totalScore) + "</td></tr>";
            }

            strTable += "</table>";

            divSummary.InnerHtml = strTable;

            //DataSet ds1 = ConvertHTMLTablesToDataSet(strTable);
        }

        private string rating(decimal score)
        {
            string result = "";

            string[] scoringCriteria = hdnscoringCriteria.Value.Split(':');

            if (scoringCriteria.Length >= 3)
            {
                if (score <= Convert.ToDecimal(scoringCriteria[0]))
                    result = scoringCriteria[1];
                else if (score <= Convert.ToDecimal(scoringCriteria[2]))
                    result = scoringCriteria[3];
                else if (score > Convert.ToDecimal(scoringCriteria[2]))
                    result = scoringCriteria[5];
            }
            return result;
        }

        private DataTable PrepareSummaryTable(DataTable dtDetails)
        {
            Dictionary<string, decimal> CatTotalList = new Dictionary<string, decimal>();
            var catWeightList = new ItemList<string, decimal>();

            var maxScore = 5;
            var totalMaxScore = 0;
            decimal totalScore = 0;
            decimal Score = 0;

            DataTable dt = new DataTable();
            dt.TableName = "dtSummary";

            dt.Columns.Add("arMasterId", typeof(string));
            dt.Columns.Add("riskCategory", typeof(string));
            dt.Columns.Add("score", typeof(string));
            dt.Columns.Add("rating", typeof(string));

            string expression = "type = 'A'";
            DataRow[] Category;
            Category = dtDetails.Select(expression);
            int index = 0;

            DataRow dr;
            foreach (var item in Category)
            {
                index++;

                dr = dt.NewRow();
                dr[0] = item["rowId"].ToString();
                dr[1] = item["summaryDescription"].ToString();

                catWeightList.Add(item["summaryDescription"].ToString(), Convert.ToDecimal(item["weight"].ToString()));

                string expression1 = "ParentId Like '" + index.ToString() + ".%' and type = 'B'";
                DataRow[] SubCategory;
                SubCategory = dtDetails.Select(expression1);

                decimal subCatWeight = Convert.ToDecimal(item["weight"].ToString()) / SubCategory.Length;

                int subCatIndex = 0;

                //subCatTotalList = new ItemList<string, decimal>();

                Dictionary<string, decimal> subCatTotalList = new Dictionary<string, decimal>();

                foreach (var subCat in SubCategory)
                {
                    subCatIndex++;

                    expression = "ParentId Like '" + index.ToString() + "." + subCatIndex.ToString() + "' and type = 'C'";
                    DataRow[] foundRows;
                    foundRows = dtDetails.Select(expression);

                    var itemCount = foundRows.Length;
                    totalMaxScore = maxScore * itemCount;

                    decimal subTotal = 0;

                    foreach (var row in foundRows)
                    {
                        if (decimal.TryParse(row["score"].ToString(), out Score))
                            subTotal += Score;
                    }

                    subCatTotalList.Add(subCatIndex.IntToLetter(), (subTotal / totalMaxScore) * subCatWeight);
                }

                decimal subCatTotal = 0;

                foreach (KeyValuePair<string, decimal> kvp in subCatTotalList)
                {
                    subCatTotal += kvp.Value;
                }

                var score = (subCatTotal / Convert.ToDecimal(item["weight"].ToString())) * maxScore;

                totalScore += score * Convert.ToDecimal(item["weight"].ToString()) / 100;

                dr[2] = (score).ToString("0.00");
                dr[3] = rating(score);
                dt.Rows.Add(dr);
            }

            dr = dt.NewRow();
            dr[0] = index.ToString();
            dr[1] = "Overall";
            dr[2] = (totalScore).ToString("0.00");
            dr[3] = rating(totalScore);
            dt.Rows.Add(dr);

            return dt;
        }

        protected void btnAgentRating_Click(object sender, EventArgs e)
        {
            var sb = new StringBuilder("<root>");

            var arDetaildId = GetStatic.ReadQueryString("arId", "");
            var agentId = GetStatic.ReadQueryString("aId", "");
            var agentType = GetStatic.ReadQueryString("atype", "");
            //var isratingCompleted = "Y";

            Table mytbl = (Table)Page.FindControl("myData");

            for (int i = 1; i <= mytbl.Rows.Count - 2; i++)
            {
                HiddenField hdnId = (HiddenField)mytbl.Rows[i].FindControl("hdn_" + i.ToString());
                DropDownList ddlScore = (DropDownList)mytbl.Rows[i].FindControl("ddl_" + i.ToString());
                TextBox txtRemarks = (TextBox)mytbl.Rows[i].FindControl("txt_" + i.ToString());

                if (null != hdnId && null != ddlScore && null != txtRemarks)
                {
                    var score = (ddlScore.SelectedValue == "") ? null : ddlScore.SelectedValue;

                    sb.Append("<row arDetaildId=\"" + arDetaildId + "\" ");
                    sb.Append(" rowId=\"" + hdnId.Value + "\" ");
                    sb.Append(" score=\"" + score + "\" ");
                    sb.Append(" remarks=\"" + obj.FilterStringForXml(txtRemarks.Text.Trim()) + "\" />");
                }
            }
            sb.Append("</root>");

            var ds = obj.SaveAgentRating(GetStatic.GetUser(), sb, agentId, agentType, arDetaildId, "Y", "", GetStatic.GetUser());

            if (ds.Tables[0].Rows[0][0].ToString() == "0")
            {
                DataTable dt = PrepareSummaryTable(ds.Tables[1]);
                sb = new StringBuilder("<root>");
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    sb.Append("<row arMasterId=\"" + dt.Rows[i][0].ToString() + "\" ");
                    sb.Append(" riskCategory=\"" + dt.Rows[i][1].ToString() + "\" ");
                    sb.Append(" score=\"" + dt.Rows[i][2].ToString() + "\" ");
                    sb.Append(" rating=\"" + dt.Rows[i][3].ToString() + "\" />");
                }
                sb.Append("</root>");

                var dbresult = obj.SaveRatingSummary(GetStatic.GetUser(), sb, arDetaildId, agentType);
            }

            ManageMessage(ds.Tables[0]);
        }

        private void ManageMessage(DataTable dt)
        {
            var url = "agentList.aspx";
            GetStatic.CallJSFunction(this, string.Format("CallBackSave('{0}','{1}", dt.Rows[0][0], dt.Rows[0][1].ToString().Replace("'", "") + "','" + url + "')"));
        }

        private void ManageMessage(DbResult dr)
        {
            var url = "agentList.aspx";
            GetStatic.CallJSFunction(this, string.Format("CallBackSave('{0}','{1}", dr.ErrorCode, dr.Msg.Replace("'", "") + "','" + url + "')"));
        }

        protected void btnReview_Click(object sender, EventArgs e)
        {
            if (reviewersComment.Text.Trim() == "")
            {
                GetStatic.AlertMessage(this, "Reviewer's comment is required.");
                return;
            }

            var arDetaildId = GetStatic.ReadQueryString("arId", "");
            var agentId = GetStatic.ReadQueryString("aId", "");
            var dbresult = obj.SaveRatingReview(GetStatic.GetUser(), reviewersComment.Text.Trim(), arDetaildId);
            ManageMessage(dbresult);
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            if (approversComment.Text.Trim() == "")
            {
                GetStatic.AlertMessage(this, "Approver's comment is required.");
                return;
            }

            var arDetaildId = GetStatic.ReadQueryString("arId", "");
            var agentId = GetStatic.ReadQueryString("aId", "");
            var dbresult = obj.ApproveAgentRating(GetStatic.GetUser(), approversComment.Text.Trim(), arDetaildId);
            ManageMessage(dbresult);
        }
    }
}