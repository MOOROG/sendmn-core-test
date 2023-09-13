using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.AML
{
    public class AMLReportDao : RemittanceDao
    {
   public ReportResult SearchByCustomer(
                 string user
                , string sCountry
                , string rCountry
                , string sAgent
                , string rAgent
                , string rMode
                , string dateType
                , string frmDate
                , string toDate
                , string searchBy
                , string saerchType
                , string searchValue
                , string pageNumber
                , string pageSize
                , string isExportFull
            )
        {
            string sql = "EXEC proc_amlSearchByCustomerRpt @flag = 'sbc'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rMode = " + FilterString(rMode);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @frmDate = " + FilterString(frmDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @searchBy = " + FilterString(searchBy);
            sql += ", @saerchType = " + FilterString(saerchType);
            sql += ", @searchValue = " + FilterString(searchValue);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @isExportFull = " + FilterString(isExportFull);
            return ParseReportResult(sql);
        }


        public ReportResult TopCustomer(
                 string user
                , string sCountry
                , string rCountry
                , string sAgent
                , string rAgent
                , string rMode
                , string dateType
                , string frmDate
                , string toDate
                , string rptBy
                , string rptFor
                , string tcNo
                , string pageNumber
                , string pageSize
                , string isExportFull
                ,string reportType
            )
        {
            string sql = "EXEC proc_amlTopCustomer @flag = 'tc'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rMode = " + FilterString(rMode);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @frmDate = " + FilterString(frmDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @rptBy = " + FilterString(rptBy);
            sql += ", @rptFor = " + FilterString(rptFor);
            sql += ", @tcNo = " + FilterString(tcNo);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @isExportFull = " + FilterString(isExportFull);
            sql += ", @reportType = " + FilterString(reportType);

            return ParseReportResult(sql);
        }

        public ReportResult CustomerReport(
              string user
            , string sCountry
            , string rCountry
            , string sAgent
            , string rAgent
            , string rMode
            , string dateType
            , string frmDate
            , string toDate
            , string fromAmt
            , string toAmt
            , string isd
            , string orderBy
            , string pageNumber
            , string pageSize
            , string isExportFull
            , string amtType
            )
        {
            string sql = "EXEC proc_amlCustomerRpt @flag = 'cr'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rMode = " + FilterString(rMode);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @frmDate = " + FilterString(frmDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @fromAmt = " + FilterString(fromAmt);
            sql += ", @toAmt = " + FilterString(toAmt);
            sql += ", @includeSenderDetails = " + FilterString(isd);
            sql += ", @orderBy = " + FilterString(orderBy);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @isExportFull = " + FilterString(isExportFull);
            sql += ", @amtType = " + FilterString(amtType);

            return ParseReportResult(sql);
        }

        public ReportResult CustomerReportDaily(
              string user
            , string sCountry
            , string rCountry
            , string sAgent
            , string rAgent
            , string rMode
            , string dateType
            , string frmDate
            , string toDate
            , string fromAmt
            , string toAmt
            , string isd
            , string orderBy
            , string pageNumber
            , string pageSize
            , string isExportFull
            )
        {
            string sql = "EXEC proc_amlCustomerRpt_daily @flag = 'cr'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rMode = " + FilterString(rMode);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @frmDate = " + FilterString(frmDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @fromAmt = " + FilterString(fromAmt);
            sql += ", @toAmt = " + FilterString(toAmt);
            sql += ", @includeSenderDetails = " + FilterString(isd);
            sql += ", @orderBy = " + FilterString(orderBy);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @isExportFull = " + FilterString(isExportFull);

            return ParseReportResult(sql);
        }

        public ReportResult MISReport(
                      string user
                    , string sCountry
                    , string rCountry
                    , string sAgent
                    , string rAgent
                    , string rMode
                    , string dateType
                    , string frmDate
                    , string toDate
                    , string mrType
                    , string pageNumber
                    , string pageSize
                    , string isExportFull
                    
                    )
        {
            string sql = "EXEC proc_amlMisRpt @flag = 'mr'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rMode = " + FilterString(rMode);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @frmDate = " + FilterString(frmDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @mrType = " + FilterString(mrType);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @isExportFull = " + FilterString(isExportFull);

            return ParseReportResult(sql);
        }

        public ReportResult OFACAndCompliance(
                      string user
                    , string sCountry
                    , string rCountry
                    , string sAgent
                    , string rAgent
                    , string rMode
                    , string dateType
                    , string frmDate
                    , string toDate
                    , string octype
                    , string ocRptType
                    , string pageNumber
                    , string pageSize
                    , string isExportFull
                    )
        {
            string sql = "EXEC proc_amlOCrpt @flag = 'oc'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rMode = " + FilterString(rMode);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @frmDate = " + FilterString(frmDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @octype = " + FilterString(octype);
            sql += ", @ocRptType = " + FilterString(ocRptType);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @isExportFull = " + FilterString(isExportFull);

            return ParseReportResult(sql);
        }

        #region DDL AML report
        public ReportResult DDLSearchByCustomer(
                      string flag, string user, string sCountry, string rCountry, string sAgent, string rAgent,
                      string rMode, string dateType, string frmDate, string toDate,
                      string searchType, string searchValue, string txnDate, string senderName, string receiverName,
                      string customerId, string rptFor, string fromAmt, string toAmt, string country, string sidType, string sidNumber, string company,
                      string searchBy, string isExportFull, string recMobile, string amtType)
        {
            string sql = "EXEC proc_amlDropDown @flag =" + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @date = " + FilterString(txnDate);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @recName = " + FilterString(receiverName);
            sql += ", @recMobile = " + FilterString(recMobile);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rMode = " + FilterString(rMode);
            sql += ", @searchType = " + FilterString(searchType);
            sql += ", @searchValue = " + FilterString(searchValue);
            sql += ", @rptFor = " + FilterString(rptFor);
            sql += ", @country = " + FilterString(country);
            sql += ", @senderName = " + FilterString(senderName);

            sql += ", @idType = " + FilterString(sidType);
            sql += ", @idNumber = " + FilterString(sidNumber);
            sql += ", @company = " + FilterString(company);
            sql += ", @searchBy = " + FilterString(searchBy);
            sql += ", @fromAmt = " + FilterString(fromAmt);
            sql += ", @toAmt = " + FilterString(toAmt);
            sql += ", @dateType = " + FilterString(dateType);
            sql += ", @frmDate = " + FilterString(frmDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @isExportFull = " + FilterString(isExportFull);
            sql += ", @amtType = " + FilterString(amtType);

            return ParseReportResult(sql);
        }
        #endregion

    }
}

