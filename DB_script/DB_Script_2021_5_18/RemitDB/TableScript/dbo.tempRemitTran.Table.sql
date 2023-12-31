USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tempRemitTran]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempRemitTran](
	[controlNo] [varchar](20) NULL,
	[sBranch] [int] NULL,
	[sBranchName] [varchar](100) NULL,
	[sAgent] [int] NULL,
	[sAgentName] [varchar](100) NULL,
	[sSuperAgent] [int] NULL,
	[sSuperAgentName] [varchar](100) NULL,
	[pBranch] [int] NULL,
	[pBranchName] [varchar](100) NULL,
	[pAgent] [int] NULL,
	[pAgentName] [varchar](100) NULL,
	[pSuperAgent] [int] NULL,
	[pSuperAgentName] [varchar](100) NULL,
	[sAgentComm] [money] NULL,
	[sAgentCommCurr] [varchar](3) NULL,
	[sSuperAgentComm] [money] NULL,
	[sSuperAgentCommCurr] [varchar](3) NULL,
	[pAgentComm] [money] NULL,
	[pAgentCommCurr] [varchar](3) NULL,
	[pSuperAgentComm] [money] NULL,
	[pSuperAgentCommCurr] [varchar](3) NULL,
	[deliveryMethodId] [int] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL
) ON [PRIMARY]
GO
