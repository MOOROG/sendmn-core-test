USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[payQueue]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payQueue](
	[controlNo] [varchar](50) NOT NULL,
	[paidBy] [varchar](30) NULL,
	[paidLocation] [varchar](300) NULL,
	[paidDate] [datetime] NULL,
	[routeId] [int] NULL,
	[processId] [varchar](50) NULL,
	[qStatus] [varchar](20) NULL,
	[paidDateUSDRate] [varchar](50) NULL,
	[paidBeneficiaryIDtype] [varchar](50) NULL,
	[paidBeneficiaryIDNumber] [varchar](50) NULL,
	[rAgentID] [varchar](50) NULL,
	[rBankBranch] [varchar](300) NULL,
 CONSTRAINT [pk_idx_payQueue_controlNo] PRIMARY KEY CLUSTERED 
(
	[controlNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
