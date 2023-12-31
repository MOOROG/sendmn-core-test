USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[manageCurrency]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[manageCurrency](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[currCode] [varchar](20) NULL,
	[currName] [varchar](100) NULL,
	[countryId] [int] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](100) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](100) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_manageCurrency_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[manageCurrency] ADD  CONSTRAINT [MSrepl_tran_version_default_D6C3EFFC_E9E5_47BA_87F0_A6CAEAAC0CD2_1883153754]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
