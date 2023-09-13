using Swift.DAL.BL.System.Utility;
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Security.Cryptography.X509Certificates;
using System.Text;

namespace Swift.DAL.BL.Helper.ThirdParty.GlobalBank
{
    public class GlobalBankApi
    {
        private readonly string userName;
        private readonly string password;

        private static X509Certificate2 cert;
        private static bool foundCertificate = false;

        public GlobalBankApi()
        {
            userName = Utility.GetgblUserid();
            password = Utility.GetgblPassword();
            //>>not needed for TEST server

            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls;
            ServicePointManager.ServerCertificateValidationCallback += (se, cert, chain, sslerror) => true;
            X509Certificate2 c = GetCertificateFromFile();
            gblApi.ClientCertificates.Add(c);


            //<<not needed for TEST server
        }

        static X509Certificate2 GetCertificate()
        {
            if (!foundCertificate)
            {
                X509Store store;
                store = new X509Store(StoreLocation.CurrentUser);
                //X509Certificate cert = new X509Certificate();
                store.Open(OpenFlags.ReadOnly);
                var certFriendlyName = Utility.GetgblCertName();

                foreach (var certificate in store.Certificates)
                {
                    if (certificate.FriendlyName.ToUpper().Equals(certFriendlyName.ToUpper()))
                    {
                        cert = certificate;
                        foundCertificate = true;
                        break;
                    }
                }

                store.Close();
            }

            return cert;
        }

