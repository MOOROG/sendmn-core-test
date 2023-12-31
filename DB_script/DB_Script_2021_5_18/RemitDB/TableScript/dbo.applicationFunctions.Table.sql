USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[applicationFunctions]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[applicationFunctions](
	[functionId] [varchar](10) NOT NULL,
	[parentFunctionId] [varchar](10) NULL,
	[functionName] [varchar](50) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_applicationFunctions_functionId] PRIMARY KEY CLUSTERED 
(
	[functionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicationFunctions] ADD  CONSTRAINT [MSrepl_tran_version_default_549CB1E7_1F98_46C2_9356_383B9A4ADEBB_811149935]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
