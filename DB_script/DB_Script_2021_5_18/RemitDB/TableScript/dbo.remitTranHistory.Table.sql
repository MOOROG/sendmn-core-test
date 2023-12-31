USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[remitTranHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[remitTranHistory](
	[id] [bigint] NOT NULL,
	[controlNo] [varchar](20) NULL,
	[sCurrCostRate] [decimal](15, 9) NULL,
	[sCurrHoMargin] [decimal](15, 9) NULL,
	[pCurrCostRate] [decimal](15, 9) NULL,
	[pCurrHoMargin] [decimal](15, 9) NULL,
	[sCurrAgentMargin] [decimal](15, 9) NULL,
	[pCurrAgentMargin] [decimal](15, 9) NULL,
	[sCurrSuperAgentMargin] [decimal](15, 9) NULL,
	[pCurrSuperAgentMargin] [decimal](15, 9) NULL,
	[customerRate] [decimal](15, 9) NULL,
	[sAgentSettRate] [decimal](15, 9) NULL,
	[pDateCostRate] [decimal](15, 9) NULL,
	[serviceCharge] [money] NULL,
	[handlingFee] [money] NULL,
	[sAgentComm] [money] NULL,
	[sAgentCommCurrency] [varchar](3) NULL,
	[sSuperAgentComm] [money] NULL,
	[sSuperAgentCommCurrency] [varchar](3) NULL,
	[sHubComm] [money] NULL,
	[sHubCommCurrency] [varchar](3) NULL,
	[pAgentComm] [money] NULL,
	[pAgentCommCurrency] [varchar](3) NULL,
	[pSuperAgentComm] [money] NULL,
	[pSuperAgentCommCurrency] [varchar](3) NULL,
	[pHubComm] [money] NULL,
	[pHubCommCurrency] [varchar](3) NULL,
	[promotionCode] [varchar](50) NULL,
	[promotionType] [varchar](50) NULL,
	[pMessage] [varchar](150) NULL,
	[sCountry] [varchar](100) NULL,
	[sSuperAgent] [int] NULL,
	[sSuperAgentName] [varchar](100) NULL,
	[sAgent] [int] NULL,
	[sAgentName] [varchar](100) NULL,
	[sBranch] [int] NULL,
	[sBranchName] [varchar](100) NULL,
	[pCountry] [varchar](100) NULL,
	[pSuperAgent] [int] NULL,
	[pSuperAgentName] [varchar](50) NULL,
	[pAgent] [int] NULL,
	[pAgentName] [varchar](100) NULL,
	[pBranch] [int] NULL,
	[pBranchName] [varchar](100) NULL,
	[pState] [varchar](100) NULL,
	[pDistrict] [varchar](100) NULL,
	[pLocation] [varchar](100) NULL,
	[paymentMethod] [varchar](50) NULL,
	[pBank] [int] NULL,
	[pBankName] [varchar](100) NULL,
	[pBankBranch] [int] NULL,
	[pBankBranchName] [varchar](100) NULL,
	[accountNo] [varchar](30) NULL,
	[collMode] [varchar](50) NULL,
	[collCurr] [varchar](3) NULL,
	[tAmt] [money] NULL,
	[cAmt] [money] NULL,
	[pAmt] [money] NULL,
	[payoutCurr] [varchar](3) NULL,
	[relWithSender] [varchar](50) NULL,
	[purposeOfRemit] [varchar](100) NULL,
	[sourceOfFund] [varchar](100) NULL,
	[tranStatus] [varchar](20) NULL,
	[payStatus] [varchar](20) NULL,
	[createdDate] [datetime] NULL,
	[createdDateLocal] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedDateLocal] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[approvedDateLocal] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[paidDate] [datetime] NULL,
	[paidDateLocal] [datetime] NULL,
	[paidBy] [varchar](30) NULL,
	[cancelRequestDate] [datetime] NULL,
	[cancelRequestDateLocal] [datetime] NULL,
	[cancelRequestBy] [varchar](30) NULL,
	[cancelReason] [varchar](200) NULL,
	[refund] [char](1) NULL,
	[cancelCharge] [money] NULL,
	[cancelApprovedDate] [datetime] NULL,
	[cancelApprovedDateLocal] [datetime] NULL,
	[cancelApprovedBy] [varchar](30) NULL,
	[blockedDate] [datetime] NULL,
	[blockedBy] [varchar](30) NULL,
	[lockedDate] [datetime] NULL,
	[lockedDateLocal] [datetime] NULL,
	[lockedBy] [varchar](30) NULL,
	[payTokenId] [bigint] NULL,
	[sendEOD] [char](1) NULL,
	[payEOD] [char](1) NULL,
	[cancelEOD] [char](1) NULL,
	[tranType] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_remitTranHistory_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[remitTranHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_572E9B4A_793A_4C0F_A792_B2684C18FE4E_1740845564]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
