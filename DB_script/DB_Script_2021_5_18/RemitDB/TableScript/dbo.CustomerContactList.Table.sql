USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[CustomerContactList]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerContactList](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[customerName] [varchar](500) NULL,
	[customerAddress] [varchar](max) NULL,
	[email] [varchar](200) NULL,
	[mobile] [varchar](200) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[isDeleted] [varchar](1) NULL,
	[catId] [int] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_CustomerContactList] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerContactList] ADD  CONSTRAINT [MSrepl_tran_version_default_4CF7D433_440F_4DC9_968B_A63DB77FE234_1692077314]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
