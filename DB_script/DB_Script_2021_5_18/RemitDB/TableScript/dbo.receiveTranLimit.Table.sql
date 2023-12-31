USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[receiveTranLimit]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[receiveTranLimit](
	[rtlId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[countryId] [varchar](100) NULL,
	[userId] [int] NULL,
	[sendingCountry] [varchar](100) NULL,
	[maxLimitAmt] [money] NULL,
	[agMaxLimitAmt] [money] NULL,
	[currency] [varchar](3) NULL,
	[tranType] [varchar](50) NULL,
	[customerType] [int] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[branchSelection] [varchar](50) NULL,
	[benificiaryIdReq] [char](1) NULL,
	[relationshipReq] [char](1) NULL,
	[benificiaryContactReq] [char](1) NULL,
	[acLengthFrom] [varchar](50) NULL,
	[acLengthTo] [varchar](50) NULL,
	[acNumberType] [varchar](50) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_receiveTranLimit_rtlId] PRIMARY KEY CLUSTERED 
(
	[rtlId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[receiveTranLimit] ADD  CONSTRAINT [MSrepl_tran_version_default_C46EF405_B047_4B55_83E7_7A15D80FAF0E_1975938361]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
