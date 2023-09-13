using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.SendTxn
{
    public class TxnAgent
    {
        public int SAgentId { get; set; }
        public string SAgentName { get; set; }
        public int SSuperAgentId { get; set; }
        public string SSuperAgentName { get; set; }
        public string AgentRefId { get; set; }
        public string PBranchId { get; set; }
        public string PBranchName { get; set; }
        public string PBranchCity { get; set; }
        public int PAgentId { get; set; }
        public string PAgentName { get; set; }
        public int SBranchId { get; set; }
        public string SBranchName { get; set; }
        public string PBankType { get; set; }
        public string PBankId { get; set; }
        public string PBankName { get; set; }
        public string PBankBranchId { get; set; }
        public string PBankBranchName { get; set; }
    }
}