using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Compliance
{
    public class complianceDao : RemittanceDao
    {
        public DataSet GetComplianceRptSenderWise(string Date)
        {
            var sql = "exec proc_complianceRpt @flag='s'";
            sql += ",@date=" + FilterString(Date);
            return ExecuteDataset(sql);
        }

        public DataTable SelectByMemId(string user, string membershipId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += " @flag = 'a1'";
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId = " + FilterString(membershipId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }
        public ReportResult GetComplianceRptReceiverWise(string flag, string Date, string user, string rName)
        {
            var sql = "exec proc_complianceRpt @flag='" + flag + "'";
            sql += ",@date=" + FilterString(Date);
            sql += ",@rName=" + FilterString(rName);
            return ParseReportResult(sql);
        }
        public DbResult Update(string id, string user, string customerCardNo, string name, string address, string country, string zone, string district, string idType, string idNumber, string dob, string fatherName, string remarks, string isActive)
        {
            string sql = "EXEC proc_blacklistDomestic";
            sql += " @flag = " + (id == "0" || id == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(id);
            sql += ", @customerCardNo = " + FilterString(customerCardNo);
            sql += ", @Name = " + FilterString(name);
            sql += ", @Address = " + FilterString(address);
            sql += ", @country = " + FilterString(country);
            sql += ", @district = " + FilterString(district);
            sql += ", @zone = " + FilterString(zone);
            sql += ", @IdType = " + FilterString(idType);
            sql += ", @IdNumber = " + FilterString(idNumber);
            sql += ", @Dob = " + FilterString(dob);
            sql += ", @FatherName = " + FilterString(fatherName);
            sql += ", @Remarks = " + FilterString(remarks);
            sql += ", @isActive = " + FilterString(isActive);
            return ParseDbResult(sql);

        }

        public DbResult Update1(string id, string user, string entNum, string vesselType, string customerCardNo, string name, string address, string country, string zone, string district, string idType, string idNumber, string dob, string fatherName, string datasource, string remarks, string isActive, string contact, string idPlaceIssue)
        {
            string sql = "EXEC proc_blacklistDomestic";
            sql += " @flag = " + (id == "0" || id == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(id);
            sql += ", @customerCardNo = " + FilterString(customerCardNo);
            sql += ", @Name = " + FilterString(name);
            sql += ", @Address = " + FilterString(address);
            sql += ", @country = " + FilterString(country);
            sql += ", @district = " + FilterString(district);
            sql += ", @zone = " + FilterString(zone);
            sql += ", @IdType = " + FilterString(idType);
            sql += ", @IdNumber = " + FilterString(idNumber);
            sql += ", @Dob = " + FilterString(dob);
            sql += ", @FatherName = " + FilterString(fatherName);
            sql += ", @Remarks = " + FilterString(remarks);
            sql += ", @isActive = " + FilterString(isActive);
            sql += ", @contact = " + FilterString(contact);
            sql += ", @idPlaceIssue = " + FilterString(idPlaceIssue);

            sql += ", @entNum = " + FilterString(entNum);
            sql += ", @vesselType = " + FilterString(vesselType);
            sql += ", @dataSource = " + FilterString(datasource);
            return ParseDbResult(sql);

        }

        public DataRow GetComplianceById(string id, string user)
        {
            string sql = "EXEC proc_blacklistDomestic";
            sql += " @flag = " + FilterString("s");
            sql += ",@user = " + FilterString(user);
            sql += ",@rowId = " + FilterString(id);
            return ExecuteDataRow(sql);
        }

        public DataSet GetComplianceSenderWiseMultipleReport(string fromDate,string toDate)
        {
            var sql = "exec proc_complianceRpt @flag='muls'";
            sql += ",@fromDate=" + FilterString(fromDate);
            sql += ",@toDate=" + FilterString(toDate);
            return ExecuteDataset(sql);
        }

        public ReportResult GetComplianceReceiverWiseMultipleReport(string flag, string fromDate,string toDate, string user, string rName)
        {
            var sql = "exec proc_complianceRpt @flag='" + flag + "'";
            sql += ",@fromDate=" + FilterString(fromDate);
            sql += ",@toDate=" + FilterString(toDate);
            sql += ",@rName=" + FilterString(rName);
            return ParseReportResult(sql);
        }
        public ReportResult GetComplianceReleaseReport(string fromDate, string toDate, string releasedBy, string includesystem, string idNumber, string customerName, string reportType, string holdReason)
        {
            var sql = "Exec proc_complianceReleaseReport";
            sql += " @flag=" + "'s'";
            sql += ",@fromDate=" + FilterString(fromDate);
            sql += ",@toDate=" + FilterString(toDate);
            sql += ",@releasedBy=" + FilterString(releasedBy);
            sql += ",@includesystem=" + FilterString(includesystem);
            sql += ",@idNumber=" + FilterString(idNumber);
            sql += ",@customerName=" + FilterString(customerName);
            sql += ",@reportType=" + FilterString(reportType);
            sql += ",@holdReason=" + FilterString(holdReason);
            return ParseReportResult(sql);
        }
        public DataSet ImportOFACList(string user, string xml, string sessionId,string ofacSourceValue)
        {
            string sql = "EXEC PROC_UPLOAD_OFACLIST ";
            sql += "@flag = 'i'";
            sql += ",@user = " + FilterString(user);
            sql += ",@XML = N'" + FilterStringForXml(xml) + "'";
            sql += ",@SESSION_ID = " + FilterString(sessionId);
            sql += ",@DATASOURCE =" + FilterString(ofacSourceValue);

            return ExecuteDataset(sql);
        }
    }
}
