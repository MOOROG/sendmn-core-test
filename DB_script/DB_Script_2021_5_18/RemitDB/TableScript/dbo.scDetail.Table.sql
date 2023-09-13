USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[scDetail]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[scDetail](
	[scDetailId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[scMasterId] [int] NULL,
	[fromAmt] [money] NULL,
	[toAmt] [money] NULL,
	[serviceChargePcnt] [float] NULL,
	[serviceChargeMinAmt] [money] NULL,
	[serviceChargeMaxAmt] [money] NULL,
	[sAgentCommPcnt] [float] NULL,
	[sAgentCommMinAmt] [money] NULL,
	[sAgentCommMaxAmt] [money] NULL,
	[ssAgentCommPcnt] [float] NULL,
	[ssAgentCommMinAmt] [money] NULL,
	[ssAgentCommMaxAmt] [money] NULL,
	[pAgentCommPcnt] [float] NULL,
	[pAgentCommMinAmt] [money] NULL,
	[pAgentCommMaxAmt] [money] NULL,
	[psAgentCommPcnt] [float] NULL,
	[psAgentCommMinAmt] [money] NULL,
	[psAgentCommMaxAmt] [money] NULL,
	[bankCommPcnt] [float] NULL,
	[bankCommMinAmt] [money] NULL,
	[bankCommMaxAmt] [money] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[scDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
