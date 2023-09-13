using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.Utility
{
    public class ExportCsvFileDao : SwiftDao
    {
        public ExportFileInformation ExportTxnAcDeposit(string user, string status, string paymentType, 
            string delimeter, string fields, string fromDate, string toDate, string bod, string eod, 
            string agentId, string branchId, string mapCodeInt)
        {

                var sql = "EXEC proc_ExportACDeposit @flag='b'";
                sql += ", @user=" + FilterString(user);
                sql += ", @status=" + FilterString(status);
                sql += ", @paymentType=" + FilterString(paymentType);
                sql += ", @delimeter='" + (delimeter)+"'";
                sql += ", @fields=" + FilterString(fields);
                sql += ", @fromDate=" + FilterString(fromDate);
                sql += ", @toDate=" + FilterString(toDate);
                sql += ", @bod=" + FilterString(bod);
                sql += ", @eod=" + FilterString(eod);
                sql += ", @agentId = " + FilterString(agentId);
                sql += ", @branchId = " + FilterString(branchId);
                sql += ", @mapCodeInt = " + FilterString(mapCodeInt);

            DataSet ds = ExecuteDataset(sql);

            var fileInfo = new ExportFileInformation();
            DataTable dtBody = ds.Tables[0];

            var sb = new StringBuilder();

            sb.Append(DataTableToText(ref dtBody, delimeter));

            fileInfo.Content = sb.ToString();
            return fileInfo;
        }

        public ExportFileInformation ExportTxn(string user, string userType ,string fields, string mapCodeInt,
           string confDate, string fromDate, string toDate, string rcountry, string ragent, string payType,
           string senBranch, string statuss, string delimeter)
        {
            var sql = "EXEC proc_exportTransaction ";
            sql += "  @fldmon= '" + fields + "'";
            sql += " ,@agentid= " + FilterString(mapCodeInt);
            sql += " ,@ddDate= " + FilterString(confDate);
            sql += " ,@fromDate= " + FilterString(fromDate);
            sql += " ,@toDate= " + FilterString(toDate);
            sql += " ,@receiverCountry= " + FilterString(rcountry);
            sql += " ,@payoutagentid= " + FilterString(ragent);
            sql += " ,@paymentType= " + FilterString(payType);
            sql += " ,@branch_id= " + FilterString(senBranch);
            sql += " ,@trn_status= " + FilterString(statuss);
            sql += " ,@user= " + FilterString(user);
            sql += " ,@userType= " + FilterString(userType);

            DataSet ds = ExecuteDataset(sql);
            var fileInfo = new ExportFileInformation();
            DataTable dtBody = ds.Tables[0];
            var sb = new StringBuilder();
            sb.Append(DataTableToText(ref dtBody, delimeter));
            fileInfo.Content = sb.ToString();
            return fileInfo;
        }

        public ExportFileInformation ExportFileAllInfo (string user, string status, string paymentType,
            string delimeter, string fields, string fromDate, string toDate, string bod, string eod,
            string agentId, string branchId, string mapCodeInt)
        {

            var sql = "EXEC proc_ExportTranAll @flag='b'";
            sql += ", @user=" + FilterString(user);
            sql += ", @status=" + FilterString(status);
            sql += ", @paymentType=" + FilterString(paymentType);
            sql += ", @delimeter='" + (delimeter) + "'";
            sql += ", @fields=" + FilterString(fields);
            sql += ", @fromDate=" + FilterString(fromDate);
            sql += ", @toDate=" + FilterString(toDate);
            sql += ", @bod=" + FilterString(bod);
            sql += ", @eod=" + FilterString(eod);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @mapCodeInt = " + FilterString(mapCodeInt);

            DataSet ds = ExecuteDataset(sql);

            var fileInfo = new ExportFileInformation();
            DataTable dtBody = ds.Tables[0];

            var sb = new StringBuilder();

            sb.Append(DataTableToText(ref dtBody, delimeter));

            fileInfo.Content = sb.ToString();
            return fileInfo;
        }

    }
    public class ExportFileInformation
    {
        public string Content { get; set; }
    }
}
