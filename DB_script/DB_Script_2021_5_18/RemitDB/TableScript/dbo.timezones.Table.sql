USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[timezones]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[timezones](
	[ROWID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[GMT] [varchar](6) NOT NULL,
	[name] [varchar](75) NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_timezones_ROWID] PRIMARY KEY CLUSTERED 
(
	[ROWID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[timezones] ADD  CONSTRAINT [MSrepl_tran_version_default_D67F1A6E_B390_4DDF_A428_7575D3AA4425_551673013]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
