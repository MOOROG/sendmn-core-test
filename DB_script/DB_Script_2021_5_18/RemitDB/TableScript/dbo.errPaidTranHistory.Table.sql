USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[errPaidTranHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[errPaidTranHistory](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[eptId] [int] NULL,
	[tranId] [bigint] NULL,
	[oldSettlingAgent] [int] NULL,
	[oldPBranch] [int] NULL,
	[oldPBranchName] [varchar](100) NULL,
	[oldPSuperAgentComm] [money] NULL,
	[oldPSuperAgentCommCurrency] [varchar](3) NULL,
	[oldPAgentComm] [money] NULL,
	[oldPAgentCommCurrency] [varchar](3) NULL,
	[oldPaidDate] [datetime] NULL,
	[newSettlingAgent] [int] NULL,
	[newPBranch] [int] NULL,
	[newPBranchName] [varchar](100) NULL,
	[newPSuperAgent] [int] NULL,
	[newPSuperAgentName] [varchar](100) NULL,
	[newPAgent] [int] NULL,
	[newPAgentName] [varchar](100) NULL,
	[newPSuperAgentComm] [money] NULL,
	[newPSuperAgentCommCurrency] [varchar](3) NULL,
	[newPAgentComm] [money] NULL,
	[newPAgentCommCurrency] [varchar](3) NULL,
	[payoutAmt] [money] NULL,
	[narration] [varchar](200) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[modType] [varchar](10) NULL,
	[newDeliveryMethod] [varchar](100) NULL,
 CONSTRAINT [pk_idx_errPaidTranHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
