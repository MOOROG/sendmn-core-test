USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[customerInfo]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customerInfo](
	[customerInfoId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[customerId] [int] NULL,
	[date] [datetime] NULL,
	[subject] [varchar](100) NULL,
	[description] [varchar](max) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[setPrimary] [char](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[customerInfoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[customerInfo] ADD  CONSTRAINT [MSrepl_tran_version_default_8D6F7F0A_DF04_401B_89AD_9BA9ED216DBF_1932638028]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
