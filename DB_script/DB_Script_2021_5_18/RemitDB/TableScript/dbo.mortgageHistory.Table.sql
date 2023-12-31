USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[mortgageHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mortgageHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[mortgageId] [int] NULL,
	[agentId] [int] NULL,
	[regOffice] [varchar](100) NULL,
	[mortgageRegNo] [varchar](20) NULL,
	[valuationAmount] [money] NULL,
	[currency] [int] NULL,
	[valuator] [varchar](50) NULL,
	[valuationDate] [datetime] NULL,
	[propertyType] [int] NULL,
	[plotNo] [varchar](100) NULL,
	[owner] [varchar](50) NULL,
	[country] [int] NULL,
	[state] [int] NULL,
	[city] [varchar](50) NULL,
	[zip] [varchar](10) NULL,
	[address] [varchar](100) NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
 CONSTRAINT [pk_idx_mortgageHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
