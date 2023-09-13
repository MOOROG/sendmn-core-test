using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using Swift.API.com.global.www;
using System.Net;
using System.Data;

namespace Swift.API.GlobalBank
{
	public class GlobalBankAPI
	{
		private static X509Certificate2 cert;
		private static bool foundCertificate = false;
		private RemoteRemit gblApi = new RemoteRemit();
		private string ProviderName = "Global Bank";

		private String username;
		private String password;
		private String payingBranchCd;

		public GlobalBankAPI()
		{
			username = Utility.GetgblUserid();
			password = Utility.GetgblPassword();
			payingBranchCd = Utility.GetgblpayoutCode();

            /*
             * Application to Production Only
            */

            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls;
            ServicePointManager.ServerCertificateValidationCallback += (se, cert, chain, sslerror) => true;
            X509Certificate2 c = GetCertificateFromFile();
            gblApi.ClientCertificates.Add(c);

        }

		public DbResult GetStatus(string user, string pinNo)
		{
			var dr = new DbResult();
			var id = "0";
			try
			{
				id = Utility.LogRequest(user, ProviderName, "GetRemoteStatus", pinNo, "Control No:" + pinNo).Id;
				var res = gblApi.GetRemoteStatus(username, password, pinNo);

				if (res == null)
					Utility.LogResponse(id, Utility.ArrayToXML(res));
				else
					Utility.LogResponse(id, Utility.ArrayToXML(res), res[0], res[1]);

				if (res == null)
				{
					dr.SetError("1", "Thirdparty API Server could not process request.", pinNo);
				}
				else if (string.IsNullOrWhiteSpace(res[0]))
				{
					dr.SetError("1", "Thirdparty API Server could not process request.", pinNo);
				}
				else
				{
					if (res[0].Equals("S007") || res[0].Equals("S008") || res[0].Equals("S009"))
					{
						dr.SetError("0", res[1], pinNo);
					}
					else
					{
						dr.SetError("1", res[1], pinNo);
					}
				}

				return dr;
			}
			catch (Exception ex)
			{
				dr.SetError("1", ex.Message, pinNo);
				Utility.LogResponse(id, ex.Message);
				return dr;
			}
		}

		public DbResult CancelTransaction(string user, string pinNo)
		{
			var dr = new DbResult();
			var id = "0";
			try
			{
				id = Utility.LogRequest(user, ProviderName, "CancelRemoteRemit", pinNo, "Control No:" + pinNo).Id;
				var res = gblApi.CancelRemoteRemit(username, password, pinNo);

				if (res == null)
					Utility.LogResponse(id, Utility.ArrayToXML(res));
				else
					Utility.LogResponse(id, Utility.ArrayToXML(res), res[0], res[1]);

				if (res == null)
				{
					dr.SetError("1", "Thirdparty API Server could not process request.", pinNo);
				}
				else if (string.IsNullOrWhiteSpace(res[0]))
				{
					dr.SetError("1", "Thirdparty API Server could not process request.", pinNo);
				}
				else
				{
					if (res[0].Equals("C000"))
					{
						dr.SetError("0", res[1], pinNo);
					}
					else
					{
						dr.SetError("1", res[1], pinNo);
					}
				}

				return dr;
			}
			catch (Exception ex)
			{
				dr.SetError("1", ex.Message, pinNo);
				Utility.LogResponse(id, ex.Message);
				return dr;
			}
		}

        public DbResult UpdateReceiverName(string user, string pinNo, string accNo, string newBenefName, string oldBenefName)
        {
            var dr = new DbResult();
            var id = "0";
            try
            {
                id = Utility.LogRequest(user, ProviderName, "AmendRemoteTxn", pinNo, "Control No:" + pinNo).Id;
                var res = gblApi.AmendRemoteTxn(username, password, pinNo,accNo,newBenefName,oldBenefName);

                if (res == null)
                    Utility.LogResponse(id, Utility.ArrayToXML(res));
                else
                    Utility.LogResponse(id, Utility.ArrayToXML(res), res[0], res[1]);

                if (res == null)
                {
                    dr.SetError("1", "Thirdparty API Server could not process request.", pinNo);
                }
                else if (string.IsNullOrWhiteSpace(res[0]))
                {
                    dr.SetError("1", "Thirdparty API Server could not process request.", pinNo);
                }
                else
                {
                    if (res[0].Equals("C000"))
                    {
                        dr.SetError("0", res[1], pinNo);
                    }
                    else
                    {
                        dr.SetError("1", res[1], pinNo);
                    }
                }

                return dr;
            }
            catch (Exception ex)
            {
                dr.SetError("1", ex.Message, pinNo);
                Utility.LogResponse(id, ex.Message);
                return dr;
            }
        }

