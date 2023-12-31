USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[fileFormatDetails]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fileFormatDetails](
	[ffdId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[flFormatId] [int] NULL,
	[name] [varchar](50) NULL,
	[replaceByValue] [varchar](100) NULL,
	[alias] [varchar](50) NULL,
	[fldDescription] [varchar](500) NULL,
	[size] [int] NULL,
	[position] [int] NULL,
	[isActive] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[dataType] [varchar](10) NULL,
	[dataFormat] [varchar](20) NULL,
	[isSerialNo] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ffdId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fileFormatDetails] ADD  CONSTRAINT [MSrepl_tran_version_default_8D61EC81_CBFB_4157_AC1F_544BCFB7D8A6_2136043041]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
