USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[receiveTranLimitMod]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[receiveTranLimitMod](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[rtlId] [int] NULL,
	[agentId] [int] NULL,
	[countryId] [varchar](100) NULL,
	[userId] [int] NULL,
	[sendingCountry] [varchar](100) NULL,
	[maxLimitAmt] [money] NULL,
	[agMaxLimitAmt] [money] NULL,
	[currency] [varchar](3) NULL,
	[tranType] [varchar](50) NULL,
	[customerType] [int] NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[modType] [char](1) NOT NULL,
	[branchSelection] [varchar](50) NULL,
	[benificiaryIdReq] [char](1) NULL,
	[relationshipReq] [char](1) NULL,
	[benificiaryContactReq] [char](1) NULL,
	[acLengthFrom] [varchar](50) NULL,
	[acLengthTo] [varchar](50) NULL,
	[acNumberType] [varchar](50) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_receiveTranLimitMod_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[receiveTranLimitMod] ADD  CONSTRAINT [MSrepl_tran_version_default_A841B25E_F563_4EC5_BA96_54E8E43E06A4_1959938304]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