        public DbResult CreateTransaction(string user, GblSendTransactionRequest input, string processId)
		{
			var dr = new DbResult();
			var id = Utility.LogRequest(user, ProviderName, "AddRemoteRemit", input.ControlNo, Utility.ObjectToXML(input), processId).Id;

			//Validate XML Request for Duplicate Checking
			var validateRes = Utility.ValidateRequest(user, input.ControlNo);
			if (validateRes.ErrorCode != "0")
			{
				Utility.LogResponse(id, validateRes.Msg, validateRes.ErrorCode, validateRes.Msg);
				dr.SetError(validateRes.ErrorCode, validateRes.Msg, validateRes.Id);
				return dr;
			}

			try
			{
				var res = gblApi.AddRemoteRemit(
					username
					, password
					, Utility.BlankIfNull(input.ControlNo)
					, Utility.BlankIfNull(input.BenefName)
					, Utility.BlankIfNull(input.BenefAdddress)
					, Utility.BlankIfNull(input.BenefTel)
					, Utility.BlankIfNull(input.BenefMobile)
					, Utility.BlankIfNull(input.BenefIdType)
					, Utility.BlankIfNull(input.BenefAccIdNo)
					, Utility.BlankIfNull(input.SenderName)
					, Utility.BlankIfNull(input.SenderAddress)
					, Utility.BlankIfNull(input.SenderTel)
					, Utility.BlankIfNull(input.SenderMobile)
					, Utility.BlankIfNull(input.SenderIdType)
					, Utility.BlankIfNull(input.SenderIdNo)
					, Utility.BlankIfNull(input.Purpose)
					, Utility.BlankIfNull(input.RemitType)
                    , Utility.BlankIfNull(input.PayingBankBranchCd)
					, Utility.BlankIfNull(input.RCurrency)
					, Utility.BlankIfNull(input.LocalAmount)
					, Utility.BlankIfNull(input.Amount)
					, Utility.BlankIfNull(input.ServiceCharge)
					, Utility.BlankIfNull(input.RCommission)
					, Utility.BlankIfNull(input.ExchangeRate)
					, Utility.BlankIfNull(input.RefNo)
					, Utility.BlankIfNull(input.Remarks)
					, Utility.BlankIfNull(input.Source)
					, Utility.BlankIfNull(input.NewAccount)
					, Utility.BlankIfNull(input.customerDOB)

					);

				if (res == null)
					Utility.LogResponse(id, Utility.ArrayToXML(res));
				else
				{
					Utility.LogResponse(id, Utility.ArrayToXML(res), res[0], res[1]);
					dr.TpErrorCode = res[0];
				}

				if (res == null)
				{
					dr.SetError("1", "Thirdparty API Server could not process request.", input.ControlNo);
				}
				else if (string.IsNullOrWhiteSpace(res[0]))
				{
					dr.SetError("1", "Thirdparty API Server could not process request.", input.ControlNo);
				}
				else
				{
					if (res[0].Equals("R000"))
					{
						dr.SetError("0", res[1], res[3]);
						dr.Extra = res[2];
					}
					else
					{
						dr.SetError("1", res[1], input.ControlNo);
					}
				}
				return dr;
			}
			catch (Exception ex)
			{
				dr.SetError("1", ex.Message, input.ControlNo);
				Utility.LogResponse(id, ex.Message);
				return dr;
			}
		}

