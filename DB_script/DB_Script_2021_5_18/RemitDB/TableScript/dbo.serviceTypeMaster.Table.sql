USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[serviceTypeMaster]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[serviceTypeMaster](
	[serviceTypeId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[serviceCode] [varchar](10) NULL,
	[typeTitle] [varchar](30) NULL,
	[typeDesc] [varchar](100) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[category] [varchar](50) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_serviceTypeMaster] PRIMARY KEY CLUSTERED 
(
	[serviceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[serviceTypeMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_CD108202_0550_49C6_982B_A542B1D3E829_1626137234]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
