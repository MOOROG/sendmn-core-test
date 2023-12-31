USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[apiLocationMapping]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiLocationMapping](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[districtId] [int] NULL,
	[apiDistrictCode] [int] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_apiLocationMapping_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[apiLocationMapping] ADD  CONSTRAINT [MSrepl_tran_version_default_6BDCD95F_42B8_4C38_B1AE_4868158EE8DF_726397757]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