		public DbResult GetTransactions(string user, string date, out string[] res)
		{
            date = DateTime.Parse(date).ToString("yyyy-MM-dd");

            var id = Utility.LogRequest(user, ProviderName, "GetRemoteTransactionDetail", date, "Date : " + date).Id;

			var dr = new DbResult();
			try
			{
				var tmpDate = Utility.GetDateToSqlDate(date);

				res = gblApi.GetRemoteTransactionDetail(username, password, tmpDate);
				Utility.LogResponse(id, Utility.ArrayToXML(res));
				if (res == null)
				{
					dr.SetError("1", "No transaction found", "");

				}
				else if (res.Length.Equals(0))
				{
					dr.SetError("1", "No transaction found", "");

				}
				else if (res[0].StartsWith("ERROR------->"))
				{
					dr.SetError("1", res[0], "");
				}
				else
				{
					dr.SetError("0", "Success", "");
				}

				return dr;
			}
			catch (Exception ex)
			{
				dr.SetError("1", ex.Message, "");
				Utility.LogResponse(id, ex.Message);
				res = null;
				return dr;
			}
		}

		public DbResult GetAccountDetail(string user, string accNo)
		{
			var id = Utility.LogRequest(user, ProviderName, "GetRemoteAccountDetail", accNo, "Account No:" + accNo).Id;

			var dr = new DbResult();
			try
			{
				var res = gblApi.GetRemoteAccountDetail(username, password, accNo);
				Utility.LogResponse(id, Utility.ArrayToXML(res));

				if (res == null)
				{
					dr.SetError("1", "Thirdparty API Server could not process request.", accNo);
				}
				else if (string.IsNullOrWhiteSpace(res[0]))
				{
					dr.SetError("1", "Thirdparty API Server could not process request.", accNo);
				}
				else
				{
					if (res[0].Equals("A000"))
					{
						if (string.IsNullOrWhiteSpace(res[3]) || string.IsNullOrWhiteSpace(res[2]))
						{
							dr.SetError("1", "Could not find Account Details.", accNo);
						}
						else
						{
							dr.SetError("0", res[3], res[2]);
						}
					}
					else
					{
						dr.SetError("1", res[1], accNo);
					}
				}

				return dr;
			}
			catch (Exception ex)
			{
				dr.SetError("1", ex.Message, accNo);
				Utility.LogResponse(id, ex.Message);
				return dr;
			}
		}
        public DbResult GetReconcileReport(string user, string trnDate, out DataTable dt)
        {
            var dr = new DbResult();
            dt = new DataTable();
            var id = "0";
            try
            {
                dt.Columns.Add("Control No");
                dt.Columns.Add("Status");
                dt.Columns.Add("SendOn");
                dt.Columns.Add("Sender");
                dt.Columns.Add("Receiver");
                dt.Columns.Add("Amount");
                dt.Columns.Add("PaidOn");
                trnDate = DateTime.Parse(trnDate).ToString("yyyy-MM-dd");
                
                var requestXml = trnDate;
                id = Utility.LogRequest(user, "Global Bank", "GetRemoteTransactionDetail", trnDate, requestXml).Id;

                var res = gblApi.GetRemoteTransactionDetail(username, password, trnDate);

                var responseXml = Utility.ObjectToXML(res);
                Utility.LogResponse(id, responseXml, "0", "Success");

                if (res == null || res.Length.Equals(0))
                {
                    dr.SetError("1", "API Server Could Not Process Your Request.", trnDate);
                    Utility.LogResponse(id, dr.Msg, dr.ErrorCode, dr.Msg);
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
                    Utility.LogResponse(id, dr.Msg, dr.ErrorCode, dr.Msg);
                }
                else
                {
                    foreach (var row in res)
                    {
                        var cols = row.Split('|');
                        var newRow = dt.NewRow();
                        for (var i = 1; i < 8; i++)
                        {
                            var iData = cols[i];
                            if (iData.ToUpper().Equals("NULL"))
                                iData = "";
                            newRow[i - 1] = iData;
                        }
                        dt.Rows.Add(newRow);
                    }
                    dr.SetError("0", "Success", trnDate);
                }
            }
            catch (Exception ex)
            {
                Utility.LogResponse(id, ex.Message, "999", "Internal Error");
                dr.SetError("1", ex.Message, "");
            }
            return dr;
        }

        private static X509Certificate2 GetCertificateFromFile()
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

        
    }
}
