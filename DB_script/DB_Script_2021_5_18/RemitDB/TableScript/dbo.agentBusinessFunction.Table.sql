USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentBusinessFunction]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentBusinessFunction](
	[agentBusinessFunctionId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[defaultDepositMode] [int] NULL,
	[invoicePrintMode] [char](1) NULL,
	[invoicePrintMethod] [char](2) NULL,
	[globalTRNAllowed] [char](1) NULL,
	[agentOperationType] [char](1) NULL,
	[applyCoverFund] [char](1) NULL,
	[sendSMSToReceiver] [char](1) NULL,
	[sendEmailToReceiver] [char](1) NULL,
	[sendSMSToSender] [char](1) NULL,
	[sendEmailToSender] [char](1) NULL,
	[trnMinAmountForTestQuestion] [money] NULL,
	[birthdayAndOtherWish] [char](1) NULL,
	[enableCashCollection] [char](1) NULL,
	[agentLimitdispSendTxn] [char](1) NULL,
	[settlementType] [int] NULL,
	[dateFormat] [int] NULL,
	[fromSendTrnTime] [time](7) NULL,
	[toSendTrnTime] [time](7) NULL,
	[fromPayTrnTime] [time](7) NULL,
	[toPayTrnTime] [time](7) NULL,
	[fromRptViewTime] [time](7) NULL,
	[toRptViewTime] [time](7) NULL,
	[isDeleted] [char](1) NULL,
	[isActive] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[isRT] [varchar](1) NULL,
	[agentAutoApprovalLimit] [money] NULL,
	[routingEnable] [char](1) NULL,
	[isSelfTxnApprove] [char](1) NULL,
	[hasUSDNostroAc] [char](1) NULL,
	[flcNostroAcCurr] [varchar](100) NULL,
	[fxGain] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_agentBusinessFunction_agentBusinessFunctionId] PRIMARY KEY CLUSTERED 
(
	[agentBusinessFunctionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentBusinessFunction] ADD  CONSTRAINT [MSrepl_tran_version_default_57CB2A26_035D_4CF2_A6A1_55AD357E35E6_1469612674]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
