USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[countryCollectionMode]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[countryCollectionMode](
	[ccmId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[countryId] [int] NULL,
	[collMode] [int] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ccmId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[countryCollectionMode] ADD  CONSTRAINT [MSrepl_tran_version_default_CB35A18A_FC37_4BA8_A1C3_C97FB940EFBD_52559621]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
