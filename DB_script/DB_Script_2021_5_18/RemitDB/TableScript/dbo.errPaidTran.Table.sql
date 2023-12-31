USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[errPaidTran]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[errPaidTran](
	[eptId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
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
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[newPaidBy] [varchar](50) NULL,
	[newPaidDate] [datetime] NULL,
	[rIdType] [varchar](100) NULL,
	[rIdNo] [varchar](30) NULL,
	[expiryType] [char](1) NULL,
	[issueDate] [datetime] NULL,
	[validDate] [datetime] NULL,
	[placeOfIssue] [varchar](100) NULL,
	[mobileNo] [varchar](20) NULL,
	[rRelativeType] [varchar](100) NULL,
	[rRelativeName] [varchar](100) NULL,
	[tranStatus] [varchar](20) NULL,
	[isDeleted] [char](1) NULL,
	[newDeliveryMethod] [varchar](100) NULL,
	[payRemarks] [varchar](max) NULL,
 CONSTRAINT [pk_idx_errPaidTran_eptId] PRIMARY KEY CLUSTERED 
(
	[eptId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
