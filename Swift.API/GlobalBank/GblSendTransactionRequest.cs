using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.GlobalBank
{
	public class GblSendTransactionRequest
	{
		public string ControlNo { get; set; }
		public string BenefName { get; set; }
		public string BenefAdddress { get; set; }
		public string BenefTel { get; set; }
		public string BenefMobile { get; set; }
		public string BenefIdType { get; set; }
		public string BenefAccIdNo { get; set; }
		public string SenderName { get; set; }
		public string SenderAddress { get; set; }
		public string SenderTel { get; set; }
		public string SenderMobile { get; set; }
		public string SenderIdType { get; set; }
		public string SenderIdNo { get; set; }
		public string Purpose { get; set; }
		public string RemitType { get; set; }
		public string PayingBankCd { get; set; }
		public string PayingBranchCd { get; set; }
		public string PayingBankBranchCd { get; set; }
		public string RCurrency { get; set; }
		public string LocalAmount { get; set; }
		public string Amount { get; set; }
		public string ServiceCharge { get; set; }
		public string RCommission { get; set; }
		public string ExchangeRate { get; set; }
		public string RefNo { get; set; }
		public string Remarks { get; set; }
		public string Source { get; set; }
		public string NewAccount { get; set; }
		public string customerDOB { get; set; }

	}
}
