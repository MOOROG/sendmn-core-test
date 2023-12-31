USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[timezoneSettings]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[timezoneSettings](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[hubTZ] [int] NULL,
	[dbTZ] [int] NULL,
	[remarks] [varchar](50) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_timezoneSettings_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[timezoneSettings] ADD  CONSTRAINT [MSrepl_tran_version_default_5945D5D5_14FE_4F1F_AF21_22C7A3B2AB0C_1235639595]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