        public Swift.DAL.GlobalRemit.RemoteRemit gblApi = new Swift.DAL.GlobalRemit.RemoteRemit();
        public DbResult GetStatus(string user, string radNo)
        {
            var requestXml = "radNo=" + radNo;
            var dr = new DbResult();
            var id = ApiUtility.LogRequest(user, "Global Bank", "GetRemoteStatus", radNo, requestXml).Id;
            try
            {
                var res = gblApi.GetRemoteStatus(userName, password, radNo);

                var responseXml = ApiUtility.ObjectToXML(res);
                ApiUtility.LogResponse(id, responseXml, "0", "Success");

                if (res == null || res.Length.Equals(0) || res[0].Equals("S990"))
                {
                    dr.SetError("1", "Invalid Control No", radNo);
                    ApiUtility.LogDataError(id, dr.ErrorCode, dr.Msg);
                    return dr;
                }
                if (!res[0].Equals("S008"))
                {
                    dr.SetError("1", string.Concat("This Transaction is in ", res[1], " mode"), res[2]);
                    ApiUtility.LogDataError(id, dr.ErrorCode, dr.Msg);
                }
                else
                {
                    dr.SetError("0", "Success", res[1]);
                }
            }
            catch (Exception ex)
            {
                ApiUtility.LogResponse(id, ex.Message, "999", "Internal Error");
                dr.SetError("1", ex.Message, "");
            }
            return dr;
        }
        public DbResult SelectByPinNo(string user, string radNo, out GlobalPayTransactionResponse response)
        {
            var requestXml = "radNo=" + radNo;
            var dr = new DbResult();
            response = null;
            var id = ApiUtility.LogRequest(user, "Global Bank", "GetRemoteRemit", radNo, requestXml).Id;
            try
            {
                var res = gblApi.GetRemoteRemit(userName, password, radNo);

                var responseXml = ApiUtility.ObjectToXML(res);
                ApiUtility.LogResponse(id, responseXml, "0", "Success");

                if (res == null || res.Length.Equals(0))
                {
                    dr.SetError("1", "No Transaction Found", "");
                    ApiUtility.LogDataError(id, dr.ErrorCode, dr.Msg);
                    response = null;
                }
                else if (!res[0].Equals("G000"))
                {
                    dr.SetError("1", res[1], "");
                    ApiUtility.LogDataError(id, dr.ErrorCode, dr.Msg);
                    response = null;
                }
                else
                {
                    dr.SetError("0", "Success", "");
                    response = GetGlobalPayObject(res);
                }
            }
            catch (Exception ex)
            {
                ApiUtility.LogResponse(id, ex.Message, "999", "Internal Error");
                dr.SetError("1", ex.Message, "");
            }
            return dr;
        }
        public DbResult SelectByPinNoCashExpress(string user, string radNo, out GlobalPayTransactionResponse response)
        {
            var requestXml = "radNo=" + radNo;
            var dr = new DbResult();
            response = null;
            var id = ApiUtility.LogRequest(user, "Global Bank", "GetCashExpressRemit", radNo, requestXml).Id;
            try
            {
                //var res = gblApi.GetCashExpressRemit(userName, password, radNo);

                //var responseXml = ApiUtility.ObjectToXML(res);
                //ApiUtility.LogResponse(id, responseXml, "0", "Success");

                //if (res == null || res.Length.Equals(0))
                //{
                //    dr.SetError("1", "No Transaction Found", "");
                //    ApiUtility.LogDataError(id, dr.ErrorCode, dr.Msg);
                //    response = null;
                //}
                //else if (!res[0].Equals("G000"))
                //{
                //    dr.SetError("1", res[1], "");
                //    ApiUtility.LogDataError(id, dr.ErrorCode, dr.Msg);
                //    response = null;
                //}
                //else
                //{
                //    dr.SetError("0", "Success", "");
                //    response = GetGlobalPayObject(res);                    
                //}
            }
            catch (Exception ex)
            {
                ApiUtility.LogResponse(id, ex.Message, "999", "Internal Error");
                dr.SetError("1", ex.Message, "");
            }
            return dr;
        }
        public DbResult PayConfirm(string user, string tokenId, string radNo,string idType,string idNumber)
        {
            var dr = new DbResult();

            var requestXml = "tokenId=" + tokenId + ";radNo =" + radNo;
            var drApi = ApiUtility.LogRequest(user, "Global Bank", "ProcessRemoteRemit", radNo, requestXml);
            var id = drApi.Id;

            if (!drApi.ErrorCode.Equals("0"))
            {
                dr.SetError(drApi.ErrorCode, "Technical Error. Please try again.", radNo);
                return dr;
            }

            try
            {
                var res = gblApi.ProcessRemoteRemit(userName, password, radNo, tokenId,idType,idNumber,"","");

                var responseXml = ApiUtility.ObjectToXML(res);
                ApiUtility.LogResponse(id, responseXml, "0", "Success");

                if (!res[0].Equals("P000"))
                {
                    dr.SetError("1", res[1], res[2]);
                    dr.Extra = res[0];//Api response Code
                    ApiUtility.LogDataError(id, dr.ErrorCode, dr.Msg);
                }
                else
                {
                    dr.SetError("0", res[1], res[2]);
                    dr.Extra = res[0];//Api response Code
                    dr.Extra2 = res[3];//Api Confirmation no
                }
            }
            catch (Exception ex)
            {
                ApiUtility.LogResponse(id, ex.Message, "999", "Internal Error");
                dr.SetError("1", ex.Message, "");
            }
            return dr;
        }
        public DbResult PayConfirmCashExpress(string user, string radNo, string tokenId, string amount, string benefIdType, string benefIdNo, string benefMobile, string benefNationality)
        {
            var dr = new DbResult();
            benefIdType = "4";
            var benefIdExpDt = DateTime.Today.AddYears(2).ToString("dd/MM/yyyy");
            var requestXml = "tokenId=" + tokenId + ";radNo=" + radNo +
                              ";benefIdType=" + benefIdType + ";benefIdNo=" + benefIdNo +
                              ";benefIdExpDt=" + benefIdExpDt + ";benefMobile=" + benefMobile +
                              ";benefNationality=" + benefNationality;

            var id = ApiUtility.LogRequest(user, "Global Bank", "ProcessCashExpressRemit", radNo, requestXml).Id;
            try
            {
                //var res = gblApi.ProcessCashExpressRemit(userName, password, radNo, tokenId, amount, benefIdType, benefIdNo, benefIdExpDt, benefMobile, benefNationality);

                //var responseXml = ApiUtility.ObjectToXML(res);
                //ApiUtility.LogResponse(id, responseXml, "0", "Success");

                //if (!res[0].Equals("P000"))
                //{
                //    dr.SetError("1", res[1], res[2]);
                //    dr.Extra = res[0];//Api response Code
                //    ApiUtility.LogDataError(id, dr.ErrorCode, dr.Msg);
                //}
                //else
                //{
                //    dr.SetError("0", res[1], res[2]);
                //    dr.Extra = res[0];//Api response Code
                //    dr.Extra2 = res[3];//Api Confirmation no
                //}
            }
            catch (Exception ex)
            {
                ApiUtility.LogResponse(id, ex.Message, "999", "Internal Error");
                dr.SetError("1", ex.Message, "");
            }
            return dr;
        }
        public DbResult GetReconcileReport(string user, string trnDate, out DataTable dt)
        {
            var dr = new DbResult();
            dt = new DataTable();
            var id = "0";
            try
            {
                dt.Columns.Add("BRN No");
                dt.Columns.Add("Status");
                dt.Columns.Add("SendOn");
                dt.Columns.Add("Sender");
                dt.Columns.Add("Receiver");
                dt.Columns.Add("Amount");
                dt.Columns.Add("PaidOn");


                var requestXml = trnDate;
                id = ApiUtility.LogRequest(user, "Global Bank", "GetRemoteTransactionDetail", trnDate, requestXml).Id;

                var res = gblApi.GetRemoteTransactionDetail(userName, password, trnDate);

                var responseXml = ApiUtility.ObjectToXML(res);
                ApiUtility.LogResponse(id, responseXml, "0", "Success");

                if (res == null || res.Length.Equals(0))
                {
                    dr.SetError("1", "API Server Could Not Process Your Request.", trnDate);
                    ApiUtility.LogDataError(id, dr.ErrorCode, dr.Msg);
                    return dr;
                }
                if (res[0].Split('|').Length < 8)
                {
                    var msg = "API Server Returned Invalid Data.";
                    if (res.Length > 1)
                    {
                        msg = res[1];
                    }
                    dr.SetError("1", msg, trnDate);
                    ApiUtility.LogDataError(id, dr.ErrorCode, dr.Msg);
                }
                else
                {
                    foreach (var row in res)
                    {
                        var cols = row.Split('|');
                        var newRow = dt.NewRow();
                        for (var i = 1; i < 8; i++)
                        {
                            newRow[i - 1] = cols[i];
                        }
                        dt.Rows.Add(newRow);
                    }
                    dr.SetError("0", "Success", trnDate);
                }
            }
            catch (Exception ex)
            {
                ApiUtility.LogResponse(id, ex.Message, "999", "Internal Error");
                dr.SetError("1", ex.Message, "");
            }
            return dr;
        }
        static X509Certificate2 GetCertificateFromFile()
        {

            if (!foundCertificate)
            {
                var gblCertPath = Utility.GetgblCertPath();
                var gblCertPwd = Utility.GetgblCertPwd();
                var c = new X509Certificate2(gblCertPath, gblCertPwd, X509KeyStorageFlags.MachineKeySet);
                cert = c;
                foundCertificate = true;
            }
            return cert;
        }

        #region Helper
        private static GlobalPayTransactionResponse GetGlobalPayObject(string[] input)
        {
            var ret = new GlobalPayTransactionResponse
            {
                SuccessCode = input[0],
                TokenId = input[1],
                RadNo = input[2],
                BenefName = input[3],
                BenefTel = input[4],
                BenefMobile = input[5],
                BenefAddress = input[6],
                BenefAccIdNo = input[7],
                BenefIdType = input[8],
                SenderName = input[9],
                SenderAddress = input[10],
                SenderTel = input[11],
                SenderMobile = input[12],
                SenderIdType = input[13],
                SenderIdNo = input[14],
                RemittanceEntryDt = input[15],
                RemittanceAuthorizedDt = input[16],
                Remarks = input[17],
                RemitType = input[18],
                RCurrency = input[19],
                PCurrency = input[20],
                PCommission = input[21],
                Amount = input[22],
                LocalAmount = input[23],
                ExchangeRate = input[24],
                DollarRate = input[25]
            };

            if (input.Length > 26)
            {
                ret.TPAgentID = input[26];
            }
            if (input.Length > 27)
            {
                ret.TPAgentName = input[27];
            }
            return ret;
        }
        #endregion
    }
}